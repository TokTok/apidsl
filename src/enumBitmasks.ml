open ApiAst
open ApiMap


let add_bit_values enumerators =
  List.mapi
    (fun i -> function
       | Enum_Namespace _ ->
           failwith "enum namespace in bitmask"
       | Enum_Name (comment, uname, Some value) ->
           failwith "bitmask enumerator already has a value"
       | Enum_Name (comment, uname, None) ->
           Enum_Name (comment, uname, Some (1 lsl i))
    ) enumerators


let map_decl v state = function
  | Decl_Enum (Enum_Bitmask, lname, enumerators) ->
      let enumerators = add_bit_values enumerators in
      Decl_Enum (Enum_Normal, lname, enumerators)

  | decl ->
      visit_decl v state decl


let v = { default with map_decl }


let transform decls =
  visit_decls v () decls
