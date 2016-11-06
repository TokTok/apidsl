let pass msg f x =
  (*print_endline msg;*)
  f x


let all pre api post =
  let api =
    api
    |> pass "GetSetStruct" GetSetStruct.transform
    |> pass "ConstFunction" ConstFunction.transform
    |> pass "ThisComments" ThisComments.transform
    |> pass "ErrorNULL" ErrorNULL.transform
    |> pass "ErrorOK" ErrorOK.transform
    |> pass "GetSetParams" GetSetParams.transform
    |> pass "LengthParams" LengthParams.transform
    |> pass "ThisParams" ThisParams.transform
    |> pass "ErrorSplitFromFunction" ErrorSplitFromFunction.transform
    |> pass "EnumBitmasks" EnumBitmasks.transform
    |> pass "EnumBitmaskNONE" EnumBitmaskNONE.transform
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


let format_error (token, start_p, end_p) =
  let open Lexing in
  Printf.sprintf "%s:%d:%d: error at %s"
    start_p.pos_fname
    start_p.pos_lnum
    (start_p.pos_cnum - start_p.pos_bol + 1)
    (ApiLexer.string_of_token token)


let lex state lexbuf =
  let token = ApiLexer.token state lexbuf in
  let start_p = Lexing.lexeme_start_p lexbuf in
  let end_p = Lexing.lexeme_end_p lexbuf in
  (token, start_p, end_p)


let rec parse state lexbuf last_input = let open ApiParser.MenhirInterpreter in
  function
  | InputNeeded env as checkpoint ->
      let last_input = lex state lexbuf in
      parse state lexbuf (Some last_input) (offer checkpoint last_input)
  | Shifting _
  | AboutToReduce _ as checkpoint ->
      parse state lexbuf last_input (resume checkpoint)
  | HandlingError env ->
      handle_error state lexbuf last_input env
  | Accepted result ->
      result
  | Rejected ->
      failwith "rejected"

and handle_error state lexbuf last_input env = let open ApiParser.MenhirInterpreter in
  match last_input with
  | None ->
      failwith "error at <epsilon>"
  | Some last_input ->
      failwith (format_error last_input)


let parse_lexbuf lexbuf =
  let state = ApiLexer.state () in
  parse state lexbuf None (ApiParser.Incremental.parse_api Lexing.dummy_pos)
