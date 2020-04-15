open Apidsl

type outlang =
  | Api
  | Ast
  | C
  | Haskell of string


let main input =
  let api = ApiPasses.parse_file input in
  let ApiAst.Api (pre, ast, post) = api in
  function
  | C               -> print_string (ApiPasses.all pre ast post)
  | Haskell modname -> print_string (ApiPasses.haskell modname ast)
  | Ast             -> print_endline (ApiAst.show_api Format.pp_print_string api)
  | Api             -> print_endline (ApiPasses.dump_api pre ast post)


let () =
  (*Printexc.record_backtrace true;*)
  try
    match Sys.argv with
    | [|_                ; input|]
    | [|_; "-c"          ; input|] -> main input C
    | [|_; "-hs"; modname; input|] -> main input (Haskell modname)
    | [|_; "-ast"        ; input|] -> main input Ast
    | [|_; "-api"        ; input|] -> main input Api
    | _ -> print_endline "Usage: apigen <file>"
  with
  | Failure msg -> print_endline ("Failure: " ^ msg)
  | ApiLexer.Lexing_error (start_p, token) ->
      let error = ApiPasses.format_lex_error start_p token in
      print_endline ("Lexing_error: " ^ error)
