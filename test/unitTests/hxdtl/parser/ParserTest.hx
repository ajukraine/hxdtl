package hxdtl.parser;

import massive.munit.Assert;
import org.hamcrest.MatchersBase;

import hxdtl.parser.Ast;

class ParserTest extends MatchersBase
{
	var parser: Parser;

	public function new()
	{
		super();
	}

	@BeforeClass
	public function beforeClass()
	{
		parser = new Parser();
	}

	@Test
	public function test_parse_text(): Void
	{
		test_ast("Some text2",
			[Text("Some text2")]);

		test_ast("Bad bracket {",
			[Text("Bad bracket {")]);
	}

	@Test
	public function test_if_tag(): Void
	{
		test_ast("{% if Last %} {% endif %}",
			[If(NullOp(Variable("Last")), [Text(" ")])]);

		test_ast("{% if Last >= _Min %}{% elif First < _Max %} Bla {% else %} {{ Result }} {% endif %}",
			[IfElse(BinOp(GreaterOrEqual, Variable("Last"), Variable("_Min")),
				[],
				[IfElse(BinOp(Less, Variable("First"), Variable("_Max")),
					[Text(" Bla ")],
					[Text(" "), Variable("Result"), Text(" ")]
				)]
			)]
		);
	}

	function test_ast<T>(input: String, expected: Array<Expr>): Void
	{
		var ast = parser.parse(new haxe.io.StringInput(input));

		assertThat(Std.string(ast), equalTo(Std.string(expected)));
	}
}