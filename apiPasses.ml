let pass msg f x =
  (*print_endline msg;*)
  f x


let all pre api post =
  let api =
    api
    |> pass "ThisComments" ThisComments.transform
    |> pass "ErrorNULL" ErrorNULL.transform
    |> pass "ErrorOK" ErrorOK.transform
    |> pass "GetSetParams" GetSetParams.transform
    |> pass "LengthParams" LengthParams.transform
    |> pass "ThisParams" ThisParams.transform
    |> pass "ErrorSplitFromFunction" ErrorSplitFromFunction.transform
    |> pass "ExtractSymbols" (fun api -> ExtractSymbols.extract api, api)
    |> pass "ScopeBinding" ScopeBinding.transform
    |> pass "EventRename" EventRename.transform
    |> pass "EventApply" EventApply.transform
    |> pass "ErrorEnumsRename" ErrorEnumsRename.transform
    |> pass "GetSetRename" GetSetRename.transform
    |> pass "GetSetFlatten" GetSetFlatten.transform
    |> pass "StaticApply" StaticApply.transform
    |> pass "StructTypes" StructTypes.transform
    |> pass "ClassToNamespace" ClassToNamespace.transform
    |> pass "NamespaceApplyEvents" NamespaceApplyEvents.transform
    |> pass "NamespaceApply" (NamespaceApply.transform 1)
    |> pass "NamespaceFlatten" (NamespaceFlatten.transform 1)
    |> pass "ErrorEnumsAddERR" ErrorEnumsAddERR.transform
    |> pass "ErrorEnums" ErrorEnums.transform
    |> pass "ErrorParams" ErrorParams.transform
    |> pass "EventFunction" EventFunction.transform
    |> pass "EventCloneFunctionName" EventCloneFunctionName.transform
    |> pass "EventParams" EventParams.transform
    |> pass "EventComments" EventComments.transform
    |> pass "EventFlatten" EventFlatten.transform
    |> pass "NamespaceApply" (NamespaceApply.transform 0)
    |> pass "NamespaceFlatten" (NamespaceFlatten.transform 0)
    |> pass "EnumNamespaceApply" EnumNamespaceApply.transform
    |> pass "EnumNamespaceFlatten" EnumNamespaceFlatten.transform
    |> pass "EnumApply" EnumApply.transform
    |> pass "ArrayToPointer" ArrayToPointer.transform
    |> pass "StaticElide" StaticElide.transform
    |> pass "Constants" Constants.transform
    |> pass "ScopeBinding" ScopeBinding.Inverse.transform
    |> pass "StringToCharP" StringToCharP.transform
  in

  Option.may (Format.pp_print_string Format.str_formatter) pre;
  Format.fprintf Format.str_formatter "%a\n"
    ApiCodegen.cg_decls api;
  Option.may (Format.fprintf Format.str_formatter "\n%s\n") post;

  Format.flush_str_formatter ()
