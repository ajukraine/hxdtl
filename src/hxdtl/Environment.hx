package hxdtl;

import hxdtl.Template;

typedef Configuration =
{
	/**	Templates base path */
	path: String
}

class Environment
{
	var config: Configuration;
	var cache: Map<String, Template>;

	public function new(config: Configuration)
	{
		this.config = config;
		cache = new Map<String, Template>();
	}

	public function getTemplate(name): Template
	{
		var tpl;

		if (cache.exists(name))
		{
			tpl = cache.get(name);
		}
		else
		{
			tpl = new Template(sys.io.File.getContent('${config.path}/${name}'));
			cache.set(name, tpl);
		}

		return tpl;
	}
}