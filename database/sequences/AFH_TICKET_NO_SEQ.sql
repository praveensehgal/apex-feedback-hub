-- Public ticket-number sequence. Rendered as 'FB-' || LPAD(value, 4, '0'). Never reset.
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_sequences WHERE sequence_name = 'AFH_TICKET_NO_SEQ';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE afh_ticket_no_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
  END IF;
END;
/
