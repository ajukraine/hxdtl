package hxdtl;

import hxparse.Lexer;
import hxparse.Types;

import hxdtl.Tokens;

enum LexerState
{
	InText;
	InCode;
}

class DtlLexer extends Lexer implements hxparse.RuleBuilder
{
	static var keywords = @:mapping Keyword;

	public static var tok = @:rule
	[
		"" => tk(Eof),
		"[^{]*" => tk(Text(lexer.current)),
		"{{" => {
			inCode(lexer);
			tk(VarOpen);
		},
		"{%" => {
			inCode(lexer);
			tk(TagOpen);
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
		"}}" => {
			inText(lexer);
			tk(VarClose);
		},
		"%}" => {
			inText(lexer);
			tk(TagClose);
		}
	];

	public var lexerStream: hxparse.LexerStream<Token> ;

	static function tk(token)
	{
		return { tok: token }
	}

	static function inCode(lexer)
	{
		cast(lexer, DtlLexer).setState(InCode);
	}

	static function inText(lexer)
	{
		cast(lexer, DtlLexer).setState(InText);
	}

	function setState(state: LexerState)
	{
		switch state
		{
			case InText:
				setRuleset(tok);
			case InCode:
				setRuleset(tokInVar);
		}
	}

	function setRuleset(ruleset: hxparse.Ruleset<Token>)
	{
		lexerStream.ruleset = ruleset;
	}
}