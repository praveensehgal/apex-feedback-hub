CREATE OR REPLACE PACKAGE BODY afh_license_pkg AS
  FUNCTION is_ok RETURN BOOLEAN IS
  BEGIN
    RETURN TRUE;   -- no-op hook; see spec header
  END;

  FUNCTION status_text RETURN VARCHAR2 IS
    l_key VARCHAR2(4000) := afh_security_pkg.config_value('LICENSE_KEY');
  BEGIN
    IF l_key IS NULL THEN
      RETURN 'Evaluation installation (no license key)';
    END IF;
    RETURN 'License key present (validation not yet enforced in ' ||
           afh_security_pkg.config_value('PRODUCT_VERSION') || ')';
  END;

  FUNCTION is_compatible(p_component_version IN VARCHAR2) RETURN BOOLEAN IS
    l_product VARCHAR2(30) := afh_security_pkg.config_value('PRODUCT_VERSION');
  BEGIN
    RETURN REGEXP_SUBSTR(l_product, '^\d+') = REGEXP_SUBSTR(p_component_version, '^\d+');
  END;
END afh_license_pkg;
/
