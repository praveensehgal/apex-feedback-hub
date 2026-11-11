prompt --application/pages/page_00011
begin
--   Manifest
--     PAGE: 00011
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>68393727750894466
,p_default_application_id=>108
,p_default_id_offset=>0
,p_default_owner=>'AFH'
);
wwv_flow_imp_page.create_page(
 p_id=>11
,p_name=>'Open Ticket'
,p_alias=>'OPEN-TICKET'
,p_step_title=>'Open Ticket'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>2526646919027767344
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68608126239417213)
,p_page_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Entry point for links in notification e-mail: f?p=<app>:11::::11:P11_TICKET_NO:<number>.',
'Page 10 refuses URL values without a checksum, and a mail built by a job has no APEX session',
'to compute one. This page takes the number unprotected, looks it up, and redirects to page 10',
'with a checksummed URL. An unknown number goes to My Work.'))
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70110000000001010)
,p_plug_name=>'Open Ticket'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70110000000001020)
,p_name=>'P11_TICKET_NO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70110000000001010)
,p_prompt=>'Ticket number'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>20
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70110000000001030)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Redirect to the ticket'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_id  afh_v_ticket_detail.ticket_id%TYPE;',
'  l_no  afh_v_ticket_detail.ticket_no%TYPE;',
'  l_url VARCHAR2(4000);',
'BEGIN',
'  BEGIN',
'    SELECT v.ticket_id, v.ticket_no INTO l_id, l_no',
'      FROM afh_v_ticket_detail v',
'     WHERE v.ticket_no = UPPER(TRIM(:P11_TICKET_NO));',
'    -- The checksummed URL is issued only to a user who may view the ticket;',
'    -- not found and not allowed look the same (My Work).',
'    IF afh_security_pkg.can_view_ticket(l_id) THEN',
'      l_url := apex_page.get_url(p_page => 10, p_clear_cache => ''10'',',
'                                 p_items => ''P10_TICKET_NO'', p_values => l_no);',
'    ELSE',
'      l_url := apex_page.get_url(p_page => 1);',
'    END IF;',
'  EXCEPTION',
'    WHEN NO_DATA_FOUND THEN',
'      l_url := apex_page.get_url(p_page => 1);',
'  END;',
'  apex_util.redirect_url(l_url);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>70110000000001030
);
wwv_flow_imp.component_end;
end;
/
