package hxdtl.parser; 


enum Keyword
{
	If;
	Elif;
	Else;
	EndIf;

	For;
	In;
	EndFor;

	And;
	Or;
	Not;
}

enum TokenDef
{
	Text(s: String);

	NumberLiteral(n: String);
	StringLiteral(s: String);

	Identifier(s: String);
	Kwd(k: Keyword);

	Op(op: String);

	VarOpen;
	VarClose;

	Dot;
	POpen;
	PClose;

	Eof;
}

typedef Token =
{
	tok: TokenDef
}