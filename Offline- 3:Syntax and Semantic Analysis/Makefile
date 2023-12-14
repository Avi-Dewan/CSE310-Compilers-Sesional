parser.out: 1905120.y 1905120.l parseNode.h parseNode.cpp 1905120_symbolInfo.h 1905120_scopeTable.h 1905120_symbolTable.h
	bison -d 1905120.y
	flex 1905120.l
	g++ -o parser.out -ggdb3 lex.yy.c 1905120.tab.c parseNode.cpp
