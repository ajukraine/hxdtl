package hxdtl;

import hxdtl.Tokens;
import hxdtl.Ast;

class DtlParser extends hxparse.Parser<Token> 
{
	public function new()
	{
		super(null);
	}

	public function parse(input: haxe.io.Input)
	{
		stream = new hxparse.LexerStream(new DtlLexer(input), DtlLexer.tok);
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

	function opt<T>(f:T->T, fallback: T = null): Null<T>
	{
		return switch stream
		{
			case [v = f(fallback)]: v;
			case _: fallback;
		}
	}

	function parseElement()
	{
		return switch stream
		{
			case [{tok: Text(t)}]:
				AstExpr.Text(t);
			case [{tok: VarOpen}, value = parseValue(), {tok: VarClose}]:
				value;
		}
	}

	function parseValue()
	{
		return switch stream
		{
			case [variable = parseVariable()]:
				variable;
		}
	}

	function parseVariable()
	{
		return switch stream
		{
			case [{tok: Identifier(identifier)}, expr = opt(parseAttribute, AstExpr.Variable(identifier))]:
				expr;
		}
	}

	function parseAttribute(outExpr)
	{
		return switch stream
		{
			case [{tok: Dot}, {tok: Identifier(identifier)}, expr = opt(parseAttribute, Attribute(outExpr, identifier))]:
				expr;
		}
	}
}