open Ast

exception EvalError of string

(** [value] is the type of a value *)
type value = 
  | VInt of int
  | VBool of bool

(** [env] represents (string to) valua maps/dictionaries *)
type 'a env = (string * 'a) list

(** [find s e] finds the value bound to [s] in [e]; 
    is [None] if no match is found. *)
let rec find (x : string) (e : 'a env) : 'a option =
  match e with
  | [] -> None
  | (s, v) :: t -> if s = x then Some v else find x t

(** [get_str v=s] returns the value within a value option type [s] *)
let get_str (s : string option) : string =
  match s with
  | None -> ""
  | Some str -> str

(** [get_val v] returns the value within a value option type [v] *)
let get_val (v : value option) : string option=
  match v with
    | Some (VInt i)-> Some (string_of_int i)
    | Some (VBool b)-> Some (string_of_bool b)
    | None -> None

(** [add s v e] adds a binding of [s] to [v] in [e];
    replaces a previously existing binding of [s] *)
let rec add (x : string) (v : 'a) (e : 'a env) : 'a env =
  match e with
  | [] -> [(x, v)]
  | (s, vl) :: t -> if s = x then (s, v) :: t else
                     (s, vl) :: add x v t


(** [eval_expr env e] evaluates [e] in [env] *)
let rec eval_expr (env : value option env) (e : expr) : value option=
  match e with
  | Int i -> Some (VInt i)
  | INeg e -> eval_ineg env e
  | BNeg e -> eval_bneg env e
  | Bool b -> Some (VBool b)
  | Var x -> eval_var env x
  | Binop (bop, e1, e2) -> eval_bop env bop e1 e2


(** [eval_var env x] evaluates [x] in [env] *)
and eval_var (env : value option env) (x : string) : value option=
  match find x env with
  | Some v -> v
  | None -> raise (EvalError "Unbound variable")

(** [eval_bop env bop e1 e2] evaluates [Binop (bop, e1, e2)] in [env] *)
and eval_bop (env : value option env) (b : bop) (e1 : expr) (e2 : expr) : value option=
  match (b, eval_expr env e1, eval_expr env e2) with
  | Add, Some (VInt i1), Some (VInt i2) -> Some(VInt (i1 + i2))
  | Mult, Some (VInt i1), Some (VInt i2) -> Some(VInt (i1 * i2))
  | Minus, Some (VInt i1), Some (VInt i2) -> Some(VInt (i1 - i2))
  | IsEqual, Some (VBool b1), Some (VBool b2) -> Some (VBool (b1 == b2))
  | IsEqual, Some (VInt i1), Some (VInt i2) -> Some (VBool (i1 == i2))
  | IsEqual, Some VBool _, Some VInt _ -> raise (EvalError "Cannot compare a boolean and an integer")
  | IsEqual, Some VInt _, Some VBool _ -> raise (EvalError "Cannot compare an integer and a boolean")
  | And, Some (VBool b1), Some (VBool b2) -> Some (VBool (b1 && b2))
  | Leq, Some (VInt i1), Some (VInt i2) -> Some (VBool (i1 <= i2))
  | _ -> raise (EvalError "Operator and operand type mismatch")

(** [eval_var env x] evaluates [e1] and [e2] in [env] *)
and eval_and (env : value option env) (e1 : expr) (e2 : expr) : value option=
  match (eval_expr env e1, eval_expr env e2) with
  | Some (VBool true), Some (VBool true) -> Some (VBool true)
  | _ -> Some (VBool false)

(** [eval_var env x] evaluates if [e1] is equal to [e2] in [env] *)
and eval_equals (env : value option env) (e1 : expr) (e2 : expr) : value option=
  match (eval_expr env e1, eval_expr env e2) with
  | Some (VBool v1), Some (VBool v2) -> if v1=v2 then Some (VBool true) else Some (VBool false)
  | Some (VBool _), Some (VInt _) -> Some (VBool false)
  | Some (VInt _), Some (VBool _) -> Some (VBool false)
  | Some (VInt v1), Some (VInt v2) -> if v1=v2 then Some (VBool true) else Some (VBool false)
  | _ -> raise (EvalError "Unimplemented")

(** [eval_var env x] negates an integer [e1] in [env] *)
and eval_ineg (env : value option env) (e1 : expr) : value option=
    match eval_expr env e1 with
      | Some (VInt i) -> Some (VInt (-i))
      | _ -> raise (EvalError "Cannot negate a boolean")

(** [eval_var env x] negates a boolean [e1] in [env] *)
and eval_bneg (env : value option env) (e1 : expr) : value option=
    match eval_expr env e1 with
      | Some (VBool true) -> Some (VBool false)
      | Some (VBool false) -> Some (VBool true)
      | _ -> raise (EvalError "Cannot use a \'not\' modifier on an integer")


(** [eval_stmt env s str] evaluates [s] in [env] and returns a list [str] of strings to be printed*)
let rec eval_stmt (env : value option env) (s : stmt) ( str : string list ) : value option env*string list= 
  match s with
    | Let (x, e1) -> let env=eval_let env x e1 in env,str
    | Comment _ -> env,str
    | Ite (c, e1, e2) -> let envi,_=eval_stmt env (Let ("return",Int 0)) str in eval_if envi c e1 e2 str
    | While (e, s)-> let envi,_=eval_stmt env (Let ("return",Int 1)) str in eval_while envi e s str
    | Print e-> let value=eval_expr env e in env,get_str (get_val value)::str 
    | PrintEL e-> let value=eval_expr env e in env,(get_str (get_val value)^"\n")::str
    | PrintS e-> let value=eval_expr env e in env,(get_str (get_val value)^" ")::str
    | Return e-> let value=eval_expr env e in 
                              let envi,_=eval_stmt env (Let ("return",Bool true)) str 
                              in envi,get_str (get_val value)::str
    | Block b -> let oenv=env in let envi,strl=eval_block env b str in 
      match find "return" env with
        | None -> (match find "return" envi with
          | None -> oenv,strl
          | Some v -> if get_val v=Some "true" then envi,strl else oenv,strl)
        | Some v -> 
          (match get_val v with
            | Some "1" | Some "0" -> envi,strl 
            | Some "true" -> envi,strl
            | _ -> oenv, strl)

(** [eval_let env x e1] evaluates [Let (x, e1)] in [env] *)
and eval_let (env : value option env) (x : string) (e1 : expr) : value option env =
  add x (eval_expr env e1) env

(** [eval_if env c s1 s2 str] evaluates [Ite (c, s1, s2)] in [env] *)
and eval_if (env : value option env) (c : expr) (s1 : stmt) (s2 : stmt) ( str : string list ) : value option env*string list =
  match eval_expr env c with
  | Some (VBool true) -> eval_stmt env s1 str
  | Some (VBool false) -> eval_stmt env s2 str
  | _ -> raise (EvalError "Expecting the if condition to be a Bool")

(** [eval_while env e s str] evaluates [s] in [env] while [e] is true *)
and eval_while (env : value option env) (e : expr) (s : stmt) ( str : string list ) : value option env*string list=
  match eval_expr env e with
    | Some (VBool true) -> let envi,strl=eval_stmt env s str in eval_while envi e s strl
    | Some (VBool false) -> env,str (*eval_stmt env s str*)
    | _ -> raise (EvalError "Cannot evaluate an integer as a conditional")

(** [eval_block env b str] evaluates a list of statements [b] in [env] *)
and eval_block (env : value option env) (b : stmt list) ( str : string list ) : value option env*string list=
  match b with
    | s::t -> let e,strl=eval_stmt env s str in let envi,strl=eval_stmt e (Block t) strl in envi,strl
    | [] -> env,str
  

(** [eval env p str] evaluates the program [p] in [env] *)
let rec eval (env : value option env) (p : program) ( str : string list ) : value option env*string list=
  match p with
    | s::t -> 
      (match eval_stmt env s str with
      | e,strl-> 
        (match find "return" e with 
          | None -> let envi,strl=eval e t strl in envi,strl
          | Some v -> if get_val v=Some "true" then e,strl else let envi,strl=eval e t strl in envi,strl))
    | [] -> env,str