type 'id uname = 'id [@@deriving show]
type 'id lname = 'id [@@deriving show]
type macro = Macro of string [@@deriving show]
type verbatim = string [@@deriving show]


type 'id var =
  | Var_UName of 'id uname
  | Var_LName of 'id lname
  | Var_Event
  [@@deriving show]


type 'id comment_fragment =
  | Cmtf_Doc of string
  | Cmtf_UName of 'id uname
  | Cmtf_LName of 'id lname
  | Cmtf_Var of 'id var list
  | Cmtf_Break
  [@@deriving show]


type 'id comment =
  | Cmt_None
  | Cmt_Doc of 'id comment_fragment list
  [@@deriving show]


type 'id size_spec =
  | Ss_UName of 'id uname
  | Ss_LName of 'id lname
  | Ss_Bounded of 'id lname * 'id uname
  [@@deriving show]


type 'id type_name =
  | Ty_UName of 'id uname
  | Ty_LName of 'id lname
  | Ty_TVar of 'id lname
  | Ty_Array of 'id lname * 'id size_spec
  | Ty_Auto
  | Ty_Const of 'id type_name
  | Ty_Pointer of 'id type_name
  [@@deriving show]


type 'id enumerator =
  | Enum_Name of 'id comment * 'id uname * int option
  | Enum_Namespace of 'id uname * 'id enumerator list
  [@@deriving show]


type 'id error_list =
  | Err_None
  | Err_From of 'id lname
  | Err_List of 'id enumerator list
  [@@deriving show]


type 'id parameter =
  | Param of 'id type_name * 'id lname
  [@@deriving show]


type 'id expr =
  | E_Number of int
  | E_UName of 'id uname
  | E_Sizeof of 'id lname
  | E_Plus of 'id expr * 'id expr
  [@@deriving show]


type enum_kind =
  | Enum_Normal
  | Enum_Class
  | Enum_Bitmask
  [@@deriving show]


type 'id decl =
  | Decl_Class of 'id lname * 'id decl list
  | Decl_Comment of 'id comment * 'id decl
  | Decl_Const of 'id uname * 'id expr
  | Decl_Enum of enum_kind * 'id uname * 'id enumerator list
  | Decl_Error of 'id lname * 'id enumerator list
  | Decl_Event of 'id lname * bool * 'id decl list
  | Decl_Function of 'id type_name * 'id lname * 'id parameter list * 'id error_list
  | Decl_GetSet of 'id type_name * 'id lname * 'id decl list
  | Decl_Macro of macro
  | Decl_Member of 'id type_name * 'id lname
  | Decl_Namespace of 'id lname * 'id decl list
  | Decl_Inline of 'id decl
  | Decl_Section of 'id comment_fragment list
  | Decl_Static of 'id decl
  | Decl_Struct of 'id lname * 'id lname list * 'id decl list
  | Decl_Typedef of 'id type_name * 'id lname * 'id parameter list
  [@@deriving show]


type 'id decls = 'id decl list
  [@@deriving show]


type 'id api =
  | Api of verbatim option * 'id decls * verbatim option
  [@@deriving show]


let id x = x
