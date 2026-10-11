CREATE OR REPLACE PACKAGE afh_license_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_LICENSE_PKG — the no-op hook where license and version-compatibility
  -- checks will live (CLAUDE.md "Productization requirements"). Today every
  -- check passes; the Administration page shows status_text. Nothing else in
  -- the product may depend on a specific return value beyond is_ok = TRUE.
  -- ---------------------------------------------------------------------------
  -- TRUE when the installation may run. Reads config LICENSE_KEY; a blank key is a
  -- development/evaluation installation and still returns TRUE in this version.
  FUNCTION is_ok RETURN BOOLEAN;
  -- Human-readable status for Page 60, e.g. 'Evaluation installation (no license key)'.
  FUNCTION status_text RETURN VARCHAR2;
  -- TRUE when the installed PRODUCT_VERSION is compatible with p_component_version
  -- (adapter or application export). Today: same major version.
  FUNCTION is_compatible(p_component_version IN VARCHAR2) RETURN BOOLEAN;
END afh_license_pkg;
/
