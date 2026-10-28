CREATE OR REPLACE PACKAGE BODY afh_security_pkg AS
  -- ---------------------------------------------------------------------------
  -- AFH_SECURITY_PKG body. Spec §9, §12, §21. Identity comes only from trusted
  -- APEX session state (APP_USER) or, under afh_compile_flags.test_mode, from
  -- set_test_subject. Role logic lives here and nowhere else.
  -- ---------------------------------------------------------------------------

  $IF afh_compile_flags.test_mode $THEN
  g_test_subject VARCHAR2(255 CHAR);
  g_real_subject VARCHAR2(255 CHAR);   -- act-as: who signed in, while g_test_subject is someone else
  $END


  -- =========================================================== errors
  FUNCTION error_number(p_code IN VARCHAR2) RETURN PLS_INTEGER IS
  BEGIN
    RETURN CASE UPPER(p_code)
      WHEN c_err_auth_001 THEN -20001
      WHEN c_err_auth_002 THEN -20002
      WHEN c_err_ctx_001  THEN -20010
      WHEN c_err_ctx_002  THEN -20011
      WHEN c_err_ctx_003  THEN -20012
      WHEN c_err_upl_001  THEN -20020
      WHEN c_err_upl_002  THEN -20021
      WHEN c_err_wf_001   THEN -20030
      WHEN c_err_lock_001 THEN -20040
      WHEN c_err_srch_001 THEN -20050
      WHEN c_err_mail_001 THEN -20060
      WHEN c_err_sys_001  THEN -20090
      WHEN c_err_sys_002  THEN -20092
      WHEN c_err_val_001  THEN -20100
      ELSE -20090
    END;
  END error_number;

  PROCEDURE raise_error(p_code IN VARCHAR2, p_message IN VARCHAR2) IS
  BEGIN
    RAISE_APPLICATION_ERROR(error_number(p_code), SUBSTR(p_code || ': ' || p_message, 1, 2000));
  END raise_error;

  FUNCTION error_code_of(p_sqlerrm IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN REGEXP_SUBSTR(p_sqlerrm, 'AFH-[A-Z]+-[0-9]{3}');
  END error_code_of;

  PROCEDURE deny(p_action IN VARCHAR2) IS
  BEGIN
    raise_error(c_err_auth_002, 'You do not have permission to ' || p_action || '.');
  END deny;

  -- =========================================================== identity
  FUNCTION canonical_subject(p_subject IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN SUBSTR(UPPER(TRIM(p_subject)), 1, 255);
  END canonical_subject;

  -- Raw APP_USER of the trusted session (NULL outside APEX). Under test_mode the
  -- impersonated subject wins so tests never depend on an APEX session.
  FUNCTION raw_session_subject RETURN VARCHAR2 IS
  BEGIN
    $IF afh_compile_flags.test_mode $THEN
    IF g_test_subject IS NOT NULL THEN
      RETURN g_test_subject;
    END IF;
    $END
    RETURN SYS_CONTEXT('APEX$SESSION', 'APP_USER');
  END raw_session_subject;

  FUNCTION current_subject RETURN VARCHAR2 IS
    l_subject VARCHAR2(255 CHAR) := canonical_subject(raw_session_subject);
  BEGIN
    IF l_subject IS NULL OR l_subject IN ('NOBODY', 'APEX_PUBLIC_USER', 'ANONYMOUS') THEN
      raise_error(c_err_auth_001, 'Sign in to continue.');
    END IF;
    RETURN l_subject;
  END current_subject;

  FUNCTION user_id_of(p_canonical IN VARCHAR2) RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    SELECT user_id INTO l_id FROM afh_users WHERE subject_canonical = p_canonical;
    RETURN l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END user_id_of;

  FUNCTION current_user_id RETURN NUMBER IS
  BEGIN
    RETURN user_id_of(current_subject);
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = error_number(c_err_auth_001) THEN
        RETURN NULL;
      END IF;
      RAISE;
  END current_user_id;

  PROCEDURE require_identity IS
    l_subject VARCHAR2(255 CHAR);
  BEGIN
    l_subject := current_subject;
  END require_identity;

  FUNCTION insert_user(
    p_subject      IN VARCHAR2,
    p_canonical    IN VARCHAR2,
    p_display_name IN VARCHAR2,
    p_email        IN VARCHAR2,
    p_touch        IN BOOLEAN) RETURN NUMBER IS
    l_id NUMBER;
    -- 19c: a BOOLEAN cannot appear inside SQL, so resolve it in PL/SQL first.
    l_seen afh_users.last_seen_at%TYPE := CASE WHEN p_touch THEN SYSTIMESTAMP END;
  BEGIN
    INSERT INTO afh_users (subject_canonical, subject_display, display_name, email, last_seen_at)
    VALUES (p_canonical, SUBSTR(TRIM(p_subject), 1, 255), SUBSTR(p_display_name, 1, 255),
            SUBSTR(p_email, 1, 320), l_seen)
    RETURNING user_id INTO l_id;
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_user,
      p_entity_id   => l_id,
      p_event_code  => 'USER_CREATED',
      p_after_facts => afh_audit_pkg.json_obj(
        apex_t_varchar2('subject', 'display_name', 'email'),
        apex_t_varchar2(p_canonical, p_display_name, p_email)),
      p_summary     => 'User ' || p_canonical || ' created',
      p_is_public   => 'N');
    RETURN l_id;
  END insert_user;

  PROCEDURE refresh_user(
    p_user_id      IN NUMBER,
    p_display_name IN VARCHAR2,
    p_email        IN VARCHAR2,
    p_touch        IN BOOLEAN) IS
    -- 19c: a BOOLEAN cannot appear inside SQL, so resolve it in PL/SQL first.
    l_touch VARCHAR2(1) := CASE WHEN p_touch THEN 'Y' ELSE 'N' END;
  BEGIN
    IF p_display_name IS NULL AND p_email IS NULL AND NOT p_touch THEN
      RETURN;
    END IF;
    UPDATE afh_users
       SET display_name = COALESCE(SUBSTR(p_display_name, 1, 255), display_name),
           email        = COALESCE(SUBSTR(p_email, 1, 320), email),
           last_seen_at = CASE WHEN l_touch = 'Y' THEN SYSTIMESTAMP ELSE last_seen_at END
     WHERE user_id = p_user_id;
  END refresh_user;

  FUNCTION upsert_user(
    p_subject      IN VARCHAR2,
    p_display_name IN VARCHAR2,
    p_email        IN VARCHAR2,
    p_touch        IN BOOLEAN) RETURN NUMBER IS
    l_canonical VARCHAR2(255 CHAR) := canonical_subject(p_subject);
    l_id        NUMBER;
  BEGIN
    IF l_canonical IS NULL THEN
      raise_error(c_err_val_001, 'A user subject is required.');
    END IF;
    l_id := user_id_of(l_canonical);
    IF l_id IS NULL THEN
      BEGIN
        RETURN insert_user(p_subject, l_canonical, p_display_name, p_email, p_touch);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          l_id := user_id_of(l_canonical);   -- concurrent first sight; fall through
      END;
    END IF;
    refresh_user(l_id, p_display_name, p_email, p_touch);
    RETURN l_id;
  END upsert_user;

  FUNCTION touch_current_user(
    p_display_name IN VARCHAR2 DEFAULT NULL,
    p_email        IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_subject VARCHAR2(255 CHAR) := current_subject;
    l_raw     VARCHAR2(255 CHAR) := SUBSTR(TRIM(raw_session_subject), 1, 255);
  BEGIN
    RETURN upsert_user(
      CASE WHEN canonical_subject(l_raw) = l_subject THEN l_raw ELSE l_subject END,
      p_display_name, p_email, TRUE);
  END touch_current_user;

  FUNCTION ensure_user(
    p_subject      IN VARCHAR2,
    p_display_name IN VARCHAR2 DEFAULT NULL,
    p_email        IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
  BEGIN
    RETURN upsert_user(p_subject, p_display_name, p_email, FALSE);
  END ensure_user;

  -- =========================================================== role primitives
  FUNCTION rank_of(p_role_code IN VARCHAR2) RETURN PLS_INTEGER IS
  BEGIN
    RETURN CASE UPPER(TRIM(p_role_code))
      WHEN c_role_user      THEN 1
      WHEN c_role_tester    THEN 2
      WHEN c_role_developer THEN 3
      WHEN c_role_app_owner THEN 4
      WHEN c_role_admin     THEN 5
      ELSE 0
    END;
  END rank_of;

  FUNCTION role_of_rank(p_rank IN PLS_INTEGER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_rank
      WHEN 1 THEN c_role_user
      WHEN 2 THEN c_role_tester
      WHEN 3 THEN c_role_developer
      WHEN 4 THEN c_role_app_owner
      WHEN 5 THEN c_role_admin
      ELSE NULL
    END;
  END role_of_rank;

  FUNCTION is_active_user(p_user_id IN NUMBER) RETURN BOOLEAN IS
    l_cnt PLS_INTEGER;
  BEGIN
    IF p_user_id IS NULL THEN
      RETURN FALSE;
    END IF;
    SELECT COUNT(*) INTO l_cnt FROM afh_users WHERE user_id = p_user_id AND is_active = 'Y';
    RETURN l_cnt > 0;
  END is_active_user;

  FUNCTION resolve_user(p_user_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN COALESCE(p_user_id, current_user_id);
  END resolve_user;

  -- Explicit, currently effective grant of p_role_code: installation-wide, for
  -- p_application_id, or (p_any_app) for any application.
  FUNCTION has_grant(
    p_user_id        IN NUMBER,
    p_role_code      IN VARCHAR2,
    p_application_id IN NUMBER,
    p_any_app        IN BOOLEAN) RETURN BOOLEAN IS
    l_any VARCHAR2(1) := CASE WHEN p_any_app THEN 'Y' ELSE 'N' END;
    l_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*)
      INTO l_cnt
      FROM afh_user_roles r
     WHERE r.user_id = p_user_id
       AND r.role_code = p_role_code
       AND (r.application_id IS NULL OR l_any = 'Y' OR r.application_id = p_application_id)
       AND (r.effective_date IS NULL OR r.effective_date <= SYSTIMESTAMP)
       AND (r.expiration_date IS NULL OR r.expiration_date > SYSTIMESTAMP);
    RETURN l_cnt > 0;
  END has_grant;

  FUNCTION owns_app(p_user_id IN NUMBER, p_application_id IN NUMBER, p_any_app IN BOOLEAN) RETURN BOOLEAN IS
    l_any VARCHAR2(1) := CASE WHEN p_any_app THEN 'Y' ELSE 'N' END;
    l_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*)
      INTO l_cnt
      FROM afh_applications a
     WHERE a.owner_user_id = p_user_id
       AND (l_any = 'Y' OR a.application_id = p_application_id);
    RETURN l_cnt > 0;
  END owns_app;

  -- Highest ladder rank for the user: 0 = no active user, 1 = plain USER.
  -- Installation grants always count; app grants count for p_application_id or,
  -- with p_any_app, for any application. Owning an application counts as APP_OWNER.
  FUNCTION max_rank(p_user_id IN NUMBER, p_application_id IN NUMBER, p_any_app IN BOOLEAN) RETURN PLS_INTEGER IS
    l_any  VARCHAR2(1) := CASE WHEN p_any_app THEN 'Y' ELSE 'N' END;
    l_rank PLS_INTEGER;
  BEGIN
    IF NOT is_active_user(p_user_id) THEN
      RETURN 0;
    END IF;
    SELECT NVL(MAX(CASE r.role_code
                     WHEN c_role_admin     THEN 5
                     WHEN c_role_app_owner THEN 4
                     WHEN c_role_developer THEN 3
                     WHEN c_role_tester    THEN 2
                     ELSE 1 END), 1)
      INTO l_rank
      FROM afh_user_roles r
     WHERE r.user_id = p_user_id
       AND (r.application_id IS NULL OR l_any = 'Y' OR r.application_id = p_application_id)
       AND (r.effective_date IS NULL OR r.effective_date <= SYSTIMESTAMP)
       AND (r.expiration_date IS NULL OR r.expiration_date > SYSTIMESTAMP);
    IF l_rank < 4 AND owns_app(p_user_id, p_application_id, p_any_app) THEN
      l_rank := 4;
    END IF;
    RETURN l_rank;
  END max_rank;

  -- =========================================================== role checks
  FUNCTION has_role(
    p_role_code      IN VARCHAR2,
    p_application_id IN NUMBER DEFAULT NULL,
    p_user_id        IN NUMBER DEFAULT NULL) RETURN BOOLEAN IS
    l_user NUMBER := resolve_user(p_user_id);
    l_role VARCHAR2(30) := UPPER(TRIM(p_role_code));
  BEGIN
    IF rank_of(l_role) = 0 THEN
      raise_error(c_err_val_001, 'Unknown role code.');
    END IF;
    IF NOT is_active_user(l_user) THEN
      RETURN FALSE;
    END IF;
    IF has_grant(l_user, c_role_admin, NULL, FALSE) THEN
      RETURN TRUE;
    END IF;
    IF l_role = c_role_user THEN
      RETURN TRUE;   -- every active authenticated user holds USER (spec §9.1)
    END IF;
    RETURN has_grant(l_user, l_role, p_application_id, FALSE);
  END has_role;

  FUNCTION meets_min_role(
    p_min_role_code  IN VARCHAR2,
    p_application_id IN NUMBER DEFAULT NULL,
    p_user_id        IN NUMBER DEFAULT NULL) RETURN BOOLEAN IS
    l_min PLS_INTEGER := rank_of(p_min_role_code);
  BEGIN
    IF l_min = 0 THEN
      raise_error(c_err_val_001, 'Unknown role code.');
    END IF;
    RETURN max_rank(resolve_user(p_user_id), p_application_id, FALSE) >= l_min;
  END meets_min_role;

  FUNCTION highest_role(
    p_application_id IN NUMBER DEFAULT NULL,
    p_user_id        IN NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
  BEGIN
    RETURN role_of_rank(max_rank(resolve_user(p_user_id), p_application_id, FALSE));
  END highest_role;

  FUNCTION has_identity RETURN BOOLEAN IS
  BEGIN
    RETURN current_subject IS NOT NULL;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = error_number(c_err_auth_001) THEN
        RETURN FALSE;
      END IF;
      RAISE;
  END has_identity;

  -- Every trusted subject is a USER (spec §9.1). In shared-session mode host users never
  -- pass the Hub's own login, so the first check registers them. Autonomous: it is also
  -- reached from queries (AFH_V_NAV_ENTRIES), where DML in the caller would be ORA-14551.
  FUNCTION register_current_user RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_id NUMBER;
  BEGIN
    l_id := touch_current_user;
    COMMIT;
    RETURN l_id;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END register_current_user;

  FUNCTION is_authenticated RETURN BOOLEAN IS
    l_user NUMBER := current_user_id;
  BEGIN
    IF l_user IS NULL AND has_identity THEN
      l_user := register_current_user;
    END IF;
    RETURN is_active_user(l_user);
  END is_authenticated;

  FUNCTION is_admin RETURN BOOLEAN IS
    l_user NUMBER := current_user_id;
  BEGIN
    RETURN is_active_user(l_user) AND has_grant(l_user, c_role_admin, NULL, FALSE);
  END is_admin;

  -- Explicit APP_OWNER grant, ownership of the application, or admin. NULL: any app.
  FUNCTION is_app_owner(p_application_id IN NUMBER DEFAULT NULL) RETURN BOOLEAN IS
    l_user NUMBER := current_user_id;
    l_any  BOOLEAN := p_application_id IS NULL;
  BEGIN
    IF NOT is_active_user(l_user) THEN
      RETURN FALSE;
    END IF;
    RETURN has_grant(l_user, c_role_admin, NULL, FALSE)
        OR has_grant(l_user, c_role_app_owner, p_application_id, l_any)
        OR owns_app(l_user, p_application_id, l_any);
  END is_app_owner;

  -- Explicit DEVELOPER grant or admin. Deliberately NOT the ladder: an application
  -- owner is not a developer for restricted reads (spec §9.2). NULL: any app.
  FUNCTION is_developer(p_application_id IN NUMBER DEFAULT NULL) RETURN BOOLEAN IS
    l_user NUMBER := current_user_id;
  BEGIN
    IF NOT is_active_user(l_user) THEN
      RETURN FALSE;
    END IF;
    RETURN has_grant(l_user, c_role_admin, NULL, FALSE)
        OR has_grant(l_user, c_role_developer, p_application_id, p_application_id IS NULL);
  END is_developer;

  -- Ladder rank TESTER or above (roles are cumulative, spec §9.1). NULL: any app.
  FUNCTION is_tester(p_application_id IN NUMBER DEFAULT NULL) RETURN BOOLEAN IS
  BEGIN
    RETURN max_rank(current_user_id, p_application_id, p_application_id IS NULL) >= rank_of(c_role_tester);
  END is_tester;

  FUNCTION is_developer_or_above RETURN BOOLEAN IS
  BEGIN
    RETURN max_rank(current_user_id, NULL, TRUE) >= rank_of(c_role_developer);
  END is_developer_or_above;

  FUNCTION yn(p_bool IN BOOLEAN) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_bool THEN 'Y' ELSE 'N' END;
  END yn;

  FUNCTION is_admin_yn RETURN VARCHAR2 IS
  BEGIN
    RETURN yn(is_admin);
  END is_admin_yn;

  FUNCTION is_developer_yn(p_application_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
  BEGIN
    RETURN yn(is_developer(p_application_id));
  END is_developer_yn;

  FUNCTION is_app_owner_yn(p_application_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
  BEGIN
    RETURN yn(is_app_owner(p_application_id));
  END is_app_owner_yn;

  FUNCTION audience_yn(p_audience_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_audience_code
             WHEN 'AUTHENTICATED'      THEN yn(is_authenticated)
             WHEN 'DEVELOPER_OR_ABOVE' THEN yn(is_developer_or_above)
             WHEN 'APP_OWNER_OR_ADMIN' THEN yn(is_app_owner OR is_admin)
             WHEN 'ADMIN'              THEN yn(is_admin)
             ELSE 'N'
           END;
  END audience_yn;

  -- =========================================================== ticket-scoped permissions
  -- Application of a ticket; NULL when the ticket does not exist.
  FUNCTION ticket_app(p_ticket_id IN NUMBER) RETURN NUMBER IS
    l_app NUMBER;
  BEGIN
    SELECT application_id INTO l_app FROM afh_tickets WHERE ticket_id = p_ticket_id;
    RETURN l_app;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END ticket_app;

  FUNCTION can_view_ticket(p_ticket_id IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    RETURN ticket_app(p_ticket_id) IS NOT NULL AND is_authenticated;
  END can_view_ticket;

  FUNCTION can_view_restricted(p_ticket_id IN NUMBER) RETURN BOOLEAN IS
    l_app NUMBER := ticket_app(p_ticket_id);
  BEGIN
    RETURN l_app IS NOT NULL AND is_developer(l_app);
  END can_view_restricted;

  FUNCTION can_add_internal_note(p_ticket_id IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    RETURN can_view_restricted(p_ticket_id);
  END can_add_internal_note;

  -- Developer of the ticket's application, owner of that application, or admin.
  FUNCTION can_triage(p_ticket_id IN NUMBER) RETURN BOOLEAN IS
    l_app NUMBER := ticket_app(p_ticket_id);
  BEGIN
    RETURN l_app IS NOT NULL AND (is_developer(l_app) OR is_app_owner(l_app));
  END can_triage;

  FUNCTION can_classify(p_ticket_id IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    RETURN can_triage(p_ticket_id);
  END can_classify;

  FUNCTION can_assign(p_ticket_id IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    RETURN can_triage(p_ticket_id);
  END can_assign;

  FUNCTION can_merge(p_ticket_id IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    RETURN can_triage(p_ticket_id);
  END can_merge;

  FUNCTION can_record_test(p_test_result_id IN NUMBER) RETURN BOOLEAN IS
    l_user     NUMBER := current_user_id;
    l_ticket   NUMBER;
    l_assignee NUMBER;
  BEGIN
    IF NOT is_active_user(l_user) THEN
      RETURN FALSE;
    END IF;
    BEGIN
      SELECT ticket_id, assignee_user_id INTO l_ticket, l_assignee
        FROM afh_test_results WHERE test_result_id = p_test_result_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    END;
    IF l_assignee = l_user THEN
      RETURN TRUE;
    END IF;
    RETURN meets_min_role(c_role_developer, ticket_app(l_ticket), l_user);
  END can_record_test;

  FUNCTION can_manage_routing(p_application_id IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    RETURN p_application_id IS NOT NULL AND is_app_owner(p_application_id);
  END can_manage_routing;

  FUNCTION can_manage_releases(p_application_id IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    RETURN p_application_id IS NOT NULL AND is_app_owner(p_application_id);
  END can_manage_releases;

  FUNCTION is_reporter(p_ticket_id IN NUMBER) RETURN BOOLEAN IS
    l_user     NUMBER := current_user_id;
    l_reporter NUMBER;
  BEGIN
    IF l_user IS NULL THEN
      RETURN FALSE;
    END IF;
    SELECT reporter_user_id INTO l_reporter FROM afh_tickets WHERE ticket_id = p_ticket_id;
    RETURN l_reporter = l_user;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
  END is_reporter;

  -- Assignee of an open (PENDING) test request, or of the most recent request.
  FUNCTION is_assigned_tester(p_ticket_id IN NUMBER) RETURN BOOLEAN IS
    l_user    NUMBER := current_user_id;
    l_pending PLS_INTEGER;
    l_latest  NUMBER;
  BEGIN
    IF l_user IS NULL THEN
      RETURN FALSE;
    END IF;
    SELECT COUNT(*) INTO l_pending
      FROM afh_test_results
     WHERE ticket_id = p_ticket_id AND result_code = 'PENDING' AND assignee_user_id = l_user;
    IF l_pending > 0 THEN
      RETURN TRUE;
    END IF;
    SELECT MAX(assignee_user_id) KEEP (DENSE_RANK LAST ORDER BY requested_at NULLS FIRST, test_result_id)
      INTO l_latest
      FROM afh_test_results
     WHERE ticket_id = p_ticket_id;
    RETURN l_latest IS NOT NULL AND l_latest = l_user;
  END is_assigned_tester;

  -- =========================================================== assertions
  PROCEDURE assert_authenticated IS
  BEGIN
    require_identity;
    IF NOT is_authenticated THEN
      raise_error(c_err_auth_002, 'Your account is not active. Contact a Feedback Hub administrator.');
    END IF;
  END assert_authenticated;

  PROCEDURE assert_admin IS
  BEGIN
    require_identity;
    IF NOT is_admin THEN
      deny('perform this administrative action');
    END IF;
  END assert_admin;

  -- Denied restricted reads are audited (non-public) before the error is raised.
  PROCEDURE assert_can_view_restricted(p_ticket_id IN NUMBER) IS
    l_subject VARCHAR2(255 CHAR) := current_subject;
  BEGIN
    IF can_view_restricted(p_ticket_id) THEN
      RETURN;
    END IF;
    -- autonomous: survives the rollback caused by the error raised below (spec §21)
    afh_audit_pkg.log_denial(
      p_entity_type => afh_audit_pkg.c_entity_ticket,
      p_entity_id   => p_ticket_id,
      p_ticket_id   => CASE WHEN ticket_app(p_ticket_id) IS NOT NULL THEN p_ticket_id END,
      p_summary     => 'Restricted read denied for ' || l_subject);
    deny('view restricted information on this ticket');
  END assert_can_view_restricted;

  PROCEDURE assert_can_classify(p_ticket_id IN NUMBER) IS
  BEGIN
    require_identity;
    IF NOT can_classify(p_ticket_id) THEN
      deny('classify this ticket');
    END IF;
  END assert_can_classify;

  PROCEDURE assert_can_assign(p_ticket_id IN NUMBER) IS
  BEGIN
    require_identity;
    IF NOT can_assign(p_ticket_id) THEN
      deny('assign this ticket');
    END IF;
  END assert_can_assign;

  PROCEDURE assert_can_merge(p_ticket_id IN NUMBER) IS
  BEGIN
    require_identity;
    IF NOT can_merge(p_ticket_id) THEN
      deny('merge this ticket');
    END IF;
  END assert_can_merge;

  PROCEDURE assert_can_manage_routing(p_application_id IN NUMBER) IS
  BEGIN
    require_identity;
    IF NOT can_manage_routing(p_application_id) THEN
      deny('manage routing for this application');
    END IF;
  END assert_can_manage_routing;

  PROCEDURE assert_can_manage_releases(p_application_id IN NUMBER) IS
  BEGIN
    require_identity;
    IF NOT can_manage_releases(p_application_id) THEN
      deny('manage releases for this application');
    END IF;
  END assert_can_manage_releases;

  PROCEDURE assert_min_role(p_min_role_code IN VARCHAR2, p_application_id IN NUMBER DEFAULT NULL) IS
  BEGIN
    require_identity;
    IF NOT meets_min_role(p_min_role_code, p_application_id) THEN
      deny('perform this action');
    END IF;
  END assert_min_role;

  -- =========================================================== configuration
  FUNCTION config_value(p_key IN VARCHAR2) RETURN VARCHAR2 IS
    l_value afh_install_config.config_value%TYPE;
  BEGIN
    SELECT config_value INTO l_value FROM afh_install_config WHERE config_key = UPPER(TRIM(p_key));
    RETURN l_value;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END config_value;

  FUNCTION config_number(p_key IN VARCHAR2, p_default IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_value afh_install_config.config_value%TYPE := config_value(p_key);
  BEGIN
    IF l_value IS NULL THEN
      RETURN p_default;
    END IF;
    RETURN TO_NUMBER(l_value);
  EXCEPTION
    WHEN VALUE_ERROR OR INVALID_NUMBER THEN
      raise_error(c_err_val_001, 'Configuration setting ' || UPPER(TRIM(p_key)) || ' is not a number.');
  END config_number;

  FUNCTION config_yn(p_key IN VARCHAR2, p_default IN VARCHAR2 DEFAULT 'N') RETURN VARCHAR2 IS
    l_value VARCHAR2(1) := UPPER(SUBSTR(TRIM(config_value(p_key)), 1, 1));
  BEGIN
    RETURN CASE WHEN l_value IN ('Y', 'N') THEN l_value ELSE p_default END;
  END config_yn;

  -- Admin mutation; implemented in afh_security_int_pkg (file-size rule).
  PROCEDURE set_config(p_key IN VARCHAR2, p_value IN VARCHAR2) IS
  BEGIN
    afh_security_int_pkg.set_config(p_key, p_value);
  END set_config;

  -- =========================================================== user & role administration
  -- Admin mutations; implemented in afh_security_int_pkg (file-size rule).
  PROCEDURE update_user(p_user_id IN NUMBER, p_display_name IN VARCHAR2, p_email IN VARCHAR2) IS
  BEGIN
    afh_security_int_pkg.update_user(p_user_id, p_display_name, p_email);
  END update_user;

  PROCEDURE set_user_active(p_user_id IN NUMBER, p_is_active IN VARCHAR2) IS
  BEGIN
    afh_security_int_pkg.set_user_active(p_user_id, p_is_active);
  END set_user_active;

  PROCEDURE grant_role(
    p_user_id        IN NUMBER,
    p_role_code      IN VARCHAR2,
    p_application_id IN NUMBER DEFAULT NULL,
    p_effective_date IN TIMESTAMP WITH LOCAL TIME ZONE DEFAULT NULL,
    p_expiration_date IN TIMESTAMP WITH LOCAL TIME ZONE DEFAULT NULL) IS
  BEGIN
    afh_security_int_pkg.grant_role(p_user_id, p_role_code, p_application_id, p_effective_date, p_expiration_date);
  END grant_role;

  PROCEDURE revoke_role(p_user_role_id IN NUMBER) IS
  BEGIN
    afh_security_int_pkg.revoke_role(p_user_role_id);
  END revoke_role;

  -- grant_role asserts a signed-in administrator, which a fresh install cannot have.
  -- The caller commits.
  PROCEDURE bootstrap_admin(
    p_subject      IN VARCHAR2,
    p_display_name IN VARCHAR2 DEFAULT NULL,
    p_email        IN VARCHAR2 DEFAULT NULL) IS
    l_admins PLS_INTEGER;
    l_user   NUMBER;
    l_id     NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO l_admins
      FROM afh_user_roles r
      JOIN afh_users u ON u.user_id = r.user_id
     WHERE r.role_code = c_role_admin
       AND u.is_active = 'Y'
       AND (r.effective_date IS NULL OR r.effective_date <= SYSTIMESTAMP)
       AND (r.expiration_date IS NULL OR r.expiration_date > SYSTIMESTAMP);
    IF l_admins > 0 THEN
      raise_error(c_err_auth_002, 'An administrator already exists. Grant roles from Users and Roles.');
    END IF;
    l_user := upsert_user(p_subject, p_display_name, p_email, FALSE);
    INSERT INTO afh_user_roles (user_id, role_code) VALUES (l_user, c_role_admin)
    RETURNING user_role_id INTO l_id;
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_user_role,
      p_entity_id   => l_id,
      p_event_code  => 'ROLE_GRANTED',
      p_summary     => 'Role ' || c_role_admin || ' granted to ' || canonical_subject(p_subject) || ' (first administrator)',
      p_is_public   => 'N');
  END bootstrap_admin;

  -- =========================================================== crypto primitives
  FUNCTION new_secret RETURN RAW IS
  BEGIN
    RETURN DBMS_CRYPTO.randombytes(32);
  END new_secret;

  FUNCTION hmac_sha256(p_key IN RAW, p_message IN VARCHAR2) RETURN RAW IS
  BEGIN
    IF p_key IS NULL THEN
      raise_error(c_err_val_001, 'A signing key is required.');
    END IF;
    RETURN DBMS_CRYPTO.mac(
      src => UTL_I18N.string_to_raw(p_message, 'AL32UTF8'),
      typ => DBMS_CRYPTO.hmac_sh256,
      key => p_key);
  END hmac_sha256;

  -- Constant time over the byte length: every byte is visited, the result is
  -- accumulated, and there is no early exit once the lengths match.
  FUNCTION raw_equals(p_a IN RAW, p_b IN RAW) RETURN BOOLEAN IS
    l_len PLS_INTEGER;
    l_x   RAW(32767);
    l_hex VARCHAR2(32767);
    l_acc PLS_INTEGER := 0;
  BEGIN
    IF p_a IS NULL OR p_b IS NULL THEN
      RETURN FALSE;
    END IF;
    l_len := UTL_RAW.length(p_a);
    IF l_len <> UTL_RAW.length(p_b) THEN
      RETURN FALSE;
    END IF;
    l_x   := UTL_RAW.bit_xor(p_a, p_b);
    l_hex := RAWTOHEX(l_x);
    FOR i IN 1 .. l_len LOOP
      l_acc := l_acc + TO_NUMBER(SUBSTR(l_hex, 2 * i - 1, 2), 'XX');
    END LOOP;
    RETURN l_acc = 0;
  END raw_equals;

  FUNCTION b64url_encode(p_raw IN RAW) RETURN VARCHAR2 IS
    l_text VARCHAR2(32767);
  BEGIN
    IF p_raw IS NULL THEN
      RETURN NULL;
    END IF;
    l_text := UTL_RAW.cast_to_varchar2(UTL_ENCODE.base64_encode(p_raw));
    l_text := REPLACE(REPLACE(l_text, CHR(13)), CHR(10));
    l_text := TRANSLATE(l_text, '+/', '-_');
    RETURN RTRIM(l_text, '=');
  END b64url_encode;

  FUNCTION b64url_decode(p_text IN VARCHAR2) RETURN RAW IS
    l_text VARCHAR2(32767) := TRANSLATE(TRIM(p_text), '-_', '+/');
    l_rem  PLS_INTEGER;
  BEGIN
    IF l_text IS NULL THEN
      RETURN NULL;
    END IF;
    IF NOT REGEXP_LIKE(l_text, '^[A-Za-z0-9+/]+=*$') THEN
      raise_error(c_err_val_001, 'The value is not valid base64url text.');
    END IF;
    l_rem := MOD(LENGTH(RTRIM(l_text, '=')), 4);
    IF l_rem = 1 THEN
      raise_error(c_err_val_001, 'The value is not valid base64url text.');
    END IF;
    l_text := RTRIM(l_text, '=') || CASE l_rem WHEN 2 THEN '==' WHEN 3 THEN '=' ELSE '' END;
    RETURN UTL_ENCODE.base64_decode(UTL_RAW.cast_to_raw(l_text));
  END b64url_decode;

  FUNCTION sha256_hex(p_blob IN BLOB) RETURN VARCHAR2 IS
  BEGIN
    IF p_blob IS NULL THEN
      RETURN NULL;
    END IF;
    RETURN LOWER(RAWTOHEX(DBMS_CRYPTO.hash(src => p_blob, typ => DBMS_CRYPTO.hash_sh256)));
  END sha256_hex;

  FUNCTION sha256_hex(p_text IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p_text IS NULL THEN
      RETURN NULL;
    END IF;
    RETURN LOWER(RAWTOHEX(DBMS_CRYPTO.hash(
      src => UTL_I18N.string_to_raw(p_text, 'AL32UTF8'), typ => DBMS_CRYPTO.hash_sh256)));
  END sha256_hex;

  -- =========================================================== act as (development aid)
  -- The real subject lives in application item G_REAL_USER inside an APEX session (protection
  -- level Restricted, so a browser cannot set it) and in g_real_subject under test_mode.
  FUNCTION in_apex_session RETURN BOOLEAN IS
  BEGIN
    RETURN SYS_CONTEXT('APEX$SESSION', 'APP_SESSION') IS NOT NULL;
  END in_apex_session;

  FUNCTION stored_real_subject RETURN VARCHAR2 IS
  BEGIN
    $IF afh_compile_flags.test_mode $THEN
    IF g_test_subject IS NOT NULL THEN
      RETURN g_real_subject;
    END IF;
    $END
    IF in_apex_session THEN
      RETURN canonical_subject(v('G_REAL_USER'));
    END IF;
    RETURN NULL;
  END stored_real_subject;

  PROCEDURE store_real_subject(p_subject IN VARCHAR2) IS
  BEGIN
    $IF afh_compile_flags.test_mode $THEN
    IF g_test_subject IS NOT NULL THEN
      g_real_subject := p_subject;
      RETURN;
    END IF;
    $END
    IF in_apex_session THEN
      apex_util.set_session_state('G_REAL_USER', p_subject);
    END IF;
  END store_real_subject;

  -- Continue the session as p_subject (a canonical subject). In APEX this is
  -- apex_custom_auth.post_login, which registers the session for the new user, runs the
  -- application's after-login process and redirects to page 1 (apex_custom_auth.set_user only
  -- changes the current request, verified 2026-09-05). Under test_mode it is the impersonation
  -- hook, so the same code path is unit-testable.
  PROCEDURE switch_session_subject(p_subject IN VARCHAR2, p_user_id IN NUMBER) IS
  BEGIN
    $IF afh_compile_flags.test_mode $THEN
    IF NOT in_apex_session THEN
      g_test_subject := canonical_subject(p_subject);
      RETURN;
    END IF;
    $END
    IF NOT in_apex_session THEN
      raise_error(c_err_auth_001, 'Sign in to continue.');
    END IF;
    apex_util.set_session_state('G_CURRENT_USER_ID', TO_CHAR(p_user_id));
    apex_custom_auth.post_login(
      p_uname         => p_subject,
      p_session_id    => v('APP_SESSION'),
      p_app_page      => v('APP_ID') || ':1',
      p_preserve_case => TRUE);
  END switch_session_subject;

  FUNCTION act_as_allowed RETURN BOOLEAN IS
  BEGIN
    RETURN config_yn('ACT_AS_ENABLED') = 'Y' AND is_authenticated;
  END act_as_allowed;

  FUNCTION act_as_allowed_yn RETURN VARCHAR2 IS
  BEGIN
    RETURN yn(act_as_allowed);
  END act_as_allowed_yn;

  FUNCTION real_subject RETURN VARCHAR2 IS
  BEGIN
    RETURN NVL(stored_real_subject, canonical_subject(raw_session_subject));
  END real_subject;

  FUNCTION is_acting_yn RETURN VARCHAR2 IS
  BEGIN
    RETURN yn(stored_real_subject IS NOT NULL);
  END is_acting_yn;

  PROCEDURE act_as(p_user_id IN NUMBER) IS
    l_target  afh_users%ROWTYPE;
    l_real    VARCHAR2(255 CHAR);
    l_real_id NUMBER;
  BEGIN
    require_identity;
    IF NOT act_as_allowed THEN
      deny('act as another user');
    END IF;
    BEGIN
      SELECT * INTO l_target FROM afh_users WHERE user_id = p_user_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_error(c_err_val_001, 'The user does not exist.');
    END;
    IF l_target.is_active <> 'Y' THEN
      raise_error(c_err_val_001, 'The user is inactive.');
    END IF;
    -- Always switch from the real person, so the audit actor is who signed in.
    l_real    := real_subject;
    l_real_id := user_id_of(l_real);
    IF stored_real_subject IS NOT NULL THEN
      switch_session_subject(l_real, l_real_id);
      store_real_subject(NULL);
    END IF;
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_user,
      p_entity_id   => p_user_id,
      p_event_code  => 'ACT_AS_START',
      p_after_facts => afh_audit_pkg.json_obj(
        apex_t_varchar2('real_subject', 'real_user_id', 'acting_subject', 'acting_user_id'),
        apex_t_varchar2(l_real, TO_CHAR(l_real_id), l_target.subject_canonical, TO_CHAR(p_user_id))),
      p_summary     => l_real || ' is acting as ' || l_target.subject_canonical,
      p_is_public   => 'N');
    store_real_subject(l_real);
    -- The canonical subject, not the display one: demo users keep their login key while
    -- subject_display carries a friendly name, and current_user_id resolves by canonical.
    switch_session_subject(l_target.subject_canonical, p_user_id);
  END act_as;

  PROCEDURE act_as_revert IS
    l_real      VARCHAR2(255 CHAR) := stored_real_subject;
    l_acting    VARCHAR2(255 CHAR);
    l_acting_id NUMBER;
    l_real_id   NUMBER;
  BEGIN
    IF l_real IS NULL THEN
      RETURN;
    END IF;
    l_acting    := canonical_subject(raw_session_subject);
    l_acting_id := user_id_of(l_acting);
    l_real_id   := user_id_of(l_real);
    switch_session_subject(l_real, l_real_id);
    store_real_subject(NULL);
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_user,
      p_entity_id   => NVL(l_acting_id, l_real_id),
      p_event_code  => 'ACT_AS_END',
      p_after_facts => afh_audit_pkg.json_obj(
        apex_t_varchar2('real_subject', 'real_user_id', 'acting_subject', 'acting_user_id'),
        apex_t_varchar2(l_real, TO_CHAR(l_real_id), l_acting, TO_CHAR(l_acting_id))),
      p_summary     => l_real || ' stopped acting as ' || l_acting,
      p_is_public   => 'N');
  END act_as_revert;

  -- =========================================================== test hook
  $IF afh_compile_flags.test_mode $THEN
  PROCEDURE set_test_subject(p_subject IN VARCHAR2) IS
  BEGIN
    g_test_subject := canonical_subject(p_subject);
    g_real_subject := NULL;
  END set_test_subject;

  PROCEDURE clear_test_subject IS
  BEGIN
    g_test_subject := NULL;
    g_real_subject := NULL;
  END clear_test_subject;
  $END

END afh_security_pkg;
/
