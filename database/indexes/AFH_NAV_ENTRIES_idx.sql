-- Indexes for AFH_NAV_ENTRIES
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_NAV_ENTRIES_IX1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[CREATE INDEX AFH_NAV_ENTRIES_IX1 ON afh_nav_entries (list_code, display_seq)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_NAV_ENTRIES_IX2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[CREATE INDEX AFH_NAV_ENTRIES_IX2 ON afh_nav_entries (parent_entry_code)]';
  END IF;
END;
/
