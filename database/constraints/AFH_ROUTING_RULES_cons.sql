-- Constraints for AFH_ROUTING_RULES
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ROUTING_RULES_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_routing_rules ADD CONSTRAINT AFH_ROUTING_RULES_FK1 FOREIGN KEY (application_id) REFERENCES afh_applications (application_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ROUTING_RULES_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_routing_rules ADD CONSTRAINT AFH_ROUTING_RULES_FK2 FOREIGN KEY (category_id) REFERENCES afh_categories (category_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ROUTING_RULES_FK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_routing_rules ADD CONSTRAINT AFH_ROUTING_RULES_FK3 FOREIGN KEY (environment_id) REFERENCES afh_environments (environment_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ROUTING_RULES_FK4';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_routing_rules ADD CONSTRAINT AFH_ROUTING_RULES_FK4 FOREIGN KEY (assignee_user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ROUTING_RULES_FK5';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_routing_rules ADD CONSTRAINT AFH_ROUTING_RULES_FK5 FOREIGN KEY (owner_user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ROUTING_RULES_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_routing_rules ADD CONSTRAINT AFH_ROUTING_RULES_CK1 CHECK (is_active IN ('Y','N'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ROUTING_RULES_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_routing_rules ADD CONSTRAINT AFH_ROUTING_RULES_CK2 CHECK (assignee_user_id IS NOT NULL OR owner_user_id IS NOT NULL)]';
  END IF;
END;
/
