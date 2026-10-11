CREATE OR REPLACE PACKAGE BODY afh_theme_pkg AS

  -- Universal Theme properties driven by the two brand colours in AFH_INSTALL_CONFIG.
  -- Every name below was verified against APEX 24.2 Core.min.css and Vita.min.css.
  -- Note in particular that the header reads --ut-header-background-color and NOT
  -- --ut-palette-primary, and that Core paints .t-Header-branding, not .t-Header.
  -- Do not add a property here without checking it exists in the target release.

  FUNCTION is_valid_value(p_data_type IN VARCHAR2, p_value IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    IF p_value IS NULL THEN
      RETURN TRUE;                       -- NULL means "use the product default"
    END IF;
    RETURN CASE p_data_type
             WHEN 'COLOR'  THEN REGEXP_LIKE(p_value, c_pattern_color)
             WHEN 'LENGTH' THEN REGEXP_LIKE(p_value, c_pattern_length)
             WHEN 'FONT'   THEN REGEXP_LIKE(p_value, c_pattern_font)
             ELSE FALSE                  -- anything else never reaches a stylesheet
           END;
  END is_valid_value;

  FUNCTION lock_token(p_token_key IN VARCHAR2) RETURN afh_theme_tokens%ROWTYPE IS
    l_row afh_theme_tokens%ROWTYPE;
  BEGIN
    SELECT * INTO l_row FROM afh_theme_tokens
     WHERE token_key = UPPER(TRIM(p_token_key)) FOR UPDATE;
    RETURN l_row;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Unknown appearance setting.');
  END lock_token;

  FUNCTION token_facts(p_token_key IN VARCHAR2, p_value IN VARCHAR2) RETURN CLOB IS
  BEGIN
    RETURN afh_audit_pkg.json_obj(
      apex_t_varchar2('token_key', 'value'),
      apex_t_varchar2(p_token_key, p_value));
  END token_facts;

  PROCEDURE log_change(p_row   IN afh_theme_tokens%ROWTYPE,
                       p_after IN VARCHAR2) IS
  BEGIN
    afh_audit_pkg.log_event(
      p_entity_type  => afh_audit_pkg.c_entity_config,
      p_entity_id    => p_row.token_id,
      p_event_code   => c_event_changed,
      p_before_facts => token_facts(p_row.token_key, p_row.token_value),
      p_after_facts  => token_facts(p_row.token_key, p_after),
      p_summary      => 'Appearance setting ' || p_row.token_key ||
                        CASE WHEN p_after IS NULL THEN ' reset to the product default'
                             ELSE ' changed' END,
      p_is_public    => 'N');
  END log_change;

  PROCEDURE write_token(p_token_key IN VARCHAR2, p_value IN VARCHAR2) IS
    l_row   afh_theme_tokens%ROWTYPE;
    l_value afh_theme_tokens.token_value%TYPE := TRIM(p_value);
  BEGIN
    afh_security_pkg.assert_admin;
    IF l_value IS NULL THEN
      l_value := NULL;                   -- an empty string is a reset, not a value
    END IF;
    l_row := lock_token(p_token_key);
    IF NOT is_valid_value(l_row.data_type, l_value) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        l_row.token_key || ' must be a valid ' || LOWER(l_row.data_type) || ' value.');
    END IF;
    IF NVL(l_row.token_value, '~') = NVL(l_value, '~') THEN
      RETURN;                            -- no change, no audit noise
    END IF;
    UPDATE afh_theme_tokens SET token_value = l_value WHERE token_id = l_row.token_id;
    log_change(l_row, l_value);
  END write_token;

  PROCEDURE set_token(p_token_key IN VARCHAR2, p_value IN VARCHAR2) IS
  BEGIN
    write_token(p_token_key, p_value);
  END set_token;

  PROCEDURE reset_token(p_token_key IN VARCHAR2) IS
  BEGIN
    write_token(p_token_key, NULL);
  END reset_token;

  PROCEDURE reset_all IS
  BEGIN
    afh_security_pkg.assert_admin;
    FOR r IN (SELECT token_key FROM afh_theme_tokens
               WHERE token_value IS NOT NULL ORDER BY token_key) LOOP
      write_token(r.token_key, NULL);
    END LOOP;
  END reset_all;

  -- ------------------------------------------------------------------ rendering

  PROCEDURE append_decl(p_buf IN OUT NOCOPY CLOB,
                        p_property IN VARCHAR2,
                        p_value    IN VARCHAR2) IS
  BEGIN
    IF p_value IS NULL THEN
      RETURN;
    END IF;
    dbms_lob.writeappend(p_buf, LENGTH('  ' || p_property || ': ' || p_value || ';' || CHR(10)),
                                        '  ' || p_property || ': ' || p_value || ';' || CHR(10));
  END append_decl;

  FUNCTION style_block RETURN CLOB IS
    l_buf     CLOB;
    l_primary afh_install_config.config_value%TYPE := afh_security_pkg.config_value('BRAND_PRIMARY_COLOR');
    l_accent  afh_install_config.config_value%TYPE := afh_security_pkg.config_value('BRAND_ACCENT_COLOR');
    l_any     BOOLEAN := FALSE;
  BEGIN
    -- The two brand colours come from AFH_INSTALL_CONFIG, where COLOR is already
    -- validated on write. Re-check here so this function is safe on its own terms.
    IF NOT is_valid_value('COLOR', l_primary) THEN
      l_primary := NULL;
    END IF;
    IF NOT is_valid_value('COLOR', l_accent) THEN
      l_accent := NULL;
    END IF;

    dbms_lob.createtemporary(l_buf, TRUE, dbms_lob.call);
    dbms_lob.writeappend(l_buf, LENGTH('<style>' || CHR(10) || ':root {' || CHR(10)),
                                        '<style>' || CHR(10) || ':root {' || CHR(10));

    IF l_primary IS NOT NULL THEN
      l_any := TRUE;
      append_decl(l_buf, '--ut-palette-primary',          l_primary);
      append_decl(l_buf, '--ut-palette-primary-contrast', '#ffffff');
      append_decl(l_buf, '--ut-header-background-color',  l_primary);
      append_decl(l_buf, '--ut-header-text-color',        '#ffffff');
      append_decl(l_buf, '--ut-link-text-color',          l_primary);
      append_decl(l_buf, '--a-base-link-text-color',      l_primary);
      append_decl(l_buf, '--ut-focus-outline-color',      l_primary);
    END IF;
    IF l_accent IS NOT NULL THEN
      l_any := TRUE;
      append_decl(l_buf, '--afh-accent', l_accent);
    END IF;

    -- Deterministic order so the rendered block is diffable between installations.
    FOR r IN (SELECT css_property, token_value, data_type
                FROM afh_theme_tokens
               WHERE token_value IS NOT NULL
               ORDER BY category, display_sequence, token_key) LOOP
      -- Second control: a row altered by direct DML, bypassing set_token, still cannot
      -- reach the page unless it is a strictly validated type carrying a valid value.
      IF r.data_type IN ('COLOR', 'LENGTH', 'FONT')
         AND is_valid_value(r.data_type, r.token_value) THEN
        l_any := TRUE;
        append_decl(l_buf, r.css_property, r.token_value);
      END IF;
    END LOOP;

    IF NOT l_any THEN
      dbms_lob.freetemporary(l_buf);
      RETURN NULL;                        -- nothing configured: emit no element at all
    END IF;

    dbms_lob.writeappend(l_buf, LENGTH('}' || CHR(10) || '</style>'),
                                        '}' || CHR(10) || '</style>');
    RETURN l_buf;
  END style_block;

END afh_theme_pkg;
/
