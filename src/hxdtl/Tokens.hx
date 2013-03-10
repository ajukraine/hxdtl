package hxdtl; 


enum Keyword
{
	If;
	Elif;
	Else;
	EndIf;

	For;
	In;
	EndFor;
}

enum TokenDef
{
	Text(s: String);

	Identifier(s: String);
	Kwd(k: Keyword);

	VarOpen;
	VarClose;
	TagOpen;
	TagClose;

	Dot;
	POpen;
	PClose;

	Eof;
}

typedef Token =
{
	tok: TokenDef
}