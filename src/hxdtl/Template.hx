package hxdtl;

import hxdtl.parser.Ast;
import hxdtl.parser.Parser;
import hxdtl.runtime.Interpreter;
import hxdtl.runtime.Context;

class Template
{
	var interpreter: Interpreter;
	var ast: Ast;
	
	public function new(source: String)
	{
		interpreter = new Interpreter();

		var parser = new Parser();
		ast = parser.parse(new haxe.io.StringInput(source));
	}

	public function render(context)
	{
		return interpreter.run(ast, new Context(context));
	}
}