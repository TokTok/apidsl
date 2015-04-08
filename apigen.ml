let parse file =
  let fh = open_in file in
  let lexbuf = Lexing.from_channel fh in

  let state = ApiLexer.state () in
  let api = ApiParser.parse_api (ApiLexer.token state) lexbuf in

  close_in fh;

  api


let (|!) x msg =
  print_endline msg;
  x


let main input =
  let ApiAst.Api (pre, api, post) = parse input in

  let api =
    api
    |> ErrorNULL.transform
    |> ErrorOK.transform
    |> GetSetParams.transform
    |> LengthParams.transform
    |> ThisParams.transform
    |> ErrorSplitFromFunction.transform
    |> (fun api -> ExtractSymbols.extract api, api)
    |> ScopeBinding.transform
    |> EventRename.transform
    |> EventApply.transform
    |> ErrorEnumsRename.transform
    |> GetSetRename.transform
    |> GetSetFlatten.transform
    |> StaticApply.transform
    |> StructTypes.transform
    |> ClassToNamespace.transform
    |> NamespaceApplyEvents.transform
    |> NamespaceApply.transform 1
    |> NamespaceFlatten.transform 1
    |> ErrorEnumsAddERR.transform
    |> ErrorEnums.transform
    |> ErrorParams.transform
    |> EventFunction.transform
    |> EventCloneFunctionName.transform
    |> EventParams.transform
    |> EventComments.transform
    |> EventFlatten.transform
    |> NamespaceApply.transform 0
    |> NamespaceFlatten.transform 0
    |> EnumNamespaceApply.transform
    |> EnumNamespaceFlatten.transform
    |> EnumApply.transform
    |> ArrayToPointer.transform
    |> StaticElide.transform
    |> Constants.transform
    |> ScopeBinding.Inverse.transform
    |> StringToCharP.transform
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
