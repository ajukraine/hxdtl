package hxdtl;

import hxparse.Lexer;
import hxparse.Types;

import hxdtl.Tokens;


enum Code
{
	Var;
	Tag;
}
enum LexerState
{
	InText;
	InCode(c: Code);
}

class DtlLexer extends Lexer implements hxparse.RuleBuilder
{
	static var keywords = @:mapping Keyword;

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


	public var lexerStream: hxparse.LexerStream<Token> ;

	static function tk(token)
	{
		return { tok: token }
	}

	static function inCodeVar(lexer)
	{
		return cast(lexer, DtlLexer).setState(InCode(Var));
	}

	static function inText(lexer)
	{
		return cast(lexer, DtlLexer).setState(InText);
	}

	static function inCodeTag(lexer)
	{
		return cast(lexer, DtlLexer).setState(InCode(Tag));
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
		}
		return lexerStream.ruleset;
	}

	function setRuleset(ruleset: hxparse.Ruleset<Token>)
	{
		lexerStream.ruleset = ruleset;
	}
}