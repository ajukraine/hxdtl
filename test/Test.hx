import haxe.io.StringInput;
import hxdtl.DtlParser;
import hxdtl.DtlInterpreter;

class Test 
{
	static function main()
	{
		trace("hxDtl - Haxe implmentation of Django Template Language");

		var input = new StringInput("Hello, Haxe! I'm from {{Country}}.");
		var parser = new DtlParser(input);
		var context =
		{
			Country: "Ukraine"
		};

		var interpreter = new DtlInterpeter();

		trace("[Template]");
		trace(input);

		trace("[Interpreted]");
		trace(interpreter.run(parser.parse(), toMap(context)));
	}

	static function toMap(obj)
	{
		var map = new Map<String, Dynamic>();

		for(field in Reflect.fields(obj))
		{
			map.set(field, Reflect.field(obj, field));
		}

		return map;
	}
}