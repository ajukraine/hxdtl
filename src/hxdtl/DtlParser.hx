package hxdtl;

import hxdtl.Tokens;
import hxdtl.Ast;

class DtlParser extends hxparse.Parser<Token> 
{
	public function new(input: haxe.io.Input)
	{
		super(new hxparse.LexerStream(new DtlLexer(input), DtlLexer.tok));
	}

	public function parse()
	{
		return
		{
			body: loop(parseElement, [])
		}
	}

	function collect<T>(acc: Array<T>, item: T) 
	{
		acc.push(item);
		return acc;
	}

	function loop<T>(f:Void->T, acc:Array<T>): Array<T> 
	{
		return switch stream
		{
			case [item = f(), list = loop(f, collect(acc, item))]:
				list;
			case _: acc;
		}
	}

	function parseElement() 
	{
		return switch stream
		{
			case [{tok: Text(t)}]:
				AstExpr.Text(t);
			case [{tok: VarOpen}, {tok: Identifier(identifier)}, {tok: VarClose}]:
				AstExpr.Variable(identifier);
		}
	}
}