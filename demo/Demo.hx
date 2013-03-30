import haxe.io.StringInput;
import hxdtl.Environment;

using Lambda;

class Demo
{
	var environment: Environment;
	var demos: Array<Void -> Map<String, Dynamic>>;

	public function new(
		templatesPath: String,
		demos: Array<Void -> Map<String, Dynamic>>)
	{
		this.demos = demos;

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

		var demo = new Demo("templates", [
			demo_varaible,
			demo_if,
			demo_for,
			demo_comment,
			demo_filter
		]);
		
		demo.run();

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

	static function demo_varaible(): Map<String, Dynamic>
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

	static function demo_if(): Map<String, Dynamic>
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

	static function demo_for(): Map<String, Dynamic>
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

	static function demo_comment(): Map<String, Dynamic>
	{
		return [
			"tag_comment" => {},
			"comment" => {}
		];
	}

	static function demo_filter(): Map<String, Dynamic>
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
		for(demo in demos)
		{
			var demoCases = demo();

			for(demoName in demoCases.keys())
			{
				rundemo(demoName, demoCases.get(demoName));
			}
		}
	}

	function rundemo(name: String, context)
	{
		trace('[Demo] ${name}');

		var tpl = environment.getTemplate('${name}.dtl');
		trace(tpl.render(context));
	}
}