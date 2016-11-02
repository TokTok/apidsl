open HaskellAst

module C = ApiAst


let map_uname = function
  | name -> name

let map_lname = function
  | name -> name

let map_macro = function
  | C.Macro macro -> Macro macro


let map_var = function
  | C.Var_UName uname ->
      let uname = map_uname uname in
      Var_UName uname
  | C.Var_LName lname ->
      let lname = map_lname lname in
      Var_LName lname
  | C.Var_Event ->
      Var_Event


let map_comment_fragment = function
  | C.Cmtf_Doc doc ->
      Cmtf_Doc doc
  | C.Cmtf_UName uname ->
      let uname = map_uname uname in
      Cmtf_UName uname
  | C.Cmtf_LName lname ->
      let lname = map_lname lname in
      Cmtf_LName lname
  | C.Cmtf_Var var ->
      let var = List.map map_var var in
      Cmtf_Var var
  | C.Cmtf_Break ->
      Cmtf_Break


let map_comment = function
  | C.Cmt_None ->
      Cmt_None
  | C.Cmt_Doc frags ->
      let frags = List.map map_comment_fragment frags in
      Cmt_Doc frags


let map_size_spec = function
  | C.Ss_UName uname ->
      let uname = map_uname uname in
      Ss_UName uname
  | C.Ss_LName lname ->
      let lname = map_lname lname in
      Ss_LName lname
  | C.Ss_Bounded (size_spec, uname) ->
      let size_spec = map_lname size_spec in
      let uname = map_uname uname in
      Ss_Bounded (size_spec, uname)


let rec map_type_name = function
  | C.Ty_UName uname ->
      let uname = map_uname uname in
      Ty_UName uname
  | C.Ty_LName lname ->
      let lname = map_lname lname in
      Ty_LName lname
  | C.Ty_TVar lname ->
      let lname = map_lname lname in
      Ty_TVar lname
  | C.Ty_Array (type_name, size_spec) ->
      let type_name = map_type_name type_name in
      let size_spec = map_size_spec size_spec in
      Ty_Array (type_name, size_spec)
  | C.Ty_Auto ->
      Ty_Auto
  | C.Ty_Const type_name ->
      map_type_name type_name
  | C.Ty_Pointer (C.Ty_LName "void") ->
      Ty_TVar "a"
  | C.Ty_Pointer type_name ->
      let type_name = map_type_name type_name in
      Ty_App ("Ptr", [type_name])


let rec map_enumerator = function
  | C.Enum_Name (comment, uname, value) ->
      let comment = map_comment comment in
      let uname = map_uname uname in
      Enum_Name (comment, uname, value)
  | C.Enum_Namespace (uname, enumerators) ->
      let uname = map_uname uname in
      let enumerators = List.map map_enumerator enumerators in
      Enum_Namespace (uname, enumerators)



let map_enum_kind = function
  | C.Enum_Normal -> Enum_Normal
  | C.Enum_Class -> Enum_Class
  | C.Enum_Bitmask -> Enum_Bitmask


let map_error_list = function
  | C.Err_None ->
      Err_None
  | C.Err_From lname ->
      let lname = map_lname lname in
      Err_From lname
  | C.Err_List enumerators ->
      let enumerators = List.map map_enumerator enumerators in
      Err_List enumerators


let map_parameter = function
  | C.Param (type_name, lname) ->
      let type_name = map_type_name type_name in
      let lname = map_lname lname in
      Param (type_name, lname)


let rec map_expr = function
  | C.E_Number num ->
      E_Number num
  | C.E_UName uname ->
      let uname = map_uname uname in
      E_UName uname
  | C.E_Sizeof lname ->
      let lname = map_lname lname in
      E_Sizeof lname
  | C.E_Plus (lhs, rhs) ->
      let lhs = map_expr lhs in
      let rhs = map_expr rhs in
      E_Plus (lhs, rhs)


let rec map_decl = function
  | C.Decl_Comment (comment, decl) ->
      let comment = map_comment comment in
      let decl = map_decl decl in
      Decl_PreComment (comment, decl)
  | C.Decl_Inline decl ->
      let decl = map_decl decl in
      Decl_Inline decl
  | C.Decl_Static decl ->
      let decl = map_decl decl in
      Decl_Static decl
  | C.Decl_Macro macro ->
      let macro = map_macro macro in
      Decl_Macro macro
  | C.Decl_Namespace (lname, decls) ->
      let lname = map_lname lname in
      let decls = List.map map_decl decls in
      Decl_Namespace (lname, decls)
  | C.Decl_Class (lname, decls) ->
      let lname = map_lname lname in
      let decls = List.map map_decl decls in
      Decl_Class (lname, decls)
  | C.Decl_Function (type_name, lname, parameters, error_list) ->
      let type_name = map_type_name type_name in
      let lname = map_lname lname in
      let parameters = List.map map_parameter parameters in
      let error_list = map_error_list error_list in
      Decl_Function (type_name, lname, parameters, error_list)
  | C.Decl_Const (uname, expr) ->
      let uname = map_uname uname in
      let expr = map_expr expr in
      Decl_Const (uname, expr)
  | C.Decl_Enum (is_class, uname, enumerators) ->
      let is_class = map_enum_kind is_class in
      let uname = map_uname uname in
      let enumerators = List.map map_enumerator enumerators in
      Decl_Enum (is_class, uname, enumerators)
  | C.Decl_Error (lname, enumerators) ->
      let lname = map_lname lname in
      let enumerators = List.map map_enumerator enumerators in
      Decl_Error (lname, enumerators)
  | C.Decl_Struct (lname, attrs, decls) ->
      let lname = map_lname lname in
      let attrs = List.map map_lname attrs in
      let decls = List.map map_decl decls in
      Decl_Struct (lname, attrs, decls)
  | C.Decl_Member (type_name, lname) ->
      let type_name = map_type_name type_name in
      let lname = map_lname lname in
      Decl_Member (type_name, lname)
  | C.Decl_GetSet (type_name, lname, decls) ->
      let type_name = map_type_name type_name in
      let lname = map_lname lname in
      let decls = List.map map_decl decls in
      Decl_GetSet (type_name, lname, decls)
  | C.Decl_Typedef (type_name, lname, parameters) ->
      let type_name = map_type_name type_name in
      let lname = map_lname lname in
      let parameters = List.map map_parameter parameters in
      Decl_Typedef (type_name, lname, parameters)
  | C.Decl_Event (lname, is_const, decl) ->
      let lname = map_lname lname in
      let decl = List.map map_decl decl in
      Decl_Event (lname, is_const, decl)
  | C.Decl_Section frags ->
      let frags = List.map map_comment_fragment frags in
      Decl_Section frags


let transform decls =
  List.map map_decl decls
