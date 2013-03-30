import massive.munit.TestSuite;

import hxdtl.parser.LexerTest;
import hxdtl.parser.ParserTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(hxdtl.parser.LexerTest);
		add(hxdtl.parser.ParserTest);
	}
}
