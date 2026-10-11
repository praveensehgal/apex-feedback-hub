-- Audit-column trigger for AFH_FOLLOWERS. No business logic.
CREATE OR REPLACE TRIGGER afh_followers_aud_trg
  BEFORE INSERT OR UPDATE ON afh_followers
  FOR EACH ROW
DECLARE
  l_actor VARCHAR2(255 CHAR) := COALESCE(SYS_CONTEXT('APEX$SESSION','APP_USER'), SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), USER);
BEGIN
  IF INSERTING THEN
    :new.created_by       := COALESCE(:new.created_by, l_actor);
    :new.creation_date    := COALESCE(:new.creation_date, SYSTIMESTAMP);
    :new.last_updated_by  := COALESCE(:new.last_updated_by, :new.created_by);
    :new.last_update_date := COALESCE(:new.last_update_date, :new.creation_date);
  ELSE
    :new.created_by       := :old.created_by;
    :new.creation_date    := :old.creation_date;
    :new.last_updated_by  := l_actor;
    :new.last_update_date := SYSTIMESTAMP;
  END IF;
END;
/
