CREATE TABLE SOURCE_VENDORS (
supplier_name varchar2(10),
supplier_id NUMBER(5),
supplier_area varchar2(10),
supplier_details varchar2(10)
);

CREATE TABLE DESTINATION_VENDORS (
supplier_name varchar2(10),
supplier_id NUMBER(5),
supplier_area varchar2(10),
supplier_details varchar2(10)
);

create table map_vendors(
supplier_id NUMBER(5),
supplier_product varchar2(3)
)
;

INSERT INTO source_vendors values ('venkat',23,'Hyd','NA');
INSERT INTO source_vendors values ('ramesh',24,'chn','NA');
INSERT INTO source_vendors values ('kumar',25,'pun','NA');
INSERT INTO source_vendors values ('kiran',26,'mum','NA');
INSERT INTO source_vendors values ('balu',27,'kar','NA');
INSERT INTO source_vendors values ('hemanthh',28,'ker','NA');


insert into map_vendors values (23,'NA');
insert into map_vendors values (24,'NA');
insert into map_vendors values (25,'NA');




CREATE OR REPLACE PROCEDURE p_create_procedure(src IN varchar2,dest IN varchar2,maps IN varchar2) AS
p_source_table_name varchar2(32);
p_destination_table_name varchar2(32);
p_mapping_table_name varchar2(32);
p_src_input_field_list varchar2(4000);
p_dest_input_field_list varchar2(4000);
p_proc_syntax varchar2(6000);

BEGIN
p_source_table_name := src;
p_destination_table_name := dest;
p_mapping_table_name := maps;

select listagg('upper(x.'||column_name, '),') within group (order by column_name) || ')' into p_src_input_field_list 
      from user_tab_columns where table_name = upper('source_vendors');
      

select listagg(column_name, ',') within group (order by column_name)  into p_dest_input_field_list 
      from user_tab_columns where table_name = upper('DESTINATION_VENDORS');      
      
p_proc_syntax := ' INSERT INTO ' || p_destination_table_name || '(' || p_dest_input_field_list || ') select '|| p_src_input_field_list || ' from '|| p_source_table_name || ' x,'|| p_mapping_table_name || ' y
 WHERE x.supplier_id = y.supplier_id(+);';

DBMS_OUTPUT.PUT_LINE(p_proc_syntax);
--INSERT INTO  DESTINATION_VENDORS (SUPPLIER_AREA,SUPPLIER_DETAILS,SUPPLIER_ID,SUPPLIER_NAME)
-- select upper(x.SUPPLIER_AREA),upper(x.SUPPLIER_DETAILS),upper(x.SUPPLIER_ID),upper(x.SUPPLIER_NAME)  from SOURCE_VENDORS x, map_vendors y
-- where x.supplier_id = y.supplier_id(+) ;
END;


exec p_create_procedure('SOURCE_VENDORS','DESTINATION_VENDORS','map_vendors');