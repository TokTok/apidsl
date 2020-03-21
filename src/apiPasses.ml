let haskell_preamble = "
import           Data.Int                  (Int16, Int32, Int64, Int8)
import           Data.Word                 (Word16, Word32, Word64, Word8)
import           Foreign.C.String          (CString, withCString)
import           Foreign.C.Types           (CInt (..), CSize (..))
import           Foreign.Ptr               (FunPtr, Ptr)
"


let pass _ f x =
  (*print_endline msg;*)
  f x


let display x =
  print_endline (ApiAst.show_decls Format.pp_print_string x);
  x


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
    ApiCodegen.C.cg_decls api;
  Option.may (Format.fprintf Format.str_formatter "\n%s\n") post;

  Format.flush_str_formatter ()


let haskell modname api =
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
    |> pass "StaticElide" StaticElide.transform
    |> pass "HaskellCamelCase" HaskellCamelCase.transform
    |> pass "HaskellTypes" HaskellTypes.transform
    |> pass "ScopeBinding" ScopeBinding.Inverse.transform
    |> pass "EnumBitmasks" EnumBitmasks.transform
    |> pass "HaskellFromC" HaskellFromC.transform
    |> pass "HaskellComments" HaskellComments.transform
  in

  Format.fprintf Format.str_formatter "module %s where@," modname;
  Format.fprintf Format.str_formatter "%s" haskell_preamble;
  Format.fprintf Format.str_formatter "%a\n"
    HaskellCodegen.cg_decls api;

  Format.flush_str_formatter ()


let dump_api pre api post =
  let pp_verbatim fmt =
    Format.fprintf fmt "%%{@\n%a@\n%%}@\n" Format.pp_print_string
  in
  Option.may (pp_verbatim Format.str_formatter) pre;
  Format.fprintf Format.str_formatter "%a\n"
    ApiCodegen.Api.cg_decls api;
  Option.may (pp_verbatim Format.str_formatter) post;

  Format.flush_str_formatter ()


let format_lex_error start_p token =
  let open Lexing in
  Printf.sprintf "%s:%d:%d: error at %s"
    start_p.pos_fname
    start_p.pos_lnum
    (start_p.pos_cnum - start_p.pos_bol + 1)
    token


let format_error (token, start_p, _) =
  format_lex_error start_p (ApiLexer.string_of_token token)


let lex state lexbuf =
  let token = ApiLexer.token state lexbuf in
  let start_p = Lexing.lexeme_start_p lexbuf in
  let end_p = Lexing.lexeme_end_p lexbuf in
  (token, start_p, end_p)


let handle_error last_input =
  match last_input with
  | None ->
      failwith "error at <epsilon>"
  | Some last_input ->
      failwith (format_error last_input)


let rec parse state lexbuf last_input = let open ApiParser.MenhirInterpreter in
  function
  | InputNeeded _ as checkpoint ->
      let last_input = lex state lexbuf in
      parse state lexbuf (Some last_input) (offer checkpoint last_input)
  | Shifting _
  | AboutToReduce _ as checkpoint ->
      parse state lexbuf last_input (resume checkpoint)
  | HandlingError _ ->
      handle_error last_input
  | Accepted result ->
      result
  | Rejected ->
      failwith "rejected"


let parse_lexbuf lexbuf =
  let state = ApiLexer.state () in
  parse state lexbuf None (ApiParser.Incremental.parse_api Lexing.dummy_pos)

let parse_string file str =
  let lexbuf = Lexing.from_string str in
  lexbuf.Lexing.lex_curr_p <- Lexing.({
      lexbuf.lex_curr_p with
      pos_fname = file;
    });

  parse_lexbuf lexbuf

let parse_file file =
  let fh = open_in file in
  let lexbuf = Lexing.from_channel fh in
  lexbuf.Lexing.lex_curr_p <- Lexing.({
      lexbuf.lex_curr_p with
      pos_fname = file;
    });

  let api = parse_lexbuf lexbuf in

  close_in fh;

  api
