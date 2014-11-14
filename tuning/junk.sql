DECLARE
  l_at_openmo_bal  bus_dir_no_instmt.at_open_mo_bal%type;
  l_cd_bus         bus_dir_no_instmt.cd_bus%type;
  l_ky_prod        bus_dir_no_instmt.ky_prod_ordno%type;
  l_at_mo_act      bus_dir_no_instmt.at_mo_act%type;
  
  l_ky_ba          bus-dir_no_instmt.ky_ba%type := 1;
  
BEGIN
  
  select AT_OPEN_MO_BAL ,CD_BUS ,KY_PROD_ORDNO ,AT_MO_ACT
    INTO l_at_openmo_bal, l_cd_bus, l_ky_prod, l_at_mot_act
    from BUS_DIR_NO_INSTMT
    where KY_BA=l_ky_ba

END;
/