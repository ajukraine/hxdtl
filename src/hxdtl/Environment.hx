package hxdtl;

import hxdtl.Template;

typedef Configuration =
{
	/**	Templates base path */
	path: String,
	/** Should cache be used? */
	?useCache: Bool
}

class Environment
{
	var config: Configuration;
	var cache: Map<String, Template>;

	public function new(config: Configuration)
	{
		this.config = config;
		if (this.config.useCache == null)
			this.config.useCache = true;

		cache = new Map<String, Template>();
	}

	public function getTemplate(name): Template
	{
		return config.useCache
			? getCachedTemplate(name)
			: createTemplate(name);
	}

	function getCachedTemplate(name): Template
	{
		var tpl;

		if (cache.exists(name))
		{
			tpl = cache.get(name);
		}
		else
		{
			tpl = createTemplate(name);
			cache.set(name, tpl);
		}

		return tpl;
	}

	function createTemplate(name): Template
	{
		return new Template(sys.io.File.getContent('${config.path}/${name}'));
	}
}