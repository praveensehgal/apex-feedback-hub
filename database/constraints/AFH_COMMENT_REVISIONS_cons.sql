-- Constraints for AFH_COMMENT_REVISIONS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_COMMENT_REVISIONS_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_comment_revisions ADD CONSTRAINT AFH_COMMENT_REVISIONS_UK1 UNIQUE (comment_id, revision_no)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_COMMENT_REVISIONS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_comment_revisions ADD CONSTRAINT AFH_COMMENT_REVISIONS_FK1 FOREIGN KEY (comment_id) REFERENCES afh_comments (comment_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_COMMENT_REVISIONS_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_comment_revisions ADD CONSTRAINT AFH_COMMENT_REVISIONS_FK2 FOREIGN KEY (edited_by_user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
