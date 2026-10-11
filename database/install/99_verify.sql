-- Post-install verification: zero invalid objects, required seed present.
DECLARE
  l_invalid PLS_INTEGER;
  l_msg     VARCHAR2(4000);
BEGIN
  SELECT COUNT(*), LISTAGG(object_type || ' ' || object_name, ', ') WITHIN GROUP (ORDER BY object_name)
    INTO l_invalid, l_msg
    FROM user_objects WHERE status = 'INVALID' AND object_name LIKE 'AFH%';
  IF l_invalid > 0 THEN
    RAISE_APPLICATION_ERROR(-20909, 'AFH-INS-009: ' || l_invalid || ' invalid object(s): ' || l_msg);
  END IF;
  DBMS_OUTPUT.put_line('verify ok: 0 invalid AFH objects');
END;
/
SELECT object_type, COUNT(*) AS objects
  FROM user_objects WHERE object_name LIKE 'AFH%'
 GROUP BY object_type ORDER BY 1;
