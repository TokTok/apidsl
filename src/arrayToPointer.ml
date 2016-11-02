open ApiAst
open ApiMap


let map_type_name v symtab = function

  | Ty_Array (type_name, _) ->
      Ty_Pointer type_name

  | type_name ->
      visit_type_name v symtab type_name


let v = { default with map_type_name }


let transform (symtab, decls) =
  symtab, visit_decls v symtab decls
