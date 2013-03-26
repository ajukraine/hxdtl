import haxe.io.StringInput;
import hxdtl.Environment;

using Lambda;

class Test
{
	var environment: Environment;
	var tests: Array<Void -> Map<String, Dynamic>>;

	public function new(
		templatesPath: String,
		tests: Array<Void -> Map<String, Dynamic>>)
	{
		this.tests = tests;

		environment = new Environment({
			path: templatesPath
		});
	}

	static function main()
	{
		var isRunningAsHxmlCmd = Sys.args().has("-hxml_cmd");
		
		var flush: Void -> Void = function () {};
		if (isRunningAsHxmlCmd)
			flush = setupCustomTrace();

		trace("hxDtl - Haxe implmentation of Django Template Language");

		var test = new Test("test/templates", [
			test_varaible,
			test_if,
			test_for,
			test_comment,
			test_filter
		]);
		
		test.run();

		if (isRunningAsHxmlCmd)
			flush();
	}

	static function setupCustomTrace()
	{
		var buffer = new String("");

		haxe.Log.trace = function (v, ?infos)
		{
			buffer += v + '\r';
			buffer = buffer.substr(-900);
		};

		return function () { Sys.print(buffer); };
	}

	static function test_varaible(): Map<String, Dynamic>
	{
		return [
			"variable_basic" => {
				Name: "Bohdan Makohin",
				Country: "Ukraine"
			},
			"variable_attributes" => {
				Exchange: {
					date: "17 March",
					rur: ["eur" => 0.025, "usd" => 0.032],
					uah: ["usd" => 0.123, "eur"=> 0.095]
				}
			}
		];
	}

	static function test_if(): Map<String, Dynamic>
	{
		return [
			"tag_if" => {
				Year: 2013,
				Dialog: {
					Jack: "Is it a future, bro'?",
					Raul: "God dammit, no!"
				}
			},
			"tag_if_else" => {
				Year: 2002,
				Count: 12
			},
			"tag_if_elif" => {
				Year: 2013,
				Count: 12
			},
			"tag_if_boolean" => {
				Count: 20,
				Max: 25,
				Zero: 0
			}
		];
	}

	static function test_for(): Map<String, Dynamic>
	{
		return [
			"tag_for" => {
				Developers: [
					{name: "Sebastian Fettel", status: "Senior", salary: 2000},
					{name: "Mark Webber", status: "Intermediate", salary: 1800},
					{name: "Niko Rosberg", status: "Intermediate", salary: 1500}
				]
			}
		];
	}

	static function test_comment(): Map<String, Dynamic>
	{
		return [
			"tag_comment" => {},
			"comment" => {}
		];
	}

	static function test_filter(): Map<String, Dynamic>
	{
		return [
			"filter_basic" => {
				supported_filters: ["add", "length", "default"]
			},
			"tag_filter" => {
				supported_filters: ["add", "length", "default"]
			}
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

		var tpl = environment.getTemplate('${name}.dtl');
		trace(tpl.render(context));
	}
}