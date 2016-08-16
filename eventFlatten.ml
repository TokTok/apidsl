open ApiAst
open ApiFoldMap


let fold_decl v state = function
  | Decl_Event (lname, is_const, decls) ->
      let state = ReplaceDecl.replace state decls in
      state, Decl_Event (lname, is_const, decls)

  | decl ->
      ReplaceDecl.fold_decl v state decl


let v = { default with fold_decl }


let transform (symtab, decls) =
  symtab, snd @@ ReplaceDecl.fold_decls v (ReplaceDecl.initial, ()) decls
