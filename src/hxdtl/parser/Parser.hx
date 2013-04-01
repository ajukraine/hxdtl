package hxdtl.parser;

import hxdtl.parser.Tokens;
import hxdtl.parser.Ast;

class Parser extends hxparse.Parser<Token> 
{
	public function new()
	{
		super(null);
	}

	public function parse(input: haxe.io.Input)
	{
		var lexer = new Lexer(input);
		stream = new hxparse.LexerStream(lexer, Lexer.tok);
		lexer.lexerStream = stream;

		return
		{
			body: loop(parseElement)
		}
	}

	function any<T>(functions: Array<Void->T>): T
	{
		for(f in functions)
		{
			var expr = switch stream
			{
				case [e = f()]: e;
				case _: null;
			}

			if (expr != null)
				return expr;
		}
		return null;
	}

	function collect<T>(acc: Array<T>, item: T) 
	{
		acc.push(item);
		return acc;
	}

	function loop<T>(f:Void->T): Array<T>
	{
		return loopAndFill(f, []);
	}

	function loopAndFill<T>(f:Void->T, acc:Array<T>): Array<T> 
	{
		return switch stream
		{
			case [item = f(), list = loopAndFill(f, collect(acc, item))]:
				list;
			case _: acc;
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

	function parseElement() return switch stream
	{
		case [{tok: Text(t)}]: AstExpr.Text(t);
		case [value = inVar(parseValue)]: value;
		case [ifExpr = parseIfBlock()]: ifExpr;
		case [forExpr = parseForBlock()]: forExpr;
		case [commentExpr = parseCommentBlock()]: commentExpr;
		case [filterExpr = parseFilterBlock()]: filterExpr;
	}

	function parseValue()
	{
		var value = switch stream
		{
			case [variable = parseVariable()]: variable;
			case [literal = parseLiteral()]: literal;
		}

		return switch stream
		{
			case [{tok: Pipe}, filter = parseFilter()]: AstExpr.ApplyFilter([value], filter);
			case _: value;
		}
	}

	function parseFilter() return switch stream
	{
		case [{tok: Identifier(filterName)}]: switch stream
		{
			case [{tok: DoubleDot}, arg = any([parseLiteral, parseVariable])]:
				AstFilter.Arg(filterName, arg);
			case _: AstFilter.NoArgs(filterName);
		}
	}

	function parseLiteral() return switch stream
	{
		case [{tok: NumberLiteral(n)}]: AstExpr.NumberLiteral(n);
		case [{tok: StringLiteral(s)}]: AstExpr.StringLiteral(s);
	}

	function parseVariable() return switch stream
	{
		case [{tok: Identifier(id)}]: switch stream
		{
			case [{tok: Dot}, v = parseVariable()]: AstExpr.Attribute(id, v);
			case _: AstExpr.Variable(id);
		}
	}

	function parseIfBlock() return switch stream
	{
		case [{tok: Kwd(If)}]: parseIfBlockBody();
	}

	function parseIfBlockBody() return switch stream
	{
		case [ifCond = parseIfCondition(), ifBody = loop(parseElement)]: switch stream
		{
			case [{tok: Kwd(EndIf)}]:
				AstExpr.If(ifCond, ifBody);
			case [{tok: Kwd(Else)}, elseBody = loop(parseElement), {tok: Kwd(EndIf)}]:
				AstExpr.IfElse(ifCond, ifBody, elseBody);
			case [{tok: Kwd(Elif)}]:
				AstExpr.IfElse(ifCond, ifBody, [parseIfBlockBody()]);
		}
	}

	function parseIfCondition() return switch stream
	{
		case [part = parseIfConditionPart()]: switch stream
		{
			case [op1 = parseBinOp1()]: AstExpr.BinOp(op1, part, parseIfCondition());
			case _: part;
		}
	}

	function parseIfConditionPart() return switch stream
	{
		case [v1 = parseValue()]: switch stream
		{
			case [op2 = parseBinOp2(), v2 = parseValue()]: AstExpr.BinOp(op2, v1, v2);
			case _: AstExpr.NullOp(v1);
		}
		case [op = parseUnOp(), v = parseValue()]: AstExpr.UnOp(op, v);
	}

	function parseForBlock() return switch stream
	{
		case [{tok: Kwd(For)}, {tok: Identifier(id)}, {tok: Kwd(In)}, {tok: Identifier(idList)},
			body = loop(parseElement)]: switch stream
		{
			case [{tok: Kwd(EndFor)}]:
				AstExpr.For(id, idList, body);
			case [{tok: Kwd(Empty)}, emptyBody = loop(parseElement), {tok: Kwd(EndFor)}]:
				AstExpr.ForEmpty(id, idList, body, emptyBody);
		}
	}

	function parseCommentBlock() return switch stream
	{
		case [{tok: Comment(text)}]: Comment(text);
		case [{tok: Kwd(Comment)}, {tok: Text(text)}, {tok: Kwd(EndComment)}]: Comment(text);
	}

	function parseFilterBlock() return switch stream
	{
		case [{tok: Kwd(Filter)}, filter = parseFilter(), filterBody = loop(parseElement), {tok: Kwd(EndFilter)}]:
			AstExpr.ApplyFilter(filterBody, filter);
	}

	function parseUnOp() return switch stream
	{
		case [{tok: Kwd(Not)}]: Not;
	}

	function parseBinOp1() return switch stream
	{
		case [{tok: Kwd(And)}]: And;
		case [{tok: Kwd(Or)}]: Or;
	}

	function parseBinOp2() return switch stream
	{
		case [{tok: Op(">")}]: Greater;
		case [{tok: Op(">=")}]: GreaterOrEqual;
		case [{tok: Op("<")}]: Less;
		case [{tok: Op("<=")}]: LessOrEqual;
		case [{tok: Op("==")}]: Equal;
		case [{tok: Op("!=")}]: NotEqual;
	}
}