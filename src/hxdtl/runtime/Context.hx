package hxdtl.runtime;

import haxe.ds.StringMap;

class Context
{
	var obj: Dynamic;
	var cache: StringMap<Dynamic>;

	public function new<T>(?obj: T)
	{
		this.obj = obj;
		cache = new StringMap<Dynamic>();
	}

	public function get<T>(key: String): T
	{
		if (!cache.exists(key))
		{
			var value = lookup(key);
			if (value != null)
				cache.set(key, value);
		}

		return cache.get(key);
	}

	public function subContext(key: String)
	{
		return new Context(get(key));
	}

	public function set(key, value)
	{
		cache.set(key, value);
	}

	public function clone(): Context
	{
		return new Context(obj);
	}

	function lookup<T>(key): Null<T>
	{
		if (Reflect.hasField(obj, key))
		{
			return Reflect.field(obj, key);
		}
		else
		{
			return switch(Type.typeof(obj))
			{
				case TClass(StringMap): cast(obj, StringMap<Dynamic>).get(key);
				case _: null;
			}
		}
	}
}