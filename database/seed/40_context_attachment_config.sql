-- Configuration keys read by AFH_CONTEXT_PKG and AFH_ATTACHMENT_PKG (DG-06 defaults).
-- Re-runnable: a key that already exists keeps its administrator-set value; only the
-- description is refreshed.
MERGE INTO afh_install_config c
USING (SELECT 'CAPTURE_MAX_PAYLOAD_BYTES' AS config_key, '1048576' AS config_value, 'NUMBER' AS data_type,
              'Maximum characters stored per diagnostic capture (items plus debug); larger captures are truncated and marked PARTIAL' AS description
         FROM dual
        UNION ALL
       SELECT 'ATTACH_ALLOWED_EXT', 'PNG,JPG,JPEG,PDF,TXT,CSV,XLSX,DOCX', 'LIST',
              'Comma-separated upload extensions; HTML, SVG, scripts, executables and archives are always rejected'
         FROM dual
        UNION ALL
       SELECT 'ATTACH_MAX_FILE_BYTES', '26214400', 'NUMBER',
              'Maximum size of one uploaded file in bytes (default 25 MB)'
         FROM dual
        UNION ALL
       SELECT 'ATTACH_MAX_TICKET_BYTES', '104857600', 'NUMBER',
              'Maximum total size of non-removed attachments per ticket in bytes (default 100 MB)'
         FROM dual) s
ON (c.config_key = s.config_key)
WHEN NOT MATCHED THEN
  INSERT (config_key, config_value, data_type, description, is_secret, is_editable)
  VALUES (s.config_key, s.config_value, s.data_type, s.description, 'N', 'Y')
WHEN MATCHED THEN
  UPDATE SET c.description = s.description;

