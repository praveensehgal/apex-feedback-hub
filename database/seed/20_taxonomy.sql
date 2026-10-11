-- 20_taxonomy.sql — feedback types, reusable fields, type->field bindings, classification
-- values, global categories, and the two statuses a new ticket needs (NEW, UNDER_REVIEW).
-- Idempotent: every MERGE is keyed on the stable code. Labels/sequence/help text are
-- updated on re-run; codes and is_active are never touched (admin deactivations survive).
-- Spec §11.2, PRD §7.2, WU-04.

-- ---------------------------------------------------------------- feedback types
MERGE INTO afh_feedback_types t
USING (
  SELECT 'BUG'         AS type_code, 'Bug or defect'                       AS label, 'fa-bug'              AS icon_token, 10 AS display_seq, 'Something is broken, wrong, or not working as designed.'                    AS help_text FROM dual UNION ALL
  SELECT 'FEATURE',                  'New feature request',                          'fa-lightbulb-o',                   20,               'Ask for a capability the application does not have today.'                               FROM dual UNION ALL
  SELECT 'ENHANCEMENT',              'Enhancement to an existing feature',           'fa-wrench',                        30,               'Suggest an improvement to something that already exists.'                                FROM dual UNION ALL
  SELECT 'USABILITY',                'Usability or accessibility issue',             'fa-universal-access',              40,               'Report something that is hard to use, confusing, or not accessible.'                    FROM dual UNION ALL
  SELECT 'DATA',                     'Data or reporting issue',                      'fa-table',                         50,               'Report a figure, record, or report that looks incorrect or incomplete.'                 FROM dual UNION ALL
  SELECT 'PERFORMANCE',              'Performance issue',                            'fa-tachometer',                    60,               'Report a page or action that is slow or times out.'                                     FROM dual UNION ALL
  SELECT 'QUESTION',                 'Question or support request',                  'fa-question-circle',               70,               'Ask how to do something or request help.'                                                FROM dual UNION ALL
  SELECT 'GENERAL',                  'General feedback',                             'fa-comment',                       80,               'Share an observation, a compliment, or a suggestion that fits no other type.'            FROM dual
) s
ON (t.type_code = s.type_code)
WHEN MATCHED THEN UPDATE SET t.label = s.label, t.icon_token = s.icon_token, t.display_seq = s.display_seq, t.help_text = s.help_text
WHEN NOT MATCHED THEN INSERT (type_code, label, icon_token, display_seq, help_text, is_active)
  VALUES (s.type_code, s.label, s.icon_token, s.display_seq, s.help_text, 'Y');

-- ---------------------------------------------------------------- field definitions
MERGE INTO afh_field_definitions t
USING (
  SELECT 'EXPECTED'         AS field_code, 'Expected behavior'             AS label, 'TEXTAREA' AS data_type, 4000 AS max_length, 'What did you expect to happen?'                                   AS help_text, CAST(NULL AS VARCHAR2(4000)) AS lov_values FROM dual UNION ALL
  SELECT 'ACTUAL',                         'Actual behavior',                        'TEXTAREA',              4000,               'What happened instead?',                                                    NULL FROM dual UNION ALL
  SELECT 'STEPS',                          'Steps to reproduce',                     'TEXTAREA',              8000,               'List the steps, one per line, that lead to the problem.',                   NULL FROM dual UNION ALL
  SELECT 'FREQUENCY',                      'How often does it happen?',              'SELECT',                NULL,               'Choose the option that best matches your experience.',                      'ALWAYS:Every time;OFTEN:Often;SOMETIMES:Sometimes;ONCE:Once' FROM dual UNION ALL
  SELECT 'IMPACT_DESC',                    'Impact on your work',                    'TEXTAREA',              2000,               'How does this affect what you are trying to do?',                           NULL FROM dual UNION ALL
  SELECT 'DESIRED_OUTCOME',                'Desired outcome',                        'TEXTAREA',              4000,               'Describe what you would like to be able to do.',                            NULL FROM dual UNION ALL
  SELECT 'WORKAROUND',                     'Current workaround',                     'TEXTAREA',              2000,               'How do you get the job done today, if at all?',                             NULL FROM dual UNION ALL
  SELECT 'BUSINESS_VALUE',                 'Business value',                         'TEXTAREA',              2000,               'Why does this matter? Who benefits and how?',                               NULL FROM dual UNION ALL
  SELECT 'AFFECTED_USERS',                 'Affected users or process',              'TEXT',                  500,                'Which people, teams, or processes are affected?',                           NULL FROM dual UNION ALL
  SELECT 'CURRENT_BEHAVIOR',               'Current behavior',                       'TEXTAREA',              4000,               'How does the feature work today?',                                          NULL FROM dual UNION ALL
  SELECT 'PROPOSED_CHANGE',                'Proposed change',                        'TEXTAREA',              4000,               'How should it work instead?',                                               NULL FROM dual UNION ALL
  SELECT 'ASSISTIVE_TECH',                 'Assistive technology or device',         'TEXT',                  255,                'Screen reader, magnifier, keyboard-only, mobile device, and so on.',        NULL FROM dual UNION ALL
  SELECT 'EXPECTED_DATA',                  'Expected data or figure',                'TEXTAREA',              2000,               'What value or records should appear?',                                      NULL FROM dual UNION ALL
  SELECT 'ACTUAL_DATA',                    'Actual data or figure',                  'TEXTAREA',              2000,               'What value or records appear instead?',                                     NULL FROM dual UNION ALL
  SELECT 'REPORT_NAME',                    'Report or screen name',                  'TEXT',                  255,                'Name of the report, chart, or screen showing the issue.',                   NULL FROM dual UNION ALL
  SELECT 'SLOW_ACTION',                    'Action that is slow',                    'TEXT',                  500,                'Which click, search, save, or page load is slow?',                          NULL FROM dual UNION ALL
  SELECT 'DURATION_SEC',                   'Observed duration (seconds)',            'NUMBER',                NULL,               'Roughly how many seconds did it take?',                                     NULL FROM dual UNION ALL
  SELECT 'RECORD_COUNT',                   'Approximate record count',               'NUMBER',                NULL,               'About how many rows or records were involved?',                             NULL FROM dual UNION ALL
  SELECT 'QUESTION_TEXT',                  'Your question',                          'TEXTAREA',              4000,               'Ask your question in as much detail as you can.',                           NULL FROM dual UNION ALL
  SELECT 'URGENCY',                        'Urgency',                                'SELECT',                NULL,               'How soon do you need an answer?',                                           'LOW:Low;NORMAL:Normal;HIGH:High' FROM dual
) s
ON (t.field_code = s.field_code)
WHEN MATCHED THEN UPDATE SET t.label = s.label, t.data_type = s.data_type, t.max_length = s.max_length, t.help_text = s.help_text, t.lov_values = s.lov_values
WHEN NOT MATCHED THEN INSERT (field_code, label, data_type, max_length, help_text, lov_values, is_active)
  VALUES (s.field_code, s.label, s.data_type, s.max_length, s.help_text, s.lov_values, 'Y');

