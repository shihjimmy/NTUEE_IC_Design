*********************************************
.inc '90nm_bulk.l'
.SUBCKT FA1 DVDD GND A B Ci Co S
*.PININFO   DVDD:I GND:I A:I B:I Cin:I Co:O S:O
*part1
MM1_P A_bar A DVDD DVDD PMOS l=0.1u w=0.5u   m=1
MM1_N A_bar A GND  GND  NMOS l=0.1u w=0.25u  m=1

*part2
MM2_P Ci_bar Ci DVDD DVDD PMOS l=0.1u w=0.5u   m=1
MM2_N Ci_bar Ci GND  GND  NMOS l=0.1u w=0.25u  m=1

*part3
MM3_P S  Y DVDD DVDD PMOS l=0.1u w=0.5u   m=1
MM3_N S  Y GND  GND  NMOS l=0.1u w=0.25u  m=1

*part4
MM4_P_1 X B A_bar DVDD PMOS l=0.1u w=0.5u   m=1
MM4_N_1 X B A     GND  NMOS l=0.1u w=0.25u  m=1
MM4_P_2 X A_bar B DVDD PMOS l=0.1u w=0.5u   m=1
MM4_N_2 X A     B GND  NMOS l=0.1u w=0.25u  m=1

*part5
MM5_P_1 Y X Ci     DVDD PMOS l=0.1u w=0.5u   m=1
MM5_N_1 Y X Ci_bar GND  NMOS l=0.1u w=0.25u  m=1
MM5_P_2 Y Ci     X DVDD PMOS l=0.1u w=0.5u   m=1
MM5_N_2 Y Ci_bar X GND  NMOS l=0.1u w=0.25u  m=1
 
*part6
MM6_P_1 N1 B DVDD DVDD  PMOS l=0.1u w=0.5u   m=1
MM6_P_2 Z  A N1   DVDD  PMOS l=0.1u w=0.5u   m=1

MM6_N_1 N2 B GND  GND   NMOS l=0.1u w=0.25u  m=1
MM6_N_2 Z  A N2   GND   NMOS l=0.1u w=0.25u  m=1

MM6_P2_1 N3 A  DVDD DVDD PMOS l=0.1u w=0.5u   m=1               
MM6_P2_2 N3 B  DVDD DVDD PMOS l=0.1u w=0.5u   m=1          
MM6_P2_3 Z  Ci N3   DVDD PMOS l=0.1u w=0.5u   m=1        

MM6_N2_1 N4 A  GND  GND  NMOS l=0.1u w=0.25u  m=1              
MM6_N2_2 N4 B  GND  GND  NMOS l=0.1u w=0.25u  m=1    
MM6_N2_3 Z  Ci N4   GND  NMOS l=0.1u w=0.25u  m=1       

MM6_P Co Z DVDD DVDD PMOS l=0.1u w=0.5u   m=1
MM6_N Co Z GND  GND  NMOS l=0.1u w=0.25u  m=1

.ENDS
*********************************************

Vdd DVDD    0   1
Vss GND     0   0

Vin1	A	0	pulse(0 1 7u 100n 100n 800n 2u)
Vin2	B	0	pwl(0n 0v 3u 0v 3.1u 1v 3.9u 1v 4u 0v 5u 0v 5.1u 1v 5.9u 1v 6u 0v 11u 0v 11.1u 1v 11.9u 1v 12u 0v 13u 0v 13.1u 1v 13.9u 1v 14u 0v 15u 0v)
Vin3	Ci	0	pulse(0 1 1u 100n 100n 800n 4u)  

x1  DVDD GND A B Ci Co S   FA1

.tran 500n 15u
.op
.option post
.end