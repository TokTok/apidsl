open ApiAst
open ApiMap


let map_comment _ _ = function
  | Cmt_None -> Cmt_None
  | Cmt_Doc comments ->
      let comments =
        List.fold_left
          (fun comments -> function
             | Cmtf_Var (ty :: Var_LName "this" :: _) as member ->
                 member :: Cmtf_Doc "." :: Cmtf_Var [ty; Var_LName "this"] :: comments
             | cmtf -> cmtf :: comments
          ) [] comments
        |> List.rev
      in

      Cmt_Doc comments


let v = { default with map_comment }


let transform decls =
  visit_decls v () decls
