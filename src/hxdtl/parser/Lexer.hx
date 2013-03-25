package hxdtl.parser;

import hxparse.Types;
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

class Lexer extends hxparse.Lexer implements hxparse.RuleBuilder
{
	static var keywords = @:mapping Keyword;

	static var buf = new StringBuf();

	static var comment = "comment";
	static var endcomment = "endcomment";

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
			buf = new StringBuf();
			lexer.token(tokComment);
		}
	];

	public static var tokInVar = @:rule
	[
		"." => tk(Dot),
		"[\r\n\t ]" => lexer.token(tokInVar),
		"[_a-zA-Z]*" => {
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
		"." => tk(Dot),
		"[\r\n\t ]" => lexer.token(tokInTag),
		"[0-9]+" => tk(NumberLiteral(lexer.current)),
		">=|<=|==|>|<|!=" => tk(Op(lexer.current)),
		comment => {
			inCommentTag(lexer);
			tk(Kwd(Comment));
		},
		"[_a-zA-Z]*" => {
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
			tk(Kwd(EndComment));
		}
	];

	public static var tokComment = @:rule
	[
		"#}" => tk(Comment(buf.toString())),
		"[^#]|[^}]" => {
			buf.add(lexer.current);
			lexer.token(tokComment);
		}
	];


	public var lexerStream: hxparse.LexerStream<Token> ;

	static function tk(token)
	{
		return { tok: token }
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