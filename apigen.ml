let parse file =
  let fh = open_in file in
  let lexbuf = Lexing.from_channel fh in

  let state = ApiLexer.state () in
  let api = ApiParser.parse_api (ApiLexer.token state) lexbuf in

  close_in fh;

  api


let pass msg f x =
  (*print_endline msg;*)
  f x


let main input =
  let ApiAst.Api (pre, api, post) = parse input in

  let api =
    api
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

  (*print_endline (ApiAst.show_decls api);*)

  Option.may print_endline pre;
  Format.fprintf Format.std_formatter "%a\n"
    ApiCodegen.cg_decls api;
  Option.may (fun x -> print_newline (); print_endline x) post;
;;


let () =
  (*Printexc.record_backtrace true;*)
  match Sys.argv with
  | [|_; input|] -> main input
  | _ -> print_endline "Usage: apigen <file>"
