CREATE OR REPLACE DIRECTORY MYLOG_DIR AS 'C:\oracle_logs';

GRANT READ, WRITE ON MYLOG_DIR TO PUBLIC;

GRANT READ, WRITE ON MYLOG_DIR TO venkat;



CREATE OR REPLACE
PROCEDURE "WRITELOG" (LOG_NAME IN VARCHAR2, LOGMESSAGE IN VARCHAR2)
AUTHID CURRENT_USER
AS
    F1 UTL_FILE.FILE_TYPE;
    PRAGMA AUTONOMOUS_TRANSACTION;
    LOG_DIR VARCHAR2;
    LOG_FILENAME VARCHAR2;
BEGIN
    LOG_DIR := 'MYLOG_DIR';
    LOG_FILENAME := LOG_NAME;
    F1 := UTL_FILE.FOPEN(LOG_DIR, TO_CHAR(SYSDATE,'YYYY-MM-DD') || '_' ||  LOG_FILENAME ||'.log','a');
    UTL_FILE.PUT_LINE(F1, TO_CHAR(SYSDATE,'DD-MM-YYYY HH:MI:SS AM') || ' - ' || LOGMESSAGE);
    UTL_FILE.FCLOSE(F1);

EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('ERROR: ' || TO_CHAR(SQLCODE) || SQLERRM);
      IF UTL_FILE.IS_OPEN(F1) THEN
        UTL_FILE.FCLOSE(F1);
      END IF;
END;

WRITELOG('p_test', 'This is my log text');