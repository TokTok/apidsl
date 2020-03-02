open ApiAst
open ApiFold


let rec rename_symbols name symtab = function
  | Decl_Comment (_, decl) ->
      rename_symbols name symtab decl

  | Decl_Function (_, fname, _, _) as decl ->
      let name = SymbolTable.name symtab name in

      begin match SymbolTable.name symtab fname with
        | "size" ->
            SymbolTable.rename fname
              (fun _ ->
                 if name = "this" then
                   "get_size"
                 else
                   "get_" ^ name ^ "_size")
              symtab

        | "get" ->
            SymbolTable.rename fname
              (fun _ ->
                 if name = "this" then
                   "get"
                 else
                   "get_" ^ name)
              symtab

        | "set" ->
            SymbolTable.rename fname
              (fun _ ->
                 if name = "this" then
                   "set"
                 else
                   "set_" ^ name)
              symtab

        | _ ->
            failwith (
              "unknown function: " ^
              show_decl (SymbolTable.pp_symbol symtab) decl
            )
      end

  | Decl_Error (uname, _) ->
      let name = String.uppercase_ascii @@ SymbolTable.name symtab name in

      SymbolTable.rename uname
        (fun error_name ->
           error_name ^ "_" ^ name)
        symtab

  | decl ->
      failwith (
        "unhandled declaration in get/set rename: " ^
        show_decl (SymbolTable.pp_symbol symtab) decl
      )


let fold_decl v symtab = function
  | Decl_GetSet (_, lname, decls) ->
      List.fold_left (rename_symbols lname) symtab decls

  | decl ->
      visit_decl v symtab decl


let v = { default with fold_decl }


let transform (symtab, decls) =
  visit_decls v symtab decls, decls
