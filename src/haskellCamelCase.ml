open ApiAst
open ApiFold


let fold_decl v symtab = function
  | Decl_Struct (lname, attrs, decls) as decl ->
      let symtab =
        SymbolTable.rename lname
          (fun name ->
             String.concat "" @@ Str.split (Str.regexp "_") name)
          symtab
      in
      visit_decl v symtab decl

  | Decl_Member (type_name, lname) ->
      SymbolTable.rename lname
        (fun name ->
           match Str.split (Str.regexp "_") name with
           | [] -> name
           | x :: xs -> x ^ String.concat "" (List.map String.capitalize xs))
        symtab

  | decl ->
      visit_decl v symtab decl


let v = { default with fold_decl }


let transform (symtab, decls) =
  let symtab = visit_decls v symtab decls in
  symtab, decls
