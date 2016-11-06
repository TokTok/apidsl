open ApiAst
open ApiMap


let map_decl v state = function
  | Decl_Enum (Enum_Bitmask, lname, enumerators) ->
      let comment = Cmt_Doc [
        Cmtf_Break;
        Cmtf_Doc " The empty bit mask. None of the bits specified below are set.";
      ] in
      let enumerators = Enum_Name (comment, "NONE", Some 0) :: enumerators in
      Decl_Enum (Enum_Bitmask, lname, enumerators)

  | decl ->
      visit_decl v state decl


let v = { default with map_decl }


let transform decls =
  visit_decls v () decls
