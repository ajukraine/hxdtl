# HxDTL

HxDTL is a Haxe implementation of Django Template Language.

## Status
There is no official release yet. However you can explore [Roadmap][Roadmap] to see the upcoming release details.

## Installation

### Haxelib release
```bash
$ haxelib install hxdtl
```

### Latest development version
```bash
$ git clone https://github.com/ajukraine/hxdtl.git
$ cd hxdtl
$ git submodule update --init
$ haxelib install mlib
$ haxe install.hxml
```

## Usage

Create template from string and render it:

```as3
import hxdtl.Template;

var tpl = new Template("
{% if Year > 2012 %}
	We have survived!
{% else %}
	Hey, {{ friend }}, are we dead?
{% endif %}
");
var data = { Year: 2013, friend: "Billy" };

trace(tpl.render(data));
```

Get template from file system and render it:

```as3
import hxdtl.Template;
import hxdtl.Environment;

var env = new Environment({
	path: "path/to/templates",
	useCache: true
});
var tpl = env.getTemplate("some_template.dtl");

trace(tpl.render({ Year: 2013, friend: "Billy" }));
```

[Roadmap]: https://github.com/ajukraine/hxdtl/wiki/Roadmap
