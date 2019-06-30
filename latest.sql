DROP table data_mapping;

CREATE TABLE data_mapping (
    source_system        VARCHAR2(32),
    target_system        VARCHAR2(32),
    mapping_type         VARCHAR2(32),
    source_table         VARCHAR2(32),
    source_column        VARCHAR2(32),
    constant_value       VARCHAR2(32),
    data_modification    VARCHAR2(32),
    destination_table    VARCHAR2(32),
    destination_column   VARCHAR2(32)
);


Insert into data_mapping (SOURCE_SYSTEM,TARGET_SYSTEM,MAPPING_TYPE,SOURCE_TABLE,SOURCE_COLUMN,CONSTANT_VALUE,DATA_MODIFICATION,DESTINATION_TABLE,DESTINATION_COLUMN) values ('ABC','XYZ','Source_Table','VENDORS','SUPPLIER_NAME',null,'upper','XX_VENDORS','SUPPLIER_NAME');
Insert into data_mapping (SOURCE_SYSTEM,TARGET_SYSTEM,MAPPING_TYPE,SOURCE_TABLE,SOURCE_COLUMN,CONSTANT_VALUE,DATA_MODIFICATION,DESTINATION_TABLE,DESTINATION_COLUMN) values ('ABC','XYZ','Source_Table','VENDORS','SUPPLIER_1',null,'upper','XX_VENDORS','SUPPLIER_1');
Insert into data_mapping (SOURCE_SYSTEM,TARGET_SYSTEM,MAPPING_TYPE,SOURCE_TABLE,SOURCE_COLUMN,CONSTANT_VALUE,DATA_MODIFICATION,DESTINATION_TABLE,DESTINATION_COLUMN) values ('ABC','XYZ','Source_Table','VENDORS','SUPPLIER_2',null,'upper','XX_VENDORS','SUPPLIER_3');
Insert into data_mapping (SOURCE_SYSTEM,TARGET_SYSTEM,MAPPING_TYPE,SOURCE_TABLE,SOURCE_COLUMN,CONSTANT_VALUE,DATA_MODIFICATION,DESTINATION_TABLE,DESTINATION_COLUMN) values ('ABC','XYZ','Source_Table','VENDORS','SUPPLIER_3',null,'upper','XX_VENDORS','SUPPLIER_2');
Insert into data_mapping (SOURCE_SYSTEM,TARGET_SYSTEM,MAPPING_TYPE,SOURCE_TABLE,SOURCE_COLUMN,CONSTANT_VALUE,DATA_MODIFICATION,DESTINATION_TABLE,DESTINATION_COLUMN) values ('ABC','XYZ','Source_Table','VENDORS','SUPPLIER_4',null,'upper','XX_VENDORS','SUPPLIER_5');
Insert into data_mapping (SOURCE_SYSTEM,TARGET_SYSTEM,MAPPING_TYPE,SOURCE_TABLE,SOURCE_COLUMN,CONSTANT_VALUE,DATA_MODIFICATION,DESTINATION_TABLE,DESTINATION_COLUMN) values ('ABC','XYZ','Source_Table','VENDORS','SUPPLIER_5',null,'upper','XX_VENDORS','SUPPLIER_4');
Insert into data_mapping (SOURCE_SYSTEM,TARGET_SYSTEM,MAPPING_TYPE,SOURCE_TABLE,SOURCE_COLUMN,CONSTANT_VALUE,DATA_MODIFICATION,DESTINATION_TABLE,DESTINATION_COLUMN) values ('ABC','XYZ','Constant','VENDORS',null,'123','upper','XX_VENDORS','SUPPLIER_C1');
Insert into data_mapping (SOURCE_SYSTEM,TARGET_SYSTEM,MAPPING_TYPE,SOURCE_TABLE,SOURCE_COLUMN,CONSTANT_VALUE,DATA_MODIFICATION,DESTINATION_TABLE,DESTINATION_COLUMN) values ('ABC','XYZ','Constant','VENDORS',null,'456','upper','XX_VENDORS','SUPPLIER_C2');
Insert into data_mapping (SOURCE_SYSTEM,TARGET_SYSTEM,MAPPING_TYPE,SOURCE_TABLE,SOURCE_COLUMN,CONSTANT_VALUE,DATA_MODIFICATION,DESTINATION_TABLE,DESTINATION_COLUMN) values ('ABC','XYZ','Constant','VENDORS',null,'789','upper','XX_VENDORS','SUPPLIER_C3');


CREATE OR REPLACE PROCEDURE p_generate_procedure (IN_SOURCE IN varchar2,IN_TARGET IN varchar2) AS
--Procedure Parameters
p_source_table varchar2(32);
p_target_table varchar2(32);
--Variables
v_src_input_field_list varchar2(4000);
v_target_input_field_list varchar2(4000);
v_target_constants varchar2(4000);
v_source_constants varchar2(4000);
v_proc_syntax varchar2(6000);
v_const_check NUMBER;
--Exceptions
PROC_CREATION_FAILED EXCEPTION;
COL_MISMATCH EXCEPTION;

BEGIN
p_source_table := IN_SOURCE;
p_target_table := IN_TARGET;

SELECT listagg(Data_Modification||'('||source_column||')', ',') within GROUP (order by destination_column)  into v_src_input_field_list 
      FROM data_mapping WHERE upper(source_table) = upper(p_source_table) and upper(destination_table)= upper(p_target_table) and mapping_type = 'Source_Table';
	  

SELECT listagg(destination_column, ',') within GROUP (order by destination_column) into v_target_input_field_list 
      FROM data_mapping WHERE upper(source_table) = upper(p_source_table) and upper(destination_table)= upper(p_target_table)  and mapping_type = 'Source_Table';

SELECT COUNT(*) INTO v_const_check from data_mapping where mapping_type = 'Constant' and upper(destination_table) = upper(p_target_table) and upper(source_table) = upper(p_source_table);
IF v_const_check > 0 THEN
	  
	SELECT listagg(Data_Modification||'('||constant_value||')', ',') within GROUP (order by destination_column) into v_source_constants 
      FROM data_mapping WHERE upper(source_table) = upper('vendors') and upper(destination_table)= upper('xx_vendors')  and mapping_type = 'Constant';     
	  

	SELECT listagg(destination_column, ',') within GROUP (order by destination_column) into v_target_constants 
      FROM data_mapping WHERE upper(source_table) = upper('vendors') and upper(destination_table)= upper('xx_vendors')  and mapping_type = 'Constant';     

END IF;

	  
v_src_input_field_list := v_src_input_field_list ||','|| v_source_constants ;
v_target_input_field_list := v_target_input_field_list ||','|| v_target_constants ;
  	  

v_proc_syntax := 'CREATE OR REPLACE PROCEDURE P_SOURCE_TO_TARGGET AS
					BEGIN
					INSERT INTO ' || p_target_table || '(' || v_target_input_field_list || ') 
						select '|| v_src_input_field_list || ' from '|| p_source_table ||';
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
WHEN PROC_CREATION_FAILED THEN
DBMS_OUTPUT.PUT_LINE('Procedure Creation Failed');
WHEN OTHERS THEN					
DBMS_OUTPUT.PUT_LINE('will see error later');
END;
						

