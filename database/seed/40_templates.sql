-- 40_templates.sql — notification templates (spec §19, PRD §7.9). Idempotent.
--
-- One IN_APP and one EMAIL template per event code, plus the DIGEST mail template.
-- Placeholders: #TICKET_NO# #TITLE# #STATUS# #ACTOR# #APPLICATION# #SUMMARY# #LINK#
-- #RECIPIENT# #PRODUCT_NAME#, and #ITEMS# (digest only). EMAIL bodies are plain text;
-- the link sits on its own line. Subjects follow '[#PRODUCT_NAME#] #TICKET_NO# — <phrase>'.
--
-- Re-run rule: a row is refreshed only while last_updated_by = created_by, i.e. it still
-- carries the installer's version. Once an administrator edits a template (Page 65 writes
-- through afh_notification_pkg.upsert_template, so the audit trigger stamps their subject
-- as last_updated_by) the installer leaves it alone. is_active is never touched.
DECLARE
  c_sig CONSTANT VARCHAR2(100) := CHR(10) || CHR(10) || '-- #PRODUCT_NAME#';

  FUNCTION mail_body(p_lead IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN 'Hello #RECIPIENT#,' || CHR(10) || CHR(10)
        || p_lead || CHR(10)
        || 'Ticket: #TICKET_NO# #TITLE#' || CHR(10)
        || 'Application: #APPLICATION#' || CHR(10)
        || 'Status: #STATUS#' || CHR(10)
        || 'By: #ACTOR#' || CHR(10) || CHR(10)
        || '#SUMMARY#' || CHR(10) || CHR(10)
        || 'Open the ticket:' || CHR(10)
        || '#LINK#' || c_sig;
  END mail_body;

  PROCEDURE seed(p_event IN VARCHAR2, p_channel IN VARCHAR2, p_subject IN VARCHAR2,
                 p_body IN VARCHAR2, p_desc IN VARCHAR2) IS
  BEGIN
    MERGE INTO afh_notification_templates t
    USING (SELECT p_event AS event_code, p_channel AS channel_code FROM dual) s
       ON (t.event_code = s.event_code AND t.channel_code = s.channel_code)
    WHEN MATCHED THEN UPDATE
      SET t.subject_template = p_subject, t.body_template = p_body, t.description = p_desc
      WHERE t.last_updated_by = t.created_by
    WHEN NOT MATCHED THEN INSERT (event_code, channel_code, subject_template, body_template, is_active, description)
      VALUES (s.event_code, s.channel_code, p_subject, p_body, 'Y', p_desc);
  END seed;

  -- Both channels for one event: the phrase drives the subject, the lead the mail body.
  PROCEDURE seed_event(p_event IN VARCHAR2, p_phrase IN VARCHAR2, p_lead IN VARCHAR2) IS
  BEGIN
    seed(p_event, 'IN_APP',
         p_phrase || ': #TICKET_NO# #TITLE#',
         '#ACTOR# — #SUMMARY#',
         'In-app notification for ' || p_event);
    seed(p_event, 'EMAIL',
         '[#PRODUCT_NAME#] #TICKET_NO# — ' || p_phrase,
         mail_body(p_lead),
         'E-mail notification for ' || p_event);
  END seed_event;
BEGIN
  seed_event('NEW_TICKET',      'New ticket',                     'A new ticket was submitted and routed to you or to a queue you follow.');
  seed_event('ASSIGNMENT',      'Assigned to you',                'This ticket has been assigned to you.');
  seed_event('MENTION',         'You were mentioned',             'You were mentioned in a comment on this ticket.');
  seed_event('COMMENT',         'New comment',                    'A new comment was added to a ticket you follow.');
  seed_event('INFO_REQUEST',    'Information requested from you', 'More information is needed from you before work can continue.');
  seed_event('INFO_RESPONSE',   'Information provided',           'The reporter has responded to a request for information.');
  seed_event('STATUS_CHANGE',   'Status changed',                 'The status of this ticket changed.');
  seed_event('PRIORITY_CHANGE', 'Priority changed',               'The priority of this ticket changed.');
  seed_event('RELEASE_CHANGE',  'Target release changed',         'The target release of this ticket changed.');
  seed_event('READY_TEST',      'Ready for testing',              'A fix is ready and the ticket is waiting for a test.');
  seed_event('TEST_REQUEST',    'Test requested from you',        'You have been asked to test a fix for this ticket.');
  seed_event('TEST_OUTCOME',    'Test outcome recorded',          'A test result was recorded for this ticket.');
  seed_event('RESOLUTION',      'Resolved',                       'This ticket has been resolved.');
  seed_event('CLOSURE',         'Closed',                         'This ticket has been closed.');
  seed_event('REOPENED',        'Reopened',                       'This ticket has been reopened.');
  seed_event('DUPLICATE_MERGE', 'Merged as a duplicate',          'This ticket was merged into another ticket as a duplicate.');

  seed('DIGEST', 'EMAIL',
       '[#PRODUCT_NAME#] Your feedback digest',
       'Hello #RECIPIENT#,' || CHR(10) || CHR(10)
    || 'Here is a summary of recent activity on tickets you follow (#SUMMARY#):' || CHR(10) || CHR(10)
    || '#ITEMS#' || CHR(10)
    || 'Open the Hub to see the details. You can change how often you receive this digest'
    || ' in your notification preferences.' || c_sig,
       'Daily / weekly digest e-mail; #ITEMS# holds one line per event');
END;
/
