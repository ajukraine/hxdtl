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

		test_ast("Bad bracket {{ name }}",
			[Text("Bad bracket "), Variable("name")]);
	}

	function test_ast(input: String, expected: Array<AstExpr>): Void
	{
		var ast = parser.parse(new haxe.io.StringInput(input));
		assertThat(expected, equalTo(ast.body));
	}
}