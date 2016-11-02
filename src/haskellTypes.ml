let rename old_name new_name symtab =
  SymbolTable.rename
    (SymbolTable.lookup symtab [] old_name)
    (fun _ -> new_name)
    symtab

let transform (symtab, decls) =
  let symtab =
    symtab
    |> rename "void" "()"
    |> rename "bool" "Bool"
    |> rename "string" "CString"
    |> rename "size_t" "CSize"
    |> rename "int8_t" "Int8"
    |> rename "int16_t" "Int16"
    |> rename "int32_t" "Int32"
    |> rename "int64_t" "Int64"
    |> rename "uint8_t" "Word8"
    |> rename "uint16_t" "Word16"
    |> rename "uint32_t" "Word32"
    |> rename "uint64_t" "Word64"
  in
  symtab, decls