-- ---------------------------------------------------------------- type -> field bindings
MERGE INTO afh_type_fields t
USING (
  SELECT ft.feedback_type_id, fd.field_definition_id, b.is_required, b.display_seq
    FROM (
      SELECT 'BUG'         AS type_code, 'EXPECTED'         AS field_code, 'Y' AS is_required, 10 AS display_seq FROM dual UNION ALL
      SELECT 'BUG',                      'ACTUAL',                         'Y',                20 FROM dual UNION ALL
      SELECT 'BUG',                      'STEPS',                          'Y',                30 FROM dual UNION ALL
      SELECT 'BUG',                      'FREQUENCY',                      'Y',                40 FROM dual UNION ALL
      SELECT 'BUG',                      'IMPACT_DESC',                    'N',                50 FROM dual UNION ALL
      SELECT 'FEATURE',                  'DESIRED_OUTCOME',                'Y',                10 FROM dual UNION ALL
      SELECT 'FEATURE',                  'WORKAROUND',                     'N',                20 FROM dual UNION ALL
      SELECT 'FEATURE',                  'BUSINESS_VALUE',                 'Y',                30 FROM dual UNION ALL
      SELECT 'FEATURE',                  'AFFECTED_USERS',                 'N',                40 FROM dual UNION ALL
      SELECT 'ENHANCEMENT',              'CURRENT_BEHAVIOR',               'Y',                10 FROM dual UNION ALL
      SELECT 'ENHANCEMENT',              'PROPOSED_CHANGE',                'Y',                20 FROM dual UNION ALL
      SELECT 'ENHANCEMENT',              'BUSINESS_VALUE',                 'N',                30 FROM dual UNION ALL
      SELECT 'USABILITY',                'EXPECTED',                       'Y',                10 FROM dual UNION ALL
      SELECT 'USABILITY',                'ACTUAL',                         'Y',                20 FROM dual UNION ALL
      SELECT 'USABILITY',                'ASSISTIVE_TECH',                 'N',                30 FROM dual UNION ALL
      SELECT 'DATA',                     'REPORT_NAME',                    'Y',                10 FROM dual UNION ALL
      SELECT 'DATA',                     'EXPECTED_DATA',                  'Y',                20 FROM dual UNION ALL
      SELECT 'DATA',                     'ACTUAL_DATA',                    'Y',                30 FROM dual UNION ALL
      SELECT 'PERFORMANCE',              'SLOW_ACTION',                    'Y',                10 FROM dual UNION ALL
      SELECT 'PERFORMANCE',              'DURATION_SEC',                   'N',                20 FROM dual UNION ALL
      SELECT 'PERFORMANCE',              'RECORD_COUNT',                   'N',                30 FROM dual UNION ALL
      SELECT 'PERFORMANCE',              'FREQUENCY',                      'Y',                40 FROM dual UNION ALL
      SELECT 'QUESTION',                 'QUESTION_TEXT',                  'Y',                10 FROM dual UNION ALL
      SELECT 'QUESTION',                 'URGENCY',                        'N',                20 FROM dual
    ) b
    JOIN afh_feedback_types    ft ON ft.type_code  = b.type_code
    JOIN afh_field_definitions fd ON fd.field_code = b.field_code
) s
ON (t.feedback_type_id = s.feedback_type_id AND t.field_definition_id = s.field_definition_id)
WHEN MATCHED THEN UPDATE SET t.is_required = s.is_required, t.display_seq = s.display_seq
WHEN NOT MATCHED THEN INSERT (feedback_type_id, field_definition_id, is_required, display_seq)
  VALUES (s.feedback_type_id, s.field_definition_id, s.is_required, s.display_seq);

