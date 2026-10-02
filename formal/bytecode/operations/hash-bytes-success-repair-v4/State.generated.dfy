// SPDX-License-Identifier: MIT
// Generated complete exact successful hash body; never edit directly.
include "Kernel.dfy"
module OperationsHashSuccessState {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import K = OperationsHashSuccessKernel
  opaque predicate Matches(code: seq<Byte>) { |code|==21346 &&
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
                                              code[7568]==91 &&
                                              code[7569]==95 &&
                                              code[7570]==130 &&
                                              code[7571]==130 &&
                                              code[7572]==96 &&
                                              code[7573]==64 &&
                                              code[7574]==81 &&
                                              code[7575]==97 &&
                                              code[7576]==29 &&
                                              code[7577]==161 &&
                                              code[7578]==146 &&
                                              code[7579]==145 &&
                                              code[7580]==144 &&
                                              code[7581]==97 &&
                                              code[7582]==78 &&
                                              code[7583]==79 &&
                                              code[7584]==86 &&
                                              code[7585]==91 &&
                                              code[7586]==96 &&
                                              code[7587]==64 &&
                                              code[7588]==81 &&
                                              code[7589]==128 &&
                                              code[7590]==145 &&
                                              code[7591]==3 &&
                                              code[7592]==144 &&
                                              code[7593]==32 &&
                                              code[7594]==144 &&
                                              code[7595]==80 &&
                                              code[7596]==146 &&
                                              code[7597]==145 &&
                                              code[7598]==80 &&
                                              code[7599]==80 &&
                                              code[7600]==86 &&
                                              code[20047]==91 &&
                                              code[20048]==129 &&
                                              code[20049]==131 &&
                                              code[20050]==130 &&
                                              code[20051]==55 &&
                                              code[20052]==95 &&
                                              code[20053]==145 &&
                                              code[20054]==1 &&
                                              code[20055]==144 &&
                                              code[20056]==129 &&
                                              code[20057]==82 &&
                                              code[20058]==145 &&
                                              code[20059]==144 &&
                                              code[20060]==80 &&
                                              code[20061]==86
  }
  function Destinations(): set<nat> { {1301,1329,7585,20047} }
  opaque predicate Good(id: nat,state: State,data: seq<Byte>,source: Word,count: Word,result: Word)
    requires count<0x10000000000000000
  {
    if id==0 then state==Running(7568,[2854126814,1329,source,count],K.Initial())
    else if id==1 then state==Running(7569,[2854126814,1329,source,count],K.Initial())
    else if id==2 then state==Running(7570,[2854126814,1329,source,count,0],K.Initial())
    else if id==3 then state==Running(7571,[2854126814,1329,source,count,0,source],K.Initial())
    else if id==4 then state==Running(7572,[2854126814,1329,source,count,0,source,count],K.Initial())
    else if id==5 then state==Running(7574,[2854126814,1329,source,count,0,source,count,64],K.Initial())
    else if id==6 then state==Running(7575,[2854126814,1329,source,count,0,source,count,128],K.Initial())
    else if id==7 then state==Running(7578,[2854126814,1329,source,count,0,source,count,128,7585],K.Initial())
    else if id==8 then state==Running(7579,[2854126814,1329,source,count,0,7585,count,128,source],K.Initial())
    else if id==9 then state==Running(7580,[2854126814,1329,source,count,0,7585,source,128,count],K.Initial())
    else if id==10 then state==Running(7581,[2854126814,1329,source,count,0,7585,source,count,128],K.Initial())
    else if id==11 then state==Running(7584,[2854126814,1329,source,count,0,7585,source,count,128,20047],K.Initial())
    else if id==12 then state==Running(20047,[2854126814,1329,source,count,0,7585,source,count,128],K.Initial())
    else if id==13 then state==Running(20048,[2854126814,1329,source,count,0,7585,source,count,128],K.Initial())
    else if id==14 then state==Running(20049,[2854126814,1329,source,count,0,7585,source,count,128,count],K.Initial())
    else if id==15 then state==Running(20050,[2854126814,1329,source,count,0,7585,source,count,128,count,source],K.Initial())
    else if id==16 then state==Running(20051,[2854126814,1329,source,count,0,7585,source,count,128,count,source,128],K.Initial())
    else if id==17 then state==Running(20052,[2854126814,1329,source,count,0,7585,source,count,128],K.Copied(data,source,count))
    else if id==18 then state==Running(20053,[2854126814,1329,source,count,0,7585,source,count,128,0],K.Copied(data,source,count))
    else if id==19 then state==Running(20054,[2854126814,1329,source,count,0,7585,source,0,128,count],K.Copied(data,source,count))
    else if id==20 then state==Running(20055,[2854126814,1329,source,count,0,7585,source,0,128+(count as nat)],K.Copied(data,source,count))
    else if id==21 then state==Running(20056,[2854126814,1329,source,count,0,7585,source,128+(count as nat),0],K.Copied(data,source,count))
    else if id==22 then state==Running(20057,[2854126814,1329,source,count,0,7585,source,128+(count as nat),0,128+(count as nat)],K.Copied(data,source,count))
    else if id==23 then state==Running(20058,[2854126814,1329,source,count,0,7585,source,128+(count as nat)],K.Cleared(data,source,count))
    else if id==24 then state==Running(20059,[2854126814,1329,source,count,0,128+(count as nat),source,7585],K.Cleared(data,source,count))
    else if id==25 then state==Running(20060,[2854126814,1329,source,count,0,128+(count as nat),7585,source],K.Cleared(data,source,count))
    else if id==26 then state==Running(20061,[2854126814,1329,source,count,0,128+(count as nat),7585],K.Cleared(data,source,count))
    else if id==27 then state==Running(7585,[2854126814,1329,source,count,0,128+(count as nat)],K.Cleared(data,source,count))
    else if id==28 then state==Running(7586,[2854126814,1329,source,count,0,128+(count as nat)],K.Cleared(data,source,count))
    else if id==29 then state==Running(7588,[2854126814,1329,source,count,0,128+(count as nat),64],K.Cleared(data,source,count))
    else if id==30 then state==Running(7589,[2854126814,1329,source,count,0,128+(count as nat),128],K.Cleared(data,source,count))
    else if id==31 then state==Running(7590,[2854126814,1329,source,count,0,128+(count as nat),128,128],K.Cleared(data,source,count))
    else if id==32 then state==Running(7591,[2854126814,1329,source,count,0,128,128,128+(count as nat)],K.Cleared(data,source,count))
    else if id==33 then state==Running(7592,[2854126814,1329,source,count,0,128,count],K.Cleared(data,source,count))
    else if id==34 then state==Running(7593,[2854126814,1329,source,count,0,count,128],K.Cleared(data,source,count))
    else if id==35 then state==Running(7594,[2854126814,1329,source,count,0,result],K.Cleared(data,source,count))
    else if id==36 then state==Running(7595,[2854126814,1329,source,count,result,0],K.Cleared(data,source,count))
    else if id==37 then state==Running(7596,[2854126814,1329,source,count,result],K.Cleared(data,source,count))
    else if id==38 then state==Running(7597,[2854126814,result,source,count,1329],K.Cleared(data,source,count))
    else if id==39 then state==Running(7598,[2854126814,result,1329,count,source],K.Cleared(data,source,count))
    else if id==40 then state==Running(7599,[2854126814,result,1329,count],K.Cleared(data,source,count))
    else if id==41 then state==Running(7600,[2854126814,result,1329],K.Cleared(data,source,count))
    else if id==42 then state==Running(1329,[2854126814,result],K.Cleared(data,source,count))
    else if id==43 then state==Running(1330,[2854126814,result],K.Cleared(data,source,count))
    else if id==44 then state==Running(1332,[2854126814,result,64],K.Cleared(data,source,count))
    else if id==45 then state==Running(1333,[2854126814,result,128],K.Cleared(data,source,count))
    else if id==46 then state==Running(1334,[2854126814,128,result],K.Cleared(data,source,count))
    else if id==47 then state==Running(1335,[2854126814,128,result,128],K.Cleared(data,source,count))
    else if id==48 then state==Running(1336,[2854126814,128],K.Finished(data,source,count,result))
    else if id==49 then state==Running(1338,[2854126814,128,32],K.Finished(data,source,count,result))
    else if id==50 then state==Running(1339,[2854126814,160],K.Finished(data,source,count,result))
    else if id==51 then state==Running(1342,[2854126814,160,1301],K.Finished(data,source,count,result))
    else if id==52 then state==Running(1301,[2854126814,160],K.Finished(data,source,count,result))
    else if id==53 then state==Running(1302,[2854126814,160],K.Finished(data,source,count,result))
    else if id==54 then state==Running(1304,[2854126814,160,64],K.Finished(data,source,count,result))
    else if id==55 then state==Running(1305,[2854126814,160,128],K.Finished(data,source,count,result))
    else if id==56 then state==Running(1306,[2854126814,160,128,128],K.Finished(data,source,count,result))
    else if id==57 then state==Running(1307,[2854126814,128,128,160],K.Finished(data,source,count,result))
    else if id==58 then state==Running(1308,[2854126814,128,32],K.Finished(data,source,count,result))
    else if id==59 then state==Running(1309,[2854126814,32,128],K.Finished(data,source,count,result))
    else false
  }
}
