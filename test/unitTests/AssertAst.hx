import massive.munit.Assert;
import hxdtl.parser.Ast;

class AssertAst
{
	public static function areEqual(expected: Array<AstExpr>, actual: Array<AstExpr>): Void
	{
		for(i in 0...expected.length)
		{
			if (!Type.enumEq(expected[i], actual[i]))
				Assert.fail('Value ${actual} was not equal to expected value ${expected}');
		}
	}
}