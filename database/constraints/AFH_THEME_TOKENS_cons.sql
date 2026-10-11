-- Constraints for AFH_THEME_TOKENS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_THEME_TOKENS_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_theme_tokens ADD CONSTRAINT AFH_THEME_TOKENS_UK1 UNIQUE (token_key)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_THEME_TOKENS_UK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_theme_tokens ADD CONSTRAINT AFH_THEME_TOKENS_UK2 UNIQUE (css_property)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_THEME_TOKENS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_theme_tokens ADD CONSTRAINT AFH_THEME_TOKENS_CK1 CHECK (REGEXP_LIKE(token_key, '^[A-Z][A-Z0-9_]{0,39}$'))]';
  END IF;
END;
/
-- The emitted property name is itself untrusted text once it reaches a stylesheet,
-- so its shape is constrained here rather than only in the renderer.
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_THEME_TOKENS_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_theme_tokens ADD CONSTRAINT AFH_THEME_TOKENS_CK2 CHECK (REGEXP_LIKE(css_property, '^--[a-z][a-z0-9-]{0,57}$'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_THEME_TOKENS_CK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_theme_tokens ADD CONSTRAINT AFH_THEME_TOKENS_CK3 CHECK (category IN ('SURFACE','TEXT','ACCENT','STATUS','SHAPE','TYPE'))]';
  END IF;
END;
/
-- Deliberately narrower than AFH_INSTALL_CONFIG_CK2: only strictly validated types
-- may ever reach a <style> element. TEXT, URL and LIST are free text and are excluded.
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_THEME_TOKENS_CK4';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_theme_tokens ADD CONSTRAINT AFH_THEME_TOKENS_CK4 CHECK (data_type IN ('COLOR','LENGTH','FONT'))]';
  END IF;
END;
/