-- ---------------------------------------------------------------- classification values
MERGE INTO afh_classification_values t
USING (
  SELECT 'PRIORITY' AS class_type, 'LOW'          AS value_code, 'Low'          AS label, 10 AS display_seq, 'N' AS is_default, 'neutral' AS color_token FROM dual UNION ALL
  SELECT 'PRIORITY',               'MEDIUM',                     'Medium',               20,                'Y',               'info'                    FROM dual UNION ALL
  SELECT 'PRIORITY',               'HIGH',                       'High',                 30,                'N',               'warning'                 FROM dual UNION ALL
  SELECT 'PRIORITY',               'CRITICAL',                   'Critical',             40,                'N',               'danger'                  FROM dual UNION ALL
  SELECT 'SEVERITY',               'COSMETIC',                   'Cosmetic',             10,                'N',               'neutral'                 FROM dual UNION ALL
  SELECT 'SEVERITY',               'MINOR',                      'Minor',                20,                'N',               'neutral'                 FROM dual UNION ALL
  SELECT 'SEVERITY',               'MEDIUM',                     'Medium',               30,                'Y',               'info'                    FROM dual UNION ALL
  SELECT 'SEVERITY',               'MAJOR',                      'Major',                40,                'N',               'warning'                 FROM dual UNION ALL
  SELECT 'SEVERITY',               'BLOCKER',                    'Blocker',              50,                'N',               'danger'                  FROM dual UNION ALL
  SELECT 'IMPACT',                 'INDIVIDUAL',                 'Individual',           10,                'N',               'neutral'                 FROM dual UNION ALL
  SELECT 'IMPACT',                 'TEAM',                       'Team',                 20,                'N',               'info'                    FROM dual UNION ALL
  SELECT 'IMPACT',                 'MEDIUM',                     'Department',           30,                'Y',               'warning'                 FROM dual UNION ALL
  SELECT 'IMPACT',                 'ORGANIZATION',               'Organization',         40,                'N',               'danger'                  FROM dual
) s
ON (t.class_type = s.class_type AND t.value_code = s.value_code)
WHEN MATCHED THEN UPDATE SET t.label = s.label, t.display_seq = s.display_seq, t.color_token = s.color_token
WHEN NOT MATCHED THEN INSERT (class_type, value_code, label, display_seq, is_default, color_token, is_active)
  VALUES (s.class_type, s.value_code, s.label, s.display_seq, s.is_default, s.color_token, 'Y');

-- ---------------------------------------------------------------- global categories (application_id NULL)
MERGE INTO afh_categories t
USING (
  SELECT 'UI'          AS category_code, 'User interface'      AS label, 10 AS display_seq FROM dual UNION ALL
  SELECT 'DATA',                         'Data',                         20 FROM dual UNION ALL
  SELECT 'REPORTS',                      'Reports',                      30 FROM dual UNION ALL
  SELECT 'SECURITY',                     'Security and access',          40 FROM dual UNION ALL
  SELECT 'PERFORMANCE',                  'Performance',                  50 FROM dual UNION ALL
  SELECT 'OTHER',                        'Other',                        60 FROM dual
) s
ON (t.application_id IS NULL AND t.category_code = s.category_code)
WHEN MATCHED THEN UPDATE SET t.label = s.label, t.display_seq = s.display_seq
WHEN NOT MATCHED THEN INSERT (application_id, category_code, label, display_seq, is_active)
  VALUES (NULL, s.category_code, s.label, s.display_seq, 'Y');

-- ---------------------------------------------------------------- statuses a ticket needs at birth
-- 30_workflow.sql owns the full status list; this MERGE only guarantees the two codes
-- afh_ticket_pkg writes, so the taxonomy seed can run (and tickets can be created) alone.
-- Insert-only: labels and sequence are left to the workflow seed.
MERGE INTO afh_workflow_statuses t
USING (
  SELECT 'NEW'          AS status_code, 'New'          AS label, 10 AS display_seq FROM dual UNION ALL
  SELECT 'UNDER_REVIEW',                'Under Review',          20 FROM dual
) s
ON (t.status_code = s.status_code)
WHEN NOT MATCHED THEN INSERT (status_code, label, display_seq, is_terminal, is_active)
  VALUES (s.status_code, s.label, s.display_seq, 'N', 'Y');

