{
    open Parser
}

(* Regular expressions *)
let white = [' ' '\t']+ 
let digit = ['0'-'9']
let int = digit+
let letter = ['a'-'z' 'A'-'Z' '_']
let id = letter+
let newline = [^'\n']
let comment = "//"_*newline

(* Lexing rules *)
(* rule read =
  parse
  | white { read lexbuf }
  | "true" { TRUE }
  | "false" { FALSE }
  | "<=" { LEQ }
  | "return" { RETURN }
  | "+" { PLUS }
  | "*" { TIMES }
  | "(" { LPAREN }
  | ";" { SEMICOLON }
  | ")" { RPAREN }
  | "=" { EQUALS }
  | "-" { MINUS }
  | "not" { NOT }
  | "{" { LSQUI }
  | "}" { RSQUI }
  | "==" { ISEQUAL }
  | "and" { AND }
  | "while" { WHILE }
  | "do" { DO }
  | "print" { PRINT }
  | "print_endline" { PRINTEL }
  | "print_space" { PRINTS }
  | "if" { IF }
  | "then" { THEN }
  | "else" { ELSE }
  | id { ID (Lexing.lexeme lexbuf) }
  | int { INT (int_of_string (Lexing.lexeme lexbuf)) }
  (* | newline { NEWLINE } *)
  | comment {  COMMENT }
  | eof { EOF } *)


rule read =
  parse
  | "true" {  TRUE }
  | "false" {  FALSE }
  | "<=" {  LEQ }
  | "return" {  RETURN }
  | "+" {  PLUS }
  | "*" {  TIMES }
  | "(" {  LPAREN }
  | ";" {  SEMICOLON }
  | ")" {  RPAREN }
  | "=" {  EQUALS }
  | "-" {  MINUS }
  | "not" {  NOT }
  | "{" { LSQUI }
  | "}" { RSQUI }
  | "==" { ISEQUAL }
  | "and" { AND }
  | "while" { WHILE }
  | "do" { DO }
  | "print" { PRINT }
  | "print_endline" { PRINTEL }
  | "print_space" { PRINTS }
  | "if" { IF }
  | "then" { THEN }
  | "else" { ELSE }
  | comment {  COMMENT }
  | id { ID (Lexing.lexeme lexbuf) }
  | int { INT (int_of_string (Lexing.lexeme lexbuf)) }
  | white {  read lexbuf }  
  | eof { EOF }
