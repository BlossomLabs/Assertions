include "../../../proof-tools/dafnyevm/src/test/dafny/proofs/InstructionSummaries.dfy"
module ProductionHelpers {
  import opened Int
  import opened EvmState
  import EVM
  import EvmFork
  import F = ForkFacts
  import S = InstructionSteps
  import P = PushSummaries
  import Shift = ShiftSummaries
  import Load = LoadSummaries
  import Stack
  import Bytecode
  import U256
  import MathUtils = EvmArithmetic
  import Code
  import ByteUtils
  import Arrays
  function Window(): seq<u8> { [91,95,96,32,130,81,16,21] + [97,15,183,87,129,81,96,64] + [81,99,106,229,194,27,96,225] + [27,129,82,95,96,4,130,1] + [82,96,36,129,1,145,144,145] + [82,96,68,1,97,5,143,86] + [91,80,96,32,1,81,144,86] + [91,95,96,160,131,144,28,21] + [97,15,237,87,96,64,81,99] + [87,191,148,75,96,224,27,129] + [82,96,4,129,1,131,144,82] + [96,36,129,1,132,144,82,96] + [68,1,97,5,143,86,91,80] + [144,145,144,80,86] }
  lemma {:isolate_assertions} WindowFacts(code:seq<u8>)
    requires 4084 <= |code|
    requires code[3975..4084] == Window()
    ensures code[3975] == 91
    ensures code[3976] == 95
    ensures code[3977] == 96
    ensures code[3978] == 32
    ensures code[3979] == 130
    ensures code[3980] == 81
    ensures code[3981] == 16
    ensures code[3982] == 21
    ensures code[3983] == 97
    ensures code[3984] == 15
    ensures code[3985] == 183
    ensures code[3986] == 87
    ensures code[3987] == 129
    ensures code[3988] == 81
    ensures code[3989] == 96
    ensures code[3990] == 64
    ensures code[3991] == 81
    ensures code[3992] == 99
    ensures code[3993] == 106
    ensures code[3994] == 229
    ensures code[3995] == 194
    ensures code[3996] == 27
    ensures code[3997] == 96
    ensures code[3998] == 225
    ensures code[3999] == 27
    ensures code[4000] == 129
    ensures code[4001] == 82
    ensures code[4002] == 95
    ensures code[4003] == 96
    ensures code[4004] == 4
    ensures code[4005] == 130
    ensures code[4006] == 1
    ensures code[4007] == 82
    ensures code[4008] == 96
    ensures code[4009] == 36
    ensures code[4010] == 129
    ensures code[4011] == 1
    ensures code[4012] == 145
    ensures code[4013] == 144
    ensures code[4014] == 145
    ensures code[4015] == 82
    ensures code[4016] == 96
    ensures code[4017] == 68
    ensures code[4018] == 1
    ensures code[4019] == 97
    ensures code[4020] == 5
    ensures code[4021] == 143
    ensures code[4022] == 86
    ensures code[4023] == 91
    ensures code[4024] == 80
    ensures code[4025] == 96
    ensures code[4026] == 32
    ensures code[4027] == 1
    ensures code[4028] == 81
    ensures code[4029] == 144
    ensures code[4030] == 86
    ensures code[4031] == 91
    ensures code[4032] == 95
    ensures code[4033] == 96
    ensures code[4034] == 160
    ensures code[4035] == 131
    ensures code[4036] == 144
    ensures code[4037] == 28
    ensures code[4038] == 21
    ensures code[4039] == 97
    ensures code[4040] == 15
    ensures code[4041] == 237
    ensures code[4042] == 87
    ensures code[4043] == 96
    ensures code[4044] == 64
    ensures code[4045] == 81
    ensures code[4046] == 99
    ensures code[4047] == 87
    ensures code[4048] == 191
    ensures code[4049] == 148
    ensures code[4050] == 75
    ensures code[4051] == 96
    ensures code[4052] == 224
    ensures code[4053] == 27
    ensures code[4054] == 129
    ensures code[4055] == 82
    ensures code[4056] == 96
    ensures code[4057] == 4
    ensures code[4058] == 129
    ensures code[4059] == 1
    ensures code[4060] == 131
    ensures code[4061] == 144
    ensures code[4062] == 82
    ensures code[4063] == 96
    ensures code[4064] == 36
    ensures code[4065] == 129
    ensures code[4066] == 1
    ensures code[4067] == 132
    ensures code[4068] == 144
    ensures code[4069] == 82
    ensures code[4070] == 96
    ensures code[4071] == 68
    ensures code[4072] == 1
    ensures code[4073] == 97
    ensures code[4074] == 5
    ensures code[4075] == 143
    ensures code[4076] == 86
    ensures code[4077] == 91
    ensures code[4078] == 80
    ensures code[4079] == 144
    ensures code[4080] == 145
    ensures code[4081] == 144
    ensures code[4082] == 80
    ensures code[4083] == 86
  { reveal Window(); }
  ghost method {:fuel MathUtils.Pow, 12, 13} FirstSuccess(st: ExecutingState, pointer: u256, continuation: u256) returns (out: State)
    requires 4084 <= |st.evm.code.contents|
    requires st.evm.code.contents[3975..4084] == Window()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.PC() == 3975
    requires st.IsJumpDest(3975) && st.IsJumpDest(4023)
    requires st.evm.stack.contents == [pointer, continuation]
    requires st.IsJumpDest(continuation)
    requires (pointer as int) <= MAX_U256 - 64
    requires (pointer as nat) + 64 <= |st.evm.memory.contents|
    requires st.Read(pointer as nat) >= 32
    requires st.Gas() >= 200
    ensures out.EXECUTING?
    ensures out.EXECUTING? ==> out.PC() == continuation as nat
    ensures out.EXECUTING? ==> out.evm.stack.contents == [st.Read((pointer as nat)+32)]
    ensures out.EXECUTING? ==> out.evm.memory == st.evm.memory
    ensures out.EXECUTING? ==> out.Gas() == st.Gas()-54
  {
    F.CancunMembership();
    WindowFacts(st.evm.code.contents);
    reveal EVM.Execute();
    reveal EVM.DeductGas();
    reveal EVM.ExecuteBytecode();
    reveal Bytecode.JumpDest();
    reveal Bytecode.Push0();
    reveal Bytecode.Push();
    reveal Bytecode.Dup();
    reveal Bytecode.Swap();
    reveal Bytecode.MLoad();
    reveal Bytecode.Lt();
    reveal Bytecode.IsZero();
    reveal Bytecode.JumpI();
    reveal Bytecode.Pop();
    reveal Bytecode.Add();
    reveal Bytecode.Jump();
    reveal Window();
    reveal Code.Slice();
    reveal Arrays.SliceAndPad();
    reveal ByteUtils.ConvertBytesTo256();
    reveal ByteUtils.ReadUint16();
    assert Window()[0] == 91;
    assert st.evm.code.contents[3975..4084][0] == st.evm.code.contents[3975];
    var s := st;
    assert s.evm.code.contents[3975] == 91;
    S.JumpDestStep(s);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 3976, stack := Stack.Make([pointer,continuation]), gas := st.Gas()-1));
    assert s.evm.code.contents[3976] == 95;
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 3977, stack := Stack.Make([0,pointer,continuation]), gas := st.Gas()-3));
    assert s.evm.code.contents[3977] == 96;
    P.PushOne(s,32);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 3979, stack := Stack.Make([32,0,pointer,continuation]), gas := st.Gas()-6));
    assert s.evm.code.contents[3979] == 130;
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 3980, stack := Stack.Make([pointer,32,0,pointer,continuation]), gas := st.Gas()-9));
    assert s.evm.code.contents[3980] == 81;
    Load.Fits(s);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 3981, stack := Stack.Make([st.Read(pointer as nat),32,0,pointer,continuation]), gas := st.Gas()-12));
    assert s.evm.code.contents[3981] == 16;
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 3982, stack := Stack.Make([0,0,pointer,continuation]), gas := st.Gas()-15));
    assert s.evm.code.contents[3982] == 21;
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 3983, stack := Stack.Make([1,0,pointer,continuation]), gas := st.Gas()-18));
    assert s.evm.code.contents[3983] == 97;
    P.PushTwo(s,15,183);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 3986, stack := Stack.Make([4023,1,0,pointer,continuation]), gas := st.Gas()-21));
    assert s.evm.code.contents[3986] == 87;
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4023, stack := Stack.Make([0,pointer,continuation]), gas := st.Gas()-31));
    assert s.evm.code.contents[4023] == 91;
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4024, stack := Stack.Make([0,pointer,continuation]), gas := st.Gas()-32));
    assert s.evm.code.contents[4024] == 80;
    S.PopStep(s);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4025, stack := Stack.Make([pointer,continuation]), gas := st.Gas()-34));
    assert s.evm.code.contents[4025] == 96;
    P.PushOne(s,32);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4027, stack := Stack.Make([32,pointer,continuation]), gas := st.Gas()-37));
    assert s.evm.code.contents[4027] == 1;
    S.AddStep(s);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4028, stack := Stack.Make([pointer+32,continuation]), gas := st.Gas()-40));
    assert s.evm.code.contents[4028] == 81;
    Load.Fits(s);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4029, stack := Stack.Make([st.Read((pointer as nat)+32),continuation]), gas := st.Gas()-43));
    assert s.evm.code.contents[4029] == 144;
    S.SwapStep(s,1);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4030, stack := Stack.Make([continuation,st.Read((pointer as nat)+32)]), gas := st.Gas()-46));
    assert s.evm.code.contents[4030] == 86;
    S.JumpStep(s);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := continuation as nat, stack := Stack.Make([st.Read((pointer as nat)+32)]), gas := st.Gas()-54));
    out := s;
  }
  ghost method AddressSuccess(st: ExecutingState, word: u256, index: u256, continuation: u256) returns (out: State)
    requires 4084 <= |st.evm.code.contents|
    requires st.evm.code.contents[3975..4084] == Window()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.PC() == 4031
    requires st.IsJumpDest(4031) && st.IsJumpDest(4077)
    requires st.evm.stack.contents == [index,word,continuation]
    requires word < 0x10000000000000000000000000000000000000000
    requires st.IsJumpDest(continuation)
    requires st.Gas() >= 200
    ensures out.EXECUTING?
    ensures out.EXECUTING? ==> out.PC() == continuation as nat
    ensures out.EXECUTING? ==> out.evm.stack.contents == [word]
    ensures out.EXECUTING? ==> out.evm.memory == st.evm.memory
    ensures out.EXECUTING? ==> out.Gas() == st.Gas()-53
  {
    Shift.Below160(word);
    F.CancunMembership();
    WindowFacts(st.evm.code.contents);
    reveal EVM.Execute();
    reveal EVM.DeductGas();
    reveal EVM.ExecuteBytecode();
    reveal Bytecode.JumpDest();
    reveal Bytecode.Push0();
    reveal Bytecode.Push();
    reveal Bytecode.Dup();
    reveal Bytecode.Swap();
    reveal Bytecode.IsZero();

    reveal Bytecode.JumpI();
    reveal Bytecode.Pop();
    reveal Bytecode.Jump();

    reveal Window();
    assert Window()[0] == 91;
    assert st.evm.code.contents[3975..4084][0] == st.evm.code.contents[3975];
    var s := st;
    assert s.evm.code.contents[4031] == 91;
    S.JumpDestStep(s);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4032, stack := Stack.Make([index,word,continuation]), gas := st.Gas()-1));
    assert s.evm.code.contents[4032] == 95;
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4033, stack := Stack.Make([0,index,word,continuation]), gas := st.Gas()-3));
    assert s.evm.code.contents[4033] == 96;
    P.PushOne(s,160);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4035, stack := Stack.Make([160,0,index,word,continuation]), gas := st.Gas()-6));
    assert s.evm.code.contents[4035] == 131;
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4036, stack := Stack.Make([word,160,0,index,word,continuation]), gas := st.Gas()-9));
    assert s.evm.code.contents[4036] == 144;
    S.SwapStep(s,1);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4037, stack := Stack.Make([160,word,0,index,word,continuation]), gas := st.Gas()-12));
    assert s.evm.code.contents[4037] == 28;
    Shift.ExecuteBelow160(s);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4038, stack := Stack.Make([0,0,index,word,continuation]), gas := st.Gas()-15));
    assert s.evm.code.contents[4038] == 21;
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4039, stack := Stack.Make([1,0,index,word,continuation]), gas := st.Gas()-18));
    assert s.evm.code.contents[4039] == 97;
    P.PushTwo(s,15,237);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4042, stack := Stack.Make([4077,1,0,index,word,continuation]), gas := st.Gas()-21));
    assert s.evm.code.contents[4042] == 87;
    S.JumpIfStep(s);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4077, stack := Stack.Make([0,index,word,continuation]), gas := st.Gas()-31));
    assert s.evm.code.contents[4077] == 91;
    S.JumpDestStep(s);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4078, stack := Stack.Make([0,index,word,continuation]), gas := st.Gas()-32));
    assert s.evm.code.contents[4078] == 80;
    S.PopStep(s);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4079, stack := Stack.Make([index,word,continuation]), gas := st.Gas()-34));
    assert s.evm.code.contents[4079] == 144;
    S.SwapStep(s,1);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4080, stack := Stack.Make([word,index,continuation]), gas := st.Gas()-37));
    assert s.evm.code.contents[4080] == 145;
    S.SwapStep(s,2);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4081, stack := Stack.Make([continuation,index,word]), gas := st.Gas()-40));
    assert s.evm.code.contents[4081] == 144;
    S.SwapStep(s,1);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4082, stack := Stack.Make([index,continuation,word]), gas := st.Gas()-43));
    assert s.evm.code.contents[4082] == 80;
    S.PopStep(s);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := 4083, stack := Stack.Make([continuation,word]), gas := st.Gas()-45));
    assert s.evm.code.contents[4083] == 86;
    S.JumpStep(s);
    s := EVM.Execute(s);
    assert s == EXECUTING(st.evm.(pc := continuation as nat, stack := Stack.Make([word]), gas := st.Gas()-53));
    out := s;
  }
}
