package hxdtl;

import hxdtl.Ast;

class DtlInterpeter 
{
	public function new()
	{
		
	}

	public function run(astTree: AstTree, context: Map<String, Dynamic>): String
	{
		var result = new StringBuf();

		for(expr in astTree.body)
		{
			switch expr
			{
				case Text(t):
					result.add(t);
				case Variable(key):
					result.add(context.get(key));
				case Attribute(_, _):

			}
		}

		return result.toString();
	}
}