// SPDX-License-Identifier: MIT
// Generated from the gated full Collections AST and compiler ABI method identifiers.
module CollectionsCompletionBoundary {
  datatype Entry = AllValues | AnyValues | FilterValues | FilterWords | FindValues | FlattenValues | FoldBytes | FoldRange | FoldValues | FoldWords | IndexOfValues | IotaWords | MapValues | MapWords | PackArray | ReverseValues | ReverseWords | SliceValues | SortValues | SortWords | SumWords | UniqueValues | UniqueWords | UnpackArray | UnzipValues | UnzipWords | WordIndexOf | ZipValues | ZipWords
  datatype Route = Unknown | Known(entry: Entry)

  function Selector(e: Entry): nat
    ensures Selector(e) < 0x100000000
  {
    match e
    case AllValues => 307145824
    case AnyValues => 3395859074
    case FilterValues => 994174373
    case FilterWords => 2005396296
    case FindValues => 2412878959
    case FlattenValues => 391003434
    case FoldBytes => 1831135132
    case FoldRange => 4057501128
    case FoldValues => 1963819735
    case FoldWords => 1843793072
    case IndexOfValues => 3001508401
    case IotaWords => 2368205965
    case MapValues => 961624077
    case MapWords => 3983393726
    case PackArray => 2625112747
    case ReverseValues => 3309852450
    case ReverseWords => 2874738232
    case SliceValues => 3921833887
    case SortValues => 3705265211
    case SortWords => 785862473
    case SumWords => 394725771
    case UniqueValues => 476661964
    case UniqueWords => 3045624246
    case UnpackArray => 3411229406
    case UnzipValues => 1085790307
    case UnzipWords => 2989505972
    case WordIndexOf => 3904669827
    case ZipValues => 166449333
    case ZipWords => 269019481
  }
  function Arity(e: Entry): nat {
    match e
    case AllValues => 3
    case AnyValues => 3
    case FilterValues => 3
    case FilterWords => 4
    case FindValues => 3
    case FlattenValues => 2
    case FoldBytes => 7
    case FoldRange => 7
    case FoldValues => 5
    case FoldWords => 7
    case IndexOfValues => 4
    case IotaWords => 1
    case MapValues => 4
    case MapWords => 4
    case PackArray => 2
    case ReverseValues => 2
    case ReverseWords => 1
    case SliceValues => 4
    case SortValues => 3
    case SortWords => 1
    case SumWords => 1
    case UniqueValues => 4
    case UniqueWords => 2
    case UnpackArray => 2
    case UnzipValues => 4
    case UnzipWords => 2
    case WordIndexOf => 2
    case ZipValues => 4
    case ZipWords => 2
  }
  function Outputs(e: Entry): nat {
    match e
    case AllValues => 1
    case AnyValues => 1
    case FilterValues => 1
    case FilterWords => 1
    case FindValues => 1
    case FlattenValues => 1
    case FoldBytes => 1
    case FoldRange => 1
    case FoldValues => 1
    case FoldWords => 1
    case IndexOfValues => 1
    case IotaWords => 1
    case MapValues => 1
    case MapWords => 1
    case PackArray => 1
    case ReverseValues => 1
    case ReverseWords => 1
    case SliceValues => 1
    case SortValues => 1
    case SortWords => 1
    case SumWords => 1
    case UniqueValues => 1
    case UniqueWords => 1
    case UnpackArray => 1
    case UnzipValues => 1
    case UnzipWords => 1
    case WordIndexOf => 1
    case ZipValues => 1
    case ZipWords => 1
  }
  function View(e: Entry): bool {
    match e
    case AllValues => true
    case AnyValues => true
    case FilterValues => true
    case FilterWords => true
    case FindValues => true
    case FlattenValues => false
    case FoldBytes => true
    case FoldRange => true
    case FoldValues => true
    case FoldWords => true
    case IndexOfValues => true
    case IotaWords => false
    case MapValues => true
    case MapWords => true
    case PackArray => false
    case ReverseValues => false
    case ReverseWords => false
    case SliceValues => false
    case SortValues => true
    case SortWords => false
    case SumWords => false
    case UniqueValues => true
    case UniqueWords => false
    case UnpackArray => false
    case UnzipValues => false
    case UnzipWords => false
    case WordIndexOf => false
    case ZipValues => false
    case ZipWords => false
  }
  function RouteFor(s: nat): Route {
    if s == 307145824 then Known(AllValues)
    else if s == 3395859074 then Known(AnyValues)
    else if s == 994174373 then Known(FilterValues)
    else if s == 2005396296 then Known(FilterWords)
    else if s == 2412878959 then Known(FindValues)
    else if s == 391003434 then Known(FlattenValues)
    else if s == 1831135132 then Known(FoldBytes)
    else if s == 4057501128 then Known(FoldRange)
    else if s == 1963819735 then Known(FoldValues)
    else if s == 1843793072 then Known(FoldWords)
    else if s == 3001508401 then Known(IndexOfValues)
    else if s == 2368205965 then Known(IotaWords)
    else if s == 961624077 then Known(MapValues)
    else if s == 3983393726 then Known(MapWords)
    else if s == 2625112747 then Known(PackArray)
    else if s == 3309852450 then Known(ReverseValues)
    else if s == 2874738232 then Known(ReverseWords)
    else if s == 3921833887 then Known(SliceValues)
    else if s == 3705265211 then Known(SortValues)
    else if s == 785862473 then Known(SortWords)
    else if s == 394725771 then Known(SumWords)
    else if s == 476661964 then Known(UniqueValues)
    else if s == 3045624246 then Known(UniqueWords)
    else if s == 3411229406 then Known(UnpackArray)
    else if s == 1085790307 then Known(UnzipValues)
    else if s == 2989505972 then Known(UnzipWords)
    else if s == 3904669827 then Known(WordIndexOf)
    else if s == 166449333 then Known(ZipValues)
    else if s == 269019481 then Known(ZipWords)
    else Unknown
  }

  lemma RoundTrip(e: Entry)
    ensures RouteFor(Selector(e)) == Known(e)
    ensures 1 <= Arity(e) <= 7
    ensures Outputs(e) == 1
  {
    match e {
      case AllValues => {}
      case AnyValues => {}
      case FilterValues => {}
      case FilterWords => {}
      case FindValues => {}
      case FlattenValues => {}
      case FoldBytes => {}
      case FoldRange => {}
      case FoldValues => {}
      case FoldWords => {}
      case IndexOfValues => {}
      case IotaWords => {}
      case MapValues => {}
      case MapWords => {}
      case PackArray => {}
      case ReverseValues => {}
      case ReverseWords => {}
      case SliceValues => {}
      case SortValues => {}
      case SortWords => {}
      case SumWords => {}
      case UniqueValues => {}
      case UniqueWords => {}
      case UnpackArray => {}
      case UnzipValues => {}
      case UnzipWords => {}
      case WordIndexOf => {}
      case ZipValues => {}
      case ZipWords => {}
    }
  }

  lemma Sound(s: nat)
    ensures RouteFor(s).Known? ==> Selector(RouteFor(s).entry) == s
  {}

  lemma Distinct(a: Entry, b: Entry)
    requires Selector(a) == Selector(b)
    ensures a == b
  {
    RoundTrip(a);
    RoundTrip(b);
  }

  lemma Complete(s: nat, e: Entry)
    requires Selector(e) == s
    ensures RouteFor(s) == Known(e)
  { RoundTrip(e); }

  lemma UnknownIsUnassigned(s: nat, e: Entry)
    requires RouteFor(s) == Unknown
    ensures Selector(e) != s
  { RoundTrip(e); }
}
