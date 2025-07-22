(* Use lexer and parser to create AST from string *)
let parse (s : string)  : Ast.stmt =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast

let () =
let fname = Sys.argv.(1) in
let ic = open_in fname in
let rec get_input () : (string list) = 
  let next_line = try (input_line ic) with
    | End_of_file -> "eof"
  in match next_line with
    | "eof" -> []
    | "" -> get_input ()
    | _ -> next_line::get_input()
in let input=get_input () in
let rec exec (input : string list) : Ast.stmt list=
  match input with
    | h::t -> parse h::exec t
    | _ -> []
in let stmts=exec input in
let _,results=Eval.eval [] stmts [] in
let rec print_evals (evals : string list)=
  match evals with
  | [] -> ()
  | h::t -> if print_string h=() then print_evals t else ()
in if results=[] then print_string "Uh-OH \n" else print_evals (List.rev results)



