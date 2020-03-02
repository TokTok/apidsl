open ApiAst


let this = Ty_LName "this"
let bool = Ty_LName "bool"
let void = Ty_LName "void"
let size_t = Ty_LName "size_t"


let rec is_array = function
  | Ty_Const ty -> is_array ty
  | Ty_Array _ -> true
  | _ -> false


let rec is_var_array = function
  | Ty_Const ty -> is_var_array ty
  | Ty_Array (_, Ss_UName _) -> false
  | Ty_Array _ -> true
  | _ -> false


let length_param_of_size_spec = function
  | Ss_UName _ -> failwith "UName as parameter name"
  | Ss_LName n -> n
  | Ss_Bounded (spec, _) -> spec


let rec length_param = function
  | Ty_Const ty -> length_param ty
  | Ty_Array (_, size_spec) ->
      length_param_of_size_spec size_spec

  | _ -> failwith "not an array type"
