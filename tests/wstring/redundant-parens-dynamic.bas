#include "fbcunit.bi"

SUITE( fbc_tests.wstring_.redundant_parens_dynamic )

	private sub f0( byref d as wstring, byref a as wstring, byref b as wstring )
		d = a & b
	end sub

	private sub f1( byref d as wstring, byref a as wstring, byref b as wstring )
		d = (a & b)
	end sub

	private sub f2( byref d as wstring, byref a as wstring, byref b as wstring )
		d = ((a & b))
	end sub

	private sub f4( byref d as wstring, byref a as wstring, byref b as wstring )
		d = ((((a & b))))
	end sub

	private sub f8( byref d as wstring, byref a as wstring, byref b as wstring )
		d = ((((((((a & b))))))))
	end sub

	private sub f_operands( byref d as wstring, byref a as wstring, byref b as wstring )
		d = (((a))) & (((b)))
	end sub

	private sub check_equal( byref got as wstring, byref expected as wstring )
		CU_ASSERT_EQUAL( len( got ), len( expected ) )
		if len( got ) = len( expected ) then
			for i as integer = 1 to len( expected )
				CU_ASSERT_EQUAL( asc( got, i ), asc( expected, i ) )
			next
		end if
	end sub

	TEST( redundant_parentheses_preserve_value_and_embedded_nul )
		dim as wstring a = wchr( 65, 0, 66 )
		dim as wstring b = wchr( 67, 0, 68 )
		dim as wstring d
		dim as wstring expected = wchr( 65, 0, 66, 67, 0, 68 )

		f0( d, a, b ): check_equal( d, expected )
		f1( d, a, b ): check_equal( d, expected )
		f2( d, a, b ): check_equal( d, expected )
		f4( d, a, b ): check_equal( d, expected )
		f8( d, a, b ): check_equal( d, expected )
		f_operands( d, a, b ): check_equal( d, expected )
	END_TEST

	TEST( redundant_parentheses_preserve_rhs_alias )
		dim as wstring a = wchr( 70, 0, 71 )
		dim as wstring d = wchr( 72, 0, 73 )
		dim as wstring expected = wchr( 70, 0, 71, 72, 0, 73 )
		f8( d, a, d )
		check_equal( d, expected )
	END_TEST

	TEST( redundant_parentheses_preserve_all_alias )
		dim as wstring d = wchr( 80, 0, 81 )
		dim as wstring expected = wchr( 80, 0, 81, 80, 0, 81 )
		f8( d, d, d )
		check_equal( d, expected )
	END_TEST

END_SUITE
