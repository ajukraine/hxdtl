package hxdtl.runtime;

import haxe.ds.StringMap;
import hxdtl.parser.Ast;
import hxdtl.runtime.Context;

class Interpreter
{
	public function new()
	{
	}

	public function run(ast: Ast, context: Context): String
	{
		return evalExpressions(ast.body, context);
	}

	function evalExpressions(expressions: Array<AstExpr>, context: Context)
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

			case For(id, idList, body): evalFor(id, idList, body, context);
				
			case ForEmpty(id, idList, body, emptyBody): evalForEmpty(id, idList, body, emptyBody, context);
			
			case NullOp(e1): evalNullOp(e1, context);
			case UnOp(op, e1): evalUnOp(op, e1, context);
			case BinOp(op, e1, e2): evalBinOp(op, e1, e2, context);

			case Comment(_): null;
		}
	}

	function evalVariable(key, context: Context)
	{
		return context.get(key);
	}

	function evalAttribute(expr, context: Context)
	{
		return switch expr
		{
			case Attribute(key2, Variable(key1)):
				evalVariable(key1, context.subContext(key2));
			case Attribute(key, attr = Attribute(_, _)):
				evalAttribute(attr, context.subContext(key));
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

	function evalFor(id, idList, body, context: Context)
	{
		var result = new StringBuf();

		var forContext = context.clone();
		var list: Array<Dynamic> = context.get(idList);

		for(item in list)
		{
			forContext.set(id, item);
			result.add(evalExpressions(body, forContext));
		}

		return result.toString();
	}

	function evalForEmpty(id, idList, body, emptyBody, context: Context)
	{
		var result = new StringBuf();

		
		var list: Array<Dynamic> = context.get(idList);

		if (list == null || list.length == 0)
		{
			result.add(evalExpressions(emptyBody, context));
		}
		else
		{
			var forContext = context.clone();
			for(item in list)
			{
				forContext.set(id, item);
				result.add(evalExpressions(body, forContext));
			}
		}

		return result.toString();
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