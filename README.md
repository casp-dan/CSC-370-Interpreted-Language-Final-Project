# CSC 370 Course Project

## Objective

Throughout this class we have used a functional style of programming where state is immutable, functions have the 
same status as other data, and recursion is preferred over iteration. You will now use OCaml to develop an interpreter for
an *imperative programming language* called **Loops** with mutable state and iteration.

## Specification of Loops
The following BNF grammar specifies the syntax of the language:
```
program ::= <stmts>

stmts = <stmt>+

stmt ::= 
    | <id> = <expr>;
    | if <expr> then <stmt> else <stmt>
    | while <expr> do <stmt>
    | { <stmts> }
    | print <expr>;
    | print_endline <expr>;
    | print_space <expr>;
    | return <expr>;

expr ::=
    | <i>
    | true
    | false
    | <id>
    | - <expr>
    | <expr> + <expr>
    | <expr> * <expr>
    | <expr> - <expr>
    | <expr> == <expr>
    | <expr> <= <expr>
    | <expr> and <expr>
    | not <expr>
    | (<expr>)

i ::= <integer constants>
id ::= <alpha-numeric variable names>
```
Notice that all simple statements end with a `;`.
Additionally, the language will also allow single-line comments that begin with `//` and end at the end of the line.
Besides end of comments, loops is a white-space agnostic language. While users might choose to input one statement per 
line and add indentation within the body of loops and if-then-elses, the interpreter will not require this.

## Errors
For incorrect syntax, rely on OCamlLex and Menhir's exceptions, and also use an exception called `EvalError`
that carries a descriptive string, as we were doing in class. Ideally, we would want to implement a 
type-checking algorithm and also keep track of line  numbers, catch any exceptions within `main.ml` and return a descriptive string explaining the error to 
the user instead of raising an exception. But this would take a considerable amount of effort, and is not required.

## Incremental Development
This is a fairly advanced language with a lot of features. It would make things easier to separate it
into incremental goals that you can develop and test independently. 

### Part 1 - Constant Expressions
As a first step, your interpreter should be able to handle arbitrary expressions. At this stage, expressions 
will not contain variables. The only statement that the interpreter will accept is `return` statements.
The BNF grammar representing the subset of the language to be implemented at this stage is:
```
program ::= <stmts>

stmts = (<stmt>)+

stmt ::= return <expr>;

expr ::=
    | <i>
    | true
    | false
    | - <expr>
    | <expr> + <expr>
    | <expr> * <expr>
    | <expr> - <expr>
    | <expr> == <expr>
    | <expr> <= <expr>
    | <expr> and <expr>
    | not <expr>
    | (<expr>)

i ::= <integer constants>
```
The semantics of `return` is the same as most other programming languages: as soon as Loops sees a `return`
statement it will evaluate and return its parameter as output. Any subsequent `return` statements are ignored.

### Part 2 - State, Statement Blocks, Print, Comments
Next, add comments, variables, assignments, block statements, and print statements. You will now need an evaluation model for
keeping track of state. We looked at the substitution model and the evaluation model in class. The evaluation model
is strongly recommended for your implementation of Loops. We need to define some semantics of the language
constructs to be implemented for this part. 

#### Variables and Assignment

There are no explicit variable 
declarations in Loops, these are done implicitly. For example, this program:
```
x = 1;
x = x + 1;
return x;
```
first creates an integer variable, sets its value to `1`, and then updates it to `2`, which is the value that is
finally returned.

Specifically, assignment semantics can be specified as:
- Assignment `<id> = <expr>` evaluates the expression in `<expr>` and binds it to the name `<id>`. 
- If `<id>` was previously bound, the binding is updated (lexical scoping).
- If `<expr>` contains a variable, it evaluates to its most recently bound value. If it was never previously 
bound, then the interpreter will raise an `EvalError` exception that carries the string `Unbound Variable`.

#### Blocks

Blocks create new variable scopes. The following
will still return `2`.
```
x = 1;
{
    x = x * 200 + 4
}
x = x + 1;
return x;
```
`x` inside the block will be updated to `204` but its scope is restricted to the block. Adding a `return x`
statement inside the block will result in the program returning `204` intead of `2`. This is because
the semantics of `return` dictate that the program will return the corresponding value as soon as it sees a `return` statement. Notice also that blocks have
access to the (preceding) global scope.

#### Comments

Comments start with `//` and end at the end of the line. Comments can have program code (or any text), but you will just ignore them altogether. The best place to implement 
comments is in the lexer. You might need to use the power of [regular expressions](https://ocaml.org/manual/5.2/lexyacc.html#ss:ocamllex-regexp) to do this.

#### Print

The language has 3 forms of print statements: `print`, `print_endline` and `print_space`. This is essentially to avoid implementing a `string` type, while still allowing some minimal output formatting. Semantics:
- `print <expr>` prints the evaluated expression on to the screen
- `print_endline <expr>` prints the evaluated expression on to the screen followed by a newline
- `print_space <expr>` prints the evaluated expression on to the screen followed by a space character

### Part 3 - Branching 
Next, add the `if ... else` branches to Loops.

#### Semantics 
Given `if <expr> then <stmt1> else <stmt2>`, as long as `<expr>` evaluates to a Boolean value, if this
Boolean value is true, then `<stmt1>` is executed, and `<stmt2>` is executed otherwise. Since the language allows
block statements, notice that the branches of the condition can execute multiple statements. The scope of 
the branch is carried over to the statements that occur after the `if ... else` branch. In other words, 
statement blocks have global scope when they occur directly under an `if .. else` branch.

### Part 4 - Iteration

Finally, we can complete the language by adding `while` loops.

#### Semantics
Given `while <expr> do <stmt>`, as long as `<expr>` evaluates to a Boolean value, and if the value is true, `<stmt>` is repeatedly executed until the Boolean value 
turns to false. If the value is false, the body is never executed. At the end of each iteration of `<stmt>`, the 
scope is carried over either to the next iteration or to  the statement after the body of the loop. In other words, statement blocks have global scope when 
they occur directly under a while branch.
