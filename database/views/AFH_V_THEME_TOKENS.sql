-- AFH_V_THEME_TOKENS: the appearance catalogue for the administration screen.
-- Shows the effective state of each token without exposing how it is rendered.
CREATE OR REPLACE VIEW afh_v_theme_tokens AS
SELECT t.token_id,
       t.token_key,
       t.css_property,
       t.category,
       t.data_type,
       t.token_value,
       t.default_hint,
       CASE WHEN t.token_value IS NULL THEN 'DEFAULT' ELSE 'CUSTOM' END AS value_state,
       CASE t.category
         WHEN 'SURFACE' THEN 10
         WHEN 'TEXT'    THEN 20
         WHEN 'ACCENT'  THEN 30
         WHEN 'STATUS'  THEN 40
         WHEN 'SHAPE'   THEN 50
         WHEN 'TYPE'    THEN 60
       END                                            AS category_sequence,
       t.display_sequence,
       t.description,
       t.last_updated_by,
       t.last_update_date
  FROM afh_theme_tokens t;
COMMENT ON TABLE afh_v_theme_tokens IS 'Appearance tokens with their effective state, ordered for the administration screen';
