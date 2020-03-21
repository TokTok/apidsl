open ApiAst
open ApiMap


let flip f a b = f b a


let scoped scopes name f =
  let scopes = name :: scopes in
  f scopes


let rec find_this symtab ns = function
  | [] ->
      SymbolTable.lookup symtab [ns] "this"
  | _ :: tl as scopes ->
      try
        let scopes = ns :: scopes in
        SymbolTable.lookup symtab scopes "this"
      with Not_found ->
        find_this symtab ns tl

let lookup symtab scopes path =
  let lname = List.hd (List.rev path) in
  if String.length lname > 3 &&
     String.sub lname (String.length lname - 2) 2 = "_t" then
    (* First, it might be a global _t type. *)
    match SymbolTable.lookup_qualified symtab [] path with
    | -1 ->
        (* If not, it must be a user-defined type with "this" struct. *)
        let ns = String.sub lname 0 (String.length lname - 2) in
        let scopes = match scopes with [] -> [] | _ :: tl -> tl in
        begin
          try
            SymbolTable.lookup symtab [ns] "this"
          with Not_found ->
            find_this symtab ns scopes
        end
    | resolved ->
        resolved
  else
    SymbolTable.lookup_qualified symtab scopes path


let map_uname symtab _ scopes uname =
  try
    lookup symtab scopes [uname]
  with Not_found ->
    failwith @@ "unresolved symbol: " ^ uname

let map_lname symtab _ scopes lname =
  try
    lookup symtab scopes [lname]
  with Not_found ->
    failwith @@ "unresolved symbol: " ^ lname


let map_comment_fragment symtab v scopes = function
  | Cmtf_Var path ->
      let path =
        List.fold_right
          (fun var path ->
             match var with
             | Var_UName name
             | Var_LName name ->
                 name :: path
             | Var_Event ->
                 match List.rev path with
                 | hd :: tl ->
                     List.rev @@ ("event " ^ hd) :: tl
                 | [] ->
                     failwith "empty name after event in comment name reference"
          ) path []
      in
      let var' = lookup symtab scopes path in
      Cmtf_Var [Var_LName var']

  | comment_fragment ->
      visit_comment_fragment v scopes comment_fragment


let map_enumerator _ v scopes = function
  | Enum_Name _ as enumerator ->
      visit_enumerator v scopes enumerator

  | Enum_Namespace (uname, enumerators) ->
      let uname' = v.map_uname v scopes uname in
      let enumerators = scoped scopes uname (flip (visit_list v.map_enumerator v) enumerators) in
      Enum_Namespace (uname', enumerators)


let map_error_list _ v scopes = function
  | Err_From lname ->
      let lname = "error " ^ lname in
      let lname' = v.map_lname v scopes lname in
      Err_From lname'

  | error_list ->
      visit_error_list v scopes error_list


let map_decl _ v scopes = function
  | Decl_Namespace (lname, decls) ->
      let lname' = v.map_lname v scopes lname in
      let decls = scoped scopes lname (flip (visit_list v.map_decl v) decls) in
      Decl_Namespace (lname', decls)
  | Decl_Class (lname, decls) ->
      let lname' = v.map_lname v scopes lname in
      let decls = scoped scopes lname (flip (visit_list v.map_decl v) decls) in
      Decl_Class (lname', decls)
  | Decl_Function (type_name, lname, parameters, error_list) ->
      let type_name = v.map_type_name v scopes type_name in
      let lname' = v.map_lname v scopes lname in
      let parameters = scoped scopes lname (flip (visit_list v.map_parameter v) parameters) in
      let error_list = scoped scopes lname (flip (v.map_error_list v) error_list) in
      Decl_Function (type_name, lname', parameters, error_list)
  | Decl_Enum (is_class, uname, enumerators) ->
      let uname' = v.map_uname v scopes uname in
      let enumerators = scoped scopes uname (flip (visit_list v.map_enumerator v) enumerators) in
      Decl_Enum (is_class, uname', enumerators)
  | Decl_Error (lname, enumerators) ->
      let lname = "error " ^ lname in
      let lname' = v.map_lname v scopes lname in
      let enumerators = scoped scopes lname (flip (visit_list v.map_enumerator v) enumerators) in
      Decl_Error (lname', enumerators)
  | Decl_Struct (lname, attrs, decls) ->
      assert (attrs = []);
      let lname' = v.map_lname v scopes lname in
      let decls = scoped scopes lname (flip (visit_list v.map_decl v) decls) in
      Decl_Struct (lname', [], decls)
  | Decl_GetSet (type_name, lname, decls) ->
      let type_name = scoped scopes lname (flip (v.map_type_name v) type_name) in
      let lname' = v.map_lname v scopes lname in
      let decls = scoped scopes lname (flip (visit_list v.map_decl v) decls) in
      Decl_GetSet (type_name, lname', decls)
  | Decl_Event (lname, is_const, decls) ->
      let lname = "event " ^ lname in
      let lname' = v.map_lname v scopes lname in
      let decls = scoped scopes lname (flip (visit_list v.map_decl v) decls) in
      Decl_Event (lname', is_const, decls)
  | Decl_Typedef (type_name, lname, parameters) ->
      let type_name = scoped scopes lname (flip (v.map_type_name v) type_name) in
      let lname' = v.map_lname v scopes lname in
      let parameters = scoped scopes lname (flip (visit_list v.map_parameter v) parameters) in
      Decl_Typedef (type_name, lname', parameters)

  | Decl_Const _
  | Decl_Member _
  | Decl_Section _
  | Decl_Comment _
  | Decl_Inline _
  | Decl_Static _
  | Decl_Macro _ as decl ->
      ApiMap.visit_decl v scopes decl


let v symtab = {
  map_uname = map_uname symtab;
  map_lname = map_lname symtab;
  map_enumerator = map_enumerator symtab;
  map_decl = map_decl symtab;
  map_error_list = map_error_list symtab;
  map_comment_fragment = map_comment_fragment symtab;

  map_var = visit_var;
  map_macro = visit_macro;
  map_comment = visit_comment;
  map_size_spec = visit_size_spec;
  map_type_name = visit_type_name;
  map_parameter = visit_parameter;
  map_expr = visit_expr;
}


let transform (symtab, decls) =
  symtab, visit_decls (v symtab) [] decls
  

module Inverse = struct

  let map_uname _ symtab uname =
    SymbolTable.name symtab uname


  let map_lname _ symtab lname =
    SymbolTable.name symtab lname


  let v = {
    map_uname;
    map_lname;

    map_var = visit_var;
    map_enumerator = visit_enumerator;
    map_decl = visit_decl;
    map_macro = visit_macro;
    map_comment_fragment = visit_comment_fragment;
    map_comment = visit_comment;
    map_size_spec = visit_size_spec;
    map_type_name = visit_type_name;
    map_error_list = visit_error_list;
    map_parameter = visit_parameter;
    map_expr = visit_expr;
  }

  let transform (symtab, decls) =
    visit_decls v symtab decls

end
