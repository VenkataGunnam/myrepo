CREATE OR REPLACE PROCEDURE p_create_procedure(src IN varchar2,dest IN varchar2,maps IN varchar2,p_out OUT varchar2) AS
--Procedure Parameters
p_source_table_name varchar2(32);
p_destination_table_name varchar2(32);
p_mapping_table_name varchar2(32);
--Variables
v_src_input_field_list varchar2(4000);
v_dest_input_field_list varchar2(4000);
v_proc_syntax varchar2(6000);
v_tables_exist NUMBER(1);
v_source_col_cnt NUMBER;
v_dest_col_cnt NUMBER;
--Exceptions
PROC_CREATION_FAILED EXCEPTION;
COL_MISMATCH EXCEPTION;

BEGIN
p_source_table_name := src;
p_destination_table_name := dest;
p_mapping_table_name := maps;

SELECT count(*) INTO v_tables_exist from user_tables where table_name IN (upper(p_source_table_name),
																			upper(p_destination_table_name),
																			upper(p_mapping_table_name));
dbms_output.put_line(v_tables_exist);
IF v_tables_exist <> 3 THEN
    RAISE NO_DATA_FOUND;
END IF;

SELECT count(*) INTO v_source_col_cnt from user_tab_columns where table_name = upper(p_source_table_name);
SELECT count(*) INTO v_dest_col_cnt from user_tab_columns where table_name = upper(p_destination_table_name);

IF v_source_col_cnt <> v_dest_col_cnt THEN
    RAISE COL_MISMATCH;
END IF;

SELECT listagg('upper(x.'||column_name, '),') within GROUP (order by column_name) || ')'  into v_src_input_field_list 
      FROM user_tab_columns WHERE table_name = upper(p_source_table_name);


SELECT listagg(column_name, ',') within GROUP (order by column_name)  into v_dest_input_field_list 
      FROM user_tab_columns WHERE table_name = upper(p_destination_table_name);      

v_proc_syntax := 'CREATE OR REPLACE PROCEDURE p_final_procedure AS
BEGIN
INSERT INTO ' || p_destination_table_name || '(' || v_dest_input_field_list || ') 
select '|| v_src_input_field_list || ' from '|| p_source_table_name || ' x,'|| p_mapping_table_name || ' y
WHERE x.supplier_id = y.supplier_id(+);
commit;
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;';

DBMS_OUTPUT.PUT_LINE(v_proc_syntax);

BEGIN
execute Immediate v_proc_syntax;
EXCEPTION
WHEN OTHERS THEN
RAISE PROC_CREATION_FAILED;
END;

EXCEPTION
WHEN NO_DATA_FOUND THEN
p_out := ' Source or Destination or Mapping table is not Found ' ;
WHEN PROC_CREATION_FAILED THEN
p_out := 'Procedure Creation Failed due to error '||SQLERRM;
WHEN COL_MISMATCH THEN
p_out := 'Source or Destination table Columns are not in SYNC';
WHEN OTHERS THEN
p_out := 'ERROR OCCURED '||SQLCODE ||' ERROR MESSAEG :'||SQLERRM;
END;
