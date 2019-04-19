lex lex.l
yacc -dv yacc.y
gcc lex.yy.c y.tab.c stack.c -ll -ly
./a.out
rm ./a.out lex.yy.c y.output y.tab.c y.tab.h