'' '@' on dynamic bare WSTRING must yield the WCHAR data pointer
'' (same as STRPTR) for every storage kind, while VARPTR keeps
'' returning the descriptor address.  Fixed WSTRING * N keeps raw
'' buffer semantics for both.
#include "fbcunit.bi"
#include once "chk-wstring.bi"

Type T
	f As WString = "field"
End Type

Dim Shared g As WString = "global"

Declare Function ProbeW( ByVal p As Const WString Ptr ) As Integer
Declare Sub CheckByref( ByRef r As WString )

SUITE( fbc_tests.wstring_.addrof_dynamic_ )

	TEST( global_var )
		Dim pd As Any Ptr = StrPtr( g )  '' data pointer
		Dim pa As Any Ptr = @g           '' must be the data pointer
		Dim pv As Any Ptr = VarPtr( g )  '' descriptor address
		CU_ASSERT( pa = pd )
		CU_ASSERT( pv <> pd )
		'' the descriptor's first field holds the data pointer
		CU_ASSERT( *CPtr( WString Ptr Ptr, pv ) = pd )
		'' data is really reachable through @g
		CU_ASSERT( *CPtr( WString Ptr, pa ) = "global" )
	END_TEST

	TEST( local_var )
		Dim s As WString = "local"
		Dim pd As Any Ptr = StrPtr( s )
		Dim pa As Any Ptr = @s
		Dim pv As Any Ptr = VarPtr( s )
		CU_ASSERT( pa = pd )
		CU_ASSERT( pv <> pd )
		CU_ASSERT( *CPtr( WString Ptr Ptr, pv ) = pd )
		CU_ASSERT( s[0] = Asc( "l" ) )
	END_TEST

	TEST( static_local_var )
		Static s As WString = "static"
		Dim pd As Any Ptr = StrPtr( s )
		Dim pa As Any Ptr = @s
		Dim pv As Any Ptr = VarPtr( s )
		CU_ASSERT( pa = pd )
		CU_ASSERT( pv <> pd )
		CU_ASSERT( *CPtr( WString Ptr Ptr, pv ) = pd )
	END_TEST

	TEST( udt_field )
		Dim u As T
		Dim pd As Any Ptr = StrPtr( u.f )
		Dim pa As Any Ptr = @u.f
		Dim pv As Any Ptr = VarPtr( u.f )
		CU_ASSERT( pa = pd )
		CU_ASSERT( pv <> pd )
		CU_ASSERT( u.f = "field" )
	END_TEST

	TEST( static_array_element )
		Dim arr(0 To 2) As WString = { "a0", "a1", "a2" }
		Dim pd As Any Ptr = StrPtr( arr(1) )
		Dim pa As Any Ptr = @arr(1)
		Dim pv As Any Ptr = VarPtr( arr(1) )
		CU_ASSERT( pa = pd )
		CU_ASSERT( pv <> pd )
		CU_ASSERT( arr(1) = "a1" )
	END_TEST

	TEST( dynamic_array_element )
		Dim dyn(Any) As WString
		Redim dyn(0 To 1)
		dyn(1) = "d1"
		Dim pd As Any Ptr = StrPtr( dyn(1) )
		Dim pa As Any Ptr = @dyn(1)
		Dim pv As Any Ptr = VarPtr( dyn(1) )
		CU_ASSERT( pa = pd )
		CU_ASSERT( pv <> pd )
		CU_ASSERT( dyn(1) = "d1" )
	END_TEST

	TEST( byref_param )
		g = "global"
		CheckByref( g )
	END_TEST

	TEST( fixed_wstring_unchanged )
		Dim fixed As WString * 16 = "fixed"
		'' no descriptor: @, VarPtr and StrPtr are all the raw buffer
		CU_ASSERT( @fixed = StrPtr( fixed ) )
		CU_ASSERT( VarPtr( fixed ) = StrPtr( fixed ) )
		CU_ASSERT( @fixed = VarPtr( fixed ) )
		CU_ASSERT( fixed = "fixed" )
	END_TEST

	TEST( mutable_data_through_addrof )
		g = "mutate-me"
		Dim pw As WString Ptr = @g
		CU_ASSERT( *pw = "mutate-me" )
		'' *pw is the raw WCHAR boundary - write the same length so the
		'' descriptor's length stays consistent with the buffer content
		*pw = "mutated!!"
		CU_ASSERT( g = "mutated!!" )
	END_TEST

	TEST( concat_and_len_after_addrof )
		Dim h As WString = "abc"
		h &= "def"
		CU_ASSERT( h = "abcdef" )
		CU_ASSERT( Len( h ) = 6 )
		CU_ASSERT( CUInt( @h ) = CUInt( StrPtr( h ) ) )
		CU_ASSERT( CUInt( @h ) <> CUInt( VarPtr( h ) ) )
	END_TEST

	TEST( pass_addrof_to_wchar_ptr_param )
		'' same call shape as PathFileExistsW(@FileName1): a dynamic
		'' WSTRING's @ must be accepted as a const WCHAR ptr data pointer
		Dim s As WString = "C:\no-such-file-xyz.txt"
		CU_ASSERT( ProbeW( s ) = 23 )
		CU_ASSERT( ProbeW( @s ) = 23 )
		CU_ASSERT( ProbeW( StrPtr( s ) ) = 23 )
	END_TEST

END_SUITE

Private Function ProbeW( ByVal p As Const WString Ptr ) As Integer
	'' a stand-in for an external API taking a WCHAR data pointer
	If( p = 0 ) Then
		Return -1
	End If
	Return Len( *p )
End Function

Private Sub CheckByref( ByRef r As WString )
	Dim pd As Any Ptr = StrPtr( r )
	Dim pa As Any Ptr = @r
	Dim pv As Any Ptr = VarPtr( r )
	CU_ASSERT( pa = pd )
	CU_ASSERT( pv <> pd )
	CU_ASSERT( *CPtr( WString Ptr Ptr, pv ) = pd )
End Sub
