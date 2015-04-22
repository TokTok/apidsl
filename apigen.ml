let parse file =
  let fh = open_in file in
  let lexbuf = Lexing.from_channel fh in

  let state = ApiLexer.state () in
  let api = ApiParser.parse_api (ApiLexer.token state) lexbuf in

  close_in fh;

  api


let main input =
  let ApiAst.Api (pre, api, post) = parse input in

  (*print_endline (ApiAst.show_decls api);*)
  print_string (ApiPasses.all pre api post);
;;


let () =
  (*Printexc.record_backtrace true;*)
  match Sys.argv with
  | [|_; input|] -> main input
  | _ -> print_endline "Usage: apigen <file>"
