package hxdtl.parser; 


enum Keyword
{
	If;
	Elif;
	Else;
	EndIf;

	For;
	In;
	Empty;
	EndFor;

	And;
	Or;
	Not;

	Comment;
	EndComment;

	Filter;
	EndFilter;
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

	Pipe;
	Dot;
	DoubleDot;
	POpen;
	PClose;

	Comment(s: String);

	Eof;
}

typedef Token =
{
	tok: TokenDef
}