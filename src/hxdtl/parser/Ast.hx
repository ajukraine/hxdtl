package hxdtl.parser;

typedef TAst = Array<Expr>;

/*enum Statement
{
	Text(text: String);
	
	If(cond: Expr, body: TAst);
	IfElse(cond: Expr, ifBody: TAst, elseBody: TAst);
	
	For(iterator: String, list: String, body: TAst);
	ForEmpty(iterator: String, list: String, body: TAst, emptyBody: TAst);
}*/

enum Expr
{
	Text(s: String);

	StringLiteral(s: String);
	NumberLiteral(n: String);

	ApplyFilter(value: TAst, filter: Filter);

	Variable(id: String);
	Attribute(id: String, v: Expr);

	If(cond: Expr, body: TAst);
	IfElse(cond: Expr, ifBody: TAst, elseBody: TAst);

	For(id: String, idList: String, body: TAst);
	ForEmpty(id: String, idList: String, body: TAst, emptyBody: TAst);

	NullOp(e: Expr);
	UnOp(op: UnaryOperator, e: Expr);
	BinOp(op: BinaryOperator, e1: Expr, e2: Expr);

	Comment(s: String);
}

enum Filter
{
	NoArgs(name: String);
	Arg(name: String, arg: Expr);
}

enum UnaryOperator
{
	Not;
}

enum BinaryOperator
{
	Greater;
	GreaterOrEqual;
	Less;
	LessOrEqual;
	Equal;
	NotEqual;
	And;
	Or;
}