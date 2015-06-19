package hxdtl.parser; 

enum Keyword
{
	If;
	Elif;
	Else;
	Endif;

	For;
	In;
	Empty;
	Endfor;

	And;
	Or;
	Not;

	Comment;
	Endcomment;

	Filter;
	Endfilter;
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

class Token
{
	public var tok: TokenDef;
	public var pos: Null<Int>;

	public function new(tok: TokenDef, pos: Null<Int>)
	{
		this.tok = tok;
		this.pos = pos;
	}
}