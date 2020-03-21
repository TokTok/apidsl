open Apidsl
open Js_of_ocaml

let () =
  Js.Unsafe.global##.apidsl := (object%js
    val parse = Js.wrap_callback (fun file contents ->
      try
        Ok (ApiPasses.parse_string
          (Js.to_string file)
          (Js.to_string contents))
      with
      | Failure(x) -> Error(Js.string x)
      | ApiLexer.Lexing_error(start_p, token) ->
          let error = ApiPasses.format_lex_error start_p token in
          Error(Js.string error))

    val ast = Js.wrap_callback (fun api ->
      try Ok (Js.string (ApiAst.show_api Format.pp_print_string api))
      with Failure(x) -> Error(Js.string x))

    val api = Js.wrap_callback (fun api ->
      let ApiAst.Api (pre, ast, post) = api in
      try Ok (Js.string (ApiPasses.dump_api pre ast post))
      with Failure(x) -> Error(Js.string x))

    val c = Js.wrap_callback (fun api ->
      let ApiAst.Api (pre, ast, post) = api in
      try Ok (Js.string (ApiPasses.all pre ast post))
      with Failure(x) -> Error(Js.string x))

    val haskell = Js.wrap_callback (fun modname api ->
      let ApiAst.Api (_, ast, _) = api in
      try Ok (Js.string (ApiPasses.haskell (Js.to_string modname) ast))
      with Failure(x) -> Error(Js.string x))
  end)
