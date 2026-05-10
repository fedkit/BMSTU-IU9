package main

import (
	"fmt"
	"go/ast"
	"go/format"
	"go/parser"
	"go/token"
	"os"
)

func isSingleIntResult(fn *ast.FuncDecl) bool {
	if fn.Type.Results == nil {
		return false
	}

	if len(fn.Type.Results.List) != 1 {
		return false
	}

	field := fn.Type.Results.List[0]

	ident, ok := field.Type.(*ast.Ident)
	if !ok {
		return false
	}

	return ident.Name == "int"
}

func insertPrint(fn *ast.FuncDecl) {
	funcName := fn.Name.Name

	ast.Inspect(fn.Body, func(n ast.Node) bool {
		block, ok := n.(*ast.BlockStmt)
		if !ok {
			return true
		}

		var newList []ast.Stmt

		for _, stmt := range block.List {
			if ret, ok := stmt.(*ast.ReturnStmt); ok {

				var value ast.Expr

				if len(ret.Results) == 1 {
					value = ret.Results[0]
				} else if len(ret.Results) == 0 {
					if fn.Type.Results != nil && len(fn.Type.Results.List) == 1 {
						field := fn.Type.Results.List[0]
						if len(field.Names) > 0 {
							value = ast.NewIdent(field.Names[0].Name)
						}
					}
				}

				if value != nil {
					printStmt := &ast.ExprStmt{
						X: &ast.CallExpr{
							Fun: &ast.SelectorExpr{
								X:   ast.NewIdent("fmt"),
								Sel: ast.NewIdent("Printf"),
							},
							Args: []ast.Expr{
								&ast.BasicLit{
									Kind:  token.STRING,
									Value: fmt.Sprintf("\"%s %%d\\n\"", funcName),
								},
								value,
							},
						},
					}
					newList = append(newList, printStmt)
				}
			}

			newList = append(newList, stmt)
		}

		block.List = newList
		return true
	})
}

func main() {
	fset := token.NewFileSet()

	file, _ := parser.ParseFile(
		fset,
		os.Args[1],
		nil,
		parser.ParseComments,
	)

	hasFmt := false
	for _, imp := range file.Imports {
		if imp.Path.Value == "\"fmt\"" {
			hasFmt = true
			break
		}
	}

	if !hasFmt {
		file.Imports = append(file.Imports, &ast.ImportSpec{
			Path: &ast.BasicLit{
				Kind:  token.STRING,
				Value: "\"fmt\"",
			},
		})
	}

	for _, decl := range file.Decls {
		fn, ok := decl.(*ast.FuncDecl)
		if !ok {
			continue
		}

		if fn.Recv != nil { 
			continue
		}

		if fn.Name == nil {
			continue
		}

		if isSingleIntResult(fn) {
			insertPrint(fn)
		}
	}

	format.Node(os.Stdout, fset, file)
}
