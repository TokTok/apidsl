open HaskellAst


let cg_list ?(sep="") cg fmt l =
  ignore (
    List.fold_left
      (fun first x ->
         if not first then
           Format.pp_print_string fmt sep;
         Format.fprintf fmt "%a" cg x;
         false
      ) true l
  )


let cg_indented cg fmt x =
  Format.fprintf fmt "@,@[<v2>%a@]" cg x


let cg_uname = Format.pp_print_string
let cg_lname = Format.pp_print_string
let cg_macro fmt (Macro s) = Format.pp_print_string fmt s


let cg_attrs fmt = function
  | [] -> ()
  | l -> cg_list ~sep:"," cg_lname fmt l


let cg_var fmt = function
  | Var_UName uname ->
      Format.fprintf fmt "%a"
        cg_uname uname
  | Var_LName lname ->
      Format.fprintf fmt "%a"
        cg_lname lname
  | Var_Event ->
      Format.fprintf fmt "event"


let cg_comment_fragment fmt = function
  | Cmtf_Doc doc ->
      Format.fprintf fmt "%s" doc
  | Cmtf_UName name ->
      Format.fprintf fmt "${%a}"
        cg_uname name
  | Cmtf_LName name ->
      Format.fprintf fmt "${%a}"
        cg_lname name
  | Cmtf_Var var ->
      Format.fprintf fmt "${%a}"
        (cg_list ~sep:"." cg_var) var
  | Cmtf_Break ->
      Format.fprintf fmt "@,--"


type comment_style =
  | Pre
  | Post

let style_char = function
  | Pre -> "|"
  | Post -> "^"


let cg_comment style fmt = function
  | Cmt_None ->
      Format.fprintf fmt "-- %s %a"
        (style_char style)
        (cg_list cg_comment_fragment) [Cmtf_Break; Cmtf_Doc " TODO: Generate doc"]
  | Cmt_Doc frags ->
      Format.fprintf fmt "-- %s %a"
        (style_char style)
        (cg_list cg_comment_fragment) frags
;;


let rec cg_size_spec fmt = function
  | Ss_UName uname ->
      Format.fprintf fmt "%a"
        cg_uname uname
  | Ss_LName lname ->
      Format.fprintf fmt "%a"
        cg_lname lname
  | Ss_Bounded (lhs, rhs) ->
      Format.fprintf fmt "%a <= %a"
        cg_lname lhs
        cg_uname rhs


let cg_size_spec fmt spec =
  Format.fprintf fmt "[%a]" cg_size_spec spec


let rec cg_type_name fmt = function
  | Ty_UName uname ->
      Format.fprintf fmt "%a"
        cg_uname uname
  | Ty_LName lname ->
      Format.fprintf fmt "%a"
        cg_lname lname
  | Ty_TVar lname ->
      Format.fprintf fmt "%a"
        cg_lname lname
  | Ty_App (uname, args) ->
      Format.fprintf fmt "%a %a"
        cg_uname uname
        (cg_list cg_type_name) args
  | Ty_Array (type_name, size_spec) ->
      Format.fprintf fmt "Ptr (%a{-%a-})"
        cg_type_name type_name
        cg_size_spec size_spec
  | Ty_Auto ->
      Format.fprintf fmt "auto "


let cg_enum_value fmt = function
  | None -> ()
  | Some value ->
      Format.fprintf fmt " = %d" value


let rec cg_enumerator is_first fmt = function
  | Enum_Name (comment, uname, value) ->
      Format.fprintf fmt "@,@[<v2>%s %a%a@,%a@]@,"
        (if is_first then "=" else "|")
        cg_uname uname
        cg_enum_value value
        (cg_comment Post) comment
  | Enum_Namespace (uname, enums) ->
      Format.fprintf fmt "@,namespace %a %a"
        cg_uname uname
        (cg_indented cg_enumerators) enums


and cg_enumerators fmt = function
  | [] -> ()
  | enum :: enums ->
      cg_enumerator true fmt enum;
      cg_list (cg_enumerator false) fmt enums


let cg_error_list fmt = function
  | Err_None -> ()
  | Err_From (name) ->
      Format.fprintf fmt "@,    with error for %a"
        cg_lname name
  | Err_List enums ->
      Format.fprintf fmt " %a"
        (cg_indented cg_enumerators) enums


let cg_parameter fmt = function
  | Param (type_name, lname) ->
      Format.fprintf fmt "{- %a :: -} %a"
        cg_lname lname
        cg_type_name type_name


let cg_parameters fmt = function
  | [] -> ()
  | params ->
      Format.fprintf fmt "%a"
        (cg_list ~sep:" -> " cg_parameter) params


let rec cg_expr fmt = function
  | E_Number i ->
      Format.fprintf fmt "%d" i
  | E_UName uname ->
      Format.fprintf fmt "%a"
        cg_uname uname
  | E_Sizeof lname ->
      Format.fprintf fmt "sizeof(%a)"
        cg_lname lname
  | E_Plus (lhs, rhs) ->
      Format.fprintf fmt "%a + %a"
        cg_expr lhs
        cg_expr rhs


