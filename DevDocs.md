My implementation of Loops, while sporting one major flaw in particular, is otherwise very complete. All while loops, ITE statements and blocks will successfully evaluate as intended. Blocks will keep their scope exclusively within themselves unless the block is a part of a loop or ITE statement, in which case it will successfully reassign variables as intended. 

The big flaw in this language is that it can not properly evaluate blocks, ITEs, or while loops when they are split across multiple lines as such: 
    x = 1;
        {
        x = 23;
        y = 23 * x;
        z = (y == 230);
        //return z;
        }
    x = x + 1;
    return x;

Ultimately, I believe it was the way that I read in a file from main into the lexer and specifically the parser generators that was my downfall. I focused on one aspect of the project at a time right from the get go instead of looking at the big picture. I believe if I had done this I may have caught this error earlier on and had more time to effectively rework my implementation to ultimately support the parsing of multiline statements. That said, everything else in this project (to my knowledge) works to specifications! 