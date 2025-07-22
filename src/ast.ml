type bop =
  | Minus
  | Add
  | Mult
  | Leq
  | IsEqual 
  | And 



type expr =
  | Var of string
  | Bool of bool
  | Int of int
  | Binop of bop * expr * expr
  | INeg of expr
  | BNeg of expr



type stmt =
  | Let of string * expr    (*<id> = <expr>;*)
  | Ite of expr * stmt * stmt (*if <expr> then <stmt> else <stmt>*)
  | While of expr*stmt             (*while <expr> do <stmt>*)
  | Block of stmt list             (*<stmts>*)
  | Print of expr             (*print <expr>;*)
  | PrintEL of expr             (*print_endline <expr>;*)
  | PrintS of expr             (*print_space <expr>;*)
  | Return of expr
  | Comment of string


type program=stmt list