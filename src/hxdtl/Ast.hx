package hxdtl;

typedef Ast =
{
	body: Array<AstExpr>
}

enum AstExpr
{
	Text(s: String);

	StringLiteral(s: String);
	NumberLiteral(n: String);

	Variable(i: String);

	Attribute(v: AstExpr, i: String);

	If(cond: AstExpr, body: Array<AstExpr>);
	IfElse(cond: AstExpr, ifBody: Array<AstExpr>, elseBody: Array<AstExpr>);

	UnOp(op: UnaryOperator, e: AstExpr);
	BinOp(op: BinaryOperator, e1: AstExpr, e2: AstExpr);
}

enum UnaryOperator
{
	Not;
}

enum BinaryOperator
{
	Greater;
	Less;
	Equals;
}