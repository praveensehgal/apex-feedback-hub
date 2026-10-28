CREATE OR REPLACE PACKAGE afh_security_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_SECURITY_PKG — canonical user resolution, role checks, application
  -- scope, restricted-read authorization, error raising, HMAC primitives for the
  -- signed-envelope identity path, and user/role administration. Spec §9, §12.
  --
  -- Identity comes ONLY from trusted APEX session state (APP_USER) or, under
  -- afh_compile_flags.test_mode, from set_test_subject. No public API takes an
  -- actor parameter.
  -- ---------------------------------------------------------------------------

  -- Role codes (spec §9.1)
  c_role_user      CONSTANT VARCHAR2(30) := 'USER';
  c_role_tester    CONSTANT VARCHAR2(30) := 'TESTER';
  c_role_developer CONSTANT VARCHAR2(30) := 'DEVELOPER';
  c_role_app_owner CONSTANT VARCHAR2(30) := 'APP_OWNER';
  c_role_admin     CONSTANT VARCHAR2(30) := 'AFH_ADMIN';

  -- Stable error codes (spec §21) and their ORA numbers. raise_error maps code -> number.
  c_err_auth_001 CONSTANT VARCHAR2(12) := 'AFH-AUTH-001';  -- no trusted identity      -20001
  c_err_auth_002 CONSTANT VARCHAR2(12) := 'AFH-AUTH-002';  -- permission denied        -20002
  c_err_ctx_001  CONSTANT VARCHAR2(12) := 'AFH-CTX-001';   -- expired/replayed launch  -20010
  c_err_ctx_002  CONSTANT VARCHAR2(12) := 'AFH-CTX-002';   -- partial context          -20011
  c_err_ctx_003  CONSTANT VARCHAR2(12) := 'AFH-CTX-003';   -- unsupported contract     -20012
  c_err_upl_001  CONSTANT VARCHAR2(12) := 'AFH-UPL-001';   -- file type rejected       -20020
  c_err_upl_002  CONSTANT VARCHAR2(12) := 'AFH-UPL-002';   -- size exceeded            -20021
  c_err_wf_001   CONSTANT VARCHAR2(12) := 'AFH-WF-001';    -- transition denied        -20030
  c_err_lock_001 CONSTANT VARCHAR2(12) := 'AFH-LOCK-001';  -- optimistic lock          -20040
  c_err_srch_001 CONSTANT VARCHAR2(12) := 'AFH-SRCH-001';  -- search unavailable       -20050
  c_err_mail_001 CONSTANT VARCHAR2(12) := 'AFH-MAIL-001';  -- mail delivery failed     -20060
  c_err_sys_001  CONSTANT VARCHAR2(12) := 'AFH-SYS-001';   -- unexpected               -20090
  c_err_sys_002  CONSTANT VARCHAR2(12) := 'AFH-SYS-002';   -- append-only violation    -20092
  c_err_val_001  CONSTANT VARCHAR2(12) := 'AFH-VAL-001';   -- input validation         -20100

  -- Raise RAISE_APPLICATION_ERROR(number_for(p_code), p_code || ': ' || p_message).
  -- Messages are user-safe: no SQL, stack, schema names, or secrets.
  PROCEDURE raise_error(p_code IN VARCHAR2, p_message IN VARCHAR2);
  FUNCTION  error_number(p_code IN VARCHAR2) RETURN PLS_INTEGER;
  -- Extract 'AFH-XXX-nnn' from SQLERRM, or NULL when the error is not an AFH error.
  FUNCTION  error_code_of(p_sqlerrm IN VARCHAR2) RETURN VARCHAR2;

  -- ----------------------------------------------------------------- identity
  -- Canonical form of a subject: UPPER(TRIM(p_subject)). NULL -> NULL.
  FUNCTION canonical_subject(p_subject IN VARCHAR2) RETURN VARCHAR2;

  -- Subject of the current trusted session (APEX APP_USER), or the test subject under
  -- test_mode. Raises AFH-AUTH-001 when there is no authenticated subject.
  FUNCTION current_subject RETURN VARCHAR2;

  -- afh_users.user_id for the current subject; NULL when the user row does not exist yet.
  -- Pure lookup, safe inside SQL and views.
  FUNCTION current_user_id RETURN NUMBER;

  -- Ensure an afh_users row exists for the current subject (creating it with role USER
  -- semantics), update display data and last_seen_at, and return the user_id. Call from
  -- the Global Page / post-authentication process. Raises AFH-AUTH-001 if no subject.
  FUNCTION touch_current_user(
    p_display_name IN VARCHAR2 DEFAULT NULL,
    p_email        IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

  -- Upsert a user by subject (administrative or launch-time use). Case-insensitive match on
  -- the canonical subject; preserves subject_display from first sight. Returns user_id.
  FUNCTION ensure_user(
    p_subject      IN VARCHAR2,
    p_display_name IN VARCHAR2 DEFAULT NULL,
    p_email        IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

  -- ----------------------------------------------------------------- role checks
  -- Explicit grant of p_role_code for the installation (application_id NULL) or for
  -- p_application_id, currently effective. AFH_ADMIN always satisfies every role.
  FUNCTION has_role(
    p_role_code      IN VARCHAR2,
    p_application_id IN NUMBER DEFAULT NULL,
    p_user_id        IN NUMBER DEFAULT NULL) RETURN BOOLEAN;

  -- TRUE when the user satisfies p_min_role for p_application_id using the cumulative
  -- ladder USER < TESTER < DEVELOPER < APP_OWNER < AFH_ADMIN (spec §10.2 "Developer,
  -- app owner, administrator" == min role DEVELOPER). Used by workflow transitions.
  FUNCTION meets_min_role(
    p_min_role_code  IN VARCHAR2,
    p_application_id IN NUMBER DEFAULT NULL,
    p_user_id        IN NUMBER DEFAULT NULL) RETURN BOOLEAN;

  -- Highest role code the user holds for p_application_id (installation grants count).
  FUNCTION highest_role(
    p_application_id IN NUMBER DEFAULT NULL,
    p_user_id        IN NUMBER DEFAULT NULL) RETURN VARCHAR2;

  -- Convenience predicates for APEX authorization schemes (PL/SQL Function Returning Boolean)
  FUNCTION is_authenticated RETURN BOOLEAN;                 -- has a subject and an active user row; registers a first-seen subject
  FUNCTION is_admin RETURN BOOLEAN;
  FUNCTION is_app_owner(p_application_id IN NUMBER DEFAULT NULL) RETURN BOOLEAN;   -- NULL: owner of any app
  FUNCTION is_developer(p_application_id IN NUMBER DEFAULT NULL) RETURN BOOLEAN;   -- NULL: developer on any app
  FUNCTION is_tester(p_application_id IN NUMBER DEFAULT NULL) RETURN BOOLEAN;
  FUNCTION is_developer_or_above RETURN BOOLEAN;            -- developer/app owner/admin anywhere: Workbench, Releases
  -- 'Y'/'N' variants for use in SQL
  FUNCTION is_admin_yn RETURN VARCHAR2;
  FUNCTION is_developer_yn(p_application_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION is_app_owner_yn(p_application_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  -- Data-driven navigation visibility (AFH_NAV_ENTRIES.AUDIENCE_CODE dispatch):
  -- AUTHENTICATED, DEVELOPER_OR_ABOVE, APP_OWNER_OR_ADMIN, ADMIN. Unknown code: 'N'.
  FUNCTION audience_yn(p_audience_code IN VARCHAR2) RETURN VARCHAR2;

  -- ----------------------------------------------------------------- ticket-scoped permissions (spec §9.2)
  FUNCTION can_view_ticket(p_ticket_id IN NUMBER) RETURN BOOLEAN;           -- any authenticated user (public tickets)
  FUNCTION can_view_restricted(p_ticket_id IN NUMBER) RETURN BOOLEAN;       -- raw context / restricted files / internal notes
  FUNCTION can_add_internal_note(p_ticket_id IN NUMBER) RETURN BOOLEAN;
  FUNCTION can_classify(p_ticket_id IN NUMBER) RETURN BOOLEAN;              -- official type/severity/priority/impact
  FUNCTION can_assign(p_ticket_id IN NUMBER) RETURN BOOLEAN;                -- assignee / target release / due date
  FUNCTION can_merge(p_ticket_id IN NUMBER) RETURN BOOLEAN;
  FUNCTION can_record_test(p_test_result_id IN NUMBER) RETURN BOOLEAN;      -- assigned tester or developer+
  FUNCTION can_manage_routing(p_application_id IN NUMBER) RETURN BOOLEAN;   -- app owner of that app or admin
  FUNCTION can_manage_releases(p_application_id IN NUMBER) RETURN BOOLEAN;
  FUNCTION is_reporter(p_ticket_id IN NUMBER) RETURN BOOLEAN;
  FUNCTION is_assigned_tester(p_ticket_id IN NUMBER) RETURN BOOLEAN;        -- open or most recent test request assignee

  -- Assertions: raise AFH-AUTH-002 (and for restricted reads write a non-public audit event)
  PROCEDURE assert_authenticated;
  PROCEDURE assert_admin;
  PROCEDURE assert_can_view_restricted(p_ticket_id IN NUMBER);
  PROCEDURE assert_can_classify(p_ticket_id IN NUMBER);
  PROCEDURE assert_can_assign(p_ticket_id IN NUMBER);
  PROCEDURE assert_can_merge(p_ticket_id IN NUMBER);
  PROCEDURE assert_can_manage_routing(p_application_id IN NUMBER);
  PROCEDURE assert_can_manage_releases(p_application_id IN NUMBER);
  PROCEDURE assert_min_role(p_min_role_code IN VARCHAR2, p_application_id IN NUMBER DEFAULT NULL);

  -- ----------------------------------------------------------------- configuration access
  FUNCTION config_value(p_key IN VARCHAR2) RETURN VARCHAR2;         -- NULL when missing
  FUNCTION config_number(p_key IN VARCHAR2, p_default IN NUMBER DEFAULT NULL) RETURN NUMBER;
  FUNCTION config_yn(p_key IN VARCHAR2, p_default IN VARCHAR2 DEFAULT 'N') RETURN VARCHAR2;
  -- Admin only; audits CONFIG_CHANGED with before/after (secret keys redacted).
  PROCEDURE set_config(p_key IN VARCHAR2, p_value IN VARCHAR2);

  -- ----------------------------------------------------------------- user and role administration (admin only)
  PROCEDURE update_user(p_user_id IN NUMBER, p_display_name IN VARCHAR2, p_email IN VARCHAR2);
  PROCEDURE set_user_active(p_user_id IN NUMBER, p_is_active IN VARCHAR2);  -- 'Y'/'N'; never rewrites history
  PROCEDURE grant_role(
    p_user_id        IN NUMBER,
    p_role_code      IN VARCHAR2,
    p_application_id IN NUMBER DEFAULT NULL,
    p_effective_date IN TIMESTAMP WITH LOCAL TIME ZONE DEFAULT NULL,
    p_expiration_date IN TIMESTAMP WITH LOCAL TIME ZONE DEFAULT NULL);
  PROCEDURE revoke_role(p_user_role_id IN NUMBER);
  -- First install only: grants AFH_ADMIN to p_subject while no active administrator exists,
  -- with no signed-in identity needed (run as the product schema). AFH-AUTH-002 once one exists.
  PROCEDURE bootstrap_admin(
    p_subject      IN VARCHAR2,
    p_display_name IN VARCHAR2 DEFAULT NULL,
    p_email        IN VARCHAR2 DEFAULT NULL);

  -- ----------------------------------------------------------------- crypto primitives (signed envelope)
  -- 32 random bytes from DBMS_CRYPTO.randombytes.
  FUNCTION new_secret RETURN RAW;
  -- HMAC-SHA256 of p_message (UTF-8) with p_key.
  FUNCTION hmac_sha256(p_key IN RAW, p_message IN VARCHAR2) RETURN RAW;
  -- Constant-time comparison of two RAW values of equal length.
  FUNCTION raw_equals(p_a IN RAW, p_b IN RAW) RETURN BOOLEAN;
  -- URL-safe base64 without padding, and its inverse.
  FUNCTION b64url_encode(p_raw IN RAW) RETURN VARCHAR2;
  FUNCTION b64url_decode(p_text IN VARCHAR2) RETURN RAW;
  -- SHA-256 hex digest of a BLOB (attachments) or string.
  FUNCTION sha256_hex(p_blob IN BLOB) RETURN VARCHAR2;
  FUNCTION sha256_hex(p_text IN VARCHAR2) RETURN VARCHAR2;

  -- ----------------------------------------------------------------- act as (development aid)
  -- Lets the signed-in session continue as another user, so a developer can test the product
  -- as a submitter, tester, developer, owner or administrator. Available only while the install
  -- setting ACT_AS_ENABLED is Y: seeded N, not editable from the admin UI, flipped by SQL on a
  -- development instance and never on a customer installation. Any signed-in user may switch
  -- (decision 010). The real subject is kept for the session (application item G_REAL_USER, or a
  -- package variable under test_mode) and every switch and revert is audited against it.
  FUNCTION  act_as_allowed RETURN BOOLEAN;
  FUNCTION  act_as_allowed_yn RETURN VARCHAR2;
  FUNCTION  real_subject RETURN VARCHAR2;          -- canonical subject that signed in (the acting one when not switched)
  FUNCTION  is_acting_yn RETURN VARCHAR2;          -- 'Y' while the session is switched to another user
  PROCEDURE act_as(p_user_id IN NUMBER);           -- AFH-AUTH-002 when not allowed, AFH-VAL-001 for an unknown or inactive user
  PROCEDURE act_as_revert;                         -- idempotent

  -- ----------------------------------------------------------------- test hook (compiled only under test_mode)
  $IF afh_compile_flags.test_mode $THEN
  PROCEDURE set_test_subject(p_subject IN VARCHAR2);
  PROCEDURE clear_test_subject;
  $END
END afh_security_pkg;
/
