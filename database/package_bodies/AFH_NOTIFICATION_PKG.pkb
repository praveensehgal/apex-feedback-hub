CREATE OR REPLACE PACKAGE BODY afh_notification_pkg AS
  -- ---------------------------------------------------------------------------
  -- AFH_NOTIFICATION_PKG body. Spec §19, WU-12, PRD §7.9.
  -- Rendering, delivery and digest assembly live in AFH_NOTIFICATION_INT_PKG.
  -- No COMMIT here except through afh_notification_int_pkg.batch_commit, which
  -- only the job entry points (process_mail_queue, send_digests) call.
  -- ---------------------------------------------------------------------------

  c_default_preset CONSTANT VARCHAR2(30) := c_preset_immediate;
  c_max_retries    CONSTANT PLS_INTEGER  := 3;
  c_src_manual     CONSTANT VARCHAR2(30) := 'MANUAL';

  -- ------------------------------------------------------------------ classification
  FUNCTION is_important_event(p_event_code IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN p_event_code IN (c_ev_assignment, c_ev_mention, c_ev_info_request,
                            c_ev_test_request, c_ev_resolution, c_ev_reopened);
  END is_important_event;

  FUNCTION is_direct_event(p_event_code IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN p_event_code IN (c_ev_assignment, c_ev_info_request, c_ev_test_request, c_ev_mention);
  END is_direct_event;

  -- ------------------------------------------------------------------ private helpers
  FUNCTION current_user RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    afh_security_pkg.assert_authenticated;
    l_id := afh_security_pkg.current_user_id;
    IF l_id IS NULL THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_001, 'No trusted identity is available.');
    END IF;
    RETURN l_id;
  END current_user;

  PROCEDURE assert_yn(p_value IN VARCHAR2, p_what IN VARCHAR2) IS
  BEGIN
    IF p_value IS NULL OR p_value NOT IN ('Y', 'N') THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, p_what || ' must be Y or N.');
    END IF;
  END assert_yn;

  PROCEDURE assert_event(p_event_code IN VARCHAR2) IS
  BEGIN
    IF NOT afh_notification_int_pkg.is_known_event(p_event_code) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Unknown notification event.');
    END IF;
  END assert_event;

  PROCEDURE assert_preset(p_preset_code IN VARCHAR2) IS
  BEGIN
    IF p_preset_code IS NULL OR p_preset_code NOT IN (c_preset_immediate, c_preset_important,
                                                      c_preset_daily, c_preset_weekly, c_preset_in_app) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Unknown notification preset.');
    END IF;
  END assert_preset;

  -- Application of a ticket; raises AFH-VAL-001 when the ticket does not exist.
  FUNCTION ticket_app(p_ticket_id IN NUMBER) RETURN NUMBER IS
    l_app NUMBER;
  BEGIN
    SELECT t.application_id INTO l_app FROM afh_tickets t WHERE t.ticket_id = p_ticket_id;
    RETURN l_app;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The ticket does not exist.');
  END ticket_app;

  PROCEDURE assert_application(p_application_id IN NUMBER) IS
    l_cnt PLS_INTEGER;
  BEGIN
    IF p_application_id IS NOT NULL THEN
      SELECT COUNT(*) INTO l_cnt FROM afh_applications a WHERE a.application_id = p_application_id;
      IF l_cnt = 0 THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The application does not exist.');
      END IF;
    END IF;
  END assert_application;

  FUNCTION user_facts(p_user_id IN NUMBER, p_ticket_id IN NUMBER, p_extra_name IN VARCHAR2, p_extra_value IN VARCHAR2)
    RETURN CLOB IS
  BEGIN
    RETURN afh_audit_pkg.json_obj(
      apex_t_varchar2('user_id', 'ticket_id', p_extra_name),
      apex_t_varchar2(TO_CHAR(p_user_id), TO_CHAR(p_ticket_id), p_extra_value));
  END user_facts;

  -- ------------------------------------------------------------------ follows
  FUNCTION is_following(p_ticket_id IN NUMBER, p_user_id IN NUMBER DEFAULT NULL) RETURN BOOLEAN IS
    l_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO l_cnt
      FROM afh_followers f
     WHERE f.ticket_id = p_ticket_id
       AND f.user_id = COALESCE(p_user_id, afh_security_pkg.current_user_id);
    RETURN l_cnt > 0;
  END is_following;

  FUNCTION is_muted(p_ticket_id IN NUMBER, p_user_id IN NUMBER DEFAULT NULL) RETURN BOOLEAN IS
    l_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO l_cnt
      FROM afh_followers f
     WHERE f.ticket_id = p_ticket_id
       AND f.user_id = COALESCE(p_user_id, afh_security_pkg.current_user_id)
       AND f.is_muted = 'Y';
    RETURN l_cnt > 0;
  END is_muted;

  -- Idempotent. Automatic follows (REPORTER, MENTION, ASSIGNMENT, COMMENT, AFFECTED,
  -- MERGE, TEST) are side effects of audited actions and write no audit of their
  -- own; only a MANUAL follow is a user decision worth a FOLLOW_CHANGED event.
  PROCEDURE follow(p_ticket_id IN NUMBER, p_user_id IN NUMBER DEFAULT NULL, p_source_code IN VARCHAR2 DEFAULT 'MANUAL') IS
    l_user NUMBER := p_user_id;
    l_app  NUMBER := ticket_app(p_ticket_id);
  BEGIN
    IF l_user IS NULL THEN
      l_user := current_user;
    END IF;
    IF p_source_code IS NULL OR p_source_code NOT IN
       ('REPORTER', 'MANUAL', 'MENTION', 'ASSIGNMENT', 'COMMENT', 'AFFECTED', 'MERGE', 'TEST') THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Unknown follow source.');
    END IF;
    IF is_following(p_ticket_id, l_user) THEN
      RETURN;
    END IF;
    INSERT INTO afh_followers (ticket_id, user_id, follow_source_code, is_muted)
    VALUES (p_ticket_id, l_user, p_source_code, 'N');
    IF p_source_code = c_src_manual THEN
      afh_audit_pkg.log_event(
        p_entity_type => afh_audit_pkg.c_entity_ticket, p_entity_id => p_ticket_id,
        p_event_code  => 'FOLLOW_CHANGED', p_ticket_id => p_ticket_id,
        p_after_facts => user_facts(l_user, p_ticket_id, 'following', 'Y'),
        p_summary     => 'Started following', p_is_public => 'N');
    END IF;
  END follow;

  FUNCTION is_assignee(p_ticket_id IN NUMBER, p_user_id IN NUMBER) RETURN BOOLEAN IS
    l_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO l_cnt FROM afh_tickets
     WHERE ticket_id = p_ticket_id AND assignee_user_id = p_user_id;
    RETURN l_cnt > 0;
  END is_assignee;

  PROCEDURE follow_required(p_ticket_id IN NUMBER, p_user_id IN NUMBER, p_source_code IN VARCHAR2) IS
  BEGIN
    follow(p_ticket_id, p_user_id, p_source_code);
    UPDATE afh_followers f SET f.is_muted = 'N'
     WHERE f.ticket_id = p_ticket_id AND f.user_id = p_user_id AND f.is_muted = 'Y';
  END follow_required;

  PROCEDURE unfollow(p_ticket_id IN NUMBER) IS
    l_user NUMBER := current_user;
    l_open PLS_INTEGER;
  BEGIN
    IF is_assignee(p_ticket_id, l_user) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        'You are assigned to this ticket, so you always follow it.');
    END IF;
    SELECT COUNT(*) INTO l_open
      FROM afh_tasks k
     WHERE k.ticket_id = p_ticket_id
       AND k.user_id = l_user
       AND k.state_code = 'OPEN'
       AND k.task_type_code IN (c_ev_assignment, c_ev_info_request);
    IF l_open > 0 THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        'You cannot unfollow a ticket while you own an open assignment or information request on it.');
    END IF;
    DELETE FROM afh_followers f WHERE f.ticket_id = p_ticket_id AND f.user_id = l_user;
    IF SQL%ROWCOUNT = 0 THEN
      RETURN;
    END IF;
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_ticket, p_entity_id => p_ticket_id,
      p_event_code  => 'FOLLOW_CHANGED', p_ticket_id => p_ticket_id,
      p_after_facts => user_facts(l_user, p_ticket_id, 'following', 'N'),
      p_summary     => 'Stopped following', p_is_public => 'N');
  END unfollow;

  PROCEDURE set_mute(p_ticket_id IN NUMBER, p_is_muted IN VARCHAR2) IS
    l_user NUMBER := current_user;
  BEGIN
    assert_yn(p_is_muted, 'Mute flag');
    IF p_is_muted = 'Y' AND is_assignee(p_ticket_id, l_user) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        'You are assigned to this ticket, so its notifications cannot be muted.');
    END IF;
    IF NOT is_following(p_ticket_id, l_user) THEN
      follow(p_ticket_id, l_user, c_src_manual);
    END IF;
    UPDATE afh_followers f
       SET f.is_muted = p_is_muted
     WHERE f.ticket_id = p_ticket_id AND f.user_id = l_user AND f.is_muted <> p_is_muted;
    IF SQL%ROWCOUNT = 0 THEN
      RETURN;
    END IF;
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_ticket, p_entity_id => p_ticket_id,
      p_event_code  => 'MUTE_CHANGED', p_ticket_id => p_ticket_id,
      p_after_facts => user_facts(l_user, p_ticket_id, 'is_muted', p_is_muted),
      p_summary     => CASE WHEN p_is_muted = 'Y' THEN 'Muted ticket' ELSE 'Unmuted ticket' END,
      p_is_public   => 'N');
  END set_mute;

  -- ------------------------------------------------------------------ preferences
  PROCEDURE audit_pref(p_user_id IN NUMBER, p_summary IN VARCHAR2, p_facts IN CLOB) IS
  BEGIN
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_user, p_entity_id => p_user_id,
      p_event_code  => 'PREFERENCE_CHANGED', p_after_facts => p_facts,
      p_summary     => p_summary, p_is_public => 'N');
  END audit_pref;

  FUNCTION pref_facts(p_application_id IN NUMBER, p_event_code IN VARCHAR2,
                      p_preset IN VARCHAR2, p_email IN VARCHAR2, p_in_app IN VARCHAR2) RETURN CLOB IS
  BEGIN
    RETURN afh_audit_pkg.json_obj(
      apex_t_varchar2('application_id', 'event_code', 'preset_code', 'email_enabled', 'in_app_enabled'),
      apex_t_varchar2(TO_CHAR(p_application_id), p_event_code, p_preset, p_email, p_in_app));
  END pref_facts;

  PROCEDURE set_preset(p_preset_code IN VARCHAR2, p_application_id IN NUMBER DEFAULT NULL) IS
    l_user NUMBER := current_user;
  BEGIN
    assert_preset(p_preset_code);
    assert_application(p_application_id);
    UPDATE afh_notification_prefs p
       SET p.preset_code = p_preset_code
     WHERE p.user_id = l_user
       AND p.event_code IS NULL
       AND ((p_application_id IS NULL AND p.application_id IS NULL) OR p.application_id = p_application_id);
    IF SQL%ROWCOUNT = 0 THEN
      INSERT INTO afh_notification_prefs (user_id, application_id, event_code, preset_code)
      VALUES (l_user, p_application_id, NULL, p_preset_code);
    END IF;
    audit_pref(l_user, 'Notification preset set to ' || p_preset_code,
               pref_facts(p_application_id, NULL, p_preset_code, NULL, NULL));
  END set_preset;

  PROCEDURE clear_preset(p_application_id IN NUMBER) IS
    l_user NUMBER := current_user;
  BEGIN
    IF p_application_id IS NULL THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'An application is required.');
    END IF;
    DELETE FROM afh_notification_prefs p
     WHERE p.user_id = l_user AND p.application_id = p_application_id AND p.event_code IS NULL;
    IF SQL%ROWCOUNT = 0 THEN
      RETURN;
    END IF;
    audit_pref(l_user, 'Application notification preset removed',
               pref_facts(p_application_id, NULL, NULL, NULL, NULL));
  END clear_preset;

  PROCEDURE set_event_override(
    p_event_code     IN VARCHAR2,
    p_email_enabled  IN VARCHAR2,
    p_in_app_enabled IN VARCHAR2,
    p_application_id IN NUMBER DEFAULT NULL) IS
    l_user NUMBER := current_user;
  BEGIN
    assert_event(p_event_code);
    assert_yn(p_email_enabled, 'E-mail flag');
    assert_yn(p_in_app_enabled, 'In-app flag');
    assert_application(p_application_id);
    UPDATE afh_notification_prefs p
       SET p.email_enabled = p_email_enabled, p.in_app_enabled = p_in_app_enabled
     WHERE p.user_id = l_user
       AND p.event_code = p_event_code
       AND ((p_application_id IS NULL AND p.application_id IS NULL) OR p.application_id = p_application_id);
    IF SQL%ROWCOUNT = 0 THEN
      INSERT INTO afh_notification_prefs (user_id, application_id, event_code, email_enabled, in_app_enabled)
      VALUES (l_user, p_application_id, p_event_code, p_email_enabled, p_in_app_enabled);
    END IF;
    audit_pref(l_user, 'Notification override set for ' || p_event_code,
               pref_facts(p_application_id, p_event_code, NULL, p_email_enabled, p_in_app_enabled));
  END set_event_override;

  PROCEDURE clear_event_override(p_event_code IN VARCHAR2, p_application_id IN NUMBER DEFAULT NULL) IS
    l_user NUMBER := current_user;
  BEGIN
    assert_event(p_event_code);
    DELETE FROM afh_notification_prefs p
     WHERE p.user_id = l_user
       AND p.event_code = p_event_code
       AND ((p_application_id IS NULL AND p.application_id IS NULL) OR p.application_id = p_application_id);
    IF SQL%ROWCOUNT = 0 THEN
      RETURN;
    END IF;
    audit_pref(l_user, 'Notification override removed for ' || p_event_code,
               pref_facts(p_application_id, p_event_code, NULL, NULL, NULL));
  END clear_event_override;

  -- Per-app preset -> global preset -> config DEFAULT_NOTIFY_PRESET -> IMMEDIATE.
  FUNCTION effective_preset(p_application_id IN NUMBER DEFAULT NULL, p_user_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
    l_user   NUMBER := COALESCE(p_user_id, afh_security_pkg.current_user_id);
    l_preset afh_notification_prefs.preset_code%TYPE;
  BEGIN
    SELECT MAX(p.preset_code) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN p.application_id IS NULL THEN 2 ELSE 1 END)
      INTO l_preset
      FROM afh_notification_prefs p
     WHERE p.user_id = l_user
       AND p.event_code IS NULL
       AND (p.application_id IS NULL OR p.application_id = p_application_id);
    RETURN COALESCE(l_preset, afh_security_pkg.config_value('DEFAULT_NOTIFY_PRESET'), c_default_preset);
  END effective_preset;

  PROCEDURE resolve_channels(
    p_user_id        IN  NUMBER,
    p_ticket_id      IN  NUMBER,
    p_event_code     IN  VARCHAR2,
    p_is_direct_task IN  VARCHAR2,
    o_in_app         OUT VARCHAR2,
    o_email          OUT VARCHAR2,
    o_digest         OUT VARCHAR2) IS
  BEGIN
    afh_notification_int_pkg.resolve_core(
      p_user_id, ticket_app(p_ticket_id), p_ticket_id, p_event_code, p_is_direct_task,
      o_in_app, o_email, o_digest);
  END resolve_channels;

  -- ------------------------------------------------------------------ raising events
  PROCEDURE insert_row(
    p_recipient IN NUMBER, p_ticket_id IN NUMBER, p_event_code IN VARCHAR2, p_channel IN VARCHAR2,
    p_state IN VARCHAR2, p_subject IN VARCHAR2, p_body IN CLOB, p_digest IN VARCHAR2,
    p_actor IN NUMBER, p_task_id IN NUMBER, p_link IN VARCHAR2) IS
  BEGIN
    INSERT INTO afh_notifications (
      recipient_user_id, ticket_id, event_code, channel_code, state_code, subject, body,
      delivery_attempts, digest_frequency, actor_user_id, task_id, link_target)
    VALUES (
      p_recipient, p_ticket_id, p_event_code, p_channel, p_state, p_subject, p_body,
      0, p_digest, p_actor, p_task_id, p_link);
  END insert_row;

  -- One recipient: decide channels, render per channel, insert rows. Counts in/out.
  PROCEDURE notify_one(
    p_event_code IN VARCHAR2, p_ticket_id IN NUMBER, p_recipient IN NUMBER, p_is_direct IN VARCHAR2,
    p_summary IN VARCHAR2, p_actor IN NUMBER, p_task_id IN NUMBER, p_link IN VARCHAR2,
    p_has_email IN BOOLEAN, p_counts IN OUT NOCOPY apex_t_number) IS
    l_in_app  VARCHAR2(1);
    l_email   VARCHAR2(1);
    l_digest  VARCHAR2(30);
    l_subject VARCHAR2(500 CHAR);
    l_body    CLOB;
  BEGIN
    resolve_channels(p_recipient, p_ticket_id, p_event_code, p_is_direct, l_in_app, l_email, l_digest);
    IF l_in_app = 'Y' THEN
      render(p_event_code, 'IN_APP', p_ticket_id, p_recipient, p_summary, l_subject, l_body);
      insert_row(p_recipient, p_ticket_id, p_event_code, 'IN_APP', 'NEW', l_subject, l_body, NULL, p_actor, p_task_id, p_link);
      p_counts(1) := p_counts(1) + 1;
    END IF;
    IF l_email = 'Y' AND p_has_email THEN   -- no address: skip silently, in-app still delivered
      render(p_event_code, 'EMAIL', p_ticket_id, p_recipient, p_summary, l_subject, l_body);
      insert_row(p_recipient, p_ticket_id, p_event_code, 'EMAIL', 'QUEUED', l_subject, l_body, NULL, p_actor, p_task_id, p_link);
      p_counts(2) := p_counts(2) + 1;
    END IF;
    IF l_digest IN ('DAILY', 'WEEKLY') AND p_has_email THEN
      render(p_event_code, 'DIGEST', p_ticket_id, p_recipient, p_summary, l_subject, l_body);
      insert_row(p_recipient, p_ticket_id, p_event_code, 'DIGEST', 'NEW', l_subject, l_body, l_digest, p_actor, p_task_id, p_link);
      p_counts(3) := p_counts(3) + 1;
    END IF;
  END notify_one;

  -- Audit: one NOTIFICATION_RAISED per call (never per row), non-public, skipped
  -- when nothing was created so an event with no audience leaves no trace.
  PROCEDURE audit_raise(p_ticket_id IN NUMBER, p_event_code IN VARCHAR2, p_counts IN apex_t_number) IS
  BEGIN
    IF p_counts(1) + p_counts(2) + p_counts(3) = 0 THEN
      RETURN;
    END IF;
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_ticket, p_entity_id => p_ticket_id,
      p_event_code  => 'NOTIFICATION_RAISED', p_ticket_id => p_ticket_id,
      p_after_facts => afh_audit_pkg.json_obj(
        apex_t_varchar2('event_code', 'in_app', 'email', 'digest'),
        apex_t_varchar2(p_event_code, TO_CHAR(p_counts(1)), TO_CHAR(p_counts(2)), TO_CHAR(p_counts(3)))),
      p_summary     => 'Notifications raised for ' || p_event_code, p_is_public => 'N');
  END audit_raise;

  PROCEDURE raise_event(
    p_event_code     IN VARCHAR2,
    p_ticket_id      IN NUMBER,
    p_target_user_id IN NUMBER   DEFAULT NULL,
    p_task_id        IN NUMBER   DEFAULT NULL,
    p_summary        IN VARCHAR2 DEFAULT NULL,
    p_notify_actor   IN VARCHAR2 DEFAULT 'N') IS
    l_actor  NUMBER := afh_security_pkg.current_user_id;
    l_no     afh_tickets.ticket_no%TYPE;
    l_link   VARCHAR2(500 CHAR);
    l_counts apex_t_number := apex_t_number(0, 0, 0);
    l_direct VARCHAR2(1);
  BEGIN
    assert_event(p_event_code);
    BEGIN
      SELECT t.ticket_no INTO l_no FROM afh_tickets t WHERE t.ticket_id = p_ticket_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The ticket does not exist.');
    END;
    l_link := afh_notification_int_pkg.in_app_link(l_no);
    FOR r IN (SELECT u.user_id, u.email
                FROM afh_users u
               WHERE u.is_active = 'Y'
                 AND (u.user_id = p_target_user_id
                      OR u.user_id IN (SELECT f.user_id FROM afh_followers f WHERE f.ticket_id = p_ticket_id))
                 AND (p_notify_actor = 'Y' OR l_actor IS NULL OR u.user_id <> l_actor)
               ORDER BY u.user_id) LOOP
      l_direct := CASE WHEN r.user_id = p_target_user_id
                        AND p_event_code IN (c_ev_assignment, c_ev_info_request, c_ev_test_request)
                       THEN 'Y' ELSE 'N' END;
      notify_one(p_event_code, p_ticket_id, r.user_id, l_direct, p_summary, l_actor, p_task_id,
                 l_link, r.email IS NOT NULL, l_counts);
    END LOOP;
    audit_raise(p_ticket_id, p_event_code, l_counts);
  END raise_event;

  -- ------------------------------------------------------------------ in-app
  -- Read receipts are not material changes: no audit event.
  PROCEDURE mark_read(p_notification_id IN NUMBER) IS
    l_user  NUMBER := current_user;
    l_owner NUMBER;
  BEGIN
    SELECT n.recipient_user_id INTO l_owner
      FROM afh_notifications n
     WHERE n.notification_id = p_notification_id AND n.channel_code = 'IN_APP';
    IF l_owner <> l_user THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002, 'This notification belongs to another user.');
    END IF;
    UPDATE afh_notifications n
       SET n.state_code = 'READ', n.read_at = SYSTIMESTAMP
     WHERE n.notification_id = p_notification_id AND n.state_code = 'NEW';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The notification does not exist.');
  END mark_read;

  PROCEDURE mark_all_read IS
    l_user NUMBER := current_user;
  BEGIN
    UPDATE afh_notifications n
       SET n.state_code = 'READ', n.read_at = SYSTIMESTAMP
     WHERE n.recipient_user_id = l_user AND n.channel_code = 'IN_APP' AND n.state_code = 'NEW';
  END mark_all_read;

  FUNCTION unread_count(p_user_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_cnt NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_cnt
      FROM afh_notifications n
     WHERE n.recipient_user_id = COALESCE(p_user_id, afh_security_pkg.current_user_id)
       AND n.channel_code = 'IN_APP' AND n.state_code = 'NEW';
    RETURN l_cnt;
  END unread_count;

  -- ------------------------------------------------------------------ templates and rendering
  PROCEDURE render(
    p_event_code   IN  VARCHAR2,
    p_channel_code IN  VARCHAR2,
    p_ticket_id    IN  NUMBER,
    p_recipient_id IN  NUMBER,
    p_summary      IN  VARCHAR2,
    o_subject      OUT VARCHAR2,
    o_body         OUT CLOB) IS
  BEGIN
    afh_notification_int_pkg.render_core(
      p_event_code, p_channel_code, p_ticket_id, p_recipient_id, p_summary, NULL, o_subject, o_body);
  END render;

  FUNCTION ticket_link(p_ticket_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN afh_notification_int_pkg.ticket_link(p_ticket_id);
  END ticket_link;

  PROCEDURE upsert_template(
    p_event_code       IN VARCHAR2,
    p_channel_code     IN VARCHAR2,
    p_subject_template IN VARCHAR2,
    p_body_template    IN CLOB,
    p_is_active        IN VARCHAR2 DEFAULT 'Y',
    p_description      IN VARCHAR2 DEFAULT NULL) IS
    l_id     NUMBER;
    l_before CLOB;
  BEGIN
    afh_security_pkg.assert_admin;
    IF p_event_code IS NULL OR NOT REGEXP_LIKE(p_event_code, '^[A-Z][A-Z0-9_]{0,29}$')
       OR p_channel_code NOT IN ('IN_APP', 'EMAIL', 'DIGEST')
       OR p_subject_template IS NULL OR p_body_template IS NULL THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        'A template needs an uppercase event code, a valid channel, a subject, and a body.');
    END IF;
    assert_yn(p_is_active, 'Active flag');
    BEGIN
      SELECT t.notification_template_id,
             afh_audit_pkg.json_obj(apex_t_varchar2('subject_template', 'is_active'),
                                    apex_t_varchar2(t.subject_template, t.is_active))
        INTO l_id, l_before
        FROM afh_notification_templates t
       WHERE t.event_code = p_event_code AND t.channel_code = p_channel_code;
      UPDATE afh_notification_templates t
         SET t.subject_template = p_subject_template, t.body_template = p_body_template,
             t.is_active = p_is_active, t.description = p_description
       WHERE t.notification_template_id = l_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO afh_notification_templates (event_code, channel_code, subject_template, body_template, is_active, description)
        VALUES (p_event_code, p_channel_code, p_subject_template, p_body_template, p_is_active, p_description)
        RETURNING notification_template_id INTO l_id;
    END;
    afh_audit_pkg.log_event(
      p_entity_type  => afh_audit_pkg.c_entity_template, p_entity_id => l_id,
      p_event_code   => 'TEMPLATE_CHANGED', p_before_facts => l_before,
      p_after_facts  => afh_audit_pkg.json_obj(
        apex_t_varchar2('event_code', 'channel_code', 'subject_template', 'is_active'),
        apex_t_varchar2(p_event_code, p_channel_code, p_subject_template, p_is_active)),
      p_summary      => 'Template ' || p_event_code || '/' || p_channel_code || ' saved', p_is_public => 'N');
  END upsert_template;

  -- ------------------------------------------------------------------ delivery (jobs)
  -- Session failure (no APEX, wrong FEEDBACK_APP_ID) leaves the rows QUEUED and
  -- writes one MAIL/FAILED integration event per run: a configuration problem,
  -- not a delivery attempt, so it never counts against a row's retries.
  FUNCTION open_mail_session RETURN BOOLEAN IS
    l_app_id NUMBER := afh_security_pkg.config_number('FEEDBACK_APP_ID');
  BEGIN
    apex_session.create_session(p_app_id => l_app_id, p_page_id => 1, p_username => 'AFH_MAILER');
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      afh_audit_pkg.log_integration_event(
        p_event_code => 'MAIL', p_result_code => 'FAILED',
        p_safe_detail => 'Mail worker could not open an APEX session for FEEDBACK_APP_ID ' || l_app_id
                      || ': ' || SUBSTR(SQLERRM, 1, 200));
      afh_notification_int_pkg.batch_commit;
      RETURN FALSE;
  END open_mail_session;

  PROCEDURE process_mail_queue(p_max_rows IN PLS_INTEGER DEFAULT 200) IS
    l_ids     apex_t_number;
    l_max     PLS_INTEGER := GREATEST(NVL(p_max_rows, 200), 1);
    l_enabled BOOLEAN := afh_security_pkg.config_yn('MAIL_ENABLED', 'N') = 'Y';
    l_retries PLS_INTEGER := afh_security_pkg.config_number('MAIL_MAX_RETRIES', c_max_retries);
  BEGIN
    IF l_enabled THEN
      afh_notification_int_pkg.reconcile_relay;      -- verdicts for earlier SENT rows first
      afh_notification_int_pkg.batch_commit;
    END IF;
    SELECT n.notification_id BULK COLLECT INTO l_ids
      FROM afh_notifications n
     WHERE n.channel_code = 'EMAIL' AND n.state_code = 'QUEUED'
     ORDER BY n.notification_id
     FETCH FIRST l_max ROWS ONLY;
    IF l_ids.COUNT = 0 THEN
      RETURN;
    END IF;
    IF NOT l_enabled THEN
      FOR i IN 1 .. l_ids.COUNT LOOP
        afh_notification_int_pkg.mark_skipped_disabled(l_ids(i));
        afh_notification_int_pkg.batch_commit;
      END LOOP;
      RETURN;
    END IF;
    IF NOT open_mail_session THEN
      RETURN;
    END IF;
    BEGIN
      FOR i IN 1 .. l_ids.COUNT LOOP
        afh_notification_int_pkg.deliver_one(l_ids(i), l_retries);
        afh_notification_int_pkg.batch_commit;
      END LOOP;
      apex_session.delete_session;
    EXCEPTION
      WHEN OTHERS THEN
        apex_session.delete_session;
        RAISE;
    END;
  END process_mail_queue;

  PROCEDURE send_digests(p_frequency IN VARCHAR2) IS
  BEGIN
    IF p_frequency NOT IN (c_preset_daily, c_preset_weekly) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Digest frequency must be DAILY or WEEKLY.');
    END IF;
    FOR r IN (SELECT DISTINCT n.recipient_user_id
                FROM afh_notifications n
               WHERE n.channel_code = 'DIGEST' AND n.state_code = 'NEW'
                 AND n.digest_frequency = p_frequency
               ORDER BY n.recipient_user_id) LOOP
      afh_notification_int_pkg.digest_for_user(r.recipient_user_id, p_frequency);
      afh_notification_int_pkg.batch_commit;
    END LOOP;
  END send_digests;

  PROCEDURE requeue(p_notification_id IN NUMBER) IS
    l_state VARCHAR2(30 CHAR);
  BEGIN
    afh_security_pkg.assert_admin;
    SELECT state_code INTO l_state FROM afh_notifications WHERE notification_id = p_notification_id AND channel_code = 'EMAIL' FOR UPDATE;
    IF l_state <> 'FAILED' THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Only failed e-mails can be requeued.');
    END IF;
    UPDATE afh_notifications
       SET state_code = 'QUEUED', delivery_attempts = 0, error_code = NULL, error_detail = NULL
     WHERE notification_id = p_notification_id;
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_notification,
      p_entity_id   => p_notification_id,
      p_event_code  => 'NOTIFICATION_REQUEUED',
      p_summary     => 'E-mail notification requeued by an administrator',
      p_is_public   => 'N');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Unknown e-mail notification.');
  END requeue;
END afh_notification_pkg;
/
