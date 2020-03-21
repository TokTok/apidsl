open Apidsl
module S = Tiny_httpd

type 'a request = Request of 'a [@@deriving yojson]
type 'a response = int * 'a [@@deriving yojson]
type text = string [@@deriving yojson]

let headers = [
  ("Access-Control-Allow-Origin", "*");
  ("Content-Type", "application/json");
]

let respond ok b_to_yojson res = 
  S.Response.make_string ~headers
    (Ok (Yojson.Safe.to_string (response_to_yojson b_to_yojson (ok, res))))

let wrap req_of_yojson res_to_yojson f req =
  try
    let Request decoded =
      let body = S.Request.body req in
      match request_of_yojson req_of_yojson (Yojson.Safe.from_string body) with
      | Ok value -> value
      | Error e -> failwith e
    in
    respond 0 res_to_yojson (f decoded)
  with e ->
    respond 0 text_to_yojson (Printexc.to_string e)

let () =
  let port_ = ref 8080 in
  Arg.parse (Arg.align [
      "--port", Arg.Set_int port_, " set port";
      "-p", Arg.Set_int port_, " set port";
    ]) (fun _ -> raise (Arg.Bad "")) "echo [option]*";
  let server = S.create ~addr:"0.0.0.0" ~port:!port_ () in

  S.add_path_handler server "/parse"
    @@ wrap text_of_yojson (ApiAst.api_to_yojson text_to_yojson)
    (ApiPasses.parse_string "input.api.h");

  S.add_path_handler server "/api"
    @@ wrap (ApiAst.api_of_yojson text_of_yojson) text_to_yojson
    (fun api ->
      let ApiAst.Api (pre, ast, post) = api in
      ApiPasses.dump_api pre ast post);

  S.add_path_handler server "/ast"
    @@ wrap (ApiAst.api_of_yojson text_of_yojson) text_to_yojson
    (ApiAst.show_api Format.pp_print_string);

  S.add_path_handler server "/c"
    @@ wrap (ApiAst.api_of_yojson text_of_yojson) text_to_yojson
    (fun api ->
      let ApiAst.Api (pre, ast, post) = api in
      ApiPasses.all pre ast post);

  S.add_path_handler server "/haskell"
    @@ wrap (ApiAst.api_of_yojson text_of_yojson) text_to_yojson
    (fun api ->
      let ApiAst.Api (_, ast, _) = api in
      ApiPasses.haskell "MyAPI" ast);

  Printf.printf "listening on http://%s:%d\n%!" (S.addr server) (S.port server);
  match S.run server with
  | Ok () -> ()
  | Error e -> raise e
