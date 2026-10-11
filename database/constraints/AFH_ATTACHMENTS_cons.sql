-- Constraints for AFH_ATTACHMENTS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ATTACHMENTS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_attachments ADD CONSTRAINT AFH_ATTACHMENTS_FK1 FOREIGN KEY (ticket_id) REFERENCES afh_tickets (ticket_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ATTACHMENTS_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_attachments ADD CONSTRAINT AFH_ATTACHMENTS_FK2 FOREIGN KEY (uploaded_by_user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ATTACHMENTS_FK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_attachments ADD CONSTRAINT AFH_ATTACHMENTS_FK3 FOREIGN KEY (original_attachment_id) REFERENCES afh_attachments (attachment_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ATTACHMENTS_FK4';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_attachments ADD CONSTRAINT AFH_ATTACHMENTS_FK4 FOREIGN KEY (comment_id) REFERENCES afh_comments (comment_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ATTACHMENTS_FK5';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_attachments ADD CONSTRAINT AFH_ATTACHMENTS_FK5 FOREIGN KEY (test_result_id) REFERENCES afh_test_results (test_result_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ATTACHMENTS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_attachments ADD CONSTRAINT AFH_ATTACHMENTS_CK1 CHECK (kind_code IN ('SCREENSHOT','SCREENSHOT_ANNOTATED','FILE','CONTEXT_EXPORT'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ATTACHMENTS_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_attachments ADD CONSTRAINT AFH_ATTACHMENTS_CK2 CHECK (is_restricted IN ('Y','N'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ATTACHMENTS_CK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_attachments ADD CONSTRAINT AFH_ATTACHMENTS_CK3 CHECK (is_deleted IN ('Y','N'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ATTACHMENTS_CK4';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_attachments ADD CONSTRAINT AFH_ATTACHMENTS_CK4 CHECK (file_size >= 0)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ATTACHMENTS_CK5';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_attachments ADD CONSTRAINT AFH_ATTACHMENTS_CK5 CHECK (annotation_json IS NULL OR annotation_json IS JSON)]';
  END IF;
END;
/
