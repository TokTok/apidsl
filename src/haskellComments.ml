open HaskellAst
open HaskellMap


let map_decl v in_struct = function
  | Decl_PreComment (comment, decl) when in_struct ->
      visit_decl v in_struct (Decl_PostComment (decl, comment))
  | Decl_Struct _ as decl ->
      visit_decl v true decl

  | decl ->
      visit_decl v in_struct decl


let v = { default with map_decl }


let transform decls =
  visit_decls v false decls
