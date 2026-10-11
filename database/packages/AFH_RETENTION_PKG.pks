CREATE OR REPLACE PACKAGE afh_retention_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_RETENTION_PKG — archive policy, attachment cleanup, hard-delete
  -- controls, storage summaries, and run reporting. Spec §11.5, WU-14.
  -- Admin only for everything destructive. Archive never deletes identity.
  -- ---------------------------------------------------------------------------

  c_policy_archive_closed CONSTANT VARCHAR2(30) := 'ARCHIVE_CLOSED';   -- closed/terminal older than ARCHIVE_AFTER_DAYS -> is_archived
  c_policy_purge_attach   CONSTANT VARCHAR2(30) := 'PURGE_ATTACHMENTS'; -- attachments on archived tickets older than DEFAULT_RETENTION_DAYS -> bytes removed, row kept
  c_policy_delete_tickets CONSTANT VARCHAR2(30) := 'DELETE_TICKETS';   -- archived tickets older than DEFAULT_RETENTION_DAYS -> hard delete with surviving audit

  -- Admin: archive / unarchive one ticket (audit TICKET_ARCHIVE_CHANGED).
  PROCEDURE archive_ticket(p_ticket_id IN NUMBER, p_reason IN VARCHAR2 DEFAULT NULL);
  PROCEDURE unarchive_ticket(p_ticket_id IN NUMBER);

  -- Preview a policy: counts and bytes only, no mutation except the PREVIEW run row.
  -- Returns retention_run_id; detail_json lists the first 100 ticket numbers affected.
  FUNCTION preview(p_policy_code IN VARCHAR2) RETURN NUMBER;

  -- Execute a policy. p_confirmation must be the literal 'DELETE' for DELETE_TICKETS and
  -- PURGE_ATTACHMENTS, 'ARCHIVE' for ARCHIVE_CLOSED; anything else raises AFH-VAL-001.
  -- Writes the EXECUTE run row first, then for each ticket a surviving non-public audit
  -- event (entity RETENTION_RUN, ticket facts without content) BEFORE deleting. Commits
  -- per batch of 50 when p_commit_batches = 'Y' (job use); otherwise caller commits.
  FUNCTION execute_policy(
    p_policy_code    IN VARCHAR2,
    p_confirmation   IN VARCHAR2,
    p_commit_batches IN VARCHAR2 DEFAULT 'N') RETURN NUMBER;

  -- Scheduled entry: runs preview for every policy; executes only when config
  -- RETENTION_JOB_ARMED = 'Y'.
  PROCEDURE scheduled_run;

  -- Storage summary for Page 66
  TYPE t_storage IS RECORD (
    kind_code        VARCHAR2(30 CHAR),
    file_count       NUMBER,
    total_bytes      NUMBER,
    restricted_count NUMBER,
    oldest_at        TIMESTAMP WITH LOCAL TIME ZONE);
  TYPE t_storage_tab IS TABLE OF t_storage;
  FUNCTION storage_summary RETURN t_storage_tab PIPELINED;
END afh_retention_pkg;
/
