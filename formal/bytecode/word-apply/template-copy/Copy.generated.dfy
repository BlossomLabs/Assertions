// SPDX-License-Identifier: MIT
// Generated actual template allocation, CALLDATACOPY and zero padding; no public retained claim.
include "Memory.dfy"
module BytecodeApplyTemplateCopy {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import M = BytecodeCopyMachine
  import E = BytecodeCopyExecution
  import H = BytecodeApplyTemplateMemory
  predicate Admitted(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word) { 0 < n < 0x800000000000000 && templateLength < 0x10000000000000000 && fp < 0x20000000000000000 && 96 <= |mem| < 0x40000000000000000 && |mem|%32 == 0 && Load(mem,64) == fp && |data| < 0x10000000000000000 && (templateOffset as nat)+templateLength <= |data| && |prefix| <= 1001 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[12334] == 91 &&
                                              code[12335] == 95 &&
                                              code[12336] == 136 &&
                                              code[12337] == 136 &&
                                              code[12338] == 128 &&
                                              code[12339] == 128 &&
                                              code[12340] == 96 &&
                                              code[12341] == 31 &&
                                              code[12342] == 1 &&
                                              code[12343] == 96 &&
                                              code[12344] == 32 &&
                                              code[12345] == 128 &&
                                              code[12346] == 145 &&
                                              code[12347] == 4 &&
                                              code[12348] == 2 &&
                                              code[12349] == 96 &&
                                              code[12350] == 32 &&
                                              code[12351] == 1 &&
                                              code[12352] == 96 &&
                                              code[12353] == 64 &&
                                              code[12354] == 81 &&
                                              code[12355] == 144 &&
                                              code[12356] == 129 &&
                                              code[12357] == 1 &&
                                              code[12358] == 96 &&
                                              code[12359] == 64 &&
                                              code[12360] == 82 &&
                                              code[12361] == 128 &&
                                              code[12362] == 147 &&
                                              code[12363] == 146 &&
                                              code[12364] == 145 &&
                                              code[12365] == 144 &&
                                              code[12366] == 129 &&
                                              code[12367] == 129 &&
                                              code[12368] == 82 &&
                                              code[12369] == 96 &&
                                              code[12370] == 32 &&
                                              code[12371] == 1 &&
                                              code[12372] == 131 &&
                                              code[12373] == 131 &&
                                              code[12374] == 128 &&
                                              code[12375] == 130 &&
                                              code[12376] == 132 &&
                                              code[12377] == 55 &&
                                              code[12378] == 95 &&
                                              code[12379] == 146 &&
                                              code[12380] == 1 &&
                                              code[12381] == 130 &&
                                              code[12382] == 144 &&
                                              code[12383] == 82 &&
                                              code[12384] == 80 &&
                                              code[12385] == 147 &&
                                              code[12386] == 148 &&
                                              code[12387] == 80 &&
                                              code[12388] == 80 &&
                                              code[12389] == 80 &&
                                              code[12390] == 80
  }
  function Destinations(): set<nat> { {} }
  opaque predicate Good(id: nat,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word) { Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && (
                                                                                                                                                                                                                                                                                      if id == 0 then state == Running(12334,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0],mem)
                                                                                                                                                                                                                                                                                      else if id == 1 then state == Running(12335,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0],mem)
                                                                                                                                                                                                                                                                                      else if id == 2 then state == Running(12336,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0],mem)
                                                                                                                                                                                                                                                                                      else if id == 3 then state == Running(12337,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset],mem)
                                                                                                                                                                                                                                                                                      else if id == 4 then state == Running(12338,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength],mem)
                                                                                                                                                                                                                                                                                      else if id == 5 then state == Running(12339,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength],mem)
                                                                                                                                                                                                                                                                                      else if id == 6 then state == Running(12340,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,templateLength],mem)
                                                                                                                                                                                                                                                                                      else if id == 7 then state == Running(12342,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,templateLength,31],mem)
                                                                                                                                                                                                                                                                                      else if id == 8 then state == Running(12343,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,templateLength+31],mem)
                                                                                                                                                                                                                                                                                      else if id == 9 then state == Running(12345,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,templateLength+31,32],mem)
                                                                                                                                                                                                                                                                                      else if id == 10 then state == Running(12346,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,templateLength+31,32,32],mem)
                                                                                                                                                                                                                                                                                      else if id == 11 then state == Running(12347,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,32,32,templateLength+31],mem)
                                                                                                                                                                                                                                                                                      else if id == 12 then state == Running(12348,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,32,H.Quot(templateLength)],mem)
                                                                                                                                                                                                                                                                                      else if id == 13 then state == Running(12349,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,H.Rounded(templateLength)],mem)
                                                                                                                                                                                                                                                                                      else if id == 14 then state == Running(12351,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,H.Rounded(templateLength),32],mem)
                                                                                                                                                                                                                                                                                      else if id == 15 then state == Running(12352,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,H.Rounded(templateLength)+32],mem)
                                                                                                                                                                                                                                                                                      else if id == 16 then state == Running(12354,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,H.Rounded(templateLength)+32,64],mem)
                                                                                                                                                                                                                                                                                      else if id == 17 then state == Running(12355,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,H.Rounded(templateLength)+32,fp],mem)
                                                                                                                                                                                                                                                                                      else if id == 18 then state == Running(12356,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,fp,H.Rounded(templateLength)+32],mem)
                                                                                                                                                                                                                                                                                      else if id == 19 then state == Running(12357,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,fp,H.Rounded(templateLength)+32,fp],mem)
                                                                                                                                                                                                                                                                                      else if id == 20 then state == Running(12358,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,fp,H.Free(fp,templateLength)],mem)
                                                                                                                                                                                                                                                                                      else if id == 21 then state == Running(12360,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,fp,H.Free(fp,templateLength),64],mem)
                                                                                                                                                                                                                                                                                      else if id == 22 then state == Running(12361,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,fp],H.Pointer(mem,fp,templateLength))
                                                                                                                                                                                                                                                                                      else if id == 23 then state == Running(12362,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,fp,fp],H.Pointer(mem,fp,templateLength))
                                                                                                                                                                                                                                                                                      else if id == 24 then state == Running(12363,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateLength,templateLength,fp,templateOffset],H.Pointer(mem,fp,templateLength))
                                                                                                                                                                                                                                                                                      else if id == 25 then state == Running(12364,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,fp,templateLength],H.Pointer(mem,fp,templateLength))
                                                                                                                                                                                                                                                                                      else if id == 26 then state == Running(12365,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,fp,templateLength],H.Pointer(mem,fp,templateLength))
                                                                                                                                                                                                                                                                                      else if id == 27 then state == Running(12366,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp],H.Pointer(mem,fp,templateLength))
                                                                                                                                                                                                                                                                                      else if id == 28 then state == Running(12367,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp,templateLength],H.Pointer(mem,fp,templateLength))
                                                                                                                                                                                                                                                                                      else if id == 29 then state == Running(12368,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp,templateLength,fp],H.Pointer(mem,fp,templateLength))
                                                                                                                                                                                                                                                                                      else if id == 30 then state == Running(12369,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp],H.Head(mem,fp,templateLength))
                                                                                                                                                                                                                                                                                      else if id == 31 then state == Running(12371,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp,32],H.Head(mem,fp,templateLength))
                                                                                                                                                                                                                                                                                      else if id == 32 then state == Running(12372,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp+32],H.Head(mem,fp,templateLength))
                                                                                                                                                                                                                                                                                      else if id == 33 then state == Running(12373,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp+32,templateOffset],H.Head(mem,fp,templateLength))
                                                                                                                                                                                                                                                                                      else if id == 34 then state == Running(12374,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp+32,templateOffset,templateLength],H.Head(mem,fp,templateLength))
                                                                                                                                                                                                                                                                                      else if id == 35 then state == Running(12375,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp+32,templateOffset,templateLength,templateLength],H.Head(mem,fp,templateLength))
                                                                                                                                                                                                                                                                                      else if id == 36 then state == Running(12376,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp+32,templateOffset,templateLength,templateLength,templateOffset],H.Head(mem,fp,templateLength))
                                                                                                                                                                                                                                                                                      else if id == 37 then state == Running(12377,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp+32,templateOffset,templateLength,templateLength,templateOffset,fp+32],H.Head(mem,fp,templateLength))
                                                                                                                                                                                                                                                                                      else if id == 38 then state == Running(12378,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp+32,templateOffset,templateLength],H.Copied(mem,fp,templateOffset,templateLength,data))
                                                                                                                                                                                                                                                                                      else if id == 39 then state == Running(12379,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp+32,templateOffset,templateLength,0],H.Copied(mem,fp,templateOffset,templateLength,data))
                                                                                                                                                                                                                                                                                      else if id == 40 then state == Running(12380,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,0,templateOffset,templateLength,fp+32],H.Copied(mem,fp,templateOffset,templateLength,data))
                                                                                                                                                                                                                                                                                      else if id == 41 then state == Running(12381,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,0,templateOffset,fp+32+templateLength],H.Copied(mem,fp,templateOffset,templateLength,data))
                                                                                                                                                                                                                                                                                      else if id == 42 then state == Running(12382,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,0,templateOffset,fp+32+templateLength,0],H.Copied(mem,fp,templateOffset,templateLength,data))
                                                                                                                                                                                                                                                                                      else if id == 43 then state == Running(12383,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,0,templateOffset,0,fp+32+templateLength],H.Copied(mem,fp,templateOffset,templateLength,data))
                                                                                                                                                                                                                                                                                      else if id == 44 then state == Running(12384,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,0,templateOffset],H.Complete(mem,fp,templateOffset,templateLength,data))
                                                                                                                                                                                                                                                                                      else if id == 45 then state == Running(12385,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,0],H.Complete(mem,fp,templateOffset,templateLength,data))
                                                                                                                                                                                                                                                                                      else if id == 46 then state == Running(12386,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,0,templateOffset,templateLength,templateLength,fp],H.Complete(mem,fp,templateOffset,templateLength,data))
                                                                                                                                                                                                                                                                                      else if id == 47 then state == Running(12387,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,fp,0,templateOffset,templateLength,templateLength,0],H.Complete(mem,fp,templateOffset,templateLength,data))
                                                                                                                                                                                                                                                                                      else if id == 48 then state == Running(12388,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,fp,0,templateOffset,templateLength,templateLength],H.Complete(mem,fp,templateOffset,templateLength,data))
                                                                                                                                                                                                                                                                                      else if id == 49 then state == Running(12389,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,fp,0,templateOffset,templateLength],H.Complete(mem,fp,templateOffset,templateLength,data))
                                                                                                                                                                                                                                                                                      else if id == 50 then state == Running(12390,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,fp,0,templateOffset],H.Complete(mem,fp,templateOffset,templateLength,data))
                                                                                                                                                                                                                                                                                      else false) }
  lemma Advance0(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(0,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12334,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0],mem);
    assert Fetch(code,12334) == Op(91,12335,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance1(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(1,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12335,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0],mem);
    assert Fetch(code,12335) == Op(95,12336,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance2(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(2,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12336,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0],mem);
    assert Fetch(code,12336) == Op(136,12337,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance3(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(3,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12337,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset],mem);
    assert Fetch(code,12337) == Op(136,12338,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance4(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(4,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12338,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength],mem);
    assert Fetch(code,12338) == Op(128,12339,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance5(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(5,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12339,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength],mem);
    assert Fetch(code,12339) == Op(128,12340,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance6(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(6,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12340,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,templateLength],mem);
    F.Push1(code,12340);
    assert Fetch(code,12340) == Op(96,12342,31);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance7(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(7,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12342,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,templateLength,31],mem);
    assert Fetch(code,12342) == Op(1,12343,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance8(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(8,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12343,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,templateLength+31],mem);
    F.Push1(code,12343);
    assert Fetch(code,12343) == Op(96,12345,32);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance9(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(9,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12345,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,templateLength+31,32],mem);
    assert Fetch(code,12345) == Op(128,12346,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance10(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(10,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12346,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,templateLength+31,32,32],mem);
    assert Fetch(code,12346) == Op(145,12347,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance11(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(11,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12347,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,32,32,templateLength+31],mem);
    assert Fetch(code,12347) == Op(4,12348,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance12(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(12,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12348,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,32,H.Quot(templateLength)],mem);
    assert Fetch(code,12348) == Op(2,12349,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance13(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(13,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12349,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,H.Rounded(templateLength)],mem);
    F.Push1(code,12349);
    assert Fetch(code,12349) == Op(96,12351,32);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance14(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(14,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12351,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,H.Rounded(templateLength),32],mem);
    assert Fetch(code,12351) == Op(1,12352,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance15(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(15,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(16,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12352,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,H.Rounded(templateLength)+32],mem);
    F.Push1(code,12352);
    assert Fetch(code,12352) == Op(96,12354,64);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance16(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(16,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(17,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12354,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,H.Rounded(templateLength)+32,64],mem);
    assert Fetch(code,12354) == Op(81,12355,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance17(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(17,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12355,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,H.Rounded(templateLength)+32,fp],mem);
    assert Fetch(code,12355) == Op(144,12356,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance18(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(18,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(19,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12356,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,fp,H.Rounded(templateLength)+32],mem);
    assert Fetch(code,12356) == Op(129,12357,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance19(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(19,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(20,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12357,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,fp,H.Rounded(templateLength)+32,fp],mem);
    assert Fetch(code,12357) == Op(1,12358,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance20(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(20,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(21,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12358,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,fp,H.Free(fp,templateLength)],mem);
    F.Push1(code,12358);
    assert Fetch(code,12358) == Op(96,12360,64);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance21(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(21,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(22,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12360,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,fp,H.Free(fp,templateLength),64],mem);
    assert Fetch(code,12360) == Op(82,12361,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance22(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(22,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(23,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12361,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,fp],H.Pointer(mem,fp,templateLength));
    assert Fetch(code,12361) == Op(128,12362,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance23(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(23,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(24,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12362,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,templateOffset,templateLength,templateLength,fp,fp],H.Pointer(mem,fp,templateLength));
    assert Fetch(code,12362) == Op(147,12363,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance24(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(24,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(25,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12363,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateLength,templateLength,fp,templateOffset],H.Pointer(mem,fp,templateLength));
    assert Fetch(code,12363) == Op(146,12364,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance25(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(25,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(26,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12364,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,fp,templateLength],H.Pointer(mem,fp,templateLength));
    assert Fetch(code,12364) == Op(145,12365,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance26(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(26,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(27,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12365,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,fp,templateLength],H.Pointer(mem,fp,templateLength));
    assert Fetch(code,12365) == Op(144,12366,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance27(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(27,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(28,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12366,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp],H.Pointer(mem,fp,templateLength));
    assert Fetch(code,12366) == Op(129,12367,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance28(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(28,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(29,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12367,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp,templateLength],H.Pointer(mem,fp,templateLength));
    assert Fetch(code,12367) == Op(129,12368,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance29(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(29,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(30,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12368,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp,templateLength,fp],H.Pointer(mem,fp,templateLength));
    assert Fetch(code,12368) == Op(82,12369,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance30(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(30,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(31,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12369,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp],H.Head(mem,fp,templateLength));
    F.Push1(code,12369);
    assert Fetch(code,12369) == Op(96,12371,32);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance31(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(31,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(32,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12371,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp,32],H.Head(mem,fp,templateLength));
    assert Fetch(code,12371) == Op(1,12372,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance32(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(32,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(33,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12372,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp+32],H.Head(mem,fp,templateLength));
    assert Fetch(code,12372) == Op(131,12373,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance33(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(33,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(34,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12373,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp+32,templateOffset],H.Head(mem,fp,templateLength));
    assert Fetch(code,12373) == Op(131,12374,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance34(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(34,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(35,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12374,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp+32,templateOffset,templateLength],H.Head(mem,fp,templateLength));
    assert Fetch(code,12374) == Op(128,12375,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance35(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(35,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(36,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12375,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp+32,templateOffset,templateLength,templateLength],H.Head(mem,fp,templateLength));
    assert Fetch(code,12375) == Op(130,12376,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance36(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(36,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(37,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12376,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp+32,templateOffset,templateLength,templateLength,templateOffset],H.Head(mem,fp,templateLength));
    assert Fetch(code,12376) == Op(132,12377,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance37(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(37,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(38,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12377,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp+32,templateOffset,templateLength,templateLength,templateOffset,fp+32],H.Head(mem,fp,templateLength));
    assert Fetch(code,12377) == Op(55,12378,0);
    reveal M.Step();
  }
  lemma Advance38(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(38,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(39,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12378,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp+32,templateOffset,templateLength],H.Copied(mem,fp,templateOffset,templateLength,data));
    assert Fetch(code,12378) == Op(95,12379,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance39(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(39,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(40,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12379,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,fp+32,templateOffset,templateLength,0],H.Copied(mem,fp,templateOffset,templateLength,data));
    assert Fetch(code,12379) == Op(146,12380,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance40(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(40,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(41,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12380,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,0,templateOffset,templateLength,fp+32],H.Copied(mem,fp,templateOffset,templateLength,data));
    assert Fetch(code,12380) == Op(1,12381,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance41(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(41,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(42,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12381,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,0,templateOffset,fp+32+templateLength],H.Copied(mem,fp,templateOffset,templateLength,data));
    assert Fetch(code,12381) == Op(130,12382,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance42(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(42,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(43,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12382,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,0,templateOffset,fp+32+templateLength,0],H.Copied(mem,fp,templateOffset,templateLength,data));
    assert Fetch(code,12382) == Op(144,12383,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance43(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(43,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(44,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12383,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,0,templateOffset,0,fp+32+templateLength],H.Copied(mem,fp,templateOffset,templateLength,data));
    assert Fetch(code,12383) == Op(82,12384,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance44(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(44,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(45,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12384,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,0,templateOffset],H.Complete(mem,fp,templateOffset,templateLength,data));
    assert Fetch(code,12384) == Op(80,12385,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance45(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(45,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(46,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12385,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,fp,templateOffset,templateLength,templateLength,0],H.Complete(mem,fp,templateOffset,templateLength,data));
    assert Fetch(code,12385) == Op(147,12386,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance46(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(46,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(47,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12386,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,0,0,templateOffset,templateLength,templateLength,fp],H.Complete(mem,fp,templateOffset,templateLength,data));
    assert Fetch(code,12386) == Op(148,12387,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance47(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(47,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(48,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12387,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,fp,0,templateOffset,templateLength,templateLength,0],H.Complete(mem,fp,templateOffset,templateLength,data));
    assert Fetch(code,12387) == Op(80,12388,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance48(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(48,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(49,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12388,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,fp,0,templateOffset,templateLength,templateLength],H.Complete(mem,fp,templateOffset,templateLength,data));
    assert Fetch(code,12388) == Op(80,12389,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance49(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(49,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); Good(50,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12389,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,fp,0,templateOffset,templateLength],H.Complete(mem,fp,templateOffset,templateLength,data));
    assert Fetch(code,12389) == Op(80,12390,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance50(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(50,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); next == Running(12391,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,fp,0],H.Complete(mem,fp,templateOffset,templateLength,data))
  {
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == Running(12390,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,fp,0,templateOffset],H.Complete(mem,fp,templateOffset,templateLength,data));
    assert Fetch(code,12390) == Op(80,12391,0);
    M.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  ghost method Block0(code: seq<Byte>,initial: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(0,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures Good(20,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial; trace := [state];
    Advance0(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next0 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0); trace := trace+[next0]; state := next0;
    Advance1(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next1 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1); trace := trace+[next1]; state := next1;
    Advance2(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next2 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2); trace := trace+[next2]; state := next2;
    Advance3(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next3 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3); trace := trace+[next3]; state := next3;
    Advance4(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next4 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4); trace := trace+[next4]; state := next4;
    Advance5(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next5 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5); trace := trace+[next5]; state := next5;
    Advance6(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next6 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6); trace := trace+[next6]; state := next6;
    Advance7(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next7 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7); trace := trace+[next7]; state := next7;
    Advance8(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next8 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8); trace := trace+[next8]; state := next8;
    Advance9(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next9 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9); trace := trace+[next9]; state := next9;
    Advance10(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next10 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10); trace := trace+[next10]; state := next10;
    Advance11(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next11 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11); trace := trace+[next11]; state := next11;
    Advance12(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next12 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12); trace := trace+[next12]; state := next12;
    Advance13(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next13 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13); trace := trace+[next13]; state := next13;
    Advance14(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next14 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14); trace := trace+[next14]; state := next14;
    Advance15(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next15 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15); trace := trace+[next15]; state := next15;
    Advance16(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next16 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16); trace := trace+[next16]; state := next16;
    Advance17(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next17 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17); trace := trace+[next17]; state := next17;
    Advance18(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next18 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18); trace := trace+[next18]; state := next18;
    Advance19(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next19 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19); trace := trace+[next19]; state := next19;
  }
  ghost method Block1(code: seq<Byte>,initial: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(20,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures Good(40,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial; trace := [state];
    Advance20(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next20 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20); trace := trace+[next20]; state := next20;
    Advance21(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next21 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21); trace := trace+[next21]; state := next21;
    Advance22(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next22 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22); trace := trace+[next22]; state := next22;
    Advance23(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next23 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23); trace := trace+[next23]; state := next23;
    Advance24(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next24 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24); trace := trace+[next24]; state := next24;
    Advance25(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next25 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25); trace := trace+[next25]; state := next25;
    Advance26(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next26 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26); trace := trace+[next26]; state := next26;
    Advance27(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next27 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27); trace := trace+[next27]; state := next27;
    Advance28(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next28 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28); trace := trace+[next28]; state := next28;
    Advance29(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next29 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29); trace := trace+[next29]; state := next29;
    Advance30(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next30 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30); trace := trace+[next30]; state := next30;
    Advance31(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next31 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31); trace := trace+[next31]; state := next31;
    Advance32(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next32 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next32); trace := trace+[next32]; state := next32;
    Advance33(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next33 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next33); trace := trace+[next33]; state := next33;
    Advance34(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next34 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next34); trace := trace+[next34]; state := next34;
    Advance35(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next35 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next35); trace := trace+[next35]; state := next35;
    Advance36(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next36 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next36); trace := trace+[next36]; state := next36;
    Advance37(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next37 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next37); trace := trace+[next37]; state := next37;
    Advance38(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next38 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next38); trace := trace+[next38]; state := next38;
    Advance39(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next39 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next39); trace := trace+[next39]; state := next39;
  }
  ghost method Block2(code: seq<Byte>,initial: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp) && Good(40,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures state == Running(12391,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,fp,0],H.Complete(mem,fp,templateOffset,templateLength,data)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 12 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial; trace := [state];
    Advance40(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next40 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next40); trace := trace+[next40]; state := next40;
    Advance41(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next41 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next41); trace := trace+[next41]; state := next41;
    Advance42(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next42 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next42); trace := trace+[next42]; state := next42;
    Advance43(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next43 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next43); trace := trace+[next43]; state := next43;
    Advance44(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next44 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next44); trace := trace+[next44]; state := next44;
    Advance45(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next45 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next45); trace := trace+[next45]; state := next45;
    Advance46(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next46 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next46); trace := trace+[next46]; state := next46;
    Advance47(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next47 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next47); trace := trace+[next47]; state := next47;
    Advance48(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next48 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next48); trace := trace+[next48]; state := next48;
    Advance49(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next49 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next49); trace := trace+[next49]; state := next49;
    Advance50(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    var next50 := M.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next50); trace := trace+[next50]; state := next50;
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, fp: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp)
    ensures state == Running(12391,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0,fp,0],H.Complete(mem,fp,templateOffset,templateLength,data)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 52 && trace[0] == Running(12334,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0],mem) && trace[|trace|-1] == state
  {
    state := Running(12334,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,0],mem); trace := [state]; reveal Good();
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block1(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block2(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,fp,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
