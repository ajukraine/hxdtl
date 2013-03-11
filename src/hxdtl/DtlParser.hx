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
		var lexer = new DtlLexer(input);
		stream = new hxparse.LexerStream(lexer, DtlLexer.tok);
		lexer.lexerStream = stream;

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

	function inTag<T>(f: Void->T): Null<T>
	{
		return switch stream
		{
			case [{tok: TagOpen}, expr = f(), {tok: TagClose}]:
				expr;
		}
	}

	function inVar<T>(f: Void->T): Null<T>
	{
		return switch stream
		{
			case [{tok: VarOpen}, expr = f(), {tok: VarClose}]:
				expr;
		}
	}

	function parseElement()
	{
		return switch stream
		{
			case [{tok: Text(t)}]: AstExpr.Text(t);
			case [ifExpr = parseIfBlock()]: ifExpr;
			case [value = inVar(parseValue)]: value;
		}
	}

	function parseValue()
	{
		return switch stream
		{
			case [variable = parseVariable()]:
				variable;
			case [literal = parseLiteral()]:
				literal;
		}
	}

	function parseLiteral()
	{
		return switch stream
		{
			case [{tok: NumberLiteral(n)}]: AstExpr.NumberLiteral(n);
			case [{tok: StringLiteral(s)}]: AstExpr.StringLiteral(s);
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
			case [{tok: Dot}, {tok: Identifier(identifier)},
				expr = opt(parseAttribute, AstExpr.Attribute(outExpr, identifier))]:
				expr;
		}
	}

	function parseIfBlock()
	{
		return switch stream
		{
			case [ifCond = inTag(parseIf), ifBody = parseElement(), tEndIf = inTag(parseEndIf)]:
				AstExpr.If(ifCond, ifBody);
		}
	}

	function parseIf()
	{
		return switch stream
		{
			case [{tok: Kwd(If)}, cond = parseIfCondition()]:
				cond;
		}
	}

	function parseIfCondition()
	{
		return switch stream
		{
			case [v1 = parseValue(), op = parseBinOp(), v2 = parseValue()]:
				AstExpr.BinOp(op, v1, v2);
		}
	}

	function parseEndIf()
	{
		return switch stream
		{
			case [{tok: Kwd(EndIf)}]:
				AstExpr.If;
		}
	}

	function parseBinOp()
	{
		return switch stream
		{
			case [{tok: Op(">")}]: Greater;
			case [{tok: Op("<")}]: Less;
		}
	}
}