SPOOL ep.out

REM set timing on;
REM SHOW PARAMETER OPTIMIZER_MODE


alter session set optimizer_mode = CHOOSE;
--alter session set optimizer_mode = RULE;



DELETE plan_table where statement_id = 'MTI'
/

EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO plan_table
  FOR
  SELECT    A.SR_SEQ_NO,
            A.ID_BA_ESCO, 
            A.KY_BA,
            A.CD_TRAN_ID, 
            A.CD_BUS,
            A.CD_SUPPLIER_ID, 
            A.FL_TAR_ONE_BILL,
            A.SERV_STATE, 
            A.DT_RDG_FROM,
            A.DT_RDG_TO, 
            A.USAGE_TOT,
            A.DT_PRCS, 
            A.AT_SUPP_LIAB,
            A.AT_SUPP_LIAB_SUM, 
            A.AT_TO_PAY_SUPP_SUM,
            A.AT_TO_PAY_SUPP,
            A.TOT_GEN, 
            A.RECUR_CHRG, 
            A.TOT_ASSOC, 
            A.TOT_MTR, 
            A.TOT_TRANSMISS, 
            A.INSTALL_CHRG, 
            A.CUST_DIST, 
            A.GRT_TAX, 
            A.EXCISE_TAX, 
            A.TOT_TAX,
            A.TOT_STATE_TAX
           ,TO_DATE(A.DT_PRCS,'yyyy-mm-dd') + B.no_due_days DUE_DATE
        FROM SUPPLIER_REMIT A
           , SUPPLIER_ACCOUNT B
        WHERE  A.KY_BA = B.KY_BA
          --AND a.sr_seq_no > 0
          AND(      (A.CD_BUS = '0200' AND A.CD_TRAN_ID In ('0095','0400')  )
               OR   (A.CD_TRAN_ID = '0235' AND A.CD_BUS IN ( '7100', '5400'))  )
          AND A.CD_SUPPLIER_ID = 'TESI      '
          AND a.cd_supplier_id = b.ky_supplier_id
          AND A.KY_BA in (51258005,97433004,104700003,140107008,231209000,299543007,449912001,614720008,655495006,661651001,673036005,690276003,810255004,854498007,998667002,1042004009,1072462000,1084609004,1111493005,1121152002,1123949003,1125319003,1180634003,1237411005,1407846003,1482963003,1485799005,1518451003,1556773008,1577426004,1597109004,1640405000,1683169003,1707338002,1719188003,1765659006,1882063006,1909032007,1913351006,1915128005,2000012002,2038225000,2129423009,2144245001,2148301000,2168483003,2197453000,2228513006,2370993009,2377984008,2403634008,2413629000,2469601001,2484020002,2508654002,2576318004,2576566000,2619975005,2723779004,2810990000,2957686003,2960137000,2999570000,3042638007,3068092001,3115673001,3121337007,3135100009,3163928008,3181462003,3196265007,3310265003,3319058004,3432609001,3516927006,3542660009,3550438002,3565094003,3634118007,3637972003,3661441008,3669972000,3684119009,3693450004,3751197004,3763921001,3770803009,3780885004,3848837000,3849559005,3876532001,3899571006,3904426001,3912669001,3930599002,3985026009,3992102005,4038053006,4039572000,4052875004,4087775008,4090290005,4093596004,4132943003,4178146000,4191151009,4196850007,4222924007,4253654003,4301934005,4334710006,4357827004,4361796003,4362246002,4370895000,4441700003,4441892006,4467587000,4510472003,4555684005,4608489009,4641587004,4690839004,4716124000,4730983001,4753573003,4780491003,4790877006,4818324000,4961203005,4971503003,4976715003,5017675003,5071608006,5085788008,5089407004,5129397007,5247000009,5301979005,5331481009,5349418001,5357961002,5385434001,5423797009,5432218002,5479626004,5525125003,5538492004,5551546005,5562469000,5587420009,5637972005,5719149000,5733286000,5762432007,5791532007,5828063006,5881176008,5909186004,5924659008,5924699002,5947302002,5968481008,6012880005,6024492006,6041917002,6043507004,6066505008,6075729007,6126541004,6174443000,6209474006,6331677006,6341420000,6416063008,6432435004,6490902000,6522795004,6556665006,6595829008,6600461001,6602722007,6734460001,6757095002,6772799001,6780256006,6788942009,6795841008,6809109006,6893457000,6976402003,7085470003,7169956000,7173948007,7255951008,7274559006,7385909005,7430232006,7482570004,7552373008,7609972006,7628281002,7644458003,7656471007,7682550006,7721861004,7859370001,7927304002,7935051001,7963336000,7972958005,8023714005,8024415001,8056981007,8060610002,8082359008,8166364001,8301153004,8331915003,8337247004,8351444005,8396198000,8398686003,8430623008,8462617007,8488605007,8541740003,8543945006,8596906006,8600256002,8639543005,8680929004,8822656000,8828060008,8836562002,8873647000,8907903000,9033274000,9047408005,9123573007,9202759009,9251313004,9255158009,9284004001,9331873001,9435810002,9446325005,9455973000,9490453005,9508411004,9566335009,9578698002,9595346007,9601954008,9624465004,9732860006,9772995006,9777985000,9784895002,9859873009,9865908004,9946971007,9996146009,2802002,591825008,761326005,875855002,940896006,1024347001,1608836005,2105305004,2137893006,2534832009,2688389006,2811356002,2891880007,3017314003,3338808006,3572841003,3672360005,3893413005,3988811000,4018317009,4198365001,4370899008,4475845002,4604396003,5054443001,5107302004,5223848007,5505815006,5582818009,5710369006,5942370000,6067857001,6145310001,6444992005,6457482009,6589809009,6712398006,6862374003,6883820000,7082962004,7510839001,7761887000,7804850009,7814923000,8125340005,8163344007,8203322005,8351453004,8386875009,8522331002,8625363008,8668884006,8779335007,8786386005,8918308002,9424827000,9472391002,9477329006,9515377008,9548878001,9570871009,9580338002,9635866008,9756869001,160007009,179546000,254594002,565908009,1016054006,1158537002,1168681008,1939288008,1959493005,2071564006,2130576002,2687376005,2939094007,3130596005,3344933001,3428504002,3443519009,3614210000,3727412001,3875534001,3892085007,3962453008,4000677005,4262096000,4380024004,5042462005,5210507006,5412089005,5561597005,5662066001,5762027006,5851640004,5855347004,5989052007,6113890007,6114855002,6151342000,6299075000,6473018009,6655949005,6692555003,6755972006,6851227002,7160948002,7401006001,7637073009,7677766001,7687180004,7883423002,7926121009,8272045000,8328015003,8570525001,8712037000,8767087005,8916585001,9329726006,9359567006,9436903006,9441057002,9925517003,10581003,194588004,214040007,472063004,575027002,684809005,983525006,1031500009,1186590000,1363899004,1834528005,1943555003,1949012007,1960530000,2076012007,2213558002,2246009005,2468585008,2504505008,2787551000,2879329005,3143015000,3159045005,3224512004,3229049006,3290869003,3306398008,3404068009,3587033004,3940002007,4059062005,4114567005,4172561003,4277069006,4423341006,4519550008,4623582001,4634051008,4785564001,4865036008,5064370006,5141003004,5155099009,5396084008,5427302006,5721093004,5810080002,5866087000,5876594003,6124560001,6217591007,6232552006,6292310006,6319072007,6441542003,6491820007,6611006007,6618033002,6732359005,6876597005,6878525007,6926081009,6935575005,7003537001,7181535005,7286519003,7324546006,7434041001,7502057004,7617019009,7655055009,7728389005,7776579006,7871081003,7902071002,8013507007,8159020003,8300576003,8399531007,8500879003,8544521000,8972839006,9121021000,9133514001,9198096006,9345050007,9511042004,9537027007,9577516001,9617850002,9629880001,9883075008,9888543001,432111003,1053542001,2699503003,6468063001,7647033008,8956573003,1749396004,3388827006,8412967007,73679008,249187004,254667000,289118001,299171001,304697005,394232001,488952003,662688002,684649009,742183008,774023004,1036211007,1149127007,1228658009,1310721004,1541199009,1830212006,1884676001,1998628006,2427616002,2693120000,3375196001,3452619003,3685182006,4044655007,4653191009,4840914001,5342235004,5793109006,6873139001,8030015008,8104607005,8226178005,8751790000,8760630008,8831166000,8873155007,9146169001,9337150007,9356051001,9407181005,9423660001,9455646008,9484564006,9555148009,9578686002,9702600001,9892157004,9969637008,8670337003,1788997009,2547485005,7762926006,8327965004,8523416004,34997003,8325466008,9850976009,3738161006,887612008,3083577005,4873079008,6833226007,812399009,1032800008,9789321007,2372445006,2839707007,7677713000)
          AND TRUNC(TO_DATE(A.DT_PRCS, 'yyyy-mm-dd')) between trunc(to_date('01-JAN-2011','DD-MON-YYYY')) AND trunc(to_date('31-DEC-2011','DD-MON-YYYY'))
/

@utlxpls.sql

spool off
