package hxdtl;

import hxparse.Lexer;
import hxdtl.Tokens;

class DtlLexer extends Lexer implements hxparse.RuleBuilder
{
	static function tk(token)
	{
		return { tok: token }
	}

	static var inCode = false;
	static var keywords = @:mapping Keyword;

	public static var tok = @:rule
	[
		"" => tk(Eof),
		"[\r\n\t ]" => lexer.token(tok),
		
		"[^({|})]*" => {
			var cur = lexer.current;
			var kwd = keywords.get(cur);

			if (inCode)
			{
				if (kwd != null)
					tk(Kwd(kwd));
				else
					tk(Identifier(cur));
			}
			else
			{
				tk(Text(cur));
			}
		},
		"{{" => {
			inCode = true;
			tk(VarOpen);
		},
		"}}" => {
			inCode = false;
			tk(VarClose);
		}
	];
}