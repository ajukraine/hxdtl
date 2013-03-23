package hxdtl;

import hxdtl.parser.Ast;
import hxdtl.parser.Parser;
import hxdtl.runtime.Interpreter;

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

	static function map<T>(obj: T)
	{
		var m = new Map<String, T>();
		for(field in Reflect.fields(obj))
		{
			m.set(field, Reflect.field(obj, field));
		}
		return m;
	}


	public function render(context)
	{
		return interpreter.run(ast, map(context));
	}
}