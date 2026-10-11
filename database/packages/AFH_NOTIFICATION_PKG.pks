CREATE OR REPLACE PACKAGE afh_notification_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_NOTIFICATION_PKG — follows and mutes, preference presets and overrides,
  -- in-app events, mail rendering, mail worker, digests, retries.
  -- Spec §19, WU-12. Mail transport is controlled by config MAIL_ENABLED.
  -- ---------------------------------------------------------------------------

  -- Event codes (PRD §7.9)
  c_ev_new_ticket     CONSTANT VARCHAR2(30) := 'NEW_TICKET';
  c_ev_assignment     CONSTANT VARCHAR2(30) := 'ASSIGNMENT';
  c_ev_mention        CONSTANT VARCHAR2(30) := 'MENTION';
  c_ev_comment        CONSTANT VARCHAR2(30) := 'COMMENT';
  c_ev_info_request   CONSTANT VARCHAR2(30) := 'INFO_REQUEST';
  c_ev_info_response  CONSTANT VARCHAR2(30) := 'INFO_RESPONSE';
  c_ev_status_change  CONSTANT VARCHAR2(30) := 'STATUS_CHANGE';
  c_ev_priority       CONSTANT VARCHAR2(30) := 'PRIORITY_CHANGE';
  c_ev_release        CONSTANT VARCHAR2(30) := 'RELEASE_CHANGE';
  c_ev_ready_test     CONSTANT VARCHAR2(30) := 'READY_TEST';
  c_ev_test_request   CONSTANT VARCHAR2(30) := 'TEST_REQUEST';
  c_ev_test_outcome   CONSTANT VARCHAR2(30) := 'TEST_OUTCOME';
  c_ev_resolution     CONSTANT VARCHAR2(30) := 'RESOLUTION';
  c_ev_closure        CONSTANT VARCHAR2(30) := 'CLOSURE';
  c_ev_reopened       CONSTANT VARCHAR2(30) := 'REOPENED';
  c_ev_merge          CONSTANT VARCHAR2(30) := 'DUPLICATE_MERGE';

  -- Presets (spec §19.1)
  c_preset_immediate CONSTANT VARCHAR2(30) := 'IMMEDIATE';
  c_preset_important CONSTANT VARCHAR2(30) := 'IMPORTANT';
  c_preset_daily     CONSTANT VARCHAR2(30) := 'DAILY';
  c_preset_weekly    CONSTANT VARCHAR2(30) := 'WEEKLY';
  c_preset_in_app    CONSTANT VARCHAR2(30) := 'IN_APP';

  -- "Important" events: ASSIGNMENT, MENTION, INFO_REQUEST, TEST_REQUEST, RESOLUTION, REOPENED.
  FUNCTION is_important_event(p_event_code IN VARCHAR2) RETURN BOOLEAN;
  -- "Direct urgent" events for digest presets: ASSIGNMENT, INFO_REQUEST, TEST_REQUEST, MENTION.
  FUNCTION is_direct_event(p_event_code IN VARCHAR2) RETURN BOOLEAN;

  -- ----------------------------------------------------------------- follows (any authenticated user)
  PROCEDURE follow(p_ticket_id IN NUMBER, p_user_id IN NUMBER DEFAULT NULL, p_source_code IN VARCHAR2 DEFAULT 'MANUAL');  -- idempotent
  -- Refused (AFH-VAL-001) while the user owns an open ASSIGNMENT or INFO_REQUEST task on the ticket.
  -- Follow as a consequence of a role on the ticket (assignment): follows when needed and
  -- clears any mute, because an assignee always receives the ticket's notifications.
  PROCEDURE follow_required(p_ticket_id IN NUMBER, p_user_id IN NUMBER, p_source_code IN VARCHAR2);
  -- Refused for the ticket's current assignee (AFH-VAL-001), and while an ASSIGNMENT or
  -- INFO_REQUEST task is open for the user.
  PROCEDURE unfollow(p_ticket_id IN NUMBER);
  PROCEDURE set_mute(p_ticket_id IN NUMBER, p_is_muted IN VARCHAR2);   -- follows first when not following
  FUNCTION  is_following(p_ticket_id IN NUMBER, p_user_id IN NUMBER DEFAULT NULL) RETURN BOOLEAN;
  FUNCTION  is_muted(p_ticket_id IN NUMBER, p_user_id IN NUMBER DEFAULT NULL) RETURN BOOLEAN;

  -- ----------------------------------------------------------------- preferences (current user)
  PROCEDURE set_preset(p_preset_code IN VARCHAR2, p_application_id IN NUMBER DEFAULT NULL);   -- NULL app = global
  PROCEDURE clear_preset(p_application_id IN NUMBER);                                          -- remove per-app preset
  PROCEDURE set_event_override(
    p_event_code     IN VARCHAR2,
    p_email_enabled  IN VARCHAR2,
    p_in_app_enabled IN VARCHAR2,
    p_application_id IN NUMBER DEFAULT NULL);
  PROCEDURE clear_event_override(p_event_code IN VARCHAR2, p_application_id IN NUMBER DEFAULT NULL);
  FUNCTION  effective_preset(p_application_id IN NUMBER DEFAULT NULL, p_user_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;

  -- Spec §19.1 precedence, evaluated top-down and returning at the first deciding rule:
  -- 1 mandatory task -> in_app Y; 2 per-ticket mute; 3 per-app+event override; 4 per-event
  -- override; 5 per-app preset; 6 global preset; 7 config DEFAULT_NOTIFY_PRESET.
  PROCEDURE resolve_channels(
    p_user_id        IN  NUMBER,
    p_ticket_id      IN  NUMBER,
    p_event_code     IN  VARCHAR2,
    p_is_direct_task IN  VARCHAR2,          -- 'Y' for ASSIGNMENT / INFO_REQUEST / TEST_REQUEST to the target user
    o_in_app         OUT VARCHAR2,          -- 'Y'/'N'
    o_email          OUT VARCHAR2,          -- 'Y'/'N' (immediate)
    o_digest         OUT VARCHAR2);         -- NONE | DAILY | WEEKLY

  -- ----------------------------------------------------------------- raising events (package code)
  -- Fan out one event: recipients = p_target_user_id (direct) plus active followers of
  -- the ticket, minus the actor (unless p_notify_actor='Y'), each through resolve_channels.
  -- Creates IN_APP rows (state NEW), EMAIL rows (state QUEUED), DIGEST rows (state NEW).
  -- Restricted facts are never placed in subject/body. Runs in the caller's transaction.
  PROCEDURE raise_event(
    p_event_code     IN VARCHAR2,
    p_ticket_id      IN NUMBER,
    p_target_user_id IN NUMBER   DEFAULT NULL,
    p_task_id        IN NUMBER   DEFAULT NULL,
    p_summary        IN VARCHAR2 DEFAULT NULL,    -- short safe text, e.g. 'Status changed to Accepted'
    p_notify_actor   IN VARCHAR2 DEFAULT 'N');

  -- ----------------------------------------------------------------- in-app (current user)
  PROCEDURE mark_read(p_notification_id IN NUMBER);
  PROCEDURE mark_all_read;
  FUNCTION  unread_count(p_user_id IN NUMBER DEFAULT NULL) RETURN NUMBER;

  -- ----------------------------------------------------------------- templates and rendering
  -- Render subject/body for an event using afh_notification_templates (#TICKET_NO#,
  -- #TITLE#, #STATUS#, #ACTOR#, #APPLICATION#, #SUMMARY#, #LINK#, #RECIPIENT#; DIGEST
  -- channel also #ITEMS#). Falls back to a built-in plain template when none is active.
  PROCEDURE render(
    p_event_code   IN  VARCHAR2,
    p_channel_code IN  VARCHAR2,
    p_ticket_id    IN  NUMBER,
    p_recipient_id IN  NUMBER,
    p_summary      IN  VARCHAR2,
    o_subject      OUT VARCHAR2,
    o_body         OUT CLOB);
  -- Hub link for a ticket: config BASE_URL || 'f?p=' || FEEDBACK_APP_ID || ':10::::10:P10_TICKET_NO:' || no
  FUNCTION ticket_link(p_ticket_id IN NUMBER) RETURN VARCHAR2;
  -- Admin template maintenance (audit TEMPLATE_CHANGED)
  PROCEDURE upsert_template(
    p_event_code       IN VARCHAR2,
    p_channel_code     IN VARCHAR2,
    p_subject_template IN VARCHAR2,
    p_body_template    IN CLOB,
    p_is_active        IN VARCHAR2 DEFAULT 'Y',
    p_description      IN VARCHAR2 DEFAULT NULL);

  -- ----------------------------------------------------------------- delivery (jobs)
  -- Process QUEUED EMAIL rows oldest first: MAIL_ENABLED='N' -> SKIPPED_DISABLED;
  -- otherwise APEX_MAIL.SEND inside an APEX session for FEEDBACK_APP_ID; transient failure
  -- increments delivery_attempts (<= MAIL_MAX_RETRIES) and requeues, permanent failure ->
  -- FAILED + integration MAIL event. Commits per row (job context).
  PROCEDURE process_mail_queue(p_max_rows IN PLS_INTEGER DEFAULT 200);
  -- Admin: put a FAILED e-mail back on the queue (attempts reset); audits NOTIFICATION_REQUEUED.
  PROCEDURE requeue(p_notification_id IN NUMBER);

  -- One digest mail per user with NEW DIGEST rows of p_frequency; marks rows DIGESTED.
  PROCEDURE send_digests(p_frequency IN VARCHAR2);   -- DAILY | WEEKLY
END afh_notification_pkg;
/
