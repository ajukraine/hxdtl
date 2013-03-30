package hxdtl.parser;

import massive.munit.Assert;
import AssertAst;

import hxdtl.parser.Parser;
import hxdtl.parser.Ast;

class ParserTest
{
	var parser: Parser;

	public function new()
	{
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

		test_ast("Bad bracket {{ name2 }}",
			[Text("Bad bracket "), Variable("name2")]);
	}

	function test_ast(input: String, expected: Array<AstExpr>): Void
	{
		var ast = parser.parse(new haxe.io.StringInput(input));
		AssertAst.areEqual(expected, ast.body);
	}
}