create or replace procedure VALIDATE_USER(username in varchar2, password in varchar2, outstatus OUT VARCHAR2)
authid current_user
is
	--
	raw_key raw(128):= hextoraw('0123456789ABCDEF');
	--
	raw_ip raw(128);
	pwd_hash varchar2(16);
	--
	cursor c_user (cp_name in varchar2) is
	select 	password
	from sys.user$
	where password is not null
	and name=cp_name;
	--
	procedure unicode_str(userpwd in varchar2, unistr out raw)
	is
		enc_str varchar2(124):='';
		tot_len number;
		curr_char char(1);
		padd_len number;
		ch char(1);
		mod_len number;
		debugp varchar2(256);
	begin
		tot_len:=length(userpwd);
		for i in 1..tot_len loop
			curr_char:=substr(userpwd,i,1);
			enc_str:=enc_str||chr(0)||curr_char;
		end loop;
		mod_len:= mod((tot_len*2),8);
		if (mod_len = 0) then
			padd_len:= 0;
		else
			padd_len:=8 - mod_len;
		end if;
		for i in 1..padd_len loop
			enc_str:=enc_str||chr(0);
		end loop;
		unistr:=utl_raw.cast_to_raw(enc_str);
	end;
	--
	function crack (userpwd in raw) return varchar2 
	is
		enc_raw raw(2048);
		--
		raw_key2 raw(128);
		pwd_hash raw(2048);
		--
		hexstr varchar2(2048);
		len number;
		password_hash varchar2(16);	
	begin
		dbms_obfuscation_toolkit.DESEncrypt(input => userpwd, 
		       key => raw_key, encrypted_data => enc_raw );
		hexstr:=rawtohex(enc_raw);
		len:=length(hexstr);
		raw_key2:=hextoraw(substr(hexstr,(len-16+1),16));
		dbms_obfuscation_toolkit.DESEncrypt(input => userpwd, 
		       key => raw_key2, encrypted_data => pwd_hash );
		hexstr:=hextoraw(pwd_hash);
		len:=length(hexstr);
		password_hash:=substr(hexstr,(len-16+1),16);
		return(password_hash);
	end;
begin
	open c_user(upper(username));
	fetch c_user into pwd_hash;
	close c_user;
	unicode_str(upper(username)||upper(password),raw_ip);
	if( pwd_hash = crack(raw_ip)) then
    --dbms_output.put_line('Y');
		--return ('Y');
        outstatus := 'Yo Validated Successfully..!';
	else
    --dbms_output.put_line('N');
     outstatus := 'Validation Unsuccesfull :(';
	--	return ('N');
	end if;
end;
/









DECLARE
  USERNAME VARCHAR2(200);
  PASSWORD VARCHAR2(200);
  OUTSTATUS VARCHAR2(200);
BEGIN
  USERNAME := 'vgunnam';
  PASSWORD := '225726';

  TESTPWDS(
    USERNAME => USERNAME,
    PASSWORD => PASSWORD,
    OUTSTATUS => OUTSTATUS
  );
 
DBMS_OUTPUT.PUT_LINE('OUTSTATUS = ' || OUTSTATUS);

 -- :OUTSTATUS := OUTSTATUS;
--rollback; 
END;
