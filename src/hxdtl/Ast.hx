package hxdtl;

typedef AstTree =
{
	body: Array<AstExpr>
}

enum AstExpr
{
	Text(s: String);
	Variable(i: String);
	Attribute(v: AstExpr, i: String);
}