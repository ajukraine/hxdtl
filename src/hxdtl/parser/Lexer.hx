package hxdtl.parser;

import hxdtl.parser.Tokens;


enum Code
{
	Var;
	Tag;
	CommentTag;
}

enum LexerState
{
	InText;
	InCode(c: Code);
}

class CustomTokenSource
{
	var lexer:Lexer;
	public var ruleset:hxparse.Ruleset<Token>;

	public function new(lexer, ruleset){
		this.lexer = lexer;
		this.ruleset = ruleset;
	}

	public function token(): Token {
		return lexer.token(ruleset);
	}

	public function curPos():hxparse.Position{
		return lexer.curPos();
	}
}

class Lexer extends hxparse.Lexer implements hxparse.RuleBuilder
{
	static var buf = new StringBuf();
	static function bufOpen()
	{
		if (buf == null)
			buf = new StringBuf();
	}
	static function bufClose()
	{
		var str = buf.toString();
		buf = null;
		return str;
	}

	static var keywords = @:mapping Keyword;

	static var comment = "comment";
	static var endcomment = "endcomment";

	static var identifier = "_*[a-zA-Z][a-zA-Z0-9_]*|_+[0-9][_a-zA-Z0-9]*";

	public static var tok = @:rule
	[
		"" => tk(Eof),
		"[^{]*" => tk(Text(lexer.current)),
		"{{" => {
			inCodeVar(lexer);
			tk(VarOpen);
		},
		"{%" => {
			lexer.token(inCodeTag(lexer));
		},
		"{#" => {
			bufOpen();
			lexer.token(tokComment);
		}
	];

	public static var tokInVar = @:rule
	[
		"\\." => tk(Dot),
		":" => tk(DoubleDot),
		"|" => tk(Pipe),
		'"' => {
			bufOpen();
			lexer.token(tokString);
		},
		"[\r\n\t ]" => lexer.token(tokInVar),
		identifier => {
			var cur = lexer.current;
			var kwd = keywords.get(cur);

			if (kwd != null)
				tk(Kwd(kwd));
			else
				tk(Identifier(cur));
		},
		"[0-9]+" => tk(NumberLiteral(lexer.current)),
		"}}" => {
			inText(lexer);
			tk(VarClose);
		}
	];

	public static var tokInTag = @:rule
	[
		"\\." => tk(Dot),
		":" => tk(DoubleDot),
		"|" => tk(Pipe),
		'"' => {
			bufOpen();
			lexer.token(tokString);
		},
		"[\r\n\t ]" => lexer.token(tokInTag),
		"[0-9]+" => tk(NumberLiteral(lexer.current)),
		">=|<=|==|>|<|!=" => tk(Op(lexer.current)),
		comment => {
			inCommentTag(lexer);
			tk(Kwd(Comment));
		},
		identifier => {
			var cur = lexer.current;
			var kwd = keywords.get(cur);

			if (kwd != null)
				tk(Kwd(kwd));
			else
				tk(Identifier(cur));
		},
		"%}" => {
			lexer.token(inText(lexer));
		}
	];

	public static var tokInCommentTag = @:rule
	[
		"[^{]*" => {
			tk(Text(lexer.current));
		},
		"{%[ ]*" + endcomment + "[ ]*%}" => {
			inText(lexer);
			tk(Kwd(Endcomment));
		}
	];

	public static var tokComment = @:rule
	[
		"[^#]|[^}]" => {
			buf.add(lexer.current);
			lexer.token(tokComment);
		},
		"#}" => tk(Comment(bufClose()))
	];

	public static var tokString = @:rule
	[
		'[^"]' => {
			buf.add(lexer.current);
			lexer.token(tokString);
		},
		'"' => tk(StringLiteral(bufClose()))
	];


	public var lexerStream: CustomTokenSource;

	static function tk(token): Token
	{
		return new Token(token, null);
	}

	static function inText(lexer)
	{
		return cast(lexer, Lexer).setState(InText);
	}

	static function inCodeVar(lexer)
	{
		return cast(lexer, Lexer).setState(InCode(Var));
	}

	static function inCodeTag(lexer)
	{
		return cast(lexer, Lexer).setState(InCode(Tag));
	}

	static function inCommentTag(lexer) 
	{
		return cast(lexer, Lexer).setState(InCode(CommentTag));
	}

	function setState(state: LexerState)
	{
		switch state
		{
			case InText:
				setRuleset(tok);
			case InCode(Var):
				setRuleset(tokInVar);
			case InCode(Tag):
				setRuleset(tokInTag);
			case InCode(CommentTag):
				setRuleset(tokInCommentTag);
		}
		return lexerStream.ruleset;
	}

	function setRuleset(ruleset: hxparse.Ruleset<Token>)
	{
		lexerStream.ruleset = ruleset;
	}
}