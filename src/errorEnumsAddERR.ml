open ApiAst
open ApiFold


let fold_decl v symtab = function
  | Decl_Error (lname, _) ->
      SymbolTable.rename lname
        (fun name -> "ERR_" ^ name) symtab

  | decl ->
      visit_decl v symtab decl


let v = { default with fold_decl }


let transform (symtab, decls) =
  visit_decls v symtab decls, decls
