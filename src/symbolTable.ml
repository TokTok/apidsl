type scopes = string list [@@deriving show]


type scope = {
  name     : string;
  id       : int;
  children : scope StringMap.t;
} [@@deriving show]


type t = string IntMap.t * scope [@@deriving show]


let empty name = {
  name;
  id = 0;
  children = StringMap.empty;
}


let enter_scope scope name =
  StringMap.find name scope.children


let leave_scope scope child =
  { scope with
    children = StringMap.add child.name child scope.children }


let scoped scope name f x =
  let child = enter_scope scope name in
  let child = f child x in
  let scope = leave_scope scope child in
  scope


let add ?(extend=false) name scope =
  if StringMap.mem name scope.children then
    if not extend then
      failwith @@ "duplicate name: " ^ name
    else
      scope
  else
    let children =
      StringMap.add name { (empty name) with id = StringMap.cardinal scope.children } scope.children
    in
    { scope with children }


let root =
  List.fold_left
    (fun root sym -> add sym root)
    (empty "<root>")
    [
      "user_data"; (* Used as name for user_data parameter. *)
      "callback"; (* Used as name for callback parameter. *)
      "error"; (* Used as name for error parameter. *)
      "void";
      "bool";
      "int8_t";
      "int16_t";
      "int32_t";
      "int64_t";
      "uint8_t";
      "uint16_t";
      "uint32_t";
      "uint64_t";
      "size_t";
      "string";
    ]


let rec renumber_ids table scope =
  let children =
    let table_size = IntMap.cardinal table in
    StringMap.map (fun child -> { child with id = child.id + table_size }) scope.children
  in

  let scope = { scope with children } in

  let table =
    StringMap.fold
      (fun name child table ->
         assert (not (IntMap.mem child.id table));
         IntMap.add child.id name table
      ) children table
  in

  let table, children =
    StringMap.fold
      (fun ns child (table, children) ->
         let table, child = renumber_ids table child in
         table, StringMap.add ns child children
      ) scope.children (table, StringMap.empty)
  in

  table, { scope with children }


let make scope =
  renumber_ids IntMap.empty scope


let lookup_qualified (_, root : t) scopes path =
  let name, member =
    match path with
    | name :: member -> name, member
    | [] -> failwith "Empty qualified symbol name"
  in
  let scopes =
    List.fold_right
      (fun scope -> function
         | [] -> assert false
         | current :: scopes ->
             let scope =
               try
                 StringMap.find scope current.children
               with Not_found ->
                 raise Not_found
             in
             scope :: current :: scopes
      ) scopes [root]
  in

  let child =
    List.fold_left
      (fun child scope ->
         match child with
         | Some _ -> child
         | None ->
             try
               Some (StringMap.find name scope.children)
             with Not_found ->
               None
      ) None scopes
  in

  let child =
    List.fold_left
      (fun child name ->
         match child with
         | None -> None
         | Some child ->
             try
               Some (StringMap.find name child.children)
             with Not_found ->
               None
      ) child member
  in

  match child with
  | Some child -> child.id
  | None       -> -1


let lookup symtab scopes name =
  lookup_qualified symtab scopes [name]


let name (table, _ : t) = function
  | -1 -> "<unresolved>"
  | id -> IntMap.find id table


let pp_symbol symtab fmt id =
  Format.fprintf fmt "\"%s\""
    (name symtab id |> String.escaped)


let rename (table, scope as symtab) id f =
  let name = name symtab id in

  let renamed = f name in

  let table = IntMap.add id renamed table in

  (table, scope)


let clone_symbol (table, scope as symtab) id =
  let name = name symtab id in

  let new_id = IntMap.cardinal table in
  assert (not @@ IntMap.mem new_id table);

  let table = IntMap.add new_id name table in

  (table, scope), new_id
