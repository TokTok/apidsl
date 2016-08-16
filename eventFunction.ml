open ApiAst
open ApiMap


let map_decl v symtab = function
  | Decl_Event (lname, is_const, [
      Decl_Comment (
        comment, Decl_Typedef (type_name, _, parameters)
      ) as typedef
    ]) ->
      let void = Ty_LName (SymbolTable.lookup symtab [] "void") in
      Decl_Event (lname, is_const, [
          typedef;
          Decl_Function (void, lname, [List.hd parameters], Err_None);
        ])

  | decl ->
      visit_decl v symtab decl


let v = { default with map_decl }


let transform (symtab, decls) =
  symtab, visit_decls v symtab decls
