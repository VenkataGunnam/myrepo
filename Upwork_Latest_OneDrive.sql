CREATE OR REPLACE PROCEDURE p_generate_procedure AS
v_proc_syntax varchar2(6000);
PROC_CREATION_FAILED EXCEPTION;

BEGIN

v_proc_syntax := q'[CREATE OR REPLACE PROCEDURE P_SOURCE_TO_TARGGET AS
                    p_source_table varchar2(32);
                    p_target_table varchar2(32);
                    --Variables
                    v_src_input_field_list varchar2(4000);
                    v_target_input_field_list varchar2(4000);
                    v_target_constants varchar2(4000);
                    v_source_constants varchar2(4000);
                    v_proc_syntax varchar2(6000);
                    v_const_check NUMBER;
					v_decode_check NUMBER;
					v_target_decode_cols varchar2(4000);
					v_source_decode_cols varchar2(4000);
                    v_insert_syntax varchar2(6000);
                    --Exceptions
                    PROC_CREATION_FAILED EXCEPTION;

                    CURSOR C1 IS
                        SELECT DISTINCT SOURCE_TABLE,DESTINATION_TABLE FROM DATA_MAPPING;

    				BEGIN
                    FOR cur in c1
                        LOOP
                        p_source_table := cur.SOURCE_TABLE;
                        p_target_table := cur.DESTINATION_TABLE;
                        
                          SELECT listagg(Data_Modification||'('||source_column||')', ',') within GROUP (order by destination_column)  into v_src_input_field_list 
                     FROM data_mapping WHERE upper(source_table) = upper(p_source_table) and upper(destination_table)= upper(p_target_table) and mapping_type = 'Source_Table' and (decode_column IS  NULL or decode_column = '');   
                        
                    
                        SELECT listagg(destination_column, ',') within GROUP (order by destination_column) into v_target_input_field_list 
                      FROM data_mapping WHERE upper(source_table) = upper(p_source_table) and upper(destination_table)= upper(p_target_table)  and mapping_type = 'Source_Table' and (decode_column IS  NULL or decode_column = '');
        
                        SELECT COUNT(*) INTO v_const_check from data_mapping where mapping_type = 'Constant' and upper(destination_table) = upper(p_target_table) and upper(source_table) = upper(p_source_table);
						
                 IF v_const_check > 0 THEN
	  
                        SELECT listagg(Data_Modification||'('||constant_value||')', ',') within GROUP (order by destination_column) into v_source_constants 
                      FROM data_mapping WHERE upper(source_table) = upper(p_source_table) and upper(destination_table)= upper(p_target_table)  and mapping_type = 'Constant';     
	  

                        SELECT listagg(destination_column, ',') within GROUP (order by destination_column) into v_target_constants 
                           FROM data_mapping WHERE upper(source_table) = upper(p_source_table) and upper(destination_table)= upper(p_target_table)  and mapping_type = 'Constant';     

						   
				 v_src_input_field_list := v_src_input_field_list ||','|| v_source_constants ;
                 v_target_input_field_list := v_target_input_field_list ||','|| v_target_constants ;
         		   
						   
						   
                  END IF;
				 SELECT COUNT(*) INTO v_decode_check from data_mapping where mapping_type = 'Source_Table' and upper(destination_table) = upper(p_target_table) and upper(source_table) = upper(p_source_table)
				 AND DECODE_COLUMN IS NOT NULL OR DECODE_COLUMN <> '';
				 
				 IF v_decode_check > 0 THEN
				 
				 
					 SELECT listagg('DECODE'||'('||SOURCE_COLUMN||','||DECODE_COLUMN||')', ',') within GROUP (order by destination_column) into v_source_decode_cols 
                      FROM data_mapping WHERE upper(source_table) = upper(p_source_table) and upper(destination_table)= upper(p_target_table) and mapping_type = 'Source_Table' and decode_column IS NOT NULL or decode_column <> '';
					  
					  SELECT listagg(destination_column, ',') within GROUP (order by destination_column) into v_target_decode_cols 
                           FROM data_mapping WHERE upper(source_table) = upper(p_source_table) and upper(destination_table)= upper(p_target_table) and mapping_type = 'Source_Table' and decode_column IS NOT NULL or decode_column <> '';    

					  
				 v_src_input_field_list := v_src_input_field_list ||','|| v_source_decode_cols ;
                 v_target_input_field_list := v_target_input_field_list ||','|| v_target_decode_cols ;
				 
				 END IF;
						
                   
                      v_insert_syntax :=    'INSERT INTO ' || p_target_table || '(' || v_target_input_field_list || ') 
                            select '|| v_src_input_field_list || ' from '|| p_source_table ||'';
                            
                            
                     execute Immediate v_insert_syntax;       
         
                    v_src_input_field_list := '';
                    v_target_input_field_list := '';
                        
                        END LOOP;
					EXCEPTION
					WHEN OTHERS THEN
						DBMS_OUTPUT.PUT_LINE(SQLERRM);
					END;]';


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
DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



exec P_GENERATE_PROCEDURE;