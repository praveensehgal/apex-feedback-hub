CREATE OR REPLACE PACKAGE BODY afh_notification_int_pkg AS
  -- ---------------------------------------------------------------------------
  -- AFH_NOTIFICATION_INT_PKG body. Helpers for AFH_NOTIFICATION_PKG (spec §19).
  -- No authorization of its own: the public package checks before calling.
  -- COMMIT appears only in batch_commit, which the job entry points call.
  -- ---------------------------------------------------------------------------

  g_batch_commit BOOLEAN := TRUE;

  c_product_default CONSTANT VARCHAR2(30) := 'APEX Feedback Hub';

  TYPE t_ids IS TABLE OF NUMBER;
  TYPE t_item IS RECORD (
    notification_id NUMBER,
    ticket_no       VARCHAR2(20 CHAR),
    subject         VARCHAR2(500 CHAR));
  TYPE t_items IS TABLE OF t_item;

  -- ------------------------------------------------------------------ events
  FUNCTION is_known_event(p_event_code IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN p_event_code IN (
      afh_notification_pkg.c_ev_new_ticket,    afh_notification_pkg.c_ev_assignment,
      afh_notification_pkg.c_ev_mention,       afh_notification_pkg.c_ev_comment,
      afh_notification_pkg.c_ev_info_request,  afh_notification_pkg.c_ev_info_response,
      afh_notification_pkg.c_ev_status_change, afh_notification_pkg.c_ev_priority,
      afh_notification_pkg.c_ev_release,       afh_notification_pkg.c_ev_ready_test,
      afh_notification_pkg.c_ev_test_request,  afh_notification_pkg.c_ev_test_outcome,
      afh_notification_pkg.c_ev_resolution,    afh_notification_pkg.c_ev_closure,
      afh_notification_pkg.c_ev_reopened,      afh_notification_pkg.c_ev_merge);
  END is_known_event;

  FUNCTION event_label(p_event_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_event_code
      WHEN 'NEW_TICKET'      THEN 'New ticket'
      WHEN 'ASSIGNMENT'      THEN 'Assigned to you'
      WHEN 'MENTION'         THEN 'You were mentioned'
      WHEN 'COMMENT'         THEN 'New comment'
      WHEN 'INFO_REQUEST'    THEN 'Information requested'
      WHEN 'INFO_RESPONSE'   THEN 'Information provided'
      WHEN 'STATUS_CHANGE'   THEN 'Status changed'
      WHEN 'PRIORITY_CHANGE' THEN 'Priority changed'
      WHEN 'RELEASE_CHANGE'  THEN 'Target release changed'
      WHEN 'READY_TEST'      THEN 'Ready for testing'
      WHEN 'TEST_REQUEST'    THEN 'Test requested'
      WHEN 'TEST_OUTCOME'    THEN 'Test outcome recorded'
      WHEN 'RESOLUTION'      THEN 'Resolved'
      WHEN 'CLOSURE'         THEN 'Closed'
      WHEN 'REOPENED'        THEN 'Reopened'
      WHEN 'DUPLICATE_MERGE' THEN 'Merged as duplicate'
      WHEN 'DIGEST'          THEN 'Digest'
      ELSE INITCAP(REPLACE(p_event_code, '_', ' '))
    END;
  END event_label;

  -- ------------------------------------------------------------------ decision core
  -- Rule 3 / rule 4: a per-event override (per application when p_application_id
  -- is given, global when NULL). TRUE when a row decided the channels.
  FUNCTION apply_override(
    p_user_id        IN     NUMBER,
    p_application_id IN     NUMBER,
    p_event_code     IN     VARCHAR2,
    p_forced_in_app  IN     BOOLEAN,
    o_in_app         IN OUT VARCHAR2,
    o_email          IN OUT VARCHAR2) RETURN BOOLEAN IS
    l_email  afh_notification_prefs.email_enabled%TYPE;
    l_in_app afh_notification_prefs.in_app_enabled%TYPE;
  BEGIN
    SELECT p.email_enabled, p.in_app_enabled
      INTO l_email, l_in_app
      FROM afh_notification_prefs p
     WHERE p.user_id = p_user_id
       AND p.event_code = p_event_code
       AND ((p_application_id IS NULL AND p.application_id IS NULL)
            OR p.application_id = p_application_id);
    o_email  := l_email;
    o_in_app := CASE WHEN p_forced_in_app THEN 'Y' ELSE l_in_app END;
    RETURN TRUE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN FALSE;
  END apply_override;

  -- Rules 5-7: preset semantics (spec §19.1 table).
  --   IMMEDIATE : email Y            in_app Y  digest NONE
  --   IMPORTANT : email important?   in_app Y  digest NONE
  --   DAILY     : email direct?      in_app Y  digest DAILY  (NONE for direct events)
  --   WEEKLY    : email direct?      in_app Y  digest WEEKLY (NONE for direct events)
  --   IN_APP    : email N            in_app Y  digest NONE
  PROCEDURE apply_preset(
    p_preset_code IN     VARCHAR2,
    p_event_code  IN     VARCHAR2,
    o_in_app      IN OUT VARCHAR2,
    o_email       IN OUT VARCHAR2,
    o_digest      IN OUT VARCHAR2) IS
    l_important BOOLEAN := afh_notification_pkg.is_important_event(p_event_code);
    l_direct    BOOLEAN := afh_notification_pkg.is_direct_event(p_event_code);
  BEGIN
    o_in_app := 'Y';
    o_digest := 'NONE';
    CASE p_preset_code
      WHEN afh_notification_pkg.c_preset_immediate THEN
        o_email := 'Y';
      WHEN afh_notification_pkg.c_preset_important THEN
        o_email := CASE WHEN l_important THEN 'Y' ELSE 'N' END;
      WHEN afh_notification_pkg.c_preset_daily THEN
        o_email  := CASE WHEN l_direct THEN 'Y' ELSE 'N' END;
        o_digest := CASE WHEN l_direct THEN 'NONE' ELSE 'DAILY' END;
      WHEN afh_notification_pkg.c_preset_weekly THEN
        o_email  := CASE WHEN l_direct THEN 'Y' ELSE 'N' END;
        o_digest := CASE WHEN l_direct THEN 'NONE' ELSE 'WEEKLY' END;
      ELSE  -- IN_APP and any unknown value degrade to the quietest preset
        o_email := 'N';
    END CASE;
  END apply_preset;

  -- Decision table (spec §19.1), first deciding rule wins:
  --   1 direct task        -> in_app Y (fixed for every later rule)
  --   2 per-ticket mute    -> email N, digest NONE, in_app N unless rule 1  -> return
  --   3 app+event override -> email/in_app from the row, digest NONE        -> return
  --   4 event override     -> same, global row                              -> return
  --   5-7 preset           -> per-app preset, global preset, config default
  PROCEDURE resolve_core(
    p_user_id        IN  NUMBER,
    p_application_id IN  NUMBER,
    p_ticket_id      IN  NUMBER,
    p_event_code     IN  VARCHAR2,
    p_is_direct_task IN  VARCHAR2,
    o_in_app         OUT VARCHAR2,
    o_email          OUT VARCHAR2,
    o_digest         OUT VARCHAR2) IS
    l_forced BOOLEAN := (p_is_direct_task = 'Y');
  BEGIN
    o_in_app := CASE WHEN l_forced THEN 'Y' ELSE 'N' END;
    o_email  := 'N';
    o_digest := 'NONE';
    IF p_ticket_id IS NOT NULL
       AND afh_notification_pkg.is_muted(p_ticket_id, p_user_id) THEN
      RETURN;
    END IF;
    IF p_application_id IS NOT NULL
       AND apply_override(p_user_id, p_application_id, p_event_code, l_forced, o_in_app, o_email) THEN
      RETURN;
    END IF;
    IF apply_override(p_user_id, NULL, p_event_code, l_forced, o_in_app, o_email) THEN
      RETURN;
    END IF;
    apply_preset(afh_notification_pkg.effective_preset(p_application_id, p_user_id),
                 p_event_code, o_in_app, o_email, o_digest);
  END resolve_core;

  FUNCTION channel_decision(
    p_user_id        IN NUMBER,
    p_application_id IN NUMBER,
    p_event_code     IN VARCHAR2,
    p_channel_code   IN VARCHAR2) RETURN VARCHAR2 IS
    l_in_app VARCHAR2(1);
    l_email  VARCHAR2(1);
    l_digest VARCHAR2(30);
  BEGIN
    resolve_core(p_user_id, p_application_id, NULL, p_event_code, 'N', l_in_app, l_email, l_digest);
    RETURN CASE p_channel_code
             WHEN c_channel_in_app THEN l_in_app
             WHEN c_channel_email  THEN l_email
             WHEN c_channel_digest THEN l_digest
           END;
  END channel_decision;

  -- ------------------------------------------------------------------ links and names
  FUNCTION product_name RETURN VARCHAR2 IS
  BEGIN
    RETURN COALESCE(afh_security_pkg.config_value('PRODUCT_NAME'), c_product_default);
  END product_name;

  FUNCTION ticket_link(p_ticket_id IN NUMBER) RETURN VARCHAR2 IS
    l_base   VARCHAR2(2000 CHAR) := TRIM(afh_security_pkg.config_value('BASE_URL'));
    l_app_id VARCHAR2(30 CHAR)   := TRIM(afh_security_pkg.config_value('FEEDBACK_APP_ID'));
    l_no     afh_tickets.ticket_no%TYPE;
  BEGIN
    IF l_base IS NULL OR l_app_id IS NULL OR p_ticket_id IS NULL THEN
      RETURN NULL;
    END IF;
    SELECT t.ticket_no INTO l_no FROM afh_tickets t WHERE t.ticket_id = p_ticket_id;
    RETURN RTRIM(l_base, '/') || '/f?p=' || l_app_id || ':10::::10:P10_TICKET_NO:' || l_no;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
  END ticket_link;

  -- CHR(38) keeps the SQL*Plus/SQLcl substitution character out of the source so
  -- the installer can run with DEFINE ON. Result: f?p=[amp]APP_ID.:10:[amp]SESSION.::NO::P10_TICKET_NO:<no>
  FUNCTION in_app_link(p_ticket_no IN VARCHAR2) RETURN VARCHAR2 IS
    l_amp CONSTANT VARCHAR2(1) := CHR(38);
  BEGIN
    RETURN 'f?p=' || l_amp || 'APP_ID.:10:' || l_amp || 'SESSION.::NO::P10_TICKET_NO:' || p_ticket_no;
  END in_app_link;

  -- ------------------------------------------------------------------ rendering
  FUNCTION load_template(
    p_event_code   IN  VARCHAR2,
    p_channel_code IN  VARCHAR2,
    o_subject      OUT VARCHAR2,
    o_body         OUT CLOB) RETURN BOOLEAN IS
  BEGIN
    SELECT t.subject_template, t.body_template
      INTO o_subject, o_body
      FROM afh_notification_templates t
     WHERE t.event_code = p_event_code
       AND t.channel_code = p_channel_code
       AND t.is_active = 'Y';
    RETURN TRUE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN FALSE;
  END load_template;

  -- Built-in plain template used when no active row exists for (event, channel).
  PROCEDURE fallback_template(
    p_event_code   IN  VARCHAR2,
    p_channel_code IN  VARCHAR2,
    o_subject      OUT VARCHAR2,
    o_body         OUT CLOB) IS
    l_label VARCHAR2(255 CHAR) := event_label(p_event_code);
  BEGIN
    IF p_event_code = c_ev_digest THEN
      o_subject := '[#PRODUCT_NAME#] Your feedback digest';
      o_body    := 'Hello #RECIPIENT#,' || CHR(10) || CHR(10)
                || 'Recent activity on tickets you follow:' || CHR(10) || CHR(10)
                || '#ITEMS#' || CHR(10) || CHR(10) || '-- #PRODUCT_NAME#';
    ELSIF p_channel_code = c_channel_email THEN
      o_subject := '[#PRODUCT_NAME#] #TICKET_NO# - ' || l_label;
      o_body    := 'Hello #RECIPIENT#,' || CHR(10) || CHR(10)
                || l_label || ': #TICKET_NO# #TITLE# (#APPLICATION#, status #STATUS#).' || CHR(10)
                || 'By: #ACTOR#' || CHR(10) || '#SUMMARY#' || CHR(10) || CHR(10)
                || 'Open the ticket:' || CHR(10) || '#LINK#' || CHR(10) || CHR(10)
                || '-- #PRODUCT_NAME#';
    ELSE
      o_subject := l_label || ': #TICKET_NO# #TITLE#';
      o_body    := '#ACTOR# - #SUMMARY#';
    END IF;
  END fallback_template;

  -- Placeholder values that come from the ticket row (all empty when no ticket).
  PROCEDURE ticket_facts(
    p_ticket_id IN NUMBER,
    p_names     IN OUT NOCOPY apex_t_varchar2,
    p_values    IN OUT NOCOPY apex_t_varchar2) IS
    l_no     afh_tickets.ticket_no%TYPE;
    l_title  afh_tickets.title%TYPE;
    l_status VARCHAR2(255 CHAR);
    l_app    afh_applications.display_name%TYPE;
    l_link   VARCHAR2(2000 CHAR);
  BEGIN
    IF p_ticket_id IS NOT NULL THEN
      SELECT t.ticket_no, t.title,
             COALESCE(s.label, INITCAP(REPLACE(t.status_code, '_', ' '))),
             a.display_name
        INTO l_no, l_title, l_status, l_app
        FROM afh_tickets t
        JOIN afh_applications a ON a.application_id = t.application_id
        LEFT JOIN afh_workflow_statuses s ON s.status_code = t.status_code
       WHERE t.ticket_id = p_ticket_id;
      l_link := ticket_link(p_ticket_id);
    END IF;
    apex_string.push(p_names, 'TICKET_NO');   apex_string.push(p_values, l_no);
    apex_string.push(p_names, 'TITLE');       apex_string.push(p_values, l_title);
    apex_string.push(p_names, 'STATUS');      apex_string.push(p_values, l_status);
    apex_string.push(p_names, 'APPLICATION'); apex_string.push(p_values, l_app);
    apex_string.push(p_names, 'LINK');        apex_string.push(p_values, COALESCE(l_link, c_link_unavailable));
  END ticket_facts;

  FUNCTION user_display(p_user_id IN NUMBER) RETURN VARCHAR2 IS
    l_name VARCHAR2(255 CHAR);
  BEGIN
    IF p_user_id IS NULL THEN
      RETURN 'System';
    END IF;
    SELECT COALESCE(u.display_name, u.subject_display) INTO l_name
      FROM afh_users u WHERE u.user_id = p_user_id;
    RETURN l_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 'System';
  END user_display;

  -- Placeholder values that describe the parties and the message.
  PROCEDURE party_facts(
    p_recipient_id IN NUMBER,
    p_summary      IN VARCHAR2,
    p_names        IN OUT NOCOPY apex_t_varchar2,
    p_values       IN OUT NOCOPY apex_t_varchar2) IS
  BEGIN
    apex_string.push(p_names, 'ACTOR');        apex_string.push(p_values, user_display(afh_security_pkg.current_user_id));
    apex_string.push(p_names, 'RECIPIENT');    apex_string.push(p_values, user_display(p_recipient_id));
    apex_string.push(p_names, 'PRODUCT_NAME'); apex_string.push(p_values, product_name);
    apex_string.push(p_names, 'SUMMARY');      apex_string.push(p_values, p_summary);
  END party_facts;

  FUNCTION substitute(
    p_text   IN CLOB,
    p_names  IN apex_t_varchar2,
    p_values IN apex_t_varchar2) RETURN CLOB IS
    l_out CLOB := p_text;
  BEGIN
    FOR i IN 1 .. p_names.COUNT LOOP
      l_out := REPLACE(l_out, '#' || p_names(i) || '#', p_values(i));
    END LOOP;
    RETURN l_out;
  END substitute;

  -- Plain-text rendering only: nothing is HTML-escaped because the mail channel is
  -- text. Callers guarantee p_summary carries no restricted facts (spec §19.2).
  PROCEDURE render_core(
    p_event_code   IN  VARCHAR2,
    p_channel_code IN  VARCHAR2,
    p_ticket_id    IN  NUMBER,
    p_recipient_id IN  NUMBER,
    p_summary      IN  VARCHAR2,
    p_items        IN  CLOB,
    o_subject      OUT VARCHAR2,
    o_body         OUT CLOB) IS
    l_subject VARCHAR2(500 CHAR);
    l_body    CLOB;
    l_names   apex_t_varchar2 := apex_t_varchar2();
    l_values  apex_t_varchar2 := apex_t_varchar2();
  BEGIN
    IF NOT load_template(p_event_code, p_channel_code, l_subject, l_body) THEN
      fallback_template(p_event_code, p_channel_code, l_subject, l_body);
    END IF;
    ticket_facts(p_ticket_id, l_names, l_values);
    party_facts(p_recipient_id, p_summary, l_names, l_values);
    o_subject := SUBSTR(substitute(l_subject, l_names, l_values), 1, 500);
    o_body    := REPLACE(substitute(l_body, l_names, l_values), '#ITEMS#', p_items);
  END render_core;

  -- ------------------------------------------------------------------ delivery
  -- Addresses are stripped before anything reaches the integration-health table.
  FUNCTION safe_error(p_text IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN SUBSTR(REGEXP_REPLACE(p_text, '[[:alnum:]._%+-]+@[[:alnum:].-]+', '[address]'), 1, 300);
  END safe_error;

  PROCEDURE record_attempt(
    p_notification_id IN NUMBER,
    p_attempts        IN NUMBER,
    p_max_retries     IN PLS_INTEGER,
    p_error           IN VARCHAR2) IS
    l_state afh_notifications.state_code%TYPE :=
      CASE WHEN p_attempts >= p_max_retries THEN 'FAILED' ELSE 'QUEUED' END;
  BEGIN
    UPDATE afh_notifications n
       SET n.delivery_attempts = p_attempts,
           n.last_attempt_at   = SYSTIMESTAMP,
           n.error_code        = afh_security_pkg.c_err_mail_001,
           n.error_detail      = SUBSTR(p_error, 1, 2000),
           n.state_code        = l_state
     WHERE n.notification_id = p_notification_id;
    IF l_state = 'FAILED' THEN
      afh_audit_pkg.log_integration_event(
        p_event_code  => 'MAIL',
        p_result_code => 'FAILED',
        p_safe_detail => 'notification_id=' || p_notification_id
                      || ' attempts=' || p_attempts || ' ' || safe_error(p_error));
    END IF;
  END record_attempt;

  PROCEDURE deliver_one(p_notification_id IN NUMBER, p_max_retries IN PLS_INTEGER) IS
    l_email    afh_users.email%TYPE;
    l_subject  afh_notifications.subject%TYPE;
    l_body     CLOB;
    l_attempts NUMBER;
    l_from     VARCHAR2(320 CHAR) := TRIM(afh_security_pkg.config_value('MAIL_FROM'));
    l_mail_id  NUMBER;
  BEGIN
    SELECT u.email, n.subject, n.body, n.delivery_attempts
      INTO l_email, l_subject, l_body, l_attempts
      FROM afh_notifications n
      JOIN afh_users u ON u.user_id = n.recipient_user_id
     WHERE n.notification_id = p_notification_id
       AND n.channel_code = c_channel_email
       AND n.state_code = 'QUEUED';
    BEGIN
      IF l_from IS NULL THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_mail_001, 'MAIL_FROM is not configured.');
      END IF;
      IF l_email IS NULL THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_mail_001, 'The recipient has no e-mail address.');
      END IF;
      l_mail_id := apex_mail.send(p_to => l_email, p_from => l_from, p_subj => l_subject, p_body => l_body);
      apex_mail.push_queue;
      -- SENT means "handed to the APEX mail queue". APEX delivers that queue asynchronously
      -- (its ORACLE_APEX_MAIL_QUEUE job; push_queue from a PL/SQL session is a no-op on 24.2),
      -- so the relay's verdict is read back later by reconcile_relay through apex_mail_id.
      UPDATE afh_notifications n
         SET n.state_code = 'SENT', n.sent_at = SYSTIMESTAMP, n.apex_mail_id = l_mail_id,
             n.delivery_attempts = l_attempts + 1, n.last_attempt_at = SYSTIMESTAMP,
             n.error_code = NULL, n.error_detail = NULL
       WHERE n.notification_id = p_notification_id;
    EXCEPTION
      WHEN OTHERS THEN
        record_attempt(p_notification_id, l_attempts + 1, p_max_retries, SQLERRM);
    END;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;   -- already handled by another worker run
  END deliver_one;

  -- Relay outcome for e-mails already handed to APEX_MAIL. A row in APEX_MAIL_LOG carrying
  -- mail_send_error means the relay refused the message after APEX's own retries (found
  -- 2026-09-06: the SES sandbox rejected an unverified recipient while the notification read
  -- SENT). Mark it FAILED with that reason so the admin sees it and can requeue it.
  PROCEDURE reconcile_relay(p_max_rows IN PLS_INTEGER DEFAULT 500) IS
  BEGIN
    FOR r IN (SELECT n.notification_id, l.mail_send_error
                FROM afh_notifications n
                JOIN apex_mail_log l ON l.mail_id = n.apex_mail_id
               WHERE n.channel_code = c_channel_email
                 AND n.state_code   = 'SENT'
                 AND n.apex_mail_id IS NOT NULL
                 AND n.sent_at      > SYSTIMESTAMP - INTERVAL '14' DAY
                 AND l.mail_send_error IS NOT NULL
               ORDER BY n.notification_id
               FETCH FIRST GREATEST(NVL(p_max_rows, 500), 1) ROWS ONLY) LOOP
      UPDATE afh_notifications n
         SET n.state_code      = 'FAILED',
             n.error_code      = afh_security_pkg.c_err_mail_001,
             n.error_detail    = SUBSTR(r.mail_send_error, 1, 2000),
             n.last_attempt_at = SYSTIMESTAMP
       WHERE n.notification_id = r.notification_id;
      afh_audit_pkg.log_integration_event(
        p_event_code  => 'MAIL',
        p_result_code => 'FAILED',
        p_safe_detail => 'notification_id=' || r.notification_id || ' relay refused: ' || safe_error(r.mail_send_error));
    END LOOP;
  END reconcile_relay;

  PROCEDURE mark_skipped_disabled(p_notification_id IN NUMBER) IS
  BEGIN
    UPDATE afh_notifications n
       SET n.state_code = 'SKIPPED_DISABLED', n.last_attempt_at = SYSTIMESTAMP
     WHERE n.notification_id = p_notification_id
       AND n.state_code = 'QUEUED';
  END mark_skipped_disabled;

  -- ------------------------------------------------------------------ digests
  PROCEDURE set_rows_state(p_ids IN t_ids, p_state IN VARCHAR2) IS
  BEGIN
    FORALL i IN 1 .. p_ids.COUNT
      UPDATE afh_notifications n
         SET n.state_code = p_state, n.sent_at = SYSTIMESTAMP
       WHERE n.notification_id = p_ids(i)
         AND n.state_code = 'NEW';
  END set_rows_state;

  FUNCTION build_items(p_items IN t_items) RETURN CLOB IS
    l_out CLOB;
  BEGIN
    DBMS_LOB.createtemporary(l_out, TRUE);
    FOR i IN 1 .. p_items.COUNT LOOP
      DBMS_LOB.append(l_out, TO_CLOB(
        COALESCE(p_items(i).ticket_no, '-') || ' - ' || p_items(i).subject || CHR(10)));
    END LOOP;
    RETURN l_out;
  END build_items;

  PROCEDURE digest_for_user(p_user_id IN NUMBER, p_frequency IN VARCHAR2) IS
    l_rows    t_items;
    l_ids     t_ids := t_ids();
    l_email   afh_users.email%TYPE;
    l_subject VARCHAR2(500 CHAR);
    l_body    CLOB;
  BEGIN
    SELECT n.notification_id, t.ticket_no, n.subject
      BULK COLLECT INTO l_rows
      FROM afh_notifications n
      LEFT JOIN afh_tickets t ON t.ticket_id = n.ticket_id
     WHERE n.recipient_user_id = p_user_id
       AND n.channel_code = c_channel_digest
       AND n.state_code = 'NEW'
       AND n.digest_frequency = p_frequency
     ORDER BY n.notification_id;
    IF l_rows.COUNT = 0 THEN
      RETURN;
    END IF;
    l_ids.EXTEND(l_rows.COUNT);
    FOR i IN 1 .. l_rows.COUNT LOOP
      l_ids(i) := l_rows(i).notification_id;
    END LOOP;
    SELECT u.email INTO l_email FROM afh_users u WHERE u.user_id = p_user_id;
    IF l_email IS NULL THEN
      set_rows_state(l_ids, 'CANCELLED');   -- nowhere to send; do not accumulate forever
      RETURN;
    END IF;
    render_core(c_ev_digest, c_channel_email, NULL, p_user_id,
                l_rows.COUNT || ' update(s)', build_items(l_rows), l_subject, l_body);
    INSERT INTO afh_notifications (
      recipient_user_id, ticket_id, event_code, channel_code, state_code,
      subject, body, delivery_attempts, digest_frequency)
    VALUES (
      p_user_id, NULL, c_ev_digest, c_channel_email, 'QUEUED',
      l_subject, l_body, 0, p_frequency);
    set_rows_state(l_ids, 'DIGESTED');
  END digest_for_user;

  -- ------------------------------------------------------------------ commit control
  PROCEDURE batch_commit IS
  BEGIN
    IF g_batch_commit THEN
      COMMIT;   -- documented exception: job entry points commit per row/recipient
    END IF;
  END batch_commit;

  $IF afh_compile_flags.test_mode $THEN
  PROCEDURE set_batch_commit(p_enabled IN BOOLEAN) IS
  BEGIN
    g_batch_commit := p_enabled;
  END set_batch_commit;
  $END
END afh_notification_int_pkg;
/
