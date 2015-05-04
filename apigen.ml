let parse_file file =
  let fh = open_in file in
  let lexbuf = Lexing.from_channel fh in
  lexbuf.Lexing.lex_curr_p <- Lexing.({
      lexbuf.lex_curr_p with
      pos_fname = file;
    });

  let api = ApiPasses.parse_lexbuf lexbuf in

  close_in fh;

  api


let main input =
  let ApiAst.Api (pre, api, post) = parse_file input in

  (*print_endline (ApiAst.show_decls api);*)
  print_string (ApiPasses.all pre api post);
;;


let () =
  (*Printexc.record_backtrace true;*)
  match Sys.argv with
  | [|_; input|] -> main input
  | _ -> print_endline "Usage: apigen <file>"
