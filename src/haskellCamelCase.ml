open ApiAst
open ApiFold

let split_snake_case = String.split_on_char '_'

let fold_decl v symtab = function
  | Decl_Struct (lname, _, _) as decl ->
      let symtab =
        SymbolTable.rename lname
          (fun name ->
             String.concat "" @@ split_snake_case name)
          symtab
      in
      visit_decl v symtab decl

  | Decl_Member (_, lname) ->
      SymbolTable.rename lname
        (fun name ->
           match split_snake_case name with
           | [] -> name
           | x :: xs -> x ^ String.concat "" (List.map String.capitalize_ascii xs))
        symtab

  | decl ->
      visit_decl v symtab decl


let v = { default with fold_decl }


let transform (symtab, decls) =
  let symtab = visit_decls v symtab decls in
  symtab, decls
