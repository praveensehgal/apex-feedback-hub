CREATE OR REPLACE PACKAGE afh_notification_int_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_NOTIFICATION_INT_PKG — private helpers for AFH_NOTIFICATION_PKG:
  -- channel decision core (SQL-callable for AFH_V_NOTIFICATION_PREFS), template
  -- rendering, mail transport, digest assembly, and batch-commit control.
  -- Not a public API: APEX pages and other packages call AFH_NOTIFICATION_PKG.
  -- Spec §19, WU-12. Split from the main body to respect the 800-line file rule.
  -- ---------------------------------------------------------------------------

  c_channel_in_app CONSTANT VARCHAR2(30) := 'IN_APP';
  c_channel_email  CONSTANT VARCHAR2(30) := 'EMAIL';
  c_channel_digest CONSTANT VARCHAR2(30) := 'DIGEST';
  c_ev_digest      CONSTANT VARCHAR2(30) := 'DIGEST';   -- event code of the digest mail itself

  c_link_unavailable CONSTANT VARCHAR2(80) := '(link unavailable until BASE_URL is configured)';

  -- Every event code the package accepts (PRD §7.9 list).
  FUNCTION is_known_event(p_event_code IN VARCHAR2) RETURN BOOLEAN;
  -- Human label for an event code ('Assigned to you', 'New comment', ...). SQL-safe.
  FUNCTION event_label(p_event_code IN VARCHAR2) RETURN VARCHAR2;

  -- ----------------------------------------------------------------- decision core
  -- Spec §19.1 precedence with the application supplied directly (the public
  -- resolve_channels derives it from the ticket). p_ticket_id NULL = no mute lookup.
  PROCEDURE resolve_core(
    p_user_id        IN  NUMBER,
    p_application_id IN  NUMBER,
    p_ticket_id      IN  NUMBER,
    p_event_code     IN  VARCHAR2,
    p_is_direct_task IN  VARCHAR2,
    o_in_app         OUT VARCHAR2,
    o_email          OUT VARCHAR2,
    o_digest         OUT VARCHAR2);
  -- SQL wrapper for views: the decision for one channel ('IN_APP' -> Y/N,
  -- 'EMAIL' -> Y/N, 'DIGEST' -> NONE/DAILY/WEEKLY) for a hypothetical non-direct,
  -- non-muted event of p_event_code in p_application_id (NULL = global scope).
  FUNCTION channel_decision(
    p_user_id        IN NUMBER,
    p_application_id IN NUMBER,
    p_event_code     IN VARCHAR2,
    p_channel_code   IN VARCHAR2) RETURN VARCHAR2;

  -- ----------------------------------------------------------------- rendering
  -- Same contract as afh_notification_pkg.render plus p_items for the DIGEST mail.
  -- p_ticket_id may be NULL (digest): ticket placeholders render empty.
  PROCEDURE render_core(
    p_event_code   IN  VARCHAR2,
    p_channel_code IN  VARCHAR2,
    p_ticket_id    IN  NUMBER,
    p_recipient_id IN  NUMBER,
    p_summary      IN  VARCHAR2,
    p_items        IN  CLOB,
    o_subject      OUT VARCHAR2,
    o_body         OUT CLOB);
  FUNCTION ticket_link(p_ticket_id IN NUMBER) RETURN VARCHAR2;
  -- Relative in-app link for afh_notifications.link_target.
  FUNCTION in_app_link(p_ticket_no IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION product_name RETURN VARCHAR2;

  -- ----------------------------------------------------------------- delivery
  -- Deliver one QUEUED EMAIL row through APEX_MAIL inside an existing APEX session.
  -- Updates the row to SENT, or records the attempt (QUEUED again / FAILED).
  -- Never raises; the caller commits.
  PROCEDURE deliver_one(p_notification_id IN NUMBER, p_max_retries IN PLS_INTEGER);
  PROCEDURE mark_skipped_disabled(p_notification_id IN NUMBER);
  -- SENT e-mails whose APEX_MAIL_LOG row carries a relay error become FAILED (with the reason).
  PROCEDURE reconcile_relay(p_max_rows IN PLS_INTEGER DEFAULT 500);
  -- Build the digest mail for one recipient and mark the NEW DIGEST rows DIGESTED
  -- (or CANCELLED when the user has no e-mail address). Never sends the same row twice.
  PROCEDURE digest_for_user(p_user_id IN NUMBER, p_frequency IN VARCHAR2);

  -- Batch commit used by the job entry points (process_mail_queue, send_digests).
  -- Under test_mode the test suite disables it so the harness can roll back.
  PROCEDURE batch_commit;
  $IF afh_compile_flags.test_mode $THEN
  PROCEDURE set_batch_commit(p_enabled IN BOOLEAN);
  $END
END afh_notification_int_pkg;
/
