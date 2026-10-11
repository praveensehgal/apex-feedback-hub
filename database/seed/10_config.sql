-- Seed: AFH_INSTALL_CONFIG keys. Idempotent: a re-run refreshes description,
-- data_type, is_secret and is_editable but NEVER touches config_value, so a
-- customer's settings survive upgrades. Empty strings are stored as NULL.
DECLARE
  PROCEDURE put(
    p_key         IN VARCHAR2,
    p_value       IN VARCHAR2,
    p_data_type   IN VARCHAR2,
    p_description IN VARCHAR2,
    p_is_secret   IN VARCHAR2 DEFAULT 'N',
    p_is_editable IN VARCHAR2 DEFAULT 'Y') IS
  BEGIN
    MERGE INTO afh_install_config t
    USING (SELECT p_key AS config_key FROM dual) s
       ON (t.config_key = s.config_key)
     WHEN MATCHED THEN UPDATE
      SET t.data_type   = p_data_type,
          t.description = p_description,
          t.is_secret   = p_is_secret,
          t.is_editable = p_is_editable
     WHEN NOT MATCHED THEN INSERT
          (config_key, config_value, data_type, description, is_secret, is_editable)
   VALUES (p_key, p_value, p_data_type, p_description, p_is_secret, p_is_editable);
  END put;
BEGIN
  -- Product and branding (whitelabel from configuration)
  put('PRODUCT_NAME',        'APEX Feedback Hub', 'TEXT',  'Product name shown in the header, titles and mail');
  put('PRODUCT_VERSION',     '0.1.0',             'TEXT',  'Installed product version; maintained by the installer', 'N', 'N');
  put('BRAND_LOGO_URL',      NULL,                'URL',   'Logo URL (workspace or application static file); blank for the product default');
  put('BRAND_PRIMARY_COLOR', '#165F59',           'COLOR', 'Primary brand color (hex)');
  put('BRAND_ACCENT_COLOR',  '#1F756C',           'COLOR', 'Accent brand color (hex)');
  put('BASE_URL',            NULL,                'URL',   'Absolute ORDS base URL used in mail links; ticket_link appends /f?p=..., e.g. https://apex.example.com/ords');
  put('FEEDBACK_APP_ID',     NULL,                'NUMBER','APEX application ID of the Hub, assigned at install time');
  put('FALLBACK_OWNER_SUBJECT', NULL,             'TEXT',  'Subject that receives tickets no routing rule or application owner claims');
  -- Lifecycle
  put('DEFAULT_RETENTION_DAYS', '365',            'NUMBER','Days a closed ticket is retained before the retention job may purge it');
  put('ARCHIVE_AFTER_DAYS',  '90',                'NUMBER','Days after closure before a ticket is archived');
  put('AUTO_CLOSE_DAYS',     '14',                'NUMBER','Days a resolved ticket waits without activity before it auto-closes');
  -- Host integration contract
  put('MIN_ADAPTER_VERSION', '1.0.0',             'TEXT',  'Lowest host adapter version the Hub accepts');
  put('CONTRACT_VERSION',    '1.0',               'TEXT',  'Launch envelope contract version implemented by this release', 'N', 'N');
  put('HANDOFF_TTL_SECONDS', '120',               'NUMBER','Seconds a launch handoff stays valid');
  put('CAPTURE_MAX_PAYLOAD_BYTES', '1048576',     'NUMBER','Largest diagnostic capture payload accepted, in bytes');
  -- Duplicate scoring (spec section 15.2)
  put('DUP_W_TITLE',         '55',                'NUMBER','Duplicate score weight: title similarity');
  put('DUP_W_DESC',          '20',                'NUMBER','Duplicate score weight: description similarity');
  put('DUP_W_APP',           '15',                'NUMBER','Duplicate score weight: same application');
  put('DUP_W_PAGE',          '5',                 'NUMBER','Duplicate score weight: same page');
  put('DUP_W_TYPE',          '5',                 'NUMBER','Duplicate score weight: same feedback type');
  put('DUP_THRESHOLD',       '65',                'NUMBER','Minimum score for a ticket to be suggested as a duplicate');
  put('DUP_MAX',             '5',                 'NUMBER','Maximum duplicate candidates shown');
  -- Collaboration
  put('COMMENT_EDIT_WINDOW_MIN', '15',            'NUMBER','Minutes during which an author may edit their own public comment');
  -- Mail and notifications
  put('MAIL_ENABLED',        'N',                 'YN',    'Send email notifications (N keeps in-app notifications only)');
  put('MAIL_FROM',           NULL,                'TEXT',  'From address for outbound mail');
  put('MAIL_MAX_RETRIES',    '3',                 'NUMBER','Delivery attempts before a mail is marked permanently failed');
  put('DIGEST_DAILY_HOUR',   '6',                 'NUMBER','Hour of day (0-23, database time) the daily digest is sent');
  put('DEFAULT_NOTIFY_PRESET', 'IMPORTANT',       'TEXT',  'Notification preset for users who have not chosen one');
  -- Attachments (DG-06)
  put('ATTACH_ALLOWED_EXT',  'PNG,JPG,JPEG,PDF,TXT,CSV,XLSX,DOCX', 'LIST', 'Comma-separated list of accepted upload extensions');
  put('ATTACH_MAX_FILE_BYTES',   '26214400',      'NUMBER','Largest single attachment, in bytes (25 MB)');
  put('ATTACH_MAX_TICKET_BYTES', '104857600',     'NUMBER','Largest total attachment size per ticket, in bytes (100 MB)');
  -- Operations
  put('RETENTION_JOB_ARMED', 'N',                 'YN',    'Retention job executes deletions only when Y; otherwise it previews');
  put('IDENTITY_DEFAULT_MODE', 'SHARED_SESSION',  'TEXT',  'Identity provider for newly registered applications: SHARED_SESSION or SIGNED_ENVELOPE');
  -- Development aid: never Y on a customer installation. Not editable from the admin UI; a
  -- development instance flips it with SQL. See docs/decisions/010-act-as-development-aid.md.
  put('ACT_AS_ENABLED',      'N',                 'YN',    'Development only: any signed-in user may act as another user from the navigation bar', 'N', 'N');
  -- Licensing hook (no-op in this release)
  put('LICENSE_KEY',         NULL,                'TEXT',  'License key; validated by a future release, ignored today', 'Y', 'Y');
END;
/
