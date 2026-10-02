#include "fbcunit.bi"

SUITE( fbc_tests.wstring_.direct_concat_init_dynamic )

	private function ret_pair( byref a as wstring, byref b as wstring ) as wstring
		return ((((a & b))))
	end function

	TEST( local_init_preserves_counted_value_and_parentheses )
		dim as wstring a = wchr( 65, 0, 66 )
		dim as wstring b = wchr( 67, 0, 68 )
		dim as wstring d = (((a))) & (((b)))
		CU_ASSERT_EQUAL( len( d ), 6 )
		CU_ASSERT_EQUAL( asc( d, 2 ), 0 )
		CU_ASSERT_EQUAL( asc( d, 4 ), 67 )
		CU_ASSERT_EQUAL( asc( d, 6 ), 68 )
	END_TEST

	TEST( return_init_preserves_same_source_and_embedded_nul )
		dim as wstring a = wchr( 80, 0, 81 )
		dim as wstring d = ret_pair( a, a )
		CU_ASSERT_EQUAL( len( d ), 6 )
		CU_ASSERT_EQUAL( asc( d, 2 ), 0 )
		CU_ASSERT_EQUAL( asc( d, 4 ), 80 )
		CU_ASSERT_EQUAL( asc( d, 6 ), 81 )
	END_TEST

END_SUITE
