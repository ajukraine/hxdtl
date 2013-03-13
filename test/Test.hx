import haxe.io.StringInput;
import hxdtl.DtlParser;
import hxdtl.DtlInterpreter;

class Test
{
	var templatesPath: String;
	var interpreter: DtlInterpreter;
	var parser: DtlParser;
	var tests: Array<Void -> Map<String, Dynamic>>;

	public function new(
		templatesPath: String,
		tests: Array<Void -> Map<String, Dynamic>>)
	{
		this.interpreter = new DtlInterpreter();
		this.parser = new DtlParser();
		this.templatesPath = templatesPath;
		this.tests = tests;
	}

	static function main()
	{
		trace("hxDtl - Haxe implmentation of Django Template Language");

		var test = new Test("test/templates/", [
			test_varaible,
			test_if
		]);

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

	static function test_varaible(): Map<String, Dynamic>
	{
		return [
			"variable_basic" => {
				Name: "Bohdan Makohin",
				Country: "Ukraine"
			},
			"variable_attributes" => {
				Exchange: map({
					rur: ["eur" => 0.025, "usd" => 0.032],
					uah: ["usd" => 0.123, "eur"=> 0.095]
				})
			}
		];
	}

	static function test_if(): Map<String, Dynamic>
	{
		return [
			"tag_if" => {
				Year: 2013,
				Dialog: map({
					Jack: "Is it a future, bro'?",
					Raul: "God dammit, no!"
				})
			},
			"tag_if_else" => {
				Year: 2002,
				Count: 12
			}/*,
			"tag_if_elif" => {
				Year: 2013,
				Count: 12
			}
			*/
		];
	}

	function run()
	{
		for(test in tests)
		{
			var testCases = test();

			for(testName in testCases.keys())
			{
				runTest(testName, testCases.get(testName));
			}
		}
	}

	function runTest(name: String, context)
	{
		trace('[Test] ${name}');
		trace(renderFromInput(sys.io.File.read('${templatesPath}${name}.dtl'), map(context)));
	}

	function renderFromInput(input: haxe.io.Input, context): String
	{
		var ast = parser.parse(input);
		return interpreter.run(ast, context);
	}
}