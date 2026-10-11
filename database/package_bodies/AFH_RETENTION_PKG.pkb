CREATE OR REPLACE PACKAGE BODY afh_retention_pkg AS
  -- ---------------------------------------------------------------------------
  -- AFH_RETENTION_PKG body. Spec §11.5, §20, WU-14; PRD §7.12.
  --
  -- Policies
  --   ARCHIVE_CLOSED     non-archived tickets in a terminal status whose last
  --                      activity is older than config ARCHIVE_AFTER_DAYS
  --                      (default 90) -> is_archived = 'Y'. One audit per ticket.
  --   PURGE_ATTACHMENTS  non-deleted attachments with bytes on tickets archived
  --                      longer than config DEFAULT_RETENTION_DAYS (default 730)
  --                      -> content emptied, file_size 0, is_deleted 'Y'; a
  --                      non-public ATTACHMENT_PURGED audit event is written
  --                      BEFORE the bytes go. The row (name, checksum) survives.
  --   DELETE_TICKETS     tickets archived longer than DEFAULT_RETENTION_DAYS that
  --                      carry no attachment bytes (purge runs first).
  --
  -- DELETE_TICKETS is implemented as ANONYMIZE, not as a physical DELETE of the
  -- ticket row. Reason: AFH_AUDIT_EVENTS.ticket_id references AFH_TICKETS and
  -- the audit table is append-only by trigger (no UPDATE, no DELETE), so the
  -- ticket row can never be removed while its history exists — and §20 says
  -- history is never removed. The ticket row therefore survives with its
  -- identity (ticket_no, type, application, environment, reporter, status,
  -- classifications, dates) while every piece of user content is removed:
  -- title -> '[deleted]', description/root cause/resolution emptied, page name
  -- and URL cleared, normalized search text cleared, and all child rows
  -- deleted (attachments, comments, field values, tasks, notifications,
  -- followers, affected users, relations, test results, ticket views; launch
  -- handoffs are unlinked). Audit rows are untouched.
  --
  -- Three child tables are ALSO append-only by trigger today: AFH_TICKET_CONTEXTS,
  -- AFH_CONTEXT_ITEMS, AFH_COMMENT_REVISIONS. This package attempts to delete
  -- them with DBMS_APPLICATION_INFO client_info = 'AFH_RETENTION_PURGE' set, so
  -- that an amended trigger can allow retention deletes without a package
  -- dependency. Until the triggers carry that guard the rows are retained,
  -- comments are scrubbed in place instead of deleted, and the run's
  -- detail_json reports "retained_append_only" so the gap is visible.
  --
  -- scheduled_run never executes DELETE_TICKETS: administrative deletion is
  -- always an explicit, confirmed, interactive action.
  --
  -- Commits: only in batch mode (p_commit_batches = 'Y', job use) and at the
  -- end of scheduled_run — the documented job-context exception.
  -- ---------------------------------------------------------------------------

  c_day           CONSTANT INTERVAL DAY TO SECOND := NUMTODSINTERVAL(1, 'DAY');
  c_batch_size    CONSTANT PLS_INTEGER := 50;
  c_detail_max    CONSTANT PLS_INTEGER := 100;
  c_ev_archive    CONSTANT VARCHAR2(30) := 'TICKET_ARCHIVE_CHANGED';
  c_ev_purged     CONSTANT VARCHAR2(30) := 'ATTACHMENT_PURGED';
  c_ev_deleted    CONSTANT VARCHAR2(30) := 'TICKET_DELETED';
  c_deleted_title CONSTANT VARCHAR2(20) := '[deleted]';
  c_client_info   CONSTANT VARCHAR2(30) := 'AFH_RETENTION_PURGE';
  c_system        CONSTANT VARCHAR2(30) := 'SYSTEM';

  TYPE t_id_tab IS TABLE OF NUMBER;

  TYPE t_candidates IS RECORD (
    policy_code      VARCHAR2(30),
    ticket_ids       t_id_tab,
    ticket_nos       apex_t_varchar2,
    attachment_ids   t_id_tab,
    ticket_count     NUMBER,
    attachment_count NUMBER,
    bytes_affected   NUMBER);

  -- Progress counters for the run in flight (read by finish_run on failure too).
  g_tickets     NUMBER := 0;
  g_attachments NUMBER := 0;
  g_bytes       NUMBER := 0;
  g_retained    NUMBER := 0;

  -- ------------------------------------------------------------- helpers
  FUNCTION actor RETURN VARCHAR2 IS
  BEGIN
    RETURN afh_security_pkg.current_subject;
  EXCEPTION
    WHEN OTHERS THEN
      IF afh_security_pkg.error_code_of(SQLERRM) = afh_security_pkg.c_err_auth_001 THEN
        RETURN c_system;
      END IF;
      RAISE;
  END actor;

  FUNCTION archive_cutoff RETURN TIMESTAMP WITH LOCAL TIME ZONE IS
  BEGIN
    RETURN SYSTIMESTAMP - (afh_security_pkg.config_number('ARCHIVE_AFTER_DAYS', 90) * c_day);
  END archive_cutoff;

  FUNCTION retention_cutoff RETURN TIMESTAMP WITH LOCAL TIME ZONE IS
  BEGIN
    RETURN SYSTIMESTAMP - (afh_security_pkg.config_number('DEFAULT_RETENTION_DAYS', 730) * c_day);
  END retention_cutoff;

  PROCEDURE validate_policy(p_policy_code IN VARCHAR2) IS
  BEGIN
    IF p_policy_code IS NULL
       OR p_policy_code NOT IN (c_policy_archive_closed, c_policy_purge_attach, c_policy_delete_tickets) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        'Unknown retention policy. Choose archive closed, purge attachments, or delete tickets.');
    END IF;
  END validate_policy;

  PROCEDURE check_confirmation(p_policy_code IN VARCHAR2, p_confirmation IN VARCHAR2) IS
    l_expected VARCHAR2(10) := CASE WHEN p_policy_code = c_policy_archive_closed THEN 'ARCHIVE' ELSE 'DELETE' END;
  BEGIN
    IF p_confirmation IS NULL OR p_confirmation <> l_expected THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        'Type ' || l_expected || ' to confirm this retention action.');
    END IF;
  END check_confirmation;

  FUNCTION detail_json(p_policy_code IN VARCHAR2, p_ticket_nos IN apex_t_varchar2) RETURN CLOB IS
    l_list apex_t_varchar2 := apex_t_varchar2();
    l_out  CLOB;
  BEGIN
    IF p_ticket_nos IS NOT NULL THEN
      FOR i IN 1 .. LEAST(p_ticket_nos.COUNT, c_detail_max) LOOP
        l_list.EXTEND;
        l_list(l_list.COUNT) := p_ticket_nos(i);
      END LOOP;
    END IF;
    apex_json.initialize_clob_output;
    apex_json.open_object;
    apex_json.write('policy', p_policy_code);
    apex_json.write('ticket_total', NVL(CARDINALITY(p_ticket_nos), 0));
    apex_json.write('retained_append_only', g_retained);
    apex_json.write('tickets', l_list);
    apex_json.close_object;
    l_out := apex_json.get_clob_output;
    apex_json.free_output;
    apex_json.initialize_output(p_http_header => FALSE);  -- back to HTP: free_output leaves output detached
    RETURN l_out;
  END detail_json;

  FUNCTION insert_run(p_policy_code IN VARCHAR2, p_mode_code IN VARCHAR2) RETURN NUMBER IS
    l_id    NUMBER;
    l_actor VARCHAR2(255 CHAR) := actor;
  BEGIN
    INSERT INTO afh_retention_runs (policy_code, mode_code, started_at, actor_subject)
    VALUES (p_policy_code, p_mode_code, SYSTIMESTAMP, l_actor)
    RETURNING retention_run_id INTO l_id;
    RETURN l_id;
  END insert_run;

  PROCEDURE finish_run(
    p_run_id      IN NUMBER,
    p_result_code IN VARCHAR2,
    p_detail_json IN CLOB,
    p_error       IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    UPDATE afh_retention_runs
       SET completed_at     = SYSTIMESTAMP,
           ticket_count     = g_tickets,
           attachment_count = g_attachments,
           bytes_affected   = g_bytes,
           result_code      = p_result_code,
           error_detail     = SUBSTR(p_error, 1, 2000),
           detail_json      = NVL(p_detail_json, detail_json)
     WHERE retention_run_id = p_run_id;
  END finish_run;

  PROCEDURE reset_counters IS
  BEGIN
    g_tickets := 0; g_attachments := 0; g_bytes := 0; g_retained := 0;
  END reset_counters;

  PROCEDURE maybe_commit(p_commit_batches IN VARCHAR2, p_n IN NUMBER) IS
  BEGIN
    -- Documented job-context exception: batch commit every c_batch_size rows.
    IF p_commit_batches = 'Y' AND MOD(p_n, c_batch_size) = 0 THEN
      COMMIT;
    END IF;
  END maybe_commit;

  -- ------------------------------------------------------------- candidates
  PROCEDURE archive_candidates(o_c IN OUT NOCOPY t_candidates) IS
    l_cutoff TIMESTAMP WITH LOCAL TIME ZONE := archive_cutoff;
  BEGIN
    SELECT t.ticket_id, t.ticket_no
      BULK COLLECT INTO o_c.ticket_ids, o_c.ticket_nos
      FROM afh_tickets t
      JOIN afh_workflow_statuses s ON s.status_code = t.status_code
     WHERE t.is_archived = 'N'
       AND s.is_terminal = 'Y'
       AND COALESCE(t.last_activity_at, t.closed_at, t.resolved_at, t.submitted_at) < l_cutoff
     ORDER BY t.ticket_id;
    o_c.ticket_count := o_c.ticket_ids.COUNT;
  END archive_candidates;

  PROCEDURE purge_candidates(o_c IN OUT NOCOPY t_candidates) IS
    l_cutoff TIMESTAMP WITH LOCAL TIME ZONE := retention_cutoff;
    l_nos    apex_t_varchar2;
    l_sizes  t_id_tab;
    l_prev   VARCHAR2(20 CHAR);
  BEGIN
    SELECT a.attachment_id, t.ticket_no, a.file_size
      BULK COLLECT INTO o_c.attachment_ids, l_nos, l_sizes
      FROM afh_attachments a
      JOIN afh_tickets t ON t.ticket_id = a.ticket_id
     WHERE t.is_archived = 'Y'
       AND t.archived_at < l_cutoff
       AND a.is_deleted = 'N'
       AND a.file_size > 0
     ORDER BY a.ticket_id, a.attachment_id;
    o_c.ticket_nos := apex_t_varchar2();
    FOR i IN 1 .. o_c.attachment_ids.COUNT LOOP
      o_c.bytes_affected := o_c.bytes_affected + l_sizes(i);
      IF l_prev IS NULL OR l_nos(i) <> l_prev THEN
        o_c.ticket_nos.EXTEND;
        o_c.ticket_nos(o_c.ticket_nos.COUNT) := l_nos(i);
        l_prev := l_nos(i);
      END IF;
    END LOOP;
    o_c.attachment_count := o_c.attachment_ids.COUNT;
    o_c.ticket_count := o_c.ticket_nos.COUNT;
  END purge_candidates;

  PROCEDURE delete_candidates(o_c IN OUT NOCOPY t_candidates) IS
    l_cutoff TIMESTAMP WITH LOCAL TIME ZONE := retention_cutoff;
  BEGIN
    SELECT t.ticket_id, t.ticket_no
      BULK COLLECT INTO o_c.ticket_ids, o_c.ticket_nos
      FROM afh_tickets t
     WHERE t.is_archived = 'Y'
       AND t.archived_at < l_cutoff
       AND NOT (t.title = c_deleted_title AND t.title_norm IS NULL)   -- already anonymized
       AND NOT EXISTS (SELECT 1 FROM afh_attachments a
                        WHERE a.ticket_id = t.ticket_id AND a.is_deleted = 'N' AND a.file_size > 0)
     ORDER BY t.ticket_id;
    o_c.ticket_count := o_c.ticket_ids.COUNT;
  END delete_candidates;

  FUNCTION collect(p_policy_code IN VARCHAR2) RETURN t_candidates IS
    l_c t_candidates;
  BEGIN
    l_c.policy_code := p_policy_code;
    l_c.ticket_ids := t_id_tab(); l_c.attachment_ids := t_id_tab(); l_c.ticket_nos := apex_t_varchar2();
    l_c.ticket_count := 0; l_c.attachment_count := 0; l_c.bytes_affected := 0;
    IF p_policy_code = c_policy_archive_closed THEN
      archive_candidates(l_c);
    ELSIF p_policy_code = c_policy_purge_attach THEN
      purge_candidates(l_c);
    ELSE
      delete_candidates(l_c);
    END IF;
    RETURN l_c;
  END collect;

  -- ------------------------------------------------------------- archive
  PROCEDURE set_archive(p_ticket_id IN NUMBER, p_flag IN VARCHAR2, p_reason IN VARCHAR2) IS
    l_row afh_tickets%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO l_row FROM afh_tickets WHERE ticket_id = p_ticket_id FOR UPDATE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The ticket does not exist.');
    END;
    IF l_row.is_archived = p_flag THEN
      RETURN;   -- no material change, no audit
    END IF;
    UPDATE afh_tickets
       SET is_archived = p_flag,
           archived_at = CASE WHEN p_flag = 'Y' THEN SYSTIMESTAMP ELSE NULL END,
           row_version = row_version + 1
     WHERE ticket_id = p_ticket_id;
    afh_audit_pkg.log_event(
      p_entity_type  => afh_audit_pkg.c_entity_ticket,
      p_entity_id    => p_ticket_id,
      p_event_code   => c_ev_archive,
      p_ticket_id    => p_ticket_id,
      p_before_facts => afh_audit_pkg.json_obj(apex_t_varchar2('is_archived'), apex_t_varchar2(l_row.is_archived)),
      p_after_facts  => afh_audit_pkg.json_obj(apex_t_varchar2('is_archived', 'reason'), apex_t_varchar2(p_flag, p_reason)),
      p_summary      => CASE WHEN p_flag = 'Y' THEN 'Ticket archived' ELSE 'Ticket restored from archive' END);
  END set_archive;

  -- ------------------------------------------------------------- purge
  PROCEDURE purge_attachment(p_attachment_id IN NUMBER) IS
    l_a  afh_attachments%ROWTYPE;
    l_no afh_tickets.ticket_no%TYPE;
  BEGIN
    SELECT * INTO l_a FROM afh_attachments WHERE attachment_id = p_attachment_id FOR UPDATE;
    SELECT ticket_no INTO l_no FROM afh_tickets WHERE ticket_id = l_a.ticket_id;
    -- Audit first: the surviving record of what was removed (no bytes).
    afh_audit_pkg.log_event(
      p_entity_type  => afh_audit_pkg.c_entity_attachment,
      p_entity_id    => p_attachment_id,
      p_event_code   => c_ev_purged,
      p_ticket_id    => l_a.ticket_id,
      p_before_facts => afh_audit_pkg.json_obj(
                          apex_t_varchar2('ticket_no', 'file_name', 'kind_code', 'file_size', 'sha256_hex', 'is_restricted'),
                          apex_t_varchar2(l_no, l_a.file_name, l_a.kind_code, TO_CHAR(l_a.file_size), l_a.sha256_hex, l_a.is_restricted)),
      p_after_facts  => afh_audit_pkg.json_obj(apex_t_varchar2('file_size', 'is_deleted'), apex_t_varchar2('0', 'Y')),
      p_summary      => 'Attachment bytes purged by retention policy',
      p_is_public    => 'N');
    UPDATE afh_attachments
       SET content    = EMPTY_BLOB(),
           file_size  = 0,
           is_deleted = 'Y',
           deleted_at = SYSTIMESTAMP
     WHERE attachment_id = p_attachment_id;
    g_attachments := g_attachments + 1;
    g_bytes := g_bytes + NVL(l_a.file_size, 0);
  END purge_attachment;

  -- ------------------------------------------------------------- delete (anonymize)
  -- Attempt a delete on an append-only table. Returns TRUE when the rows went,
  -- FALSE when the immutability trigger kept them (AFH-SYS-002).
  FUNCTION try_delete(p_what IN VARCHAR2, p_ticket_id IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    IF p_what = 'REVISIONS' THEN
      DELETE FROM afh_comment_revisions r
       WHERE r.comment_id IN (SELECT c.comment_id FROM afh_comments c WHERE c.ticket_id = p_ticket_id);
    ELSIF p_what = 'CONTEXT_ITEMS' THEN
      DELETE FROM afh_context_items i
       WHERE i.ticket_context_id IN (SELECT x.ticket_context_id FROM afh_ticket_contexts x WHERE x.ticket_id = p_ticket_id);
    ELSE
      DELETE FROM afh_ticket_contexts x WHERE x.ticket_id = p_ticket_id;
    END IF;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      IF afh_security_pkg.error_code_of(SQLERRM) = afh_security_pkg.c_err_sys_002 THEN
        RETURN FALSE;
      END IF;
      RAISE;
  END try_delete;

  PROCEDURE delete_links(p_ticket_id IN NUMBER) IS
  BEGIN
    DELETE FROM afh_notifications     WHERE ticket_id = p_ticket_id;
    DELETE FROM afh_tasks             WHERE ticket_id = p_ticket_id;
    DELETE FROM afh_followers         WHERE ticket_id = p_ticket_id;
    DELETE FROM afh_affected_users    WHERE ticket_id = p_ticket_id;
    DELETE FROM afh_ticket_relations  WHERE source_ticket_id = p_ticket_id OR target_ticket_id = p_ticket_id;
    DELETE FROM afh_ticket_views      WHERE ticket_id = p_ticket_id;
    UPDATE afh_launch_handoffs SET ticket_id = NULL WHERE ticket_id = p_ticket_id;
  END delete_links;

  -- Content rows. Comments are deleted when their revisions could be deleted,
  -- otherwise scrubbed in place. Returns TRUE when any append-only rows remain.
  FUNCTION delete_content(p_ticket_id IN NUMBER) RETURN BOOLEAN IS
    l_retained BOOLEAN := FALSE;
    l_prev     VARCHAR2(64);
  BEGIN
    l_prev := SYS_CONTEXT('USERENV', 'CLIENT_INFO');
    DBMS_APPLICATION_INFO.set_client_info(c_client_info);
    DELETE FROM afh_attachments         WHERE ticket_id = p_ticket_id;
    DELETE FROM afh_test_results        WHERE ticket_id = p_ticket_id;
    DELETE FROM afh_ticket_field_values WHERE ticket_id = p_ticket_id;
    IF try_delete('REVISIONS', p_ticket_id) THEN
      DELETE FROM afh_comments WHERE ticket_id = p_ticket_id;
    ELSE
      l_retained := TRUE;
      UPDATE afh_comments
         SET body = EMPTY_CLOB(), is_archived = 'Y', edit_deadline_at = NULL
       WHERE ticket_id = p_ticket_id;
    END IF;
    IF try_delete('CONTEXT_ITEMS', p_ticket_id) THEN
      IF NOT try_delete('CONTEXTS', p_ticket_id) THEN
        l_retained := TRUE;
      END IF;
    ELSE
      l_retained := TRUE;
    END IF;
    DBMS_APPLICATION_INFO.set_client_info(l_prev);
    RETURN l_retained;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_APPLICATION_INFO.set_client_info(l_prev);
      RAISE;
  END delete_content;

  PROCEDURE scrub_ticket(p_ticket_id IN NUMBER) IS
  BEGIN
    UPDATE afh_tickets
       SET title       = c_deleted_title,
           description = EMPTY_CLOB(),
           title_norm  = NULL,
           desc_norm   = NULL,
           page_name   = NULL,
           source_url  = NULL,
           root_cause  = NULL,
           resolution  = NULL,
           is_archived = 'Y',
           archived_at = NVL(archived_at, SYSTIMESTAMP),
           row_version = row_version + 1
     WHERE ticket_id = p_ticket_id;
  END scrub_ticket;

  -- Surviving administrative record (§11.5, §20): identity and counts, no content.
  PROCEDURE audit_deletion(p_run_id IN NUMBER, p_ticket_id IN NUMBER) IS
    l_names  apex_t_varchar2;
    l_values apex_t_varchar2;
  BEGIN
    SELECT apex_t_varchar2('ticket_no', 'title', 'type_code', 'app_key', 'reporter_subject', 'submitted_at',
                           'status_code', 'comment_count', 'attachment_count', 'context_count'),
           apex_t_varchar2(t.ticket_no, t.title, ft.type_code, a.app_key, u.subject_canonical,
                           TO_CHAR(t.submitted_at, 'YYYY-MM-DD"T"HH24:MI:SS'), t.status_code,
                           TO_CHAR((SELECT COUNT(*) FROM afh_comments c WHERE c.ticket_id = t.ticket_id)),
                           TO_CHAR((SELECT COUNT(*) FROM afh_attachments x WHERE x.ticket_id = t.ticket_id)),
                           TO_CHAR((SELECT COUNT(*) FROM afh_ticket_contexts k WHERE k.ticket_id = t.ticket_id)))
      INTO l_names, l_values
      FROM afh_tickets t
      JOIN afh_feedback_types ft ON ft.feedback_type_id = t.feedback_type_id
      JOIN afh_applications a ON a.application_id = t.application_id
      JOIN afh_users u ON u.user_id = t.reporter_user_id
     WHERE t.ticket_id = p_ticket_id;
    afh_audit_pkg.log_event(
      p_entity_type  => afh_audit_pkg.c_entity_retention,
      p_entity_id    => p_run_id,
      p_event_code   => c_ev_deleted,
      p_ticket_id    => p_ticket_id,
      p_before_facts => afh_audit_pkg.json_obj(l_names, l_values),
      p_after_facts  => afh_audit_pkg.json_obj(apex_t_varchar2('title', 'content_removed'), apex_t_varchar2(c_deleted_title, 'Y')),
      p_summary      => 'Ticket ' || l_values(1) || ' content deleted by retention policy',
      p_is_public    => 'N');
  END audit_deletion;

  PROCEDURE anonymize_ticket(p_run_id IN NUMBER, p_ticket_id IN NUMBER) IS
  BEGIN
    audit_deletion(p_run_id, p_ticket_id);
    delete_links(p_ticket_id);
    IF delete_content(p_ticket_id) THEN
      g_retained := g_retained + 1;
    END IF;
    scrub_ticket(p_ticket_id);
    g_tickets := g_tickets + 1;
  END anonymize_ticket;

  -- ------------------------------------------------------------- execution
  PROCEDURE run_archive(p_c IN t_candidates, p_commit_batches IN VARCHAR2) IS
  BEGIN
    FOR i IN 1 .. p_c.ticket_ids.COUNT LOOP
      set_archive(p_c.ticket_ids(i), 'Y', 'Retention policy ' || c_policy_archive_closed);
      g_tickets := g_tickets + 1;
      maybe_commit(p_commit_batches, g_tickets);
    END LOOP;
  END run_archive;

  PROCEDURE run_purge(p_c IN t_candidates, p_commit_batches IN VARCHAR2) IS
  BEGIN
    FOR i IN 1 .. p_c.attachment_ids.COUNT LOOP
      purge_attachment(p_c.attachment_ids(i));
      maybe_commit(p_commit_batches, g_attachments);
    END LOOP;
    g_tickets := p_c.ticket_count;
  END run_purge;

  PROCEDURE run_delete(p_run_id IN NUMBER, p_c IN t_candidates, p_commit_batches IN VARCHAR2) IS
  BEGIN
    FOR i IN 1 .. p_c.ticket_ids.COUNT LOOP
      anonymize_ticket(p_run_id, p_c.ticket_ids(i));
      maybe_commit(p_commit_batches, g_tickets);
    END LOOP;
  END run_delete;

  FUNCTION do_preview(p_policy_code IN VARCHAR2) RETURN NUMBER IS
    l_c      t_candidates;
    l_run_id NUMBER;
  BEGIN
    validate_policy(p_policy_code);
    reset_counters;
    l_c := collect(p_policy_code);
    l_run_id := insert_run(p_policy_code, 'PREVIEW');
    g_tickets := l_c.ticket_count;
    g_attachments := l_c.attachment_count;
    g_bytes := l_c.bytes_affected;
    finish_run(l_run_id, 'OK', detail_json(p_policy_code, l_c.ticket_nos));
    RETURN l_run_id;
  END do_preview;

  FUNCTION do_execute(p_policy_code IN VARCHAR2, p_commit_batches IN VARCHAR2) RETURN NUMBER IS
    l_c      t_candidates;
    l_run_id NUMBER;
    l_commit VARCHAR2(1) := CASE WHEN UPPER(p_commit_batches) = 'Y' THEN 'Y' ELSE 'N' END;
  BEGIN
    validate_policy(p_policy_code);
    reset_counters;
    l_run_id := insert_run(p_policy_code, 'EXECUTE');
    l_c := collect(p_policy_code);
    BEGIN
      IF p_policy_code = c_policy_archive_closed THEN
        run_archive(l_c, l_commit);
      ELSIF p_policy_code = c_policy_purge_attach THEN
        run_purge(l_c, l_commit);
      ELSE
        run_delete(l_run_id, l_c, l_commit);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        finish_run(l_run_id, 'FAILED', detail_json(p_policy_code, l_c.ticket_nos), SQLERRM);
        IF l_commit = 'Y' THEN
          COMMIT;
        END IF;
        RAISE;
    END;
    finish_run(l_run_id, 'OK', detail_json(p_policy_code, l_c.ticket_nos));
    IF l_commit = 'Y' THEN
      COMMIT;
    END IF;
    RETURN l_run_id;
  END do_execute;

  -- ------------------------------------------------------------- public API
  PROCEDURE archive_ticket(p_ticket_id IN NUMBER, p_reason IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    afh_security_pkg.assert_admin;
    set_archive(p_ticket_id, 'Y', p_reason);
  END archive_ticket;

  PROCEDURE unarchive_ticket(p_ticket_id IN NUMBER) IS
  BEGIN
    afh_security_pkg.assert_admin;
    set_archive(p_ticket_id, 'N', NULL);
  END unarchive_ticket;

  FUNCTION preview(p_policy_code IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    afh_security_pkg.assert_admin;
    RETURN do_preview(p_policy_code);
  END preview;

  FUNCTION execute_policy(
    p_policy_code    IN VARCHAR2,
    p_confirmation   IN VARCHAR2,
    p_commit_batches IN VARCHAR2 DEFAULT 'N') RETURN NUMBER IS
  BEGIN
    afh_security_pkg.assert_admin;
    validate_policy(p_policy_code);
    check_confirmation(p_policy_code, p_confirmation);
    RETURN do_execute(p_policy_code, p_commit_batches);
  END execute_policy;

  -- Scheduler entry (trusted context, no APEX session; audit actor = SYSTEM).
  -- Previews every policy; when RETENTION_JOB_ARMED = 'Y' executes the two
  -- reversible-by-design policies in batch mode. DELETE_TICKETS is never
  -- executed here. Commits at the end (job context).
  PROCEDURE scheduled_run IS
    l_id NUMBER;
  BEGIN
    l_id := do_preview(c_policy_archive_closed);
    l_id := do_preview(c_policy_purge_attach);
    l_id := do_preview(c_policy_delete_tickets);
    IF afh_security_pkg.config_yn('RETENTION_JOB_ARMED', 'N') = 'Y' THEN
      l_id := do_execute(c_policy_archive_closed, 'Y');
      l_id := do_execute(c_policy_purge_attach, 'Y');
    END IF;
    COMMIT;
  END scheduled_run;

  -- ------------------------------------------------------------- storage summary
  FUNCTION storage_summary RETURN t_storage_tab PIPELINED IS
    l_row t_storage;
  BEGIN
    FOR r IN (SELECT a.kind_code,
                     COUNT(*) AS file_count,
                     SUM(a.file_size) AS total_bytes,
                     SUM(CASE WHEN a.is_restricted = 'Y' THEN 1 ELSE 0 END) AS restricted_count,
                     MIN(a.uploaded_at) AS oldest_at
                FROM afh_attachments a
               WHERE a.is_deleted = 'N'
               GROUP BY a.kind_code
               ORDER BY a.kind_code) LOOP
      l_row.kind_code        := r.kind_code;
      l_row.file_count       := r.file_count;
      l_row.total_bytes      := r.total_bytes;
      l_row.restricted_count := r.restricted_count;
      l_row.oldest_at        := r.oldest_at;
      PIPE ROW (l_row);
    END LOOP;
    RETURN;
  END storage_summary;
END afh_retention_pkg;
/
