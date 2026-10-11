-- Constraints for AFH_NAV_ENTRIES
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NAV_ENTRIES_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_nav_entries ADD CONSTRAINT AFH_NAV_ENTRIES_UK1 UNIQUE (entry_code)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NAV_ENTRIES_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_nav_entries ADD CONSTRAINT AFH_NAV_ENTRIES_FK1 FOREIGN KEY (parent_entry_code) REFERENCES afh_nav_entries (entry_code)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NAV_ENTRIES_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_nav_entries ADD CONSTRAINT AFH_NAV_ENTRIES_CK1 CHECK (list_code IN ('MENU','NAVBAR'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NAV_ENTRIES_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_nav_entries ADD CONSTRAINT AFH_NAV_ENTRIES_CK2 CHECK (audience_code IN ('AUTHENTICATED','DEVELOPER_OR_ABOVE','APP_OWNER_OR_ADMIN','ADMIN'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NAV_ENTRIES_CK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_nav_entries ADD CONSTRAINT AFH_NAV_ENTRIES_CK3 CHECK (is_active IN ('Y','N'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NAV_ENTRIES_CK4';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_nav_entries ADD CONSTRAINT AFH_NAV_ENTRIES_CK4 CHECK (target_type IN ('PAGE','LOGOUT'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NAV_ENTRIES_CK5';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_nav_entries ADD CONSTRAINT AFH_NAV_ENTRIES_CK5 CHECK ((target_type = 'PAGE' AND page_no IS NOT NULL) OR (target_type <> 'PAGE' AND page_no IS NULL))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NAV_ENTRIES_CK6';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_nav_entries ADD CONSTRAINT AFH_NAV_ENTRIES_CK6 CHECK (badge_source IN ('UNREAD_NOTIFICATIONS'))]';
  END IF;
END;
/
