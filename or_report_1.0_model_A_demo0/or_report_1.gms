Free variable
    Z "objective" ;
    
Positive variable
    x_ab ,
    x_ac ,
    x_ad ,
    x_ae ,
    x_bc ,
    x_bd ,
    x_be ,
    x_cd ,
    x_ce ,
    x_de ,
    
    x_ba ,
    x_ca ,
    x_da ,
    x_ea ,
    x_cb ,
    x_db ,
    x_eb ,
    x_dc ,
    x_ec ,
    x_ed ;
    
Equation
    eq_z "obj " ,
    eq_a "a_out" ,
    eq_e "e_in" ,
    eq_b "b" ,
    eq_c "c" ,
    eq_d "e" ,
    
    eq_x__ab ,
    eq_x__ac ,
    eq_x__ad ,
    eq_x__ae ,
    eq_x__bc ,
    eq_x__bd ,
    eq_x__be ,
    eq_x__cd ,
    eq_x__ce ,
    eq_x__de ,
    
    eq_x__ba ,
    eq_x__ca ,
    eq_x__da ,
    eq_x__ea ,
    eq_x__cb ,
    eq_x__db ,
    eq_x__eb ,
    eq_x__dc ,
    eq_x__ec ,
    eq_x__ed ;
    

    eq_z .. Z =e= x_ab + x_ac + x_ad + x_ae + x_bc+ x_bd + x_be + x_cd + x_ce + x_de  +  x_ba + x_ca + x_da + x_ea + x_cb + x_db + x_eb + x_dc + x_ec + x_ed ;
    eq_a .. x_ab + x_ac + x_ad + x_ae - x_ba - x_ca - x_da - x_ea =e= 100 ;
    eq_e .. x_ea + x_eb + x_ec + x_ed - x_ae - x_be - x_ce - x_de =e= -100 ;
    eq_b .. x_ba + x_bc + x_bd + x_be - x_ab - x_cb - x_db - x_eb =e= 0 ;
    eq_c .. x_ca + x_cb + x_cd + x_ce - x_ac - x_bc - x_dc - x_ec =e= 0 ;
    eq_d .. x_da + x_db + x_dc + x_de - x_ad - x_bd - x_cd - x_ed =e= 0 ;
    
    eq_x__ab .. x_ab =l= 100 ; 
    eq_x__ac .. x_ac =l= 100 ; 
    eq_x__ad .. x_ad =l= 100 ; 
    eq_x__ae .. x_ae =l= 100 ; 
    eq_x__bc .. x_bc =l= 100 ; 
    eq_x__bd .. x_bd =l= 100 ; 
    eq_x__be .. x_be =l= 100 ; 
    eq_x__cd .. x_cd =l= 100 ; 
    eq_x__ce .. x_ce =l= 100 ; 
    eq_x__de .. x_de =l= 100 ; 
    
    eq_x__ba .. x_ba =l= 100 ; 
    eq_x__ca .. x_ca =l= 100 ; 
    eq_x__da .. x_da =l= 100 ; 
    eq_x__ea .. x_ea =l= 100 ; 
    eq_x__cb .. x_cb =l= 100 ; 
    eq_x__db .. x_db =l= 100 ; 
    eq_x__eb .. x_eb =l= 100 ; 
    eq_x__dc .. x_dc =l= 100 ; 
    eq_x__ec .. x_ec =l= 100 ; 
    eq_x__ed .. x_ed =l= 100 ; 

Model
    model_test /all/;
    
Solve model_test using LP min Z;

parameter
    a  /2/,
    b  /2/,
    c  ;
    
c = a-b;
display c;
execute_unload 'or_report.1.0.gdx', a , b ,c;
    
