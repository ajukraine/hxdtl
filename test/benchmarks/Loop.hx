import hxdtl.Environment;
import hxdtl.Template;
import haxe.Timer;


class Loop
{
	public static function main()
	{
		var loop = new Loop();
		loop.run();
	}

	public function new()
	{
	}

	public function run()
	{
		Timer.measure(function () {
			var envCache = new Environment({
				path: "demo/templates",
				useCache: true
			});

			for(i in 0...1000)
			{
				runWithEnvironment(envCache);
			}
		});

		Timer.measure(function() {
			var envNoCache = new Environment({
				path: "demo/templates",
				useCache: false
			});

			for(i in 0...1000)
			{
				runWithEnvironment(envNoCache);
			}
		});

		Timer.measure(function() {
			for(i in 0...1000)
			{
				runFromString();
			}
		});
	}

	function runWithEnvironment(env)
	{
		env.getTemplate("tag_if.dtl").render({
			Year: 2013,
			Dialog: {
				Jack: "Is it a future, bro'?",
				Raul: "God dammit, no!"
			}
		});
	}

	function runFromString()
	{
		new Template
("<h3>Brungilda's saga</h3>

{% if Year > 2011 %}Jack: Yeah!!! I've survided!
	{% if Year > 2012 %}
Jack: Is it a future, bro'?
		{% if Year < 2006 %}
DiCaprio: It's an e*ception...
		{% endif %}
	{% endif %}
{% endif %}

{% if Year < 2015 %}Raul: {{ Dialog.Raul }}{% endif %}")
		.render({
			Year: 2013,
			Dialog: {
				Jack: "Is it a future, bro'?",
				Raul: "God dammit, no!"
			}
		});
	}
}