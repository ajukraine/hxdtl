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
		var result = new StringBuf();

		for(expr in ast.body)
		{
			switch expr
			{
				case Text(t):
					result.add(t);
				case Variable(key):
					result.add(context.get(key));
				case attr = Attribute(_, _):
					result.add(evalAttribute(attr, context));
			}
		}

		return result.toString();
	}

	function evalAttribute(expr, context)
	{
		return switch expr
		{
			case Attribute(Variable(key1), key2):
				cast(context.get(key1), StringMap<Dynamic>).get(key2);
			case Attribute(attr = Attribute(_, _), key):
				cast(evalAttribute(attr, context), StringMap<Dynamic>).get(key);
			case _:
				null;
		}
	}
}