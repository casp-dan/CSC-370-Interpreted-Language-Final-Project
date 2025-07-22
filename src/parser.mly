%{
    open Ast
%}

// Tokens
%token <int> INT
%token <string> ID
%token TRUE
%token FALSE
%token LEQ
%token RETURN
%token PLUS
%token TIMES
%token NEWLINE
%token COMMENT
%token LPAREN
%token LSQUI
%token RSQUI
%token SEMICOLON
%token RPAREN
%token EQUALS
%token MINUS
%token NOT
%token ISEQUAL
%token AND
%token WHILE
%token DO
%token PRINT
%token PRINTEL
%token PRINTS
%token IF
%token THEN
%token ELSE
%token EOF







%nonassoc NOT
%left LEQ
%left ISEQUAL
%left AND
%left MINUS
%left PLUS
%left TIMES

// Start symbol
%start <Ast.stmt> prog

%%

// Parsing grammar rules

prog:
    | p = stmt; EOF {p}
    ;

stmt:
    | RETURN; e=expr; SEMICOLON { Return e }
    | x = ID; EQUALS; e1 = expr; SEMICOLON { Let (x, e1) }
    | IF; e = expr; THEN; s1 = stmt; ELSE; s2 = stmt; SEMICOLON { Ite (e, s1, s2) }
    | LSQUI; b=stmt+; RSQUI; { Block b }  
    | WHILE; e = expr; DO; s=stmt; SEMICOLON { While (e, s) }
    | PRINT; e = expr; SEMICOLON { Print (e) }
    | PRINTEL; e = expr; SEMICOLON { PrintEL (e) }
    | PRINTS; e = expr; SEMICOLON { PrintS (e) }
    | COMMENT { Comment ("") }
    ;

expr:
    | i = INT { Int i}
    | x = ID { Var x }
    | TRUE { Bool true }
    | FALSE { Bool false }
    | e1 = expr; LEQ; e2 = expr { Binop (Leq, e1, e2) }
    | e1 = expr; TIMES; e2 = expr { Binop (Mult, e1, e2) }
    | e1 = expr; PLUS; e2 = expr { Binop (Add, e1, e2) }
    | e1 = expr; MINUS; e2 = expr { Binop (Minus, e1, e2) }
    | e1 = expr; AND; e2 = expr {Binop  (And, e1, e2) }
    | e1 = expr; ISEQUAL; e2 = expr { Binop (IsEqual, e1, e2) }
    | NOT; e1=expr {BNeg e1}
    | MINUS; e1=expr {INeg e1}
    | LPAREN; e = expr; RPAREN { e }
    ;