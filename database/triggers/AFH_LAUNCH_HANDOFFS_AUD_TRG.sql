-- Creation-column trigger for AFH_LAUNCH_HANDOFFS.
CREATE OR REPLACE TRIGGER afh_launch_handoffs_aud_trg
  BEFORE INSERT ON afh_launch_handoffs
  FOR EACH ROW
DECLARE
  l_actor VARCHAR2(255 CHAR) := COALESCE(SYS_CONTEXT('APEX$SESSION','APP_USER'), SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), USER);
BEGIN
  :new.created_by    := COALESCE(:new.created_by, l_actor);
  :new.creation_date := COALESCE(:new.creation_date, SYSTIMESTAMP);
END;
/
