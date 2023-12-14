run: scope.out
	./scope.out

scope.out: SymbolTable.cpp ScopeTable.cpp SymbolInfo.cpp
	g++ SymbolTable.cpp -o scope.out

clean:
	rm scope.out