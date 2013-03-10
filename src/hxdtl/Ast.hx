package hxdtl;

typedef Ast =
{
	body: Array<AstExpr>
}

enum AstExpr
{
	Text(s: String);
	Variable(i: String);
	Attribute(v: AstExpr, i: String);
}