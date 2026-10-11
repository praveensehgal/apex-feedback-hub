-- Indexes for AFH_CATEGORIES
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_CATEGORIES_IX1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_CATEGORIES_IX1 ON afh_categories (parent_category_id)';
  END IF;
END;
/
