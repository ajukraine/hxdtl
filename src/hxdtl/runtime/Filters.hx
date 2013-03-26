package hxdtl.runtime;

class Filters 
{
	var filtersMap: Map<String, Dynamic>;

	public function new()
	{
		filtersMap = [
			"length" => function (value: Array<Dynamic>) {
				return value.length;
			},
			"add" => function (value: Dynamic, argument: Dynamic) {

				return switch [Type.typeof(value), Type.typeof(argument)]
				{
					case [TInt, _] if (Std.parseInt(argument) != null): value + Std.parseInt(argument);
					case [TClass(Array), TClass(Array)]: value.concat(argument);
					case _: value + argument;
				}
			},
			"default" => function (value, defaultValue) {
				var isFalse = switch Type.typeof(value)
				{
					case TClass(String): value == "";
					case _: value == null;
				}

				return isFalse ? defaultValue : value;
			}
		];
	}

	public function getFilter(name)
	{
		return filtersMap.get(name);
	}
}