CREATE OR REPLACE PACKAGE afh_theme_pkg AS
  /*
   * Appearance tokens. Implements docs/decisions/007-theme-tokens-from-configuration.md.
   *
   * The product look lives in apex/static/afh_theme.css, where every themed declaration
   * is written as var(--afh-token, <default>). This package emits a <style> element
   * carrying ONLY the tokens an installation has actually overridden; unset tokens emit
   * nothing and the stylesheet fallback stands. An installation that configures nothing
   * renders the approved mockup unchanged.
   *
   * Security: these values are interpolated into a <style> element, so the type system is
   * the control. Only COLOR, LENGTH and FONT may be stored (AFH_THEME_TOKENS_CK4), each
   * has a strict pattern, and style_block re-checks the pattern at render time so a row
   * written by direct DML still cannot reach the page. TEXT, URL and LIST are free text
   * and can never become a theme token.
   */

  -- Value patterns. Public so the administration page and the test suite assert against
  -- the same definitions the validator uses, rather than restating them.
  c_pattern_color  CONSTANT VARCHAR2(100) := '^#[0-9A-Fa-f]{6}$';
  -- A unit is required except for a bare 0, which CSS permits and which is how an
  -- administrator naturally asks for square corners.
  c_pattern_length CONSTANT VARCHAR2(100) := '^(0|[0-9]{1,3}(\.[0-9]{1,2})?(px|rem|em))$';
  -- Letters, digits, spaces, commas, quotes and hyphens only. Admits no ; { } < > ( ) : / \ @
  -- so a value can neither close the element nor open a declaration, rule or at-rule;
  -- url() and @import are unreachable by construction rather than by blocklist.
  c_pattern_font   CONSTANT VARCHAR2(100) := '^[A-Za-z0-9 ,"''-]{1,200}$';

  c_event_changed  CONSTANT VARCHAR2(30)  := 'THEME_TOKEN_CHANGED';

  -- Renders the branding <style> element for the Global Page region, or NULL when the
  -- installation has overridden nothing. Read-only; safe to call on every page request.
  FUNCTION style_block RETURN CLOB;

  -- TRUE when the value is well formed for the token's data type.
  FUNCTION is_valid_value(p_data_type IN VARCHAR2, p_value IN VARCHAR2) RETURN BOOLEAN;

  -- Admin mutations. Each validates, writes, and logs THEME_TOKEN_CHANGED in the caller's
  -- transaction. The caller controls commit.
  PROCEDURE set_token(p_token_key IN VARCHAR2, p_value IN VARCHAR2);
  PROCEDURE reset_token(p_token_key IN VARCHAR2);
  PROCEDURE reset_all;
END afh_theme_pkg;
/
