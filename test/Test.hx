import haxe.io.StringInput;
import hxdtl.DtlParser;
import hxdtl.DtlInterpreter;

class Test
{
	var templatesPath: String;
	var interpreter: DtlInterpreter;
	var parser: DtlParser;

	public function new(templatesPath: String)
	{
		this.interpreter = new DtlInterpreter();
		this.parser = new DtlParser();
		this.templatesPath = templatesPath;
	}

	static function main()
	{
		trace("hxDtl - Haxe implmentation of Django Template Language");

		var test = new Test("test/templates/");
		test.run();
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

	function run()
	{
		var context: Map<String, Dynamic> = map({
			Country: "Ukraine",
			Name: "Bohdan Makohin",
			Year: 2013,
			Exchange: map({
				rur: ["eur" => 0.025, "usd" => 0.032],
				uah: ["usd" => 0.123, "eur"=> 0.095]
			})
		});

		var files = sys.FileSystem.readDirectory(templatesPath);
		for(file in files)
		{
			trace("[File] " + file);
			trace(renderFromInput(sys.io.File.read(templatesPath + file), context));
		}
	}

	function renderFromInput(input: haxe.io.Input, context): String
	{
		var ast = parser.parse(input);
		return interpreter.run(ast, context);
	}
}