let cg_expr fmt expr =
  let is_simple =
    match expr with
    | E_Number _ | E_UName _ -> true
    | E_Sizeof _ | E_Plus _ -> false
  in
  if not is_simple then
    Format.pp_print_char fmt '(';
  cg_expr fmt expr;
  if not is_simple then
    Format.pp_print_char fmt ')';
;;


let rec cg_decl_qualified qualifier fmt = function
  | Decl_PreComment (comment, decl) ->
      assert (qualifier = "");
      Format.fprintf fmt "%a%a"
        (cg_comment Pre) comment
        cg_decl decl
  | Decl_PostComment (decl, comment) ->
      assert (qualifier = "");
      Format.fprintf fmt "@[<v>%a@,%a@]@,"
        cg_decl decl
        (cg_comment Post) comment
  | Decl_Macro (macro) ->
      assert (qualifier = "");
      Format.fprintf fmt "@,%a"
        cg_macro macro
  | Decl_Namespace (name, decls) ->
      Format.fprintf fmt "@,%snamespace %a %a"
        qualifier
        cg_lname name
        (cg_indented cg_decls) decls
  | Decl_Class (lname, []) ->
      Format.fprintf fmt "@,%sclass %a"
        qualifier
        cg_lname lname
  | Decl_Class (lname, decls) ->
      Format.fprintf fmt "@,%sclass %a %a"
        qualifier
        cg_lname lname
        (cg_indented cg_decls) decls
  | Decl_Function (type_name, lname, parameters, error_list) ->
      Format.fprintf fmt "@,--foreign import ccall %s%a :: %a"
        qualifier
        cg_lname lname
        cg_parameters (parameters @ [Param (type_name, "result")])
  | Decl_Const (uname, expr) ->
      assert (qualifier = "");
      Format.fprintf fmt "@,--const %a = %a"
        cg_uname uname
        cg_expr expr
  | Decl_Enum (kind, uname, enumerators) ->
      assert (qualifier = "");
      let is_class = kind = Enum_Class in
      Format.fprintf fmt "@,data %a %aderiving (Eq, Ord, Enum, Bounded, Read, Show)"
        cg_uname uname
        (cg_indented cg_enumerators) enumerators
  | Decl_Error (lname, enumerators) ->
      assert (qualifier = "");
      Format.fprintf fmt "@,error for %a %a"
        cg_lname lname
        (cg_indented cg_enumerators) enumerators
  | Decl_Struct (lname, attrs, []) ->
      assert (qualifier = "");
      let uname = String.uppercase lname in
      Format.fprintf fmt "@,--struct %a%a"
        cg_lname lname
        cg_attrs attrs
      ;
  | Decl_Struct (lname, attrs, decls) ->
      assert (qualifier = "");
      Format.fprintf fmt "@,data %a = %a@, %a %a"
        cg_lname lname
        cg_lname lname
        cg_attrs attrs
        (cg_indented cg_record_members) decls
  | Decl_Member (type_name, lname) ->
      assert (qualifier = "");
      Format.fprintf fmt "%a :: %a"
        cg_lname lname
        cg_type_name type_name
  | Decl_GetSet (type_name, lname, decls) ->
      assert (qualifier = "");
      Format.fprintf fmt "@,%a%a %a"
        cg_type_name type_name
        cg_lname lname
        (cg_indented cg_decls) decls
  | Decl_Typedef (type_name, lname, parameters) ->
      assert (qualifier = "");
      Format.fprintf fmt "@,--typedef %a = %a -> %a@,"
        cg_lname lname
        cg_parameters parameters
        cg_type_name type_name
  | Decl_Event (lname, is_const, decl) ->
      assert (qualifier = "");
      Format.fprintf fmt "@,event %a%s %a"
        cg_lname lname
        (if is_const then " const" else "")
        (cg_indented cg_decls) decl
  | Decl_Inline (decl) ->
      assert (qualifier = "");
      Format.fprintf fmt "%a"
        (cg_decl_qualified "inline ") decl
  | Decl_Static (decl) ->
      assert (qualifier = "");
      Format.fprintf fmt "%a"
        (cg_decl_qualified "static ") decl
  | Decl_Section frags ->
      Format.fprintf fmt "@,@,";
      for i = 0 to 79 do
        Format.pp_print_char fmt '-'
      done;
      Format.fprintf fmt "%a"
        (cg_list cg_comment_fragment) frags;
      Format.fprintf fmt "@,";
      for i = 0 to 79 do
        Format.pp_print_char fmt '-'
      done;
      Format.fprintf fmt "@,@,";


and cg_record_members fmt = function
  | [] -> ()
  | decl :: decls ->
      Format.fprintf fmt "  { %a" cg_decl decl;
      cg_list cg_record_member fmt decls;
      Format.fprintf fmt "}"


and cg_record_member fmt decl =
  Format.fprintf fmt ", %a" cg_decl decl


and cg_decl fmt decl =
  cg_decl_qualified "" fmt decl


and cg_decls fmt = cg_list ~sep:"\n" cg_decl fmt


let cg_decls fmt decls =
  Format.fprintf fmt "@[<v>%a@]"
    cg_decls decls
