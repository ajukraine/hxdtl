package hxdtl;

import haxe.ds.StringMap;
import hxdtl.Ast;

class DtlInterpreter
{
	public function new()
	{
	}

	public function run(ast: Ast, context: Map<String, Dynamic>): String
	{
		return evalExpressions(ast.body, context);
	}

	function evalExpressions(expressions: Array<AstExpr>, context)
	{
		var result = new StringBuf();
		for(expr in expressions)
		{
			var s = evalExpression(expr, context);
			if (s != null)
				result.add(s);
		}

		return result.toString();
	}

	function evalExpression<T>(expr, context): T
	{
		return switch expr
		{
			case NumberLiteral(n): Std.parseInt(n);
			case StringLiteral(s): s;
			case Text(text): text;
			case Variable(identifier): evalVariable(identifier, context);
			case attrExpr = Attribute(_, _): evalAttribute(attrExpr, context);
			
			case If(eCond, eBody): evalIf(eCond, eBody, [], context);
			case IfElse(eCond, eBodyIf, eBodyElse): evalIf(eCond, eBodyIf, eBodyElse, context);
			
			case NullOp(e1): evalNullOp(e1, context);
			case UnOp(op, e1): evalUnOp(op, e1, context);
			case BinOp(op, e1, e2): evalBinOp(op, e1, e2, context);
		}
	}

	function evalVariable(key, context: Dynamic)
	{
		return cast(context, StringMap<Dynamic>).get(key);
	}

	function evalAttribute(expr, context)
	{
		return switch expr
		{
			case Attribute(key2, Variable(key1)):
				evalVariable(key1, context.get(key2));
			case Attribute(key, attr = Attribute(_, _)):
				evalAttribute(attr, evalVariable(key, context));
			case _:
				null;
		}
	}

	function evalIf(eCond, eBodyIf, eBodyElse, context)
	{
		return evalExpressions(
				(evalExpression(eCond, context)) ? eBodyIf : eBodyElse,
				context);
	}

	function evalNullOp(e1, context)
	{
		var v = evalExpression(e1, context);
		return v != 0;
	}

	function evalUnOp(op, e1, context) 
	{
		return switch op
		{
			case Not: !evalExpression(e1, context);
		}
	}

	function evalBinOp(op, e1, e2, context)
	{
		return switch op
		{
			case Equal: evalExpression(e1, context) == evalExpression(e2, context);
			case NotEqual: evalExpression(e1, context) != evalExpression(e2, context);
			case Greater: evalExpression(e1, context) > evalExpression(e2, context);
			case GreaterOrEqual: evalExpression(e1, context) >= evalExpression(e2, context);
			case Less: evalExpression(e1, context) < evalExpression(e2, context);
			case LessOrEqual: evalExpression(e1, context) <= evalExpression(e2, context);
			case And: evalExpression(e1, context) && evalExpression(e2, context);
			case Or: evalExpression(e1, context) || evalExpression(e2, context);
		}
	}
}