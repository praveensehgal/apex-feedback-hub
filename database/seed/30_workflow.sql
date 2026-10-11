-- 30_workflow.sql — workflow statuses (spec §10.1) and the default transition matrix (spec §10.2).
-- Idempotent: MERGE on stable codes. Re-running updates labels/facts but never re-enables a
-- transition an administrator has disabled (is_active is left alone on match).
--
-- Column conventions for afh_workflow_transitions:
--   min_role_code   lowest cumulative role on the ladder USER < TESTER < DEVELOPER < APP_OWNER < AFH_ADMIN
--   alt_actors      comma list of predicates that may also act: REPORTER, ASSIGNED_TESTER, SYSTEM,
--                   DEV_OR_ADMIN_ONLY (explicit DEVELOPER grant or admin; replaces the ladder so an
--                   app owner without a developer grant is NOT allowed — spec §10.2 last row)
--   required_facts  comma list of fact tokens checked by afh_workflow_pkg before any write:
--                   QUEUE, ASSIGNEE, MASTER_TICKET, REASON, CLASSIFICATION, ROOT_CAUSE, RESOLUTION,
--                   TEST_REQUEST, RELEASE_OR_NOTE, TEST_PASSED, TEST_FAILED, EVIDENCE, UNLINK_DECISION
DECLARE
  PROCEDURE st(p_code IN VARCHAR2, p_label IN VARCHAR2, p_seq IN NUMBER, p_terminal IN VARCHAR2,
               p_color IN VARCHAR2, p_desc IN VARCHAR2) IS
  BEGIN
    MERGE INTO afh_workflow_statuses s
    USING (SELECT p_code AS status_code FROM dual) src
       ON (s.status_code = src.status_code)
     WHEN MATCHED THEN UPDATE
          SET s.label = p_label, s.display_seq = p_seq, s.is_terminal = p_terminal,
              s.color_token = p_color, s.description = p_desc
     WHEN NOT MATCHED THEN INSERT (status_code, label, display_seq, is_terminal, is_active, color_token, description)
          VALUES (p_code, p_label, p_seq, p_terminal, 'Y', p_color, p_desc);
  END;

  PROCEDURE tr(p_from IN VARCHAR2, p_to IN VARCHAR2, p_min_role IN VARCHAR2, p_alt IN VARCHAR2,
               p_facts IN VARCHAR2, p_reason_req IN VARCHAR2, p_label IN VARCHAR2, p_seq IN NUMBER,
               p_desc IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    MERGE INTO afh_workflow_transitions t
    USING (SELECT p_from AS from_status_code, p_to AS to_status_code FROM dual) src
       ON (t.from_status_code = src.from_status_code AND t.to_status_code = src.to_status_code)
     WHEN MATCHED THEN UPDATE
          SET t.min_role_code = p_min_role, t.alt_actors = p_alt, t.required_facts = p_facts,
              t.reason_required = p_reason_req, t.label = p_label, t.display_seq = p_seq,
              t.description = p_desc
     WHEN NOT MATCHED THEN INSERT (from_status_code, to_status_code, min_role_code, alt_actors, required_facts,
                                   reason_required, is_active, display_seq, label, description)
          VALUES (p_from, p_to, p_min_role, p_alt, p_facts, p_reason_req, 'Y', p_seq, p_label, p_desc);
  END;
BEGIN
  -- ------------------------------------------------------------------ statuses (spec §10.1)
  st('NEW',              'New',                     10, 'N', 'info',    'Submitted and waiting for triage.');
  st('UNDER_REVIEW',     'Under Review',            20, 'N', 'info',    'A developer is reviewing the report.');
  st('MORE_INFO',        'More Information Needed', 30, 'N', 'warning', 'Waiting for the reporter to answer a question.');
  st('ACCEPTED',         'Accepted',                40, 'N', 'info',    'Confirmed as valid work; classification is official.');
  st('PLANNED',          'Planned',                 50, 'N', 'info',    'Scheduled for a target release or planning note recorded.');
  st('IN_PROGRESS',      'In Progress',             60, 'N', 'info',    'Assigned and being worked on.');
  st('READY_TEST',       'Ready for Testing',       70, 'N', 'warning', 'A fix is ready and a test request is open.');
  st('RESOLVED',         'Resolved',                80, 'N', 'success', 'Validation passed; closes automatically after the configured delay.');
  st('CLOSED',           'Closed',                  90, 'Y', 'neutral', 'Work complete. Developers or administrators may reopen.');
  st('DUPLICATE',        'Duplicate',              100, 'Y', 'neutral', 'Merged into a master ticket.');
  st('REJECTED',         'Rejected',               110, 'Y', 'danger',  'Will not be addressed; a public reason was given.');
  st('CANNOT_REPRODUCE', 'Cannot Reproduce',       120, 'Y', 'danger',  'Could not be reproduced; a public reason was given.');
  st('REOPENED',         'Reopened',               130, 'N', 'warning', 'Reopened after resolution or closure; needs triage.');

  -- ------------------------------------------------------------------ transitions (spec §10.2)
  tr('NEW',          'UNDER_REVIEW',     'DEVELOPER', NULL,              'QUEUE',                              'N', 'Start review',        10, 'Assignee or owning queue');
  tr('NEW',          'DUPLICATE',        'DEVELOPER', NULL,              'MASTER_TICKET,REASON',               'N', 'Mark duplicate',      20, 'Master ticket and reason');

  tr('UNDER_REVIEW', 'MORE_INFO',        'DEVELOPER', NULL,              'REASON',                             'Y', 'Request information', 10, 'Public question and response task');
  tr('UNDER_REVIEW', 'ACCEPTED',         'DEVELOPER', NULL,              'CLASSIFICATION',                     'N', 'Accept',              20, 'Official classification confirmed');
  tr('UNDER_REVIEW', 'REJECTED',         'DEVELOPER', NULL,              'REASON',                             'Y', 'Reject',              30, 'Public reason');
  tr('UNDER_REVIEW', 'CANNOT_REPRODUCE', 'DEVELOPER', NULL,              'REASON',                             'Y', 'Cannot reproduce',    40, 'Reproduction notes and environment');
  tr('UNDER_REVIEW', 'DUPLICATE',        'DEVELOPER', NULL,              'MASTER_TICKET,REASON',               'N', 'Mark duplicate',      50, 'Master ticket and reason');

  tr('MORE_INFO',    'UNDER_REVIEW',     'DEVELOPER', 'SYSTEM',          NULL,                                 'N', 'Resume review',       10, 'System after reporter response, or developer; closes the response task');
  tr('MORE_INFO',    'REJECTED',         'DEVELOPER', NULL,              'REASON',                             'Y', 'Reject',              20, 'Public reason');
  tr('MORE_INFO',    'DUPLICATE',        'DEVELOPER', NULL,              'MASTER_TICKET,REASON',               'N', 'Mark duplicate',      30, 'Any nonterminal status -> Duplicate');

  tr('ACCEPTED',     'PLANNED',          'DEVELOPER', NULL,              'RELEASE_OR_NOTE',                    'N', 'Plan',                10, 'Target release or planning note');
  tr('ACCEPTED',     'IN_PROGRESS',      'DEVELOPER', NULL,              'ASSIGNEE',                           'N', 'Start work',          20, 'Assignee');
  tr('ACCEPTED',     'DUPLICATE',        'DEVELOPER', NULL,              'MASTER_TICKET,REASON',               'N', 'Mark duplicate',      30, 'Any nonterminal status -> Duplicate');

  tr('PLANNED',      'IN_PROGRESS',      'DEVELOPER', NULL,              'ASSIGNEE',                           'N', 'Start work',          10, 'Assignee');
  tr('PLANNED',      'DUPLICATE',        'DEVELOPER', NULL,              'MASTER_TICKET,REASON',               'N', 'Mark duplicate',      20, 'Any nonterminal status -> Duplicate');

  tr('IN_PROGRESS',  'READY_TEST',       'DEVELOPER', NULL,              'ROOT_CAUSE,RESOLUTION,TEST_REQUEST', 'N', 'Ready for testing',   10, 'Root cause, resolution, test request and target environment');
  tr('IN_PROGRESS',  'DUPLICATE',        'DEVELOPER', NULL,              'MASTER_TICKET,REASON',               'N', 'Mark duplicate',      20, 'Any nonterminal status -> Duplicate');

  tr('READY_TEST',   'IN_PROGRESS',      'DEVELOPER', 'ASSIGNED_TESTER', 'TEST_FAILED',                        'N', 'Test failed',         10, 'Failed test result and evidence');
  tr('READY_TEST',   'RESOLVED',         'DEVELOPER', 'ASSIGNED_TESTER', 'TEST_PASSED',                        'N', 'Test passed',         20, 'Passed test result');
  tr('READY_TEST',   'DUPLICATE',        'DEVELOPER', NULL,              'MASTER_TICKET,REASON',               'N', 'Mark duplicate',      30, 'Any nonterminal status -> Duplicate');

  tr('RESOLVED',     'CLOSED',           'DEVELOPER', 'SYSTEM',          'REASON',                             'N', 'Close',               10, 'Closure note, or the auto-close job after the configured delay');
  tr('RESOLVED',     'REOPENED',         'DEVELOPER', 'REPORTER,ASSIGNED_TESTER', 'REASON,EVIDENCE',           'Y', 'Reopen',              20, 'Reason and new evidence or explanation');
  tr('RESOLVED',     'DUPLICATE',        'DEVELOPER', NULL,              'MASTER_TICKET,REASON',               'N', 'Mark duplicate',      30, 'Any nonterminal status -> Duplicate');

  tr('REOPENED',     'UNDER_REVIEW',     'DEVELOPER', NULL,              NULL,                                 'N', 'Triage',              10, 'Triage acknowledgement');
  tr('REOPENED',     'IN_PROGRESS',      'DEVELOPER', NULL,              'ASSIGNEE',                           'N', 'Start work',          20, 'Assignee');
  tr('REOPENED',     'DUPLICATE',        'DEVELOPER', NULL,              'MASTER_TICKET,REASON',               'N', 'Mark duplicate',      30, 'Any nonterminal status -> Duplicate');

  tr('CLOSED',           'REOPENED',     'DEVELOPER', 'DEV_OR_ADMIN_ONLY', 'REASON',                           'Y', 'Reopen',              10, 'Developer or administrator only; reason');
  tr('REJECTED',         'REOPENED',     'DEVELOPER', 'DEV_OR_ADMIN_ONLY', 'REASON',                           'Y', 'Reopen',              10, 'Developer or administrator only; reason');
  tr('CANNOT_REPRODUCE', 'REOPENED',     'DEVELOPER', 'DEV_OR_ADMIN_ONLY', 'REASON',                           'Y', 'Reopen',              10, 'Developer or administrator only; reason');
  tr('DUPLICATE',        'REOPENED',     'DEVELOPER', 'DEV_OR_ADMIN_ONLY', 'REASON,UNLINK_DECISION',           'Y', 'Reopen',              10, 'Developer or administrator only; reason and unlink decision');
END;
/
