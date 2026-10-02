// SPDX-License-Identifier: MIT
// Generated exact current log2 executed-byte certificate. Never edit directly.
include "Kernel.dfy"
include "Binary.dfy"
module OperationsBytecodeLog2Zero {
  import opened OperationsBytecodeLog2Machine
  import K = OperationsBytecodeLog2Kernel
  import F = OperationsBytecodeLog2Math
  import B = OperationsBytecodeLog2BinaryKernel
  function Result(a: Word): Word { F.Log(a)%Modulus() }
  predicate Admitted(value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) { value==0 && 36<=size<0x10000000000000000 && Selector(word)==0x5456bf13 && a==0 }
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
                                              code[3238]==91 &&
                                              code[3239]==96 &&
                                              code[3240]==64 &&
                                              code[3241]==81 &&
                                              code[3242]==128 &&
                                              code[3243]==145 &&
                                              code[3244]==3 &&
                                              code[3245]==144 &&
                                              code[3246]==253 &&
                                              code[4653]==91 &&
                                              code[4654]==95 &&
                                              code[4655]==129 &&
                                              code[4656]==95 &&
                                              code[4657]==3 &&
                                              code[4658]==97 &&
                                              code[4659]==18 &&
                                              code[4660]==80 &&
                                              code[4661]==87 &&
                                              code[4662]==96 &&
                                              code[4663]==64 &&
                                              code[4664]==81 &&
                                              code[4665]==99 &&
                                              code[4666]==7 &&
                                              code[4667]==232 &&
                                              code[4668]==48 &&
                                              code[4669]==11 &&
                                              code[4670]==96 &&
                                              code[4671]==228 &&
                                              code[4672]==27 &&
                                              code[4673]==129 &&
                                              code[4674]==82 &&
                                              code[4675]==95 &&
                                              code[4676]==96 &&
                                              code[4677]==4 &&
                                              code[4678]==130 &&
                                              code[4679]==1 &&
                                              code[4680]==82 &&
                                              code[4681]==96 &&
                                              code[4682]==36 &&
                                              code[4683]==1 &&
                                              code[4684]==97 &&
                                              code[4685]==12 &&
                                              code[4686]==166 &&
                                              code[4687]==86 &&
                                              code[4688]==91 &&
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
  function Destinations(): set<nat> { {15,655,828,909,968,1266,1851,1865,3238,4653,4688,18955,18971} }
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
    else if id==80 then state==Running(4662,[1414971155,1329,a,0],Store([],64,128))
    else if id==81 then state==Running(4664,[1414971155,1329,a,0,64],Store([],64,128))
    else if id==82 then state==Running(4665,[1414971155,1329,a,0,128],Store([],64,128))
    else if id==83 then state==Running(4670,[1414971155,1329,a,0,128,132657163],Store([],64,128))
    else if id==84 then state==Running(4672,[1414971155,1329,a,0,128,132657163,228],Store([],64,128))
    else if id==85 then state==Running(4673,[1414971155,1329,a,0,128,57222880631928146700726860017955557287559719528248089563825216715499480547328],Store([],64,128))
    else if id==86 then state==Running(4674,[1414971155,1329,a,0,128,57222880631928146700726860017955557287559719528248089563825216715499480547328,128],Store([],64,128))
    else if id==87 then state==Running(4675,[1414971155,1329,a,0,128],Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328))
    else if id==88 then state==Running(4676,[1414971155,1329,a,0,128,0],Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328))
    else if id==89 then state==Running(4678,[1414971155,1329,a,0,128,0,4],Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328))
    else if id==90 then state==Running(4679,[1414971155,1329,a,0,128,0,4,128],Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328))
    else if id==91 then state==Running(4680,[1414971155,1329,a,0,128,0,132],Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328))
    else if id==92 then state==Running(4681,[1414971155,1329,a,0,128],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0))
    else if id==93 then state==Running(4683,[1414971155,1329,a,0,128,36],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0))
    else if id==94 then state==Running(4684,[1414971155,1329,a,0,164],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0))
    else if id==95 then state==Running(4687,[1414971155,1329,a,0,164,3238],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0))
    else if id==96 then state==Running(3238,[1414971155,1329,a,0,164],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0))
    else if id==97 then state==Running(3239,[1414971155,1329,a,0,164],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0))
    else if id==98 then state==Running(3241,[1414971155,1329,a,0,164,64],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0))
    else if id==99 then state==Running(3242,[1414971155,1329,a,0,164,128],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0))
    else if id==100 then state==Running(3243,[1414971155,1329,a,0,164,128,128],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0))
    else if id==101 then state==Running(3244,[1414971155,1329,a,0,128,128,164],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0))
    else if id==102 then state==Running(3245,[1414971155,1329,a,0,128,36],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0))
    else if id==103 then state==Running(3246,[1414971155,1329,a,0,36,128],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0))
    else false
  }
  lemma Advance0(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(0,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(1,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(0,[],[]);
    assert Immediate(code,1,1)==128;
    assert Fetch(code,0)==Op(96,2,128);
  }
  lemma Advance1(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(1,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(2,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(2,[128],[]);
    assert Immediate(code,3,1)==64;
    assert Fetch(code,2)==Op(96,4,64);
  }
  lemma Advance2(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(2,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(3,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4,[128,64],[]);
    assert Fetch(code,4)==Op(82,5,0);
    StoreLoad([],64,128);
  }
  lemma Advance3(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(3,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(4,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(5,[],Store([],64,128));
    assert Fetch(code,5)==Op(52,6,0);
  }
  lemma Advance4(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(4,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(5,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(6,[value],Store([],64,128));
    assert Fetch(code,6)==Op(128,7,0);
  }
  lemma Advance5(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(5,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(6,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(7,[value,value],Store([],64,128));
    assert Fetch(code,7)==Op(21,8,0);
  }
  lemma Advance6(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(6,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(7,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(8,[value,K.Bool((value)==0)],Store([],64,128));
    assert Immediate(code,9,1)==0;
    assert Immediate(code,9,2)==15;
    assert Fetch(code,8)==Op(97,11,15);
  }
  lemma Advance7(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(7,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(8,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11,[value,K.Bool((value)==0),15],Store([],64,128));
    assert Fetch(code,11)==Op(87,12,0);
    assert 15 in Destinations() && code[15]==0x5b;
  }
  lemma Advance8(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(8,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(9,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(15,[value],Store([],64,128));
    assert Fetch(code,15)==Op(91,16,0);
  }
  lemma Advance9(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(9,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(10,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(16,[value],Store([],64,128));
    assert Fetch(code,16)==Op(80,17,0);
  }
  lemma Advance10(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(10,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(11,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(17,[],Store([],64,128));
    assert Immediate(code,18,1)==4;
    assert Fetch(code,17)==Op(96,19,4);
  }
  lemma Advance11(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(11,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(12,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(19,[4],Store([],64,128));
    assert Fetch(code,19)==Op(54,20,0);
  }
  lemma Advance12(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(12,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(13,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(20,[4,size],Store([],64,128));
    assert Fetch(code,20)==Op(16,21,0);
  }
  lemma Advance13(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(13,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(14,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(21,[K.Bool((size)<(4))],Store([],64,128));
    assert Immediate(code,22,1)==4;
    assert Immediate(code,22,2)==1266;
    assert Fetch(code,21)==Op(97,24,1266);
  }
  lemma Advance14(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(14,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(15,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(24,[K.Bool((size)<(4)),1266],Store([],64,128));
    assert Fetch(code,24)==Op(87,25,0);
    assert 1266 in Destinations() && code[1266]==0x5b;
  }
  lemma Advance15(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(15,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(16,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(25,[],Store([],64,128));
    assert Fetch(code,25)==Op(95,26,0);
  }
  lemma Advance16(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(16,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(17,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(26,[0],Store([],64,128));
    assert Fetch(code,26)==Op(53,27,0);
  }
  lemma Advance17(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(17,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(18,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(27,[word],Store([],64,128));
    assert Immediate(code,28,1)==224;
    assert Fetch(code,27)==Op(96,29,224);
  }
  lemma Advance18(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(18,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(19,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(29,[word,224],Store([],64,128));
    assert Fetch(code,29)==Op(28,30,0);
    SelectorRight(word);
  }
  lemma Advance19(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(19,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(20,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(30,[1414971155],Store([],64,128));
    assert Fetch(code,30)==Op(128,31,0);
  }
  lemma Advance20(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(20,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(21,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(31,[1414971155,1414971155],Store([],64,128));
    assert Immediate(code,32,1)==129;
    assert Immediate(code,32,2)==33278;
    assert Immediate(code,32,3)==8519255;
    assert Immediate(code,32,4)==2180929414;
    assert Fetch(code,31)==Op(99,36,2180929414);
  }
  lemma Advance21(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(21,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(22,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(36,[1414971155,1414971155,2180929414],Store([],64,128));
    assert Fetch(code,36)==Op(17,37,0);
  }
  lemma Advance22(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(22,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(23,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(37,[1414971155,1],Store([],64,128));
    assert Immediate(code,38,1)==2;
    assert Immediate(code,38,2)==655;
    assert Fetch(code,37)==Op(97,40,655);
  }
  lemma Advance23(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(23,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(24,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(40,[1414971155,1,655],Store([],64,128));
    assert Fetch(code,40)==Op(87,41,0);
    assert 655 in Destinations() && code[655]==0x5b;
  }
  lemma Advance24(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(24,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(25,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(655,[1414971155],Store([],64,128));
    assert Fetch(code,655)==Op(91,656,0);
  }
  lemma Advance25(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(25,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(26,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(656,[1414971155],Store([],64,128));
    assert Fetch(code,656)==Op(128,657,0);
  }
  lemma Advance26(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(26,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(27,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(657,[1414971155,1414971155],Store([],64,128));
    assert Immediate(code,658,1)==64;
    assert Immediate(code,658,2)==16513;
    assert Immediate(code,658,3)==4227439;
    assert Immediate(code,658,4)==1082224558;
    assert Fetch(code,657)==Op(99,662,1082224558);
  }
  lemma Advance27(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(27,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(28,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(662,[1414971155,1414971155,1082224558],Store([],64,128));
    assert Fetch(code,662)==Op(17,663,0);
  }
  lemma Advance28(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(28,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(29,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(663,[1414971155,0],Store([],64,128));
    assert Immediate(code,664,1)==3;
    assert Immediate(code,664,2)==968;
    assert Fetch(code,663)==Op(97,666,968);
  }
  lemma Advance29(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(29,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(30,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(666,[1414971155,0,968],Store([],64,128));
    assert Fetch(code,666)==Op(87,667,0);
    assert 968 in Destinations() && code[968]==0x5b;
  }
  lemma Advance30(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(30,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(31,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(667,[1414971155],Store([],64,128));
    assert Fetch(code,667)==Op(128,668,0);
  }
  lemma Advance31(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(31,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(32,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(668,[1414971155,1414971155],Store([],64,128));
    assert Immediate(code,669,1)==101;
    assert Immediate(code,669,2)==25938;
    assert Immediate(code,669,3)==6640369;
    assert Immediate(code,669,4)==1699934599;
    assert Fetch(code,668)==Op(99,673,1699934599);
  }
  lemma Advance32(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(32,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(33,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(673,[1414971155,1414971155,1699934599],Store([],64,128));
    assert Fetch(code,673)==Op(17,674,0);
  }
  lemma Advance33(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(33,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(34,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(674,[1414971155,1],Store([],64,128));
    assert Immediate(code,675,1)==3;
    assert Immediate(code,675,2)==828;
    assert Fetch(code,674)==Op(97,677,828);
  }
  lemma Advance34(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(34,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(35,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(677,[1414971155,1,828],Store([],64,128));
    assert Fetch(code,677)==Op(87,678,0);
    assert 828 in Destinations() && code[828]==0x5b;
  }
  lemma Advance35(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(35,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(36,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(828,[1414971155],Store([],64,128));
    assert Fetch(code,828)==Op(91,829,0);
  }
  lemma Advance36(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(36,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(37,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(829,[1414971155],Store([],64,128));
    assert Fetch(code,829)==Op(128,830,0);
  }
  lemma Advance37(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(37,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(38,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(830,[1414971155,1414971155],Store([],64,128));
    assert Immediate(code,831,1)==84;
    assert Immediate(code,831,2)==21590;
    assert Immediate(code,831,3)==5527231;
    assert Immediate(code,831,4)==1414971155;
    assert Fetch(code,830)==Op(99,835,1414971155);
  }
  lemma Advance38(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(38,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(39,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(835,[1414971155,1414971155,1414971155],Store([],64,128));
    assert Fetch(code,835)==Op(17,836,0);
  }
  lemma Advance39(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(39,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(40,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(836,[1414971155,0],Store([],64,128));
    assert Immediate(code,837,1)==3;
    assert Immediate(code,837,2)==909;
    assert Fetch(code,836)==Op(97,839,909);
  }
  lemma Advance40(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(40,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(41,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(839,[1414971155,0,909],Store([],64,128));
    assert Fetch(code,839)==Op(87,840,0);
    assert 909 in Destinations() && code[909]==0x5b;
  }
  lemma Advance41(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(41,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(42,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(840,[1414971155],Store([],64,128));
    assert Fetch(code,840)==Op(128,841,0);
  }
  lemma Advance42(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(42,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(43,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(841,[1414971155,1414971155],Store([],64,128));
    assert Immediate(code,842,1)==84;
    assert Immediate(code,842,2)==21590;
    assert Immediate(code,842,3)==5527231;
    assert Immediate(code,842,4)==1414971155;
    assert Fetch(code,841)==Op(99,846,1414971155);
  }
  lemma Advance43(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(43,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(44,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(846,[1414971155,1414971155,1414971155],Store([],64,128));
    assert Fetch(code,846)==Op(20,847,0);
  }
  lemma Advance44(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(44,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(45,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(847,[1414971155,1],Store([],64,128));
    assert Immediate(code,848,1)==7;
    assert Immediate(code,848,2)==1851;
    assert Fetch(code,847)==Op(97,850,1851);
  }
  lemma Advance45(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(45,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(46,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(850,[1414971155,1,1851],Store([],64,128));
    assert Fetch(code,850)==Op(87,851,0);
    assert 1851 in Destinations() && code[1851]==0x5b;
  }
  lemma Advance46(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(46,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(47,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1851,[1414971155],Store([],64,128));
    assert Fetch(code,1851)==Op(91,1852,0);
  }
  lemma Advance47(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(47,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(48,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1852,[1414971155],Store([],64,128));
    assert Immediate(code,1853,1)==5;
    assert Immediate(code,1853,2)==1329;
    assert Fetch(code,1852)==Op(97,1855,1329);
  }
  lemma Advance48(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(48,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(49,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1855,[1414971155,1329],Store([],64,128));
    assert Immediate(code,1856,1)==7;
    assert Immediate(code,1856,2)==1865;
    assert Fetch(code,1855)==Op(97,1858,1865);
  }
  lemma Advance49(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(49,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(50,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1858,[1414971155,1329,1865],Store([],64,128));
    assert Fetch(code,1858)==Op(54,1859,0);
  }
  lemma Advance50(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(50,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(51,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1859,[1414971155,1329,1865,size],Store([],64,128));
    assert Immediate(code,1860,1)==4;
    assert Fetch(code,1859)==Op(96,1861,4);
  }
  lemma Advance51(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(51,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(52,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1861,[1414971155,1329,1865,size,4],Store([],64,128));
    assert Immediate(code,1862,1)==74;
    assert Immediate(code,1862,2)==18955;
    assert Fetch(code,1861)==Op(97,1864,18955);
  }
  lemma Advance52(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(52,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(53,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1864,[1414971155,1329,1865,size,4,18955],Store([],64,128));
    assert Fetch(code,1864)==Op(86,1865,0);
    assert 18955 in Destinations() && code[18955]==0x5b;
  }
  lemma Advance53(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(53,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(54,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(18955,[1414971155,1329,1865,size,4],Store([],64,128));
    assert Fetch(code,18955)==Op(91,18956,0);
  }
  lemma Advance54(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(54,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(55,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(18956,[1414971155,1329,1865,size,4],Store([],64,128));
    assert Fetch(code,18956)==Op(95,18957,0);
  }
  lemma Advance55(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(55,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(56,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(18957,[1414971155,1329,1865,size,4,0],Store([],64,128));
    assert Immediate(code,18958,1)==32;
    assert Fetch(code,18957)==Op(96,18959,32);
  }
  lemma Advance56(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(56,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(57,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(18959,[1414971155,1329,1865,size,4,0,32],Store([],64,128));
    assert Fetch(code,18959)==Op(130,18960,0);
  }
  lemma Advance57(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(57,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(58,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(18960,[1414971155,1329,1865,size,4,0,32,4],Store([],64,128));
    assert Fetch(code,18960)==Op(132,18961,0);
  }
  lemma Advance58(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(58,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(59,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(18961,[1414971155,1329,1865,size,4,0,32,4,size],Store([],64,128));
    assert Fetch(code,18961)==Op(3,18962,0);
  }
  lemma Advance59(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(59,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(60,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(18962,[1414971155,1329,1865,size,4,0,32,(((size) as nat)+Modulus()-((4) as nat))%Modulus()],Store([],64,128));
    assert Fetch(code,18962)==Op(18,18963,0);
  }
  lemma Advance60(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(60,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(61,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(18963,[1414971155,1329,1865,size,4,0,K.Bool(Signed((((size) as nat)+Modulus()-((4) as nat))%Modulus())<Signed(32))],Store([],64,128));
    assert Fetch(code,18963)==Op(21,18964,0);
  }
  lemma Advance61(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(61,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(62,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(18964,[1414971155,1329,1865,size,4,0,K.Bool((K.Bool(Signed((((size) as nat)+Modulus()-((4) as nat))%Modulus())<Signed(32)))==0)],Store([],64,128));
    assert Immediate(code,18965,1)==74;
    assert Immediate(code,18965,2)==18971;
    assert Fetch(code,18964)==Op(97,18967,18971);
  }
  lemma Advance62(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(62,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(63,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(18967,[1414971155,1329,1865,size,4,0,K.Bool((K.Bool(Signed((((size) as nat)+Modulus()-((4) as nat))%Modulus())<Signed(32)))==0),18971],Store([],64,128));
    assert Fetch(code,18967)==Op(87,18968,0);
    assert 18971 in Destinations() && code[18971]==0x5b;
  }
  lemma Advance63(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(63,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(64,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(18971,[1414971155,1329,1865,size,4,0],Store([],64,128));
    assert Fetch(code,18971)==Op(91,18972,0);
  }
  lemma Advance64(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(64,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(65,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(18972,[1414971155,1329,1865,size,4,0],Store([],64,128));
    assert Fetch(code,18972)==Op(80,18973,0);
  }
  lemma Advance65(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(65,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(66,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(18973,[1414971155,1329,1865,size,4],Store([],64,128));
    assert Fetch(code,18973)==Op(53,18974,0);
  }
  lemma Advance66(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(66,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(67,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(18974,[1414971155,1329,1865,size,a],Store([],64,128));
    assert Fetch(code,18974)==Op(145,18975,0);
  }
  lemma Advance67(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(67,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(68,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(18975,[1414971155,1329,a,size,1865],Store([],64,128));
    assert Fetch(code,18975)==Op(144,18976,0);
  }
  lemma Advance68(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(68,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(69,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(18976,[1414971155,1329,a,1865,size],Store([],64,128));
    assert Fetch(code,18976)==Op(80,18977,0);
  }
  lemma Advance69(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(69,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(70,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(18977,[1414971155,1329,a,1865],Store([],64,128));
    assert Fetch(code,18977)==Op(86,18978,0);
    assert 1865 in Destinations() && code[1865]==0x5b;
  }
  lemma Advance70(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(70,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(71,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1865,[1414971155,1329,a],Store([],64,128));
    assert Fetch(code,1865)==Op(91,1866,0);
  }
  lemma Advance71(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(71,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(72,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1866,[1414971155,1329,a],Store([],64,128));
    assert Immediate(code,1867,1)==18;
    assert Immediate(code,1867,2)==4653;
    assert Fetch(code,1866)==Op(97,1869,4653);
  }
  lemma Advance72(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(72,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(73,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1869,[1414971155,1329,a,4653],Store([],64,128));
    assert Fetch(code,1869)==Op(86,1870,0);
    assert 4653 in Destinations() && code[4653]==0x5b;
  }
  lemma Advance73(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(73,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(74,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4653,[1414971155,1329,a],Store([],64,128));
    assert Fetch(code,4653)==Op(91,4654,0);
  }
  lemma Advance74(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(74,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(75,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4654,[1414971155,1329,a],Store([],64,128));
    assert Fetch(code,4654)==Op(95,4655,0);
  }
  lemma Advance75(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(75,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(76,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4655,[1414971155,1329,a,0],Store([],64,128));
    assert Fetch(code,4655)==Op(129,4656,0);
  }
  lemma Advance76(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(76,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(77,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4656,[1414971155,1329,a,0,a],Store([],64,128));
    assert Fetch(code,4656)==Op(95,4657,0);
  }
  lemma Advance77(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(77,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(78,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4657,[1414971155,1329,a,0,a,0],Store([],64,128));
    assert Fetch(code,4657)==Op(3,4658,0);
  }
  lemma Advance78(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(78,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(79,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4658,[1414971155,1329,a,0,(((0) as nat)+Modulus()-((a) as nat))%Modulus()],Store([],64,128));
    assert Immediate(code,4659,1)==18;
    assert Immediate(code,4659,2)==4688;
    assert Fetch(code,4658)==Op(97,4661,4688);
  }
  lemma Advance79(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(79,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(80,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4661,[1414971155,1329,a,0,(((0) as nat)+Modulus()-((a) as nat))%Modulus(),4688],Store([],64,128));
    assert Fetch(code,4661)==Op(87,4662,0);
    assert 4688 in Destinations() && code[4688]==0x5b;
  }
  lemma Advance80(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(80,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(81,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4662,[1414971155,1329,a,0],Store([],64,128));
    assert Immediate(code,4663,1)==64;
    assert Fetch(code,4662)==Op(96,4664,64);
  }
  lemma Advance81(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(81,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(82,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4664,[1414971155,1329,a,0,64],Store([],64,128));
    assert Fetch(code,4664)==Op(81,4665,0);
    StoreLoad([],64,128);
  }
  lemma Advance82(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(82,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(83,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4665,[1414971155,1329,a,0,128],Store([],64,128));
    assert Immediate(code,4666,1)==7;
    assert Immediate(code,4666,2)==2024;
    assert Immediate(code,4666,3)==518192;
    assert Immediate(code,4666,4)==132657163;
    assert Fetch(code,4665)==Op(99,4670,132657163);
  }
  lemma Advance83(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(83,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(84,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4670,[1414971155,1329,a,0,128,132657163],Store([],64,128));
    assert Immediate(code,4671,1)==228;
    assert Fetch(code,4670)==Op(96,4672,228);
  }
  lemma Advance84(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(84,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(85,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4672,[1414971155,1329,a,0,128,132657163,228],Store([],64,128));
    assert Fetch(code,4672)==Op(27,4673,0);
    K.FixedShift(132657163,228,57222880631928146700726860017955557287559719528248089563825216715499480547328);
  }
  lemma Advance85(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(85,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(86,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4673,[1414971155,1329,a,0,128,57222880631928146700726860017955557287559719528248089563825216715499480547328],Store([],64,128));
    assert Fetch(code,4673)==Op(129,4674,0);
  }
  lemma Advance86(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(86,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(87,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4674,[1414971155,1329,a,0,128,57222880631928146700726860017955557287559719528248089563825216715499480547328,128],Store([],64,128));
    assert Fetch(code,4674)==Op(82,4675,0);
    StoreLoad(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328);
  }
  lemma Advance87(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(87,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(88,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4675,[1414971155,1329,a,0,128],Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328));
    assert Fetch(code,4675)==Op(95,4676,0);
  }
  lemma Advance88(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(88,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(89,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4676,[1414971155,1329,a,0,128,0],Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328));
    assert Immediate(code,4677,1)==4;
    assert Fetch(code,4676)==Op(96,4678,4);
  }
  lemma Advance89(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(89,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(90,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4678,[1414971155,1329,a,0,128,0,4],Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328));
    assert Fetch(code,4678)==Op(130,4679,0);
  }
  lemma Advance90(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(90,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(91,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4679,[1414971155,1329,a,0,128,0,4,128],Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328));
    assert Fetch(code,4679)==Op(1,4680,0);
  }
  lemma Advance91(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(91,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(92,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4680,[1414971155,1329,a,0,128,0,132],Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328));
    assert Fetch(code,4680)==Op(82,4681,0);
    StoreLoad(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0);
  }
  lemma Advance92(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(92,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(93,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4681,[1414971155,1329,a,0,128],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0));
    assert Immediate(code,4682,1)==36;
    assert Fetch(code,4681)==Op(96,4683,36);
  }
  lemma Advance93(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(93,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(94,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4683,[1414971155,1329,a,0,128,36],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0));
    assert Fetch(code,4683)==Op(1,4684,0);
  }
  lemma Advance94(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(94,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(95,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4684,[1414971155,1329,a,0,164],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0));
    assert Immediate(code,4685,1)==12;
    assert Immediate(code,4685,2)==3238;
    assert Fetch(code,4684)==Op(97,4687,3238);
  }
  lemma Advance95(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(95,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(96,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4687,[1414971155,1329,a,0,164,3238],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0));
    assert Fetch(code,4687)==Op(86,4688,0);
    assert 3238 in Destinations() && code[3238]==0x5b;
  }
  lemma Advance96(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(96,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(97,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(3238,[1414971155,1329,a,0,164],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0));
    assert Fetch(code,3238)==Op(91,3239,0);
  }
  lemma Advance97(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(97,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(98,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(3239,[1414971155,1329,a,0,164],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0));
    assert Immediate(code,3240,1)==64;
    assert Fetch(code,3239)==Op(96,3241,64);
  }
  lemma Advance98(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(98,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(99,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(3241,[1414971155,1329,a,0,164,64],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0));
    assert Fetch(code,3241)==Op(81,3242,0);
    StoreLoad([],64,128);
    StoreFrame(Store([],64,128),128,K.ErrorWord,64);
    StoreFrame(Store(Store([],64,128),128,K.ErrorWord),132,0,64);
  }
  lemma Advance99(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(99,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(100,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(3242,[1414971155,1329,a,0,164,128],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0));
    assert Fetch(code,3242)==Op(128,3243,0);
  }
  lemma Advance100(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(100,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(101,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(3243,[1414971155,1329,a,0,164,128,128],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0));
    assert Fetch(code,3243)==Op(145,3244,0);
  }
  lemma Advance101(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(101,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(102,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(3244,[1414971155,1329,a,0,128,128,164],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0));
    assert Fetch(code,3244)==Op(3,3245,0);
  }
  lemma Advance102(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(102,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(103,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(3245,[1414971155,1329,a,0,128,36],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0));
    assert Fetch(code,3245)==Op(144,3246,0);
  }
  lemma Advance103(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(103,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=9 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); next==Reverted(K.Undefined())
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(3246,[1414971155,1329,a,0,36,128],Store(Store(Store([],64,128),128,57222880631928146700726860017955557287559719528248089563825216715499480547328),132,0));
    assert Fetch(code,3246)==Op(253,3247,0);
    K.ErrorStores(Store([],64,128));
  }
  ghost method Run(code: seq<Byte>,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,c)
    ensures state==Reverted(K.Undefined())
  {
    reveal Good(); state:=Running(0,[],[]); assert Good(0,state,value,size,word,a,b,c);
    Advance0(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance1(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance2(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance3(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance4(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance5(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance6(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance7(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance8(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance9(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance10(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance11(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance12(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance13(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance14(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance15(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance16(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance17(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance18(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance19(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance20(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance21(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance22(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance23(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance24(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance25(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance26(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance27(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance28(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance29(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance30(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance31(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance32(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance33(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance34(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance35(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance36(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance37(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance38(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance39(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance40(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance41(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance42(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance43(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance44(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance45(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance46(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance47(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance48(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance49(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance50(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance51(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance52(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance53(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance54(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance55(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance56(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance57(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance58(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance59(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance60(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance61(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance62(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance63(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance64(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance65(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance66(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance67(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance68(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance69(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance70(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance71(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance72(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance73(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance74(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance75(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance76(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance77(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance78(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance79(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance80(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance81(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance82(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance83(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance84(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance85(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance86(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance87(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance88(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance89(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance90(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance91(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance92(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance93(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance94(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance95(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance96(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance97(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance98(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance99(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance100(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance101(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance102(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance103(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
  }
}
