-- Appearance token catalogue. Implements docs/decisions/007.
--
-- Every row seeds with token_value NULL, meaning "use the product default". Defaults are
-- written in exactly one place - the :root block of apex/static/afh_theme.css - and an
-- override wins by cascade order, because the Global Page renders its <style> in the body,
-- after the head stylesheets, at equal specificity.
--
-- DEFAULT_HINT is display-only placeholder copy for the administration screen and is never
-- emitted into a page. It must match the stylesheet default exactly;
-- tests/tools/check_theme_tokens.py fails the build when it does not.
--
-- Re-runnable: MERGE updates the catalogue metadata and deliberately leaves token_value
-- alone, so an upgrade never discards an installation's appearance.
DECLARE
  PROCEDURE put(p_key    IN VARCHAR2,
                p_prop   IN VARCHAR2,
                p_cat    IN VARCHAR2,
                p_type   IN VARCHAR2,
                p_hint   IN VARCHAR2,
                p_seq    IN NUMBER,
                p_desc   IN VARCHAR2) IS
  BEGIN
    MERGE INTO afh_theme_tokens t
    USING (SELECT p_key AS token_key FROM dual) s
       ON (t.token_key = s.token_key)
     WHEN MATCHED THEN UPDATE
          SET t.css_property     = p_prop,
              t.category         = p_cat,
              t.data_type        = p_type,
              t.default_hint     = p_hint,
              t.display_sequence = p_seq,
              t.description      = p_desc
     WHEN NOT MATCHED THEN INSERT
          (token_key, css_property, category, data_type, token_value,
           default_hint, display_sequence, description)
   VALUES (p_key, p_prop, p_cat, p_type, NULL, p_hint, p_seq, p_desc);
  END put;
BEGIN
  -- ---------------------------------------------------------------- SURFACE
  put('THEME_PAPER',       '--afh-paper',       'SURFACE', 'COLOR', '#ffffff', 10,
      'Card and panel background.');
  put('THEME_PAPER_2',     '--afh-paper-2',     'SURFACE', 'COLOR', '#faf7ef', 20,
      'Page background behind cards.');
  put('THEME_PAPER_3',     '--afh-paper-3',     'SURFACE', 'COLOR', '#f2ede2', 30,
      'Recessed fill for image stages, chips and closed states.');
  put('THEME_BORDER',      '--afh-border',      'SURFACE', 'COLOR', '#e4ddcf', 40,
      'Border and divider colour.');

  -- ------------------------------------------------------------------- TEXT
  put('THEME_INK',         '--afh-ink',         'TEXT',    'COLOR', '#172622', 10,
      'Body text.');
  put('THEME_INK_SOFT',    '--afh-ink-soft',    'TEXT',    'COLOR', '#3c504a', 20,
      'Secondary text and field labels.');
  put('THEME_INK_MUTED',   '--afh-ink-muted',   'TEXT',    'COLOR', '#586c65', 30,
      'Captions, metadata and column headings.');

  -- ----------------------------------------------------------------- ACCENT
  put('THEME_ACCENT',      '--afh-accent',      'ACCENT',  'COLOR', '#1f756c', 10,
      'Primary accent for confirmation, progress and live indicators.');
  put('THEME_ACCENT_INK',  '--afh-accent-ink',  'ACCENT',  'COLOR', '#ffffff', 20,
      'Text drawn on the accent colour.');
  put('THEME_ACCENT_SOFT', '--afh-accent-soft', 'ACCENT',  'COLOR', '#dceee9', 30,
      'Tinted accent background for badges and highlights.');
  put('THEME_SIGNAL',      '--afh-signal',      'ACCENT',  'COLOR', '#d95026', 40,
      'Attention colour for selection, annotation and emphasis.');
  put('THEME_SIGNAL_SOFT', '--afh-signal-soft', 'ACCENT',  'COLOR', '#fee8dc', 50,
      'Tinted attention background.');
  put('THEME_FOCUS',       '--afh-focus',       'ACCENT',  'COLOR', '#315b7a', 60,
      'Keyboard focus ring. Keep this clearly visible against your backgrounds.');

  -- ----------------------------------------------------------------- STATUS
  put('THEME_OK',          '--afh-ok',          'STATUS',  'COLOR', '#1f6548', 10,
      'Success text.');
  put('THEME_OK_BG',       '--afh-ok-bg',       'STATUS',  'COLOR', '#dbf1e4', 20,
      'Success background.');
  put('THEME_WARN',        '--afh-warn',        'STATUS',  'COLOR', '#855717', 30,
      'Warning text.');
  put('THEME_WARN_BG',     '--afh-warn-bg',     'STATUS',  'COLOR', '#fff0ca', 40,
      'Warning background.');
  put('THEME_DANGER',      '--afh-danger',      'STATUS',  'COLOR', '#9f352f', 50,
      'Error text.');
  put('THEME_DANGER_BG',   '--afh-danger-bg',   'STATUS',  'COLOR', '#f8ded8', 60,
      'Error background.');

  -- ------------------------------------------------------------------ SHAPE
  put('THEME_RADIUS_SM',   '--afh-radius-sm',   'SHAPE',   'LENGTH', '6px',  20,
      'Radius for buttons, inputs and small chips.');
  put('THEME_RADIUS_MD',   '--afh-radius',      'SHAPE',   'LENGTH', '11px', 30,
      'Radius for cards and panels.');
  put('THEME_RADIUS_LG',   '--afh-radius-lg',   'SHAPE',   'LENGTH', '18px', 40,
      'Large radius used for the oversized corner on feature panels.');

  -- ------------------------------------------------------------------- TYPE
  put('THEME_FONT_DISPLAY','--afh-display',     'TYPE',    'FONT',
      '"Iowan Old Style", "Palatino Linotype", Palatino, Georgia, serif', 10,
      'Headings. A font stack of installed font names - letters, digits, spaces, commas, quotes and hyphens only.');
  put('THEME_FONT_BODY',   '--afh-body',        'TYPE',    'FONT',
      '"Avenir Next", "Segoe UI", Arial, sans-serif', 20,
      'Body text font stack.');
  put('THEME_FONT_MONO',   '--afh-mono',        'TYPE',    'FONT',
      '"SFMono-Regular", ui-monospace, Consolas, "Liberation Mono", monospace', 30,
      'Monospace font stack for identifiers, metadata and column headings.');
END;
/
