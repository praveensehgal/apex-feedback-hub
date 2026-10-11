CREATE OR REPLACE PACKAGE afh_ticket_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_TICKET_PKG — ticket creation, type-specific field validation,
  -- classification, assignment, relationships, affected users, archive state,
  -- optimistic locking. Spec §11.5, §14, WU-04.
  -- Followers and mutes live in afh_notification_pkg (spec §12 "follows").
  -- Every mutator takes p_row_version and raises AFH-LOCK-001 on mismatch.
  -- ---------------------------------------------------------------------------

  -- Audit event codes written by this package (also used by the timeline view)
  c_ev_created        CONSTANT VARCHAR2(30) := 'TICKET_CREATED';
  c_ev_details        CONSTANT VARCHAR2(30) := 'TICKET_DETAILS_CHANGED';
  c_ev_fields         CONSTANT VARCHAR2(30) := 'TICKET_FIELDS_CHANGED';
  c_ev_classified     CONSTANT VARCHAR2(30) := 'TICKET_CLASSIFIED';
  c_ev_assigned       CONSTANT VARCHAR2(30) := 'TICKET_ASSIGNED';
  c_ev_owner          CONSTANT VARCHAR2(30) := 'TICKET_OWNER_CHANGED';
  c_ev_release        CONSTANT VARCHAR2(30) := 'TICKET_RELEASE_CHANGED';
  c_ev_due            CONSTANT VARCHAR2(30) := 'TICKET_DUE_CHANGED';
  c_ev_relation       CONSTANT VARCHAR2(30) := 'TICKET_RELATION_CHANGED';
  c_ev_affected       CONSTANT VARCHAR2(30) := 'TICKET_AFFECTED_CHANGED';
  c_ev_archived       CONSTANT VARCHAR2(30) := 'TICKET_ARCHIVE_CHANGED';
  c_ev_resolution     CONSTANT VARCHAR2(30) := 'TICKET_RESOLUTION_CHANGED';

  -- Public ticket number for a sequence value: 'FB-' || LPAD(n, 4, '0') (never truncated above 9999).
  FUNCTION format_ticket_no(p_seq IN NUMBER) RETURN VARCHAR2;
  -- ticket_id for a public number (case-insensitive, tolerant of a missing 'FB-' prefix); NULL if none.
  FUNCTION get_ticket_id(p_ticket_no IN VARCHAR2) RETURN NUMBER;
  -- application_id of a ticket (used by authorization helpers).
  FUNCTION application_id_of(p_ticket_id IN NUMBER) RETURN NUMBER;
  FUNCTION status_code_of(p_ticket_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION row_version_of(p_ticket_id IN NUMBER) RETURN NUMBER;

  -- Lock the ticket row FOR UPDATE and verify p_row_version; raises AFH-LOCK-001.
  -- Shared by workflow/comment/search packages so every mutation goes through one gate.
  PROCEDURE lock_ticket(p_ticket_id IN NUMBER, p_row_version IN NUMBER);
  -- Increment row_version and touch last_activity_at (call after any ticket mutation).
  PROCEDURE bump_version(p_ticket_id IN NUMBER);

  -- ----------------------------------------------------------------- creation (spec §14.3)
  -- One transaction creates: ticket + number, field values, routing owner/assignee,
  -- reporter follower (p_follow_yn), assignment task, audit TICKET_CREATED, NEW_TICKET
  -- notifications. The launch handoff is NOT consumed here: the caller calls
  -- afh_launch_pkg.consume(p_correlation_id, ticket_id) in the same transaction
  -- (afh_submit_pkg.submit does), which is what makes the retry below idempotent.
  -- Context, attachments and the integration success event are added by the caller
  -- (afh_context_pkg.store_context, afh_attachment_pkg.add_from_apex_collection,
  -- afh_launch_pkg.consume) in the SAME transaction; the page process commits.
  -- p_field_values_json: {"FIELD_CODE":"value", ...} validated against the active
  -- metadata for p_type_code (required fields, data types, lengths).
  -- Raises AFH-VAL-001 with a field-level message on validation failure.
  -- Idempotency: if p_correlation_id already produced a ticket, returns that ticket_id
  -- and makes no change.
  FUNCTION create_ticket(
    p_type_code               IN VARCHAR2,
    p_title                   IN VARCHAR2,
    p_description             IN CLOB,
    p_application_id          IN NUMBER,
    p_environment_id          IN NUMBER,
    p_page_id                 IN NUMBER,
    p_page_name               IN VARCHAR2,
    p_source_url              IN VARCHAR2,
    p_app_version             IN VARCHAR2,
    p_category_id             IN NUMBER,
    p_proposed_priority_code  IN VARCHAR2,
    p_proposed_severity_code  IN VARCHAR2,
    p_proposed_impact_code    IN VARCHAR2,
    p_field_values_json       IN CLOB     DEFAULT NULL,
    p_follow_yn               IN VARCHAR2 DEFAULT 'Y',
    p_context_result_code     IN VARCHAR2 DEFAULT 'NONE',
    p_correlation_id          IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

  -- ----------------------------------------------------------------- details
  -- Reporter while status is NEW, or developer+ for the ticket's application.
  PROCEDURE update_details(
    p_ticket_id          IN NUMBER,
    p_row_version        IN NUMBER,
    p_title              IN VARCHAR2,
    p_description        IN CLOB,
    p_category_id        IN NUMBER,
    p_field_values_json  IN CLOB DEFAULT NULL);

  -- Developer / app owner / admin. Proposed values are never touched.
  PROCEDURE set_classification(
    p_ticket_id     IN NUMBER,
    p_row_version   IN NUMBER,
    p_priority_code IN VARCHAR2,
    p_severity_code IN VARCHAR2,
    p_impact_code   IN VARCHAR2,
    p_type_code     IN VARCHAR2 DEFAULT NULL);   -- official type change re-validates fields

  -- Developer / app owner / admin. Creates/cancels the ASSIGNMENT task and ASSIGNMENT event.
  PROCEDURE assign(
    p_ticket_id        IN NUMBER,
    p_row_version      IN NUMBER,
    p_assignee_user_id IN NUMBER,          -- NULL unassigns
    p_due_date         IN TIMESTAMP WITH LOCAL TIME ZONE DEFAULT NULL);

  PROCEDURE set_owner(p_ticket_id IN NUMBER, p_row_version IN NUMBER, p_owner_user_id IN NUMBER);
  PROCEDURE set_release(p_ticket_id IN NUMBER, p_row_version IN NUMBER, p_release_id IN NUMBER);
  PROCEDURE set_due_date(p_ticket_id IN NUMBER, p_row_version IN NUMBER, p_due_date IN TIMESTAMP WITH LOCAL TIME ZONE);
  PROCEDURE set_resolution(
    p_ticket_id   IN NUMBER,
    p_row_version IN NUMBER,
    p_root_cause  IN CLOB,
    p_resolution  IN CLOB);

  -- ----------------------------------------------------------------- relations (developer+ ; RELATED also by reporter)
  FUNCTION add_relation(
    p_source_ticket_id IN NUMBER,
    p_target_ticket_id IN NUMBER,
    p_relation_code    IN VARCHAR2,   -- RELATED | DEPENDS_ON | BLOCKS (DUPLICATE_OF only via afh_workflow_pkg.merge_duplicate)
    p_reason           IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  PROCEDURE remove_relation(p_ticket_relation_id IN NUMBER);
  -- TRUE when adding source->target of p_relation_code would create a cycle.
  FUNCTION would_create_cycle(p_source_ticket_id IN NUMBER, p_target_ticket_id IN NUMBER, p_relation_code IN VARCHAR2) RETURN BOOLEAN;

  -- ----------------------------------------------------------------- affected users (any authenticated user)
  PROCEDURE mark_affected(p_ticket_id IN NUMBER, p_comment_text IN VARCHAR2 DEFAULT NULL);  -- idempotent; auto-follows
  PROCEDURE unmark_affected(p_ticket_id IN NUMBER);
  FUNCTION  is_affected(p_ticket_id IN NUMBER) RETURN BOOLEAN;
  -- TRUE when the current user is the ticket's assignee (page conditions: an assignee
  -- always follows the ticket and cannot mute it).
  FUNCTION  is_assignee(p_ticket_id IN NUMBER) RETURN BOOLEAN;
  FUNCTION  affected_count(p_ticket_id IN NUMBER) RETURN NUMBER;

  -- ----------------------------------------------------------------- archive (admin) and views
  PROCEDURE set_archived(p_ticket_id IN NUMBER, p_is_archived IN VARCHAR2);
  -- Upsert afh_ticket_views for the current user (call from Ticket Detail page load).
  PROCEDURE record_view(p_ticket_id IN NUMBER);

  -- ----------------------------------------------------------------- metadata helpers for pages
  -- Validate a field-values document against type metadata without saving (Page 20 step 1).
  PROCEDURE validate_field_values(p_type_code IN VARCHAR2, p_field_values_json IN CLOB);
  -- Active type-specific field definitions for a type as JSON array for the modal
  -- [{"code","label","dataType","required","maxLength","helpText","lov":[...]}]
  FUNCTION type_fields_json(p_type_code IN VARCHAR2) RETURN CLOB;
END afh_ticket_pkg;
/
