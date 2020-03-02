open ApiAst
open ApiFoldMap


let fold_decl v repl = function
  | Decl_Const (name, expr) as const ->
      let func = Decl_Static (
        Decl_Function (
          Ty_LName "uint32_t",
          String.lowercase_ascii name,
          [],
          Err_None
        )
      ) in
      let repl = ReplaceDecl.replace repl [const; func] in
      repl, Decl_Const (name, expr)

  | decl ->
      ReplaceDecl.fold_decl v repl decl


let v = { default with fold_decl }


let transform decls =
  let _, decls =
    ReplaceDecl.fold_decls v (ReplaceDecl.initial, ()) decls
  in
  decls
