open ApiAst
open ApiFoldMap


let rec make_accessors acc ns = function
  | [] -> acc
  | Decl_Comment (_, decl) :: decls ->
      make_accessors acc ns (decl :: decls)
  | Decl_Namespace (name, inner) :: decls ->
      let acc = make_accessors acc (ns ^ name ^ "_") inner in
      make_accessors acc ns decls
  | Decl_Member (ty, name) :: decls ->
      let acc = Decl_Function (
          Ty_Const ty, "get_" ^ ns ^ name, [], Err_None
        ) :: acc in
      let acc = Decl_Function (
          Ty_LName "void", "set_" ^ ns ^ name, [Param (ty, name)], Err_None
        ) :: acc in
      make_accessors acc ns decls
  | decl :: _ ->
      failwith @@ "cannot generate accessors for decl: "
                  ^ (show_decl Format.pp_print_string decl)


let fold_decl v repl = function
  | Decl_Struct (_, [], _) as decl -> repl, decl
  | Decl_Struct (lname, ["get"; "set"], decls) ->
      let funcs = List.rev @@ make_accessors [] "" decls in
      let decl = Decl_Struct (lname, [], decls) in
      let repl = ReplaceDecl.append repl funcs in
      repl, decl

  | decl ->
      ReplaceDecl.fold_decl v repl decl


let v = { default with fold_decl }


let transform decls =
  let _, decls =
    ReplaceDecl.fold_decls v (ReplaceDecl.initial, ()) decls
  in
  decls
