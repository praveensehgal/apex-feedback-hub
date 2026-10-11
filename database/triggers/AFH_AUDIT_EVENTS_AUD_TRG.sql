-- Immutability trigger for AFH_AUDIT_EVENTS: rows may be inserted, never updated or deleted.
CREATE OR REPLACE TRIGGER afh_audit_events_aud_trg
  BEFORE INSERT OR UPDATE OR DELETE ON afh_audit_events
  FOR EACH ROW
DECLARE
  l_actor VARCHAR2(255 CHAR) := COALESCE(SYS_CONTEXT('APEX$SESSION','APP_USER'), SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), USER);
BEGIN
  IF INSERTING THEN
    :new.created_by    := COALESCE(:new.created_by, l_actor);
    :new.creation_date := COALESCE(:new.creation_date, SYSTIMESTAMP);
  ELSE
    RAISE_APPLICATION_ERROR(-20092, 'AFH-SYS-002: AFH_AUDIT_EVENTS is append-only');
  END IF;
END;
/
