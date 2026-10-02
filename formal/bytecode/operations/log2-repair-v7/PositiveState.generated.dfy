// SPDX-License-Identifier: MIT
// Generated exact current log2 executed-byte certificate. Never edit directly.
include "Kernel.dfy"
include "Binary.dfy"
module OperationsBytecodeLog2PositiveState {
  import opened OperationsBytecodeLog2Machine
  import K = OperationsBytecodeLog2Kernel
  import F = OperationsBytecodeLog2Math
  import B = OperationsBytecodeLog2BinaryKernel
  function Result(a: Word): Word { F.Log(a)%Modulus() }
  predicate Admitted(value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) { value==0 && 36<=size<0x10000000000000000 && Selector(word)==0x5456bf13 && a>0 }
  opaque predicate Matches(code: seq<Byte>) { |code|==21346 &&
                                              code[0]==96 &&
                                              code[1]==128 &&
                                              code[2]==96 &&
                                              code[3]==64 &&
                                              code[4]==82 &&
                                              code[5]==52 &&
                                              code[6]==128 &&
                                              code[7]==21 &&
                                              code[8]==97 &&
                                              code[9]==0 &&
                                              code[10]==15 &&
                                              code[11]==87 &&
                                              code[15]==91 &&
                                              code[16]==80 &&
                                              code[17]==96 &&
                                              code[18]==4 &&
                                              code[19]==54 &&
                                              code[20]==16 &&
                                              code[21]==97 &&
                                              code[22]==4 &&
                                              code[23]==242 &&
                                              code[24]==87 &&
                                              code[25]==95 &&
                                              code[26]==53 &&
                                              code[27]==96 &&
                                              code[28]==224 &&
                                              code[29]==28 &&
                                              code[30]==128 &&
                                              code[31]==99 &&
                                              code[32]==129 &&
                                              code[33]==254 &&
                                              code[34]==87 &&
                                              code[35]==134 &&
                                              code[36]==17 &&
                                              code[37]==97 &&
                                              code[38]==2 &&
                                              code[39]==143 &&
                                              code[40]==87 &&
                                              code[655]==91 &&
                                              code[656]==128 &&
                                              code[657]==99 &&
                                              code[658]==64 &&
                                              code[659]==129 &&
                                              code[660]==111 &&
                                              code[661]==174 &&
                                              code[662]==17 &&
                                              code[663]==97 &&
                                              code[664]==3 &&
                                              code[665]==200 &&
                                              code[666]==87 &&
                                              code[667]==128 &&
                                              code[668]==99 &&
                                              code[669]==101 &&
                                              code[670]==82 &&
                                              code[671]==241 &&
                                              code[672]==135 &&
                                              code[673]==17 &&
                                              code[674]==97 &&
                                              code[675]==3 &&
                                              code[676]==60 &&
                                              code[677]==87 &&
                                              code[828]==91 &&
                                              code[829]==128 &&
                                              code[830]==99 &&
                                              code[831]==84 &&
                                              code[832]==86 &&
                                              code[833]==191 &&
                                              code[834]==19 &&
                                              code[835]==17 &&
                                              code[836]==97 &&
                                              code[837]==3 &&
                                              code[838]==141 &&
                                              code[839]==87 &&
                                              code[840]==128 &&
                                              code[841]==99 &&
                                              code[842]==84 &&
                                              code[843]==86 &&
                                              code[844]==191 &&
                                              code[845]==19 &&
                                              code[846]==20 &&
                                              code[847]==97 &&
                                              code[848]==7 &&
                                              code[849]==59 &&
                                              code[850]==87 &&
                                              code[909]==91 &&
                                              code[968]==91 &&
                                              code[1266]==91 &&
                                              code[1301]==91 &&
                                              code[1302]==96 &&
                                              code[1303]==64 &&
                                              code[1304]==81 &&
                                              code[1305]==128 &&
                                              code[1306]==145 &&
                                              code[1307]==3 &&
                                              code[1308]==144 &&
                                              code[1309]==243 &&
                                              code[1329]==91 &&
                                              code[1330]==96 &&
                                              code[1331]==64 &&
                                              code[1332]==81 &&
                                              code[1333]==144 &&
                                              code[1334]==129 &&
                                              code[1335]==82 &&
                                              code[1336]==96 &&
                                              code[1337]==32 &&
                                              code[1338]==1 &&
                                              code[1339]==97 &&
                                              code[1340]==5 &&
                                              code[1341]==21 &&
                                              code[1342]==86 &&
                                              code[1851]==91 &&
                                              code[1852]==97 &&
                                              code[1853]==5 &&
                                              code[1854]==49 &&
                                              code[1855]==97 &&
                                              code[1856]==7 &&
                                              code[1857]==73 &&
                                              code[1858]==54 &&
                                              code[1859]==96 &&
                                              code[1860]==4 &&
                                              code[1861]==97 &&
                                              code[1862]==74 &&
                                              code[1863]==11 &&
                                              code[1864]==86 &&
                                              code[1865]==91 &&
                                              code[1866]==97 &&
                                              code[1867]==18 &&
                                              code[1868]==45 &&
                                              code[1869]==86 &&
                                              code[2984]==91 &&
                                              code[2985]==146 &&
                                              code[2986]==145 &&
                                              code[2987]==80 &&
                                              code[2988]==80 &&
                                              code[2989]==86 &&
                                              code[4653]==91 &&
                                              code[4654]==95 &&
                                              code[4655]==129 &&
                                              code[4656]==95 &&
                                              code[4657]==3 &&
                                              code[4658]==97 &&
                                              code[4659]==18 &&
                                              code[4660]==80 &&
                                              code[4661]==87 &&
                                              code[4688]==91 &&
                                              code[4689]==97 &&
                                              code[4690]==11 &&
                                              code[4691]==168 &&
                                              code[4692]==130 &&
                                              code[4693]==97 &&
                                              code[4694]==42 &&
                                              code[4695]==241 &&
                                              code[4696]==86 &&
                                              code[10993]==91 &&
                                              code[10994]==95 &&
                                              code[10995]==96 &&
                                              code[10996]==7 &&
                                              code[10997]==111 &&
                                              code[10998]==255 &&
                                              code[10999]==255 &&
                                              code[11000]==255 &&
                                              code[11001]==255 &&
                                              code[11002]==255 &&
                                              code[11003]==255 &&
                                              code[11004]==255 &&
                                              code[11005]==255 &&
                                              code[11006]==255 &&
                                              code[11007]==255 &&
                                              code[11008]==255 &&
                                              code[11009]==255 &&
                                              code[11010]==255 &&
                                              code[11011]==255 &&
                                              code[11012]==255 &&
                                              code[11013]==255 &&
                                              code[11014]==131 &&
                                              code[11015]==17 &&
                                              code[11016]==144 &&
                                              code[11017]==27 &&
                                              code[11018]==144 &&
                                              code[11019]==80 &&
                                              code[11020]==96 &&
                                              code[11021]==6 &&
                                              code[11022]==96 &&
                                              code[11023]==1 &&
                                              code[11024]==96 &&
                                              code[11025]==1 &&
                                              code[11026]==96 &&
                                              code[11027]==64 &&
                                              code[11028]==27 &&
                                              code[11029]==3 &&
                                              code[11030]==131 &&
                                              code[11031]==131 &&
                                              code[11032]==28 &&
                                              code[11033]==17 &&
                                              code[11034]==144 &&
                                              code[11035]==27 &&
                                              code[11036]==23 &&
                                              code[11037]==96 &&
                                              code[11038]==5 &&
                                              code[11039]==99 &&
                                              code[11040]==255 &&
                                              code[11041]==255 &&
                                              code[11042]==255 &&
                                              code[11043]==255 &&
                                              code[11044]==131 &&
                                              code[11045]==131 &&
                                              code[11046]==28 &&
                                              code[11047]==17 &&
                                              code[11048]==144 &&
                                              code[11049]==27 &&
                                              code[11050]==23 &&
                                              code[11051]==96 &&
                                              code[11052]==4 &&
                                              code[11053]==97 &&
                                              code[11054]==255 &&
                                              code[11055]==255 &&
                                              code[11056]==131 &&
                                              code[11057]==131 &&
                                              code[11058]==28 &&
                                              code[11059]==17 &&
                                              code[11060]==144 &&
                                              code[11061]==27 &&
                                              code[11062]==23 &&
                                              code[11063]==96 &&
                                              code[11064]==3 &&
                                              code[11065]==96 &&
                                              code[11066]==255 &&
                                              code[11067]==131 &&
                                              code[11068]==131 &&
                                              code[11069]==28 &&
                                              code[11070]==17 &&
                                              code[11071]==144 &&
                                              code[11072]==27 &&
                                              code[11073]==23 &&
                                              code[11074]==96 &&
                                              code[11075]==2 &&
                                              code[11076]==96 &&
                                              code[11077]==15 &&
                                              code[11078]==131 &&
                                              code[11079]==131 &&
                                              code[11080]==28 &&
                                              code[11081]==17 &&
                                              code[11082]==109 &&
                                              code[11083]==1 &&
                                              code[11084]==1 &&
                                              code[11085]==2 &&
                                              code[11086]==2 &&
                                              code[11087]==2 &&
                                              code[11088]==2 &&
                                              code[11089]==3 &&
                                              code[11090]==3 &&
                                              code[11091]==3 &&
                                              code[11092]==3 &&
                                              code[11093]==3 &&
                                              code[11094]==3 &&
                                              code[11095]==3 &&
                                              code[11096]==3 &&
                                              code[11097]==96 &&
                                              code[11098]==128 &&
                                              code[11099]==27 &&
                                              code[11100]==145 &&
                                              code[11101]==27 &&
                                              code[11102]==145 &&
                                              code[11103]==144 &&
                                              code[11104]==145 &&
                                              code[11105]==23 &&
                                              code[11106]==145 &&
                                              code[11107]==130 &&
                                              code[11108]==28 &&
                                              code[11109]==26 &&
                                              code[11110]==23 &&
                                              code[11111]==144 &&
                                              code[11112]==86 &&
                                              code[18955]==91 &&
                                              code[18956]==95 &&
                                              code[18957]==96 &&
                                              code[18958]==32 &&
                                              code[18959]==130 &&
                                              code[18960]==132 &&
                                              code[18961]==3 &&
                                              code[18962]==18 &&
                                              code[18963]==21 &&
                                              code[18964]==97 &&
                                              code[18965]==74 &&
                                              code[18966]==27 &&
                                              code[18967]==87 &&
                                              code[18971]==91 &&
                                              code[18972]==80 &&
                                              code[18973]==53 &&
                                              code[18974]==145 &&
                                              code[18975]==144 &&
                                              code[18976]==80 &&
                                              code[18977]==86
  }
  function Destinations(): set<nat> { {15,655,828,909,968,1266,1301,1329,1851,1865,2984,4653,4688,10993,18955,18971} }
  opaque predicate Good(id: nat,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) {
    if id==0 then state==Running(0,[],[])
    else if id==1 then state==Running(2,[128],[])
    else if id==2 then state==Running(4,[128,64],[])
    else if id==3 then state==Running(5,[],Store([],64,128))
    else if id==4 then state==Running(6,[value],Store([],64,128))
    else if id==5 then state==Running(7,[value,value],Store([],64,128))
    else if id==6 then state==Running(8,[value,K.Bool((value)==0)],Store([],64,128))
    else if id==7 then state==Running(11,[value,K.Bool((value)==0),15],Store([],64,128))
    else if id==8 then state==Running(15,[value],Store([],64,128))
    else if id==9 then state==Running(16,[value],Store([],64,128))
    else if id==10 then state==Running(17,[],Store([],64,128))
    else if id==11 then state==Running(19,[4],Store([],64,128))
    else if id==12 then state==Running(20,[4,size],Store([],64,128))
    else if id==13 then state==Running(21,[K.Bool((size)<(4))],Store([],64,128))
    else if id==14 then state==Running(24,[K.Bool((size)<(4)),1266],Store([],64,128))
    else if id==15 then state==Running(25,[],Store([],64,128))
    else if id==16 then state==Running(26,[0],Store([],64,128))
    else if id==17 then state==Running(27,[word],Store([],64,128))
    else if id==18 then state==Running(29,[word,224],Store([],64,128))
    else if id==19 then state==Running(30,[1414971155],Store([],64,128))
    else if id==20 then state==Running(31,[1414971155,1414971155],Store([],64,128))
    else if id==21 then state==Running(36,[1414971155,1414971155,2180929414],Store([],64,128))
    else if id==22 then state==Running(37,[1414971155,1],Store([],64,128))
    else if id==23 then state==Running(40,[1414971155,1,655],Store([],64,128))
    else if id==24 then state==Running(655,[1414971155],Store([],64,128))
    else if id==25 then state==Running(656,[1414971155],Store([],64,128))
    else if id==26 then state==Running(657,[1414971155,1414971155],Store([],64,128))
    else if id==27 then state==Running(662,[1414971155,1414971155,1082224558],Store([],64,128))
    else if id==28 then state==Running(663,[1414971155,0],Store([],64,128))
    else if id==29 then state==Running(666,[1414971155,0,968],Store([],64,128))
    else if id==30 then state==Running(667,[1414971155],Store([],64,128))
    else if id==31 then state==Running(668,[1414971155,1414971155],Store([],64,128))
    else if id==32 then state==Running(673,[1414971155,1414971155,1699934599],Store([],64,128))
    else if id==33 then state==Running(674,[1414971155,1],Store([],64,128))
    else if id==34 then state==Running(677,[1414971155,1,828],Store([],64,128))
    else if id==35 then state==Running(828,[1414971155],Store([],64,128))
    else if id==36 then state==Running(829,[1414971155],Store([],64,128))
    else if id==37 then state==Running(830,[1414971155,1414971155],Store([],64,128))
    else if id==38 then state==Running(835,[1414971155,1414971155,1414971155],Store([],64,128))
    else if id==39 then state==Running(836,[1414971155,0],Store([],64,128))
    else if id==40 then state==Running(839,[1414971155,0,909],Store([],64,128))
    else if id==41 then state==Running(840,[1414971155],Store([],64,128))
    else if id==42 then state==Running(841,[1414971155,1414971155],Store([],64,128))
    else if id==43 then state==Running(846,[1414971155,1414971155,1414971155],Store([],64,128))
    else if id==44 then state==Running(847,[1414971155,1],Store([],64,128))
    else if id==45 then state==Running(850,[1414971155,1,1851],Store([],64,128))
    else if id==46 then state==Running(1851,[1414971155],Store([],64,128))
    else if id==47 then state==Running(1852,[1414971155],Store([],64,128))
    else if id==48 then state==Running(1855,[1414971155,1329],Store([],64,128))
    else if id==49 then state==Running(1858,[1414971155,1329,1865],Store([],64,128))
    else if id==50 then state==Running(1859,[1414971155,1329,1865,size],Store([],64,128))
    else if id==51 then state==Running(1861,[1414971155,1329,1865,size,4],Store([],64,128))
    else if id==52 then state==Running(1864,[1414971155,1329,1865,size,4,18955],Store([],64,128))
    else if id==53 then state==Running(18955,[1414971155,1329,1865,size,4],Store([],64,128))
    else if id==54 then state==Running(18956,[1414971155,1329,1865,size,4],Store([],64,128))
    else if id==55 then state==Running(18957,[1414971155,1329,1865,size,4,0],Store([],64,128))
    else if id==56 then state==Running(18959,[1414971155,1329,1865,size,4,0,32],Store([],64,128))
    else if id==57 then state==Running(18960,[1414971155,1329,1865,size,4,0,32,4],Store([],64,128))
    else if id==58 then state==Running(18961,[1414971155,1329,1865,size,4,0,32,4,size],Store([],64,128))
    else if id==59 then state==Running(18962,[1414971155,1329,1865,size,4,0,32,(((size) as nat)+Modulus()-((4) as nat))%Modulus()],Store([],64,128))
    else if id==60 then state==Running(18963,[1414971155,1329,1865,size,4,0,K.Bool(Signed((((size) as nat)+Modulus()-((4) as nat))%Modulus())<Signed(32))],Store([],64,128))
    else if id==61 then state==Running(18964,[1414971155,1329,1865,size,4,0,K.Bool((K.Bool(Signed((((size) as nat)+Modulus()-((4) as nat))%Modulus())<Signed(32)))==0)],Store([],64,128))
    else if id==62 then state==Running(18967,[1414971155,1329,1865,size,4,0,K.Bool((K.Bool(Signed((((size) as nat)+Modulus()-((4) as nat))%Modulus())<Signed(32)))==0),18971],Store([],64,128))
    else if id==63 then state==Running(18971,[1414971155,1329,1865,size,4,0],Store([],64,128))
    else if id==64 then state==Running(18972,[1414971155,1329,1865,size,4,0],Store([],64,128))
    else if id==65 then state==Running(18973,[1414971155,1329,1865,size,4],Store([],64,128))
    else if id==66 then state==Running(18974,[1414971155,1329,1865,size,a],Store([],64,128))
    else if id==67 then state==Running(18975,[1414971155,1329,a,size,1865],Store([],64,128))
    else if id==68 then state==Running(18976,[1414971155,1329,a,1865,size],Store([],64,128))
    else if id==69 then state==Running(18977,[1414971155,1329,a,1865],Store([],64,128))
    else if id==70 then state==Running(1865,[1414971155,1329,a],Store([],64,128))
    else if id==71 then state==Running(1866,[1414971155,1329,a],Store([],64,128))
    else if id==72 then state==Running(1869,[1414971155,1329,a,4653],Store([],64,128))
    else if id==73 then state==Running(4653,[1414971155,1329,a],Store([],64,128))
    else if id==74 then state==Running(4654,[1414971155,1329,a],Store([],64,128))
    else if id==75 then state==Running(4655,[1414971155,1329,a,0],Store([],64,128))
    else if id==76 then state==Running(4656,[1414971155,1329,a,0,a],Store([],64,128))
    else if id==77 then state==Running(4657,[1414971155,1329,a,0,a,0],Store([],64,128))
    else if id==78 then state==Running(4658,[1414971155,1329,a,0,(((0) as nat)+Modulus()-((a) as nat))%Modulus()],Store([],64,128))
    else if id==79 then state==Running(4661,[1414971155,1329,a,0,(((0) as nat)+Modulus()-((a) as nat))%Modulus(),4688],Store([],64,128))
    else if id==80 then state==Running(4688,[1414971155,1329,a,0],Store([],64,128))
    else if id==81 then state==Running(4689,[1414971155,1329,a,0],Store([],64,128))
    else if id==82 then state==Running(4692,[1414971155,1329,a,0,2984],Store([],64,128))
    else if id==83 then state==Running(4693,[1414971155,1329,a,0,2984,a],Store([],64,128))
    else if id==84 then state==Running(4696,[1414971155,1329,a,0,2984,a,10993],Store([],64,128))
    else if id==85 then state==Running(10993,[1414971155,1329,a,0,2984,a],Store([],64,128))
    else if id==86 then state==Running(10994,[1414971155,1329,a,0,2984,a],Store([],64,128))
    else if id==87 then state==Running(10995,[1414971155,1329,a,0,2984,a,0],Store([],64,128))
    else if id==88 then state==Running(10997,[1414971155,1329,a,0,2984,a,0,7],Store([],64,128))
    else if id==89 then state==Running(11014,[1414971155,1329,a,0,2984,a,0,7,340282366920938463463374607431768211455],Store([],64,128))
    else if id==90 then state==Running(11015,[1414971155,1329,a,0,2984,a,0,7,340282366920938463463374607431768211455,a],Store([],64,128))
    else if id==91 then state==Running(11016,[1414971155,1329,a,0,2984,a,0,7,K.Bool((a)>(340282366920938463463374607431768211455))],Store([],64,128))
    else if id==92 then state==Running(11017,[1414971155,1329,a,0,2984,a,0,K.Bool((a)>(340282366920938463463374607431768211455)),7],Store([],64,128))
    else if id==93 then state==Running(11018,[1414971155,1329,a,0,2984,a,0,K.R128(a)],Store([],64,128))
    else if id==94 then state==Running(11019,[1414971155,1329,a,0,2984,a,K.R128(a),0],Store([],64,128))
    else if id==95 then state==Running(11020,[1414971155,1329,a,0,2984,a,K.R128(a)],Store([],64,128))
    else if id==96 then state==Running(11022,[1414971155,1329,a,0,2984,a,K.R128(a),6],Store([],64,128))
    else if id==97 then state==Running(11024,[1414971155,1329,a,0,2984,a,K.R128(a),6,1],Store([],64,128))
    else if id==98 then state==Running(11026,[1414971155,1329,a,0,2984,a,K.R128(a),6,1,1],Store([],64,128))
    else if id==99 then state==Running(11028,[1414971155,1329,a,0,2984,a,K.R128(a),6,1,1,64],Store([],64,128))
    else if id==100 then state==Running(11029,[1414971155,1329,a,0,2984,a,K.R128(a),6,1,18446744073709551616],Store([],64,128))
    else if id==101 then state==Running(11030,[1414971155,1329,a,0,2984,a,K.R128(a),6,18446744073709551615],Store([],64,128))
    else if id==102 then state==Running(11031,[1414971155,1329,a,0,2984,a,K.R128(a),6,18446744073709551615,a],Store([],64,128))
    else if id==103 then state==Running(11032,[1414971155,1329,a,0,2984,a,K.R128(a),6,18446744073709551615,a,K.R128(a)],Store([],64,128))
    else if id==104 then state==Running(11033,[1414971155,1329,a,0,2984,a,K.R128(a),6,18446744073709551615,Right(a,K.R128(a))],Store([],64,128))
    else if id==105 then state==Running(11034,[1414971155,1329,a,0,2984,a,K.R128(a),6,K.Bool((Right(a,K.R128(a)))>(18446744073709551615))],Store([],64,128))
    else if id==106 then state==Running(11035,[1414971155,1329,a,0,2984,a,K.R128(a),K.Bool((Right(a,K.R128(a)))>(18446744073709551615)),6],Store([],64,128))
    else if id==107 then state==Running(11036,[1414971155,1329,a,0,2984,a,K.R128(a),Shift(K.Bool((Right(a,K.R128(a)))>(18446744073709551615)),6)],Store([],64,128))
    else if id==108 then state==Running(11037,[1414971155,1329,a,0,2984,a,K.R64(a)],Store([],64,128))
    else if id==109 then state==Running(11039,[1414971155,1329,a,0,2984,a,K.R64(a),5],Store([],64,128))
    else if id==110 then state==Running(11044,[1414971155,1329,a,0,2984,a,K.R64(a),5,4294967295],Store([],64,128))
    else if id==111 then state==Running(11045,[1414971155,1329,a,0,2984,a,K.R64(a),5,4294967295,a],Store([],64,128))
    else if id==112 then state==Running(11046,[1414971155,1329,a,0,2984,a,K.R64(a),5,4294967295,a,K.R64(a)],Store([],64,128))
    else if id==113 then state==Running(11047,[1414971155,1329,a,0,2984,a,K.R64(a),5,4294967295,Right(a,K.R64(a))],Store([],64,128))
    else if id==114 then state==Running(11048,[1414971155,1329,a,0,2984,a,K.R64(a),5,K.Bool((Right(a,K.R64(a)))>(4294967295))],Store([],64,128))
    else if id==115 then state==Running(11049,[1414971155,1329,a,0,2984,a,K.R64(a),K.Bool((Right(a,K.R64(a)))>(4294967295)),5],Store([],64,128))
    else if id==116 then state==Running(11050,[1414971155,1329,a,0,2984,a,K.R64(a),Shift(K.Bool((Right(a,K.R64(a)))>(4294967295)),5)],Store([],64,128))
    else if id==117 then state==Running(11051,[1414971155,1329,a,0,2984,a,K.R32(a)],Store([],64,128))
    else if id==118 then state==Running(11053,[1414971155,1329,a,0,2984,a,K.R32(a),4],Store([],64,128))
    else if id==119 then state==Running(11056,[1414971155,1329,a,0,2984,a,K.R32(a),4,65535],Store([],64,128))
    else if id==120 then state==Running(11057,[1414971155,1329,a,0,2984,a,K.R32(a),4,65535,a],Store([],64,128))
    else if id==121 then state==Running(11058,[1414971155,1329,a,0,2984,a,K.R32(a),4,65535,a,K.R32(a)],Store([],64,128))
    else if id==122 then state==Running(11059,[1414971155,1329,a,0,2984,a,K.R32(a),4,65535,Right(a,K.R32(a))],Store([],64,128))
    else if id==123 then state==Running(11060,[1414971155,1329,a,0,2984,a,K.R32(a),4,K.Bool((Right(a,K.R32(a)))>(65535))],Store([],64,128))
    else if id==124 then state==Running(11061,[1414971155,1329,a,0,2984,a,K.R32(a),K.Bool((Right(a,K.R32(a)))>(65535)),4],Store([],64,128))
    else if id==125 then state==Running(11062,[1414971155,1329,a,0,2984,a,K.R32(a),Shift(K.Bool((Right(a,K.R32(a)))>(65535)),4)],Store([],64,128))
    else if id==126 then state==Running(11063,[1414971155,1329,a,0,2984,a,K.R16(a)],Store([],64,128))
    else if id==127 then state==Running(11065,[1414971155,1329,a,0,2984,a,K.R16(a),3],Store([],64,128))
    else if id==128 then state==Running(11067,[1414971155,1329,a,0,2984,a,K.R16(a),3,255],Store([],64,128))
    else if id==129 then state==Running(11068,[1414971155,1329,a,0,2984,a,K.R16(a),3,255,a],Store([],64,128))
    else if id==130 then state==Running(11069,[1414971155,1329,a,0,2984,a,K.R16(a),3,255,a,K.R16(a)],Store([],64,128))
    else if id==131 then state==Running(11070,[1414971155,1329,a,0,2984,a,K.R16(a),3,255,Right(a,K.R16(a))],Store([],64,128))
    else if id==132 then state==Running(11071,[1414971155,1329,a,0,2984,a,K.R16(a),3,K.Bool((Right(a,K.R16(a)))>(255))],Store([],64,128))
    else if id==133 then state==Running(11072,[1414971155,1329,a,0,2984,a,K.R16(a),K.Bool((Right(a,K.R16(a)))>(255)),3],Store([],64,128))
    else if id==134 then state==Running(11073,[1414971155,1329,a,0,2984,a,K.R16(a),Shift(K.Bool((Right(a,K.R16(a)))>(255)),3)],Store([],64,128))
    else if id==135 then state==Running(11074,[1414971155,1329,a,0,2984,a,K.R8(a)],Store([],64,128))
    else if id==136 then state==Running(11076,[1414971155,1329,a,0,2984,a,K.R8(a),2],Store([],64,128))
    else if id==137 then state==Running(11078,[1414971155,1329,a,0,2984,a,K.R8(a),2,15],Store([],64,128))
    else if id==138 then state==Running(11079,[1414971155,1329,a,0,2984,a,K.R8(a),2,15,a],Store([],64,128))
    else if id==139 then state==Running(11080,[1414971155,1329,a,0,2984,a,K.R8(a),2,15,a,K.R8(a)],Store([],64,128))
    else if id==140 then state==Running(11081,[1414971155,1329,a,0,2984,a,K.R8(a),2,15,Right(a,K.R8(a))],Store([],64,128))
    else if id==141 then state==Running(11082,[1414971155,1329,a,0,2984,a,K.R8(a),2,K.Bool((Right(a,K.R8(a)))>(15))],Store([],64,128))
    else if id==142 then state==Running(11097,[1414971155,1329,a,0,2984,a,K.R8(a),2,K.Bool((Right(a,K.R8(a)))>(15)),20362259163519060155341817971459],Store([],64,128))
    else if id==143 then state==Running(11099,[1414971155,1329,a,0,2984,a,K.R8(a),2,K.Bool((Right(a,K.R8(a)))>(15)),20362259163519060155341817971459,128],Store([],64,128))
    else if id==144 then state==Running(11100,[1414971155,1329,a,0,2984,a,K.R8(a),2,K.Bool((Right(a,K.R8(a)))>(15)),6928917744019834342450304135053993530982274426945361611473370484834304],Store([],64,128))
    else if id==145 then state==Running(11101,[1414971155,1329,a,0,2984,a,K.R8(a),6928917744019834342450304135053993530982274426945361611473370484834304,K.Bool((Right(a,K.R8(a)))>(15)),2],Store([],64,128))
    else if id==146 then state==Running(11102,[1414971155,1329,a,0,2984,a,K.R8(a),6928917744019834342450304135053993530982274426945361611473370484834304,Shift(K.Bool((Right(a,K.R8(a)))>(15)),2)],Store([],64,128))
    else if id==147 then state==Running(11103,[1414971155,1329,a,0,2984,a,Shift(K.Bool((Right(a,K.R8(a)))>(15)),2),6928917744019834342450304135053993530982274426945361611473370484834304,K.R8(a)],Store([],64,128))
    else if id==148 then state==Running(11104,[1414971155,1329,a,0,2984,a,Shift(K.Bool((Right(a,K.R8(a)))>(15)),2),K.R8(a),6928917744019834342450304135053993530982274426945361611473370484834304],Store([],64,128))
    else if id==149 then state==Running(11105,[1414971155,1329,a,0,2984,a,6928917744019834342450304135053993530982274426945361611473370484834304,K.R8(a),Shift(K.Bool((Right(a,K.R8(a)))>(15)),2)],Store([],64,128))
    else if id==150 then state==Running(11106,[1414971155,1329,a,0,2984,a,6928917744019834342450304135053993530982274426945361611473370484834304,K.R4(a)],Store([],64,128))
    else if id==151 then state==Running(11107,[1414971155,1329,a,0,2984,K.R4(a),6928917744019834342450304135053993530982274426945361611473370484834304,a],Store([],64,128))
    else if id==152 then state==Running(11108,[1414971155,1329,a,0,2984,K.R4(a),6928917744019834342450304135053993530982274426945361611473370484834304,a,K.R4(a)],Store([],64,128))
    else if id==153 then state==Running(11109,[1414971155,1329,a,0,2984,K.R4(a),6928917744019834342450304135053993530982274426945361611473370484834304,Right(a,K.R4(a))],Store([],64,128))
    else if id==154 then state==Running(11110,[1414971155,1329,a,0,2984,K.R4(a),ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304)],Store([],64,128))
    else if id==155 then state==Running(11111,[1414971155,1329,a,0,2984,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))],Store([],64,128))
    else if id==156 then state==Running(11112,[1414971155,1329,a,0,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)),2984],Store([],64,128))
    else if id==157 then state==Running(2984,[1414971155,1329,a,0,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))],Store([],64,128))
    else if id==158 then state==Running(2985,[1414971155,1329,a,0,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))],Store([],64,128))
    else if id==159 then state==Running(2986,[1414971155,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)),a,0,1329],Store([],64,128))
    else if id==160 then state==Running(2987,[1414971155,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)),1329,0,a],Store([],64,128))
    else if id==161 then state==Running(2988,[1414971155,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)),1329,0],Store([],64,128))
    else if id==162 then state==Running(2989,[1414971155,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)),1329],Store([],64,128))
    else if id==163 then state==Running(1329,[1414971155,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))],Store([],64,128))
    else if id==164 then state==Running(1330,[1414971155,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))],Store([],64,128))
    else if id==165 then state==Running(1332,[1414971155,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)),64],Store([],64,128))
    else if id==166 then state==Running(1333,[1414971155,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)),128],Store([],64,128))
    else if id==167 then state==Running(1334,[1414971155,128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))],Store([],64,128))
    else if id==168 then state==Running(1335,[1414971155,128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)),128],Store([],64,128))
    else if id==169 then state==Running(1336,[1414971155,128],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))))
    else if id==170 then state==Running(1338,[1414971155,128,32],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))))
    else if id==171 then state==Running(1339,[1414971155,160],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))))
    else if id==172 then state==Running(1342,[1414971155,160,1301],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))))
    else if id==173 then state==Running(1301,[1414971155,160],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))))
    else if id==174 then state==Running(1302,[1414971155,160],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))))
    else if id==175 then state==Running(1304,[1414971155,160,64],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))))
    else if id==176 then state==Running(1305,[1414971155,160,128],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))))
    else if id==177 then state==Running(1306,[1414971155,160,128,128],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))))
    else if id==178 then state==Running(1307,[1414971155,128,128,160],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))))
    else if id==179 then state==Running(1308,[1414971155,128,32],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))))
    else if id==180 then state==Running(1309,[1414971155,32,128],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))))
    else false
  }
  lemma BeforeOr107(state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Good(107,state,value,size,word,a,b,c)
    ensures state==Running(11036,[1414971155,1329,a,0,2984,a,K.R128(a),Shift(K.Bool((Right(a,K.R128(a)))>(18446744073709551615)),6)],Store([],64,128))
  { reveal Good(); }
  lemma AfterOr107(state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires state==Running(11037,[1414971155,1329,a,0,2984,a,K.R64(a)],Store([],64,128))
    ensures Good(108,state,value,size,word,a,b,c)
  { reveal Good(); }
  lemma BeforeOr116(state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Good(116,state,value,size,word,a,b,c)
    ensures state==Running(11050,[1414971155,1329,a,0,2984,a,K.R64(a),Shift(K.Bool((Right(a,K.R64(a)))>(4294967295)),5)],Store([],64,128))
  { reveal Good(); }
  lemma AfterOr116(state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires state==Running(11051,[1414971155,1329,a,0,2984,a,K.R32(a)],Store([],64,128))
    ensures Good(117,state,value,size,word,a,b,c)
  { reveal Good(); }
  lemma BeforeOr125(state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Good(125,state,value,size,word,a,b,c)
    ensures state==Running(11062,[1414971155,1329,a,0,2984,a,K.R32(a),Shift(K.Bool((Right(a,K.R32(a)))>(65535)),4)],Store([],64,128))
  { reveal Good(); }
  lemma AfterOr125(state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires state==Running(11063,[1414971155,1329,a,0,2984,a,K.R16(a)],Store([],64,128))
    ensures Good(126,state,value,size,word,a,b,c)
  { reveal Good(); }
  lemma BeforeOr134(state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Good(134,state,value,size,word,a,b,c)
    ensures state==Running(11073,[1414971155,1329,a,0,2984,a,K.R16(a),Shift(K.Bool((Right(a,K.R16(a)))>(255)),3)],Store([],64,128))
  { reveal Good(); }
  lemma AfterOr134(state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires state==Running(11074,[1414971155,1329,a,0,2984,a,K.R8(a)],Store([],64,128))
    ensures Good(135,state,value,size,word,a,b,c)
  { reveal Good(); }
  lemma BeforeOr149(state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Good(149,state,value,size,word,a,b,c)
    ensures state==Running(11105,[1414971155,1329,a,0,2984,a,6928917744019834342450304135053993530982274426945361611473370484834304,K.R8(a),Shift(K.Bool((Right(a,K.R8(a)))>(15)),2)],Store([],64,128))
  { reveal Good(); }
  lemma AfterOr149(state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires state==Running(11106,[1414971155,1329,a,0,2984,a,6928917744019834342450304135053993530982274426945361611473370484834304,K.R4(a)],Store([],64,128))
    ensures Good(150,state,value,size,word,a,b,c)
  { reveal Good(); }
}
