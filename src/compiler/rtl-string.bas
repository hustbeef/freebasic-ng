'' intrinsic runtime lib string functions (MID, LEFT, STR, VAL, HEX, ...)
''
'' chng: oct/2004 written [v1ctor]


#include once "fb.bi"
#include once "fbint.bi"
#include once "ast.bi"
#include once "rtl.bi"

	dim shared as FB_RTL_PROCDEF funcdata( 0 to ... ) = _
	{ _
		/' function fb_StrInit( byref dst as any, byval dst_len as const integer, _
				byref src as const any, byval src_len as const integer, _
				byval fillrem as const long = 1 ) as string '/ _
		( _
			@FB_RTL_STRINIT, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			5, _
			{ _
				( FB_DATATYPE_VOID, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_VOID ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, TRUE, 1 ) _
			} _
		), _
		/' function fb_WstrAssignToA_Init( byref dst as any, byval dst_len as const integer, _
				byval src as const wstring ptr, byval fillrem as const integer ) as string '/ _
		( _
			@FB_RTL_WSTRASSIGNAW_INIT, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			4, _
			{ _
				( FB_DATATYPE_VOID, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_StrAssign( byref dst as any, byval dst_len as const integer, _
				byref src as const any, byval src_len as const integer, _
				byval fillrem as const long = 1 ) as string '/ _
		( _
			@FB_RTL_STRASSIGN, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			5, _
			{ _
				( FB_DATATYPE_VOID, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_VOID ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, TRUE, 1 ) _
			} _
		), _
		/' function fb_WstrAssign( byval dst as wstring ptr, byval dst_len as const integer, _
				byval src as const wstring ptr) as wstring ptr '/ _
		( _
			@FB_RTL_WSTRASSIGN, NULL, _
			typeAddrOf( FB_DATATYPE_WCHAR ), FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( typeAddrOf( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynDelete( byref dst as wstring ) '/ _
		( _
			@FB_RTL_DWSTRDELETE, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynArrayDtor cdecl( byval this_ as any ptr ) '/ _
		( _
			@FB_RTL_DWSTRARRAYDTOR, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_CDECL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeAddrOf( FB_DATATYPE_VOID ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynAssign( byref dst as wstring, byref src as const wstring ) '/ _
		( _
			@FB_RTL_DWSTRASSIGN, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynInit( byref dst as wstring, byref src as const wstring ) '/ _
		( _
			@FB_RTL_DWSTRINIT, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynInitW( byref dst as wstring, byval src as const wchar ptr ) '/ _
		( _
			@FB_RTL_DWSTRINITW, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynInitWN( byref dst as wstring, byval src as const wchar ptr, byval n as integer ) '/ _
		( _
			@FB_RTL_DWSTRINITWN, NULL, FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 3, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynInitA( byref dst as wstring, byref src as const any, byval src_size as integer ) '/ _
		( _
			@FB_RTL_DWSTRINITA, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_VOID ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynMoveInit( byref dst as wstring, byref src as wstring ) '/ _
		( _
			@FB_RTL_DWSTRMOVEINIT, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynMoveAssign( byref dst as wstring, byref src as wstring ) '/ _
		( _
			@FB_RTL_DWSTRMOVEASSIGN, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynConcatAssignPair( byref dst as wstring, byref lhs as const wstring, byref rhs as const wstring ) '/ _
		( _
			@FB_RTL_DWSTRCATPAIR, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynConcatInitPair( byref dst as wstring, byref lhs as const wstring, byref rhs as const wstring ) '/ _
		( _
			@FB_RTL_DWSTRCATINITPAIR, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynCopyToW( byval dst as wchar ptr, byval dst_chars as integer, byref src as const wstring ) '/ _
		( _
			@FB_RTL_DWSTRCOPYTOW, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( typeAddrOf( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYVAL, FALSE ), _
				( FB_DATATYPE_INTEGER, FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynCopyToA( byref dst as any, byval dst_size as integer, byref src as const wstring ) '/ _
		( _
			@FB_RTL_DWSTRCOPYTOA, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( FB_DATATYPE_VOID, FB_PARAMMODE_BYREF, FALSE ), _
				( FB_DATATYPE_INTEGER, FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynAssignW( byref dst as wstring, byval src as const wchar ptr ) '/ _
		( _
			@FB_RTL_DWSTRASSIGNW, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynAssignWN( byref dst as wstring, byval src as const wchar ptr, byval n as integer ) '/ _
		( _
			@FB_RTL_DWSTRASSIGNWN, NULL, FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 3, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynAssignA( byref dst as wstring, byref src as const any, byval src_size as integer ) '/ _
		( _
			@FB_RTL_DWSTRASSIGNA, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_VOID ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrDynLen( byref src as const wstring ) as integer '/ _
		( _
			@FB_RTL_DWSTRLEN, NULL, _
			FB_DATATYPE_INTEGER, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrDynToWstr( byref src as const wstring ) as wstring '/ _
		( _
			@FB_RTL_DWSTRTOWSTR, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrDynToStr( byref src as const wstring ) as string '/ _
		( _
			@FB_RTL_DWSTRTOSTR, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynConcatAssign( byref dst as wstring, byref src as const wstring ) '/ _
		( _
			@FB_RTL_DWSTRCAT, NULL, FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 2, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynConcatAssignW( byref dst as wstring, byval src as const wchar ptr ) '/ _
		( _
			@FB_RTL_DWSTRCATW, NULL, FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 2, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynConcatAssignWN( byref dst as wstring, byval src as const wchar ptr, byval n as integer ) '/ _
		( _
			@FB_RTL_DWSTRCATWN, NULL, FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 3, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynConcatAssignA( byref dst as wstring, byref src as const any, byval src_size as integer ) '/ _
		( _
			@FB_RTL_DWSTRCATA, NULL, FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 3, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_VOID ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrDynAsc( byref src as const wstring, byval pos as integer ) as ulong '/ _
		( _
			@FB_RTL_DWSTRASC, NULL, FB_DATATYPE_ULONG, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, TRUE, 1 ) _
			} _
		), _
		/' function fb_WstrDynCompare( byref lhs as const wstring, byref rhs as const wstring ) as integer '/ _
		( _
			@FB_RTL_DWSTRCOMPARE, NULL, FB_DATATYPE_LONG, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrDynInstr( byval start as integer, byref src as const wstring, byref patt as const wstring ) as integer '/ _
		( _
			@FB_RTL_DWSTRINSTR, NULL, FB_DATATYPE_INTEGER, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 3, _
			{ _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrDynInstrAny( byval start as integer, byref src as const wstring, byref patt as const wstring ) as integer '/ _
		( _
			@FB_RTL_DWSTRINSTRANY, NULL, FB_DATATYPE_INTEGER, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 3, _
			{ _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrDynInstrRev( byref src as const wstring, byref patt as const wstring, byval start as integer ) as integer '/ _
		( _
			@FB_RTL_DWSTRINSTRREV, NULL, FB_DATATYPE_INTEGER, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 3, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrDynInstrRevAny( byref src as const wstring, byref patt as const wstring, byval start as integer ) as integer '/ _
		( _
			@FB_RTL_DWSTRINSTRREVANY, NULL, FB_DATATYPE_INTEGER, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 3, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynAssignMid( byref dst as wstring, byval start as integer, byval chars as integer, byref src as const wstring ) '/ _
		( _
			@FB_RTL_DWSTRMIDASSIGN, NULL, FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 4, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrDynMidResult( byref src as const wstring, byval start as integer, byval chars as integer ) as wstring '/ _
		( _
			@FB_RTL_DWSTRMID, NULL, FB_DATATYPE_WSTRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 3, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrDynCaseResult( byref src as const wstring, byval mode as long, byval to_lower as long ) as wstring '/ _
		( _
			@FB_RTL_DWSTRCASE, NULL, FB_DATATYPE_WSTRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 3, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrDynTrimSimpleResult( byref src as const wstring, byval side as long ) as wstring '/ _
		( _
			@FB_RTL_DWSTRTRIMSIMPLE, NULL, FB_DATATYPE_WSTRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrDynTrimPatternResult( byref src as const wstring, byref patt as const wstring, byval side as long, byval is_any as long ) as wstring '/ _
		( _
			@FB_RTL_DWSTRTRIMPATTERN, NULL, FB_DATATYPE_WSTRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 4, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_WstrDynLRSet( byref dst as wstring, byref src as const wstring, byval is_rset as long ) '/ _
		( _
			@"fb_WstrDynLRSet", NULL, FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 3, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrDynFillResult( byval chars as integer, byval c as ulong ) as wstring '/ _
		( _
			@FB_RTL_DWSTRFILL, NULL, FB_DATATYPE_WSTRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_ULONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrDynFillWstrResult( byval chars as integer, byref src as const wstring ) as wstring '/ _
		( _
			@FB_RTL_DWSTRFILLWSTR, NULL, FB_DATATYPE_WSTRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrDynChrResult cdecl( byval args as long, ... ) as wstring '/ _
		( _
			@FB_RTL_DWSTRCHR, NULL, FB_DATATYPE_WSTRING, FB_FUNCMODE_CDECL, _
			NULL, FB_RTL_OPT_NONE, 2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ), _
				( FB_DATATYPE_INVALID, FB_PARAMMODE_VARARG, FALSE ) _
			} _
		), _
		/' function fb_WstrDynAllocTempResult( byref src as wstring ) as wstring '/ _
		( _
			@FB_RTL_DWSTRTEMPRESULT, NULL, FB_DATATYPE_WSTRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, 1, _
			{ _
				( FB_DATATYPE_WSTRING, FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrAssignFromA( byval dst as wstring ptr, byval dst_len as const integer, _
				byref src as const any, byval src_len as const integer ) as wstring ptr '/ _
		( _
			@FB_RTL_WSTRASSIGNWA, NULL, _
			typeAddrOf( FB_DATATYPE_WCHAR ), FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			4, _
			{ _
				( typeAddrOf( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_VOID ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrAssignToA( byref dst as any, byval dst_len as const integer, _
				byval src as const wstring ptr, byval fillrem as const long ) as string '/ _
		( _
			@FB_RTL_WSTRASSIGNAW, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			4, _
			{ _
				( FB_DATATYPE_VOID, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_StrDelete( byref str as const string ) '/ _
		( _
			@FB_RTL_STRDELETE, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_hStrDelTemp( byref str as const string ) as long '/ _
		( _
			@FB_RTL_HSTRDELTEMP, NULL, _
			FB_DATATYPE_LONG, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' sub fb_WstrDelete( byval str as const wstring ptr ) '/ _
		( _
			@FB_RTL_WSTRDELETE, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_StrConcat( byref dst as string, _
				byref str1 as const any, byval str1_size as const integer, _
				byref str2 as const any, byval str2_size as const integer ) as string '/ _
		( _
			@FB_RTL_STRCONCAT, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			5, _
			{ _
				( FB_DATATYPE_STRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_VOID ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_VOID ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_StrConcatByref(
				byref str1 as const any, byval str1_size as const integer, _
				byref str2 as const any, byval str2_size as const integer, _
				byval fillrem as const long = 1 ) as string '/ _
		( _
			@FB_RTL_STRCONCATBYREF, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			5, _
			{ _
				( FB_DATATYPE_VOID, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_VOID ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, TRUE, 1 ) _
			} _
		), _
		/' function fb_WstrConcat( byval str1 as const wstring ptr, byval str2 as const wstring ptr ) as wstring '/ _
		( _
			@FB_RTL_WSTRCONCAT, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrConcatWA( byval str1 as const wstring ptr, _
				byref str2 as const any, byval str2_size as const integer ) as wstring '/ _
		( _
			@FB_RTL_WSTRCONCATWA, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_VOID ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrConcatAW( byref str1 as const any, byval str1_size as const integer, _
				byval str2 as const wstring ptr ) as wstring '/ _
		( _
			@FB_RTL_WSTRCONCATAW, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( typeSetIsConst( FB_DATATYPE_VOID ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_StrCompare( byref str1 as const any, byval str1_size as const integer, _
				byref str2 as const any, byval str2_size as const integer ) as long '/ _
		( _
			@FB_RTL_STRCOMPARE, NULL, _
			FB_DATATYPE_LONG, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			4, _
			{ _
				( typeSetIsConst( FB_DATATYPE_VOID ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_VOID ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrCompare( byval str1 as const wstring ptr, byval str2 as const wstring ptr ) as long '/ _
		( _
			@FB_RTL_WSTRCOMPARE, NULL, _
			FB_DATATYPE_LONG, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_StrConcatAssign( byref dst as any, byval dst_size as const integer, _
				byref src as const any, byval src_len as const integer, _
				byval fillrem as const long = 1 ) as string '/ _
		( _
			@FB_RTL_STRCONCATASSIGN, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			5, _
			{ _
				( FB_DATATYPE_VOID, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_VOID ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, TRUE, 1 ) _
			} _
		), _
		/' function fb_WstrConcatAssign( byval dst as wstring ptr, byval dst_chars as const integer, _
				byval src as const wstring ptr ) as wstring ptr '/ _
		( _
			@FB_RTL_WSTRCONCATASSIGN, NULL, _
			typeAddrOf( FB_DATATYPE_WCHAR ), FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( typeAddrOf( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_StrAllocTempResult( byref str as const string ) as string '/ _
		( _
			@FB_RTL_STRALLOCTEMPRES, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_StrAllocTempDescF( byref str as const any, byval str_size as const integer ) as string '/ _
		( _
			@FB_RTL_STRALLOCTEMPDESCF, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_VOID ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_StrAllocTempDescZ( byval str as const zstring ptr ) as string '/ _
		( _
			@FB_RTL_STRALLOCTEMPDESCZ, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_CHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_StrAllocTempDescZEx( byval str as const zstring ptr, byval len as const integer ) as string '/ _
		( _
			@FB_RTL_STRALLOCTEMPDESCZEX, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_CHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrAlloc( byval chars as const integer ) as wstring ptr '/ _
		( _
			@FB_RTL_WSTRALLOC, NULL, _
			typeAddrOf( FB_DATATYPE_WCHAR ), FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_BoolToStr( byval num as const boolean ) as string '/ _
		( _
			@FB_RTL_BOOL2STR, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_BOOLEAN ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_IntToStr( byval num as const long ) as string '/ _
		( _
			@FB_RTL_INT2STR, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_IntToStrQB( byval num as const long ) as string '/ _
		( _
			@FB_RTL_INT2STR_QB, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_QBONLY, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_BoolToWstr( byval num as const boolean ) as wstring '/ _
		( _
			@FB_RTL_BOOL2WSTR, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_BOOLEAN ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_IntToWstr( byval num as const long ) as wstring '/ _
		( _
			@FB_RTL_INT2WSTR, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_UIntToStr( byval num as const ulong ) as string '/ _
		( _
			@FB_RTL_UINT2STR, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_UIntToStrQB( byval num as const ulong ) as string '/ _
		( _
			@FB_RTL_UINT2STR_QB, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_QBONLY, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_UIntToWstr( byval num as const ulong ) as wstring '/ _
		( _
			@FB_RTL_UINT2WSTR, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_LongintToStr( byval num as const longint ) as string '/ _
		( _
			@FB_RTL_LONGINT2STR, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_LONGINT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_LongintToStrQB( byval num as const longint ) as string '/ _
		( _
			@FB_RTL_LONGINT2STR_QB, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_QBONLY, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_LONGINT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_LongintToWstr( byval num as const longint ) as wstring '/ _
		( _
			@FB_RTL_LONGINT2WSTR, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_LONGINT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_ULongintToStr( byval num as const ulongint ) as string '/ _
		( _
			@FB_RTL_ULONGINT2STR, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONGINT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_ULongintToStrQB( byval num as const ulongint ) as string '/ _
		( _
			@FB_RTL_ULONGINT2STR_QB, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_QBONLY, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONGINT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_ULongintToWstr( byval num as const ulongint ) as wstring '/ _
		( _
			@FB_RTL_ULONGINT2WSTR, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONGINT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_FloatToStr( byval num as const single ) as string '/ _
		( _
			@FB_RTL_FLT2STR, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_SINGLE ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_FloatToStrQB( byval num as const single ) as string '/ _
		( _
			@FB_RTL_FLT2STR_QB, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_QBONLY, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_SINGLE ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_FloatToWstr( byval num as const single ) as wstring '/ _
		( _
			@FB_RTL_FLT2WSTR, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_SINGLE ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_DoubleToStr( byval num as const double ) as string '/ _
		( _
			@FB_RTL_DBL2STR, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_DOUBLE ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_DoubleToStrQB( byval num as const double ) as string '/ _
		( _
			@FB_RTL_DBL2STR_QB, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_QBONLY, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_DOUBLE ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_DoubleToWstr( byval num as const double ) as wstring '/ _
		( _
			@FB_RTL_DBL2WSTR, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_DOUBLE ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrToStr( byval str as const wstring ptr ) as string '/ _
		( _
			@FB_RTL_WSTR2STR, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_StrToWstr( byval str as const zstring ptr ) as wstring '/ _
		( _
			@FB_RTL_STR2WSTR, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_CHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_StrMid( byref str as const string, byval start as const integer, _
				byval len as const integer ) as string '/ _
		( _
			@FB_RTL_STRMID, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrMid( byval str as const wstring ptr, byval start as const integer, _
				byval len as const integer ) as wstring '/ _
		( _
			@FB_RTL_WSTRMID, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_StrAssignMid( byref dst as string, byval start as const integer, _
				byval len as const integer, byref src as const string ) '/ _
		( _
			@FB_RTL_STRASSIGNMID, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			4, _
			{ _
				( FB_DATATYPE_STRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' sub fb_WstrAssignMid ( byval dst as wstring ptr, byval dst_len as const integer, _
				byval start as const integer, byval len as const integer, _
				byval src as const wstring ptr ) '/ _
		( _
			@FB_RTL_WSTRASSIGNMID, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			5, _
			{ _
				( typeAddrOf( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_StrFill1( byval cnt as const integer, byval char as const long ) as string '/ _
		( _
			@FB_RTL_STRFILL1, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrFill1( byval chars as const integer, byval c as const long ) as wstring '/ _
		( _
			@FB_RTL_WSTRFILL1, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' fb_StrFill2( byval cnt as const integer, byref src as const string ) as string '/ _
		( _
			@FB_RTL_STRFILL2, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrFill2( byval cnt as const integer, byval src as const wstring ptr ) as wstring '/ _
		( _
			@FB_RTL_WSTRFILL2, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_StrLen( byref str as const any, byval str_size as const integer ) as integer '/ _
		( _
			@FB_RTL_STRLEN, NULL, _
			FB_DATATYPE_INTEGER, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_VOID ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrLen( byval str as const wstring ptr ) as integer '/ _
		( _
			@FB_RTL_WSTRLEN, NULL, _
			FB_DATATYPE_INTEGER, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_StrLset( byref dst as string, byref src as const string ) '/ _
		( _
			@FB_RTL_STRLSET, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( FB_DATATYPE_STRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' sub fb_StrLsetANA( byref dst as any, byval dst_len as const integer, _
				byref src as const any, byval src_len as const integer ) '/ _
		( _
			@FB_RTL_STRLSETANA, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( FB_DATATYPE_VOID, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' sub fb_WstrLset( byval dst as wstring ptr, byval src as const wstring ptr ) '/ _
		( _
			@FB_RTL_WSTRLSET, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeAddrOf( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_StrRset( byref dst as string, byref src as const string ) '/ _
		( _
			@FB_RTL_STRRSET, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( FB_DATATYPE_STRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' sub fb_StrRsetANA overload( byref dst as any, byval dst_len as const integer, _
				byref src as const any, byval src_len as const integer ) '/ _
		( _
			@FB_RTL_STRRSETANA, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER, _
			3, _
			{ _
				( FB_DATATYPE_VOID, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' sub fb_WstrRset( byval dst as wstring ptr, byval src as const wstring ptr ) '/ _
		( _
			@FB_RTL_WSTRRSET, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeAddrOf( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_ASC( byref str as const string, byval pos as const integer = 0 ) as ulong '/ _
		( _
			@FB_RTL_STRASC, NULL, _
			FB_DATATYPE_ULONG, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, TRUE, 0 ) _
			} _
		), _
		/' function fb_WstrAsc( byval str as const wstring ptr, byval pos as const integer = 0 ) as ulong '/ _
		( _
			@FB_RTL_WSTRASC, NULL, _
			FB_DATATYPE_ULONG, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, TRUE, 0 ) _
			} _
		), _
		/' function fb_CHR cdecl( byval args as const long, ... ) as string '/ _
		( _
			@FB_RTL_STRCHR, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_CDECL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ), _
				( FB_DATATYPE_INVALID, FB_PARAMMODE_VARARG, FALSE ) _
			} _
		), _
		/' function fb_WstrChr cdecl( byval args as const long, ... ) as wstring '/ _
		( _
			@FB_RTL_WSTRCHR, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_CDECL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ), _
				( FB_DATATYPE_INVALID, FB_PARAMMODE_VARARG, FALSE ) _
			} _
		), _
		/' function fb_StrInstr( byval start as const integer, byref src as const string, _
				byref patt as const string ) as integer '/ _
		( _
			@FB_RTL_STRINSTR, NULL, _
			FB_DATATYPE_INTEGER, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrInstr( byval start as const integer, byval src as const wstring ptr, _
				byval patt as const wstring ptr ) as integer '/ _
		( _
			@FB_RTL_WSTRINSTR, NULL, _
			FB_DATATYPE_INTEGER, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_StrInstrAny( byval start as const integer, byref src as const string, _
				byref pattern as const string ) as integer '/ _
		( _
			@FB_RTL_STRINSTRANY, NULL, _
			FB_DATATYPE_INTEGER, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrInstrAny( byval start as const integer, byval src as const wstring ptr, _
				byval pattern as const wstring ptr ) as integer '/ _
		( _
			@FB_RTL_WSTRINSTRANY, NULL, _
			FB_DATATYPE_INTEGER, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_StrInstrRev( byref src as const string, byref patt as const string, _
				byval start as const integer ) as integer '/ _
		( _
			@FB_RTL_STRINSTRREV, NULL, _
			FB_DATATYPE_INTEGER, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrInstrRev( byval src as const wstring ptr, byval patt as const wstring ptr, _
				byval start as const integer ) as integer '/ _
		( _
			@FB_RTL_WSTRINSTRREV, NULL, _
			FB_DATATYPE_INTEGER, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_StrInstrRevAny( byref src as const string, byref patt as const string, _
				byval start as const integer ) as integer '/ _
		( _
			@FB_RTL_STRINSTRREVANY, NULL, _
			FB_DATATYPE_INTEGER, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_WstrInstrRevAny( byval src as const wstring ptr, byval patt as const wstring ptr, _
				byval start as const integer ) as integer '/ _
		( _
			@FB_RTL_WSTRINSTRREVANY, NULL, _
			FB_DATATYPE_INTEGER, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			3, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_TRIM( byref str as const string ) as string '/ _
		( _
			@FB_RTL_STRTRIM, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrTrim( byval str as const wstring ptr ) as wstring '/ _
		( _
			@FB_RTL_WSTRTRIM, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_TrimAny( byref str as const string, byref pattern as const string ) as string '/ _
		( _
			@FB_RTL_STRTRIMANY, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrTrimAny( byval str as const wstring ptr, byval pattern as const wstring ptr ) as wstring '/ _
		( _
			@FB_RTL_WSTRTRIMANY, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_TrimEx( byref str as const string, byref pattern as const string ) as string '/ _
		( _
			@FB_RTL_STRTRIMEX, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrTrimEx( byval str as const wstring ptr, byval pattern as const wstring ptr ) as wstring '/ _
		( _
			@FB_RTL_WSTRTRIMEX, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_RTRIM( byref str as const string ) as string '/ _
		( _
			@FB_RTL_STRRTRIM, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrRTrim( byval str as const wstring ptr ) as wstring '/ _
		( _
			@FB_RTL_WSTRRTRIM, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_RTrimAny( byref str as const string, byref pattern as const string ) as string '/ _
		( _
			@FB_RTL_STRRTRIMANY, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrRTrimAny( byval str as const wstring ptr, byval pattern as const wstring ptr ) as wstring '/ _
		( _
			@FB_RTL_WSTRRTRIMANY, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_RTrimEx( byref str as const string, byref pattern as const string ) as string '/ _
		( _
			@FB_RTL_STRRTRIMEX, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrRTrimEx( byval str as const wstring ptr, byval pattern as const wstring ptr ) as wstring '/ _
		( _
			@FB_RTL_WSTRRTRIMEX, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_LTRIM( byref str as const string ) as string '/ _
		( _
			@FB_RTL_STRLTRIM, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrLTrim( byval str as const wstring ptr ) as wstring '/ _
		( _
			@FB_RTL_WSTRLTRIM, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_LTrimAny( byref str as const string, byref pattern as const string ) as string '/ _
		( _
			@FB_RTL_STRLTRIMANY, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrLTrimAny( byval str as const wstring ptr, byval pattern as const wstring ptr ) as wstring '/ _
		( _
			@FB_RTL_WSTRLTRIMANY, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_LTrimEx( byref str as const string, byref pattern as const string ) as string '/ _
		( _
			@FB_RTL_STRLTRIMEX, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_WstrLTrimEx( byval str as const wstring ptr, byval pattern as const wstring ptr ) as wstring '/ _
		( _
			@FB_RTL_WSTRLTRIMEX, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_WCHAR ) ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_StrSwap( byref str1 as any, byval size1 as const integer, byval fillrem1 as const long, _
				   byref str2 as any, byval size2 as const integer, byval fillrem2 as const long ) '/ _
		( _
			@FB_RTL_STRSWAP, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			6, _
			{ _
				( FB_DATATYPE_VOID, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ), _
				( FB_DATATYPE_VOID, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_WstrSwap( byval str1 as wstring ptr, byval size1 as const integer, _
				    byval str2 as wstring ptr, byval size2 as const integer ) '/ _
		( _
			@FB_RTL_WSTRSWAP, NULL, _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			4, _
			{ _
				( typeAddrOf( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeAddrOf( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function val overload( byref str as const string ) as double '/ _
		( _
			@FB_RTL_STR2DBL, @"fb_VAL", _
			FB_DATATYPE_DOUBLE, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function val overload( byref str as const wstring ) as double '/ _
		( _
			@FB_RTL_STR2DBL, @"fb_WstrVal", _
			FB_DATATYPE_DOUBLE, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function val overload( byref str as const native wstring ) as double '/ _
		( _
			@FB_RTL_STR2DBL, @"fb_WstrDynVal", _
			FB_DATATYPE_DOUBLE, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function valbool overload( byref str as const string ) as boolean '/ _
		( _
			@FB_RTL_STR2BOOL, NULL, _
			FB_DATATYPE_BOOLEAN, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function valbool overload( byref str as const wstring ) as boolean '/ _
		( _
			@FB_RTL_STR2BOOL, @"fb_WstrValBool", _
			FB_DATATYPE_BOOLEAN, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function valbool overload( byref str as const native wstring ) as boolean '/ _
		( _
			@FB_RTL_STR2BOOL, @"fb_WstrDynValBool", _
			FB_DATATYPE_BOOLEAN, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function valint overload( byref str as const string ) as long '/ _
		( _
			@FB_RTL_STR2INT, @"fb_VALINT", _
			FB_DATATYPE_LONG, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function valint overload( byref str as const wstring ) as long '/ _
		( _
			@FB_RTL_STR2INT, @"fb_WstrValInt", _
			FB_DATATYPE_LONG, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function valint overload( byref str as const native wstring ) as long '/ _
		( _
			@FB_RTL_STR2INT, @"fb_WstrDynValInt", _
			FB_DATATYPE_LONG, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function valuint overload( byref str as const string ) as ulong '/ _
		( _
			@FB_RTL_STR2UINT, @"fb_VALUINT", _
			FB_DATATYPE_ULONG, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function valuint overload( byref str as const wstring ) as ulong '/ _
		( _
			@FB_RTL_STR2UINT, @"fb_WstrValUInt", _
			FB_DATATYPE_ULONG, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function valuint overload( byref str as const native wstring ) as ulong '/ _
		( _
			@FB_RTL_STR2UINT, @"fb_WstrDynValUInt", _
			FB_DATATYPE_ULONG, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function vallng overload( byref str as const string ) as longint '/ _
		( _
			@FB_RTL_STR2LNG, @"fb_VALLNG", _
			FB_DATATYPE_LONGINT, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function vallng overload( byref str as const wstring ) as longint '/ _
		( _
			@FB_RTL_STR2LNG, @"fb_WstrValLng", _
			FB_DATATYPE_LONGINT, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function vallng overload( byref str as const native wstring ) as longint '/ _
		( _
			@FB_RTL_STR2LNG, @"fb_WstrDynValLng", _
			FB_DATATYPE_LONGINT, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function valulng overload( byref str as const string ) as ulongint '/ _
		( _
			@FB_RTL_STR2ULNG, @"fb_VALULNG", _
			FB_DATATYPE_ULONGINT, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function valulng overload( byref str as const wstring ) as ulongint '/ _
		( _
			@FB_RTL_STR2ULNG, @"fb_WstrValULng", _
			FB_DATATYPE_ULONGINT, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function valulng overload( byref str as const native wstring ) as ulongint '/ _
		( _
			@FB_RTL_STR2ULNG, @"fb_WstrDynValULng", _
			FB_DATATYPE_ULONGINT, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function hex overload( byval number as const ubyte ) as string '/ _
		( _
			@"hex", @"fb_HEX_b", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_UBYTE ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function hex overload( byval number as const ushort ) as string '/ _
		( _
			@"hex", @"fb_HEX_s", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_USHORT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function hex overload( byval number as const ulong ) as string '/ _
		( _
			@"hex", @"fb_HEX_i", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function hex overload( byval number as const ulongint ) as string '/ _
		( _
			@"hex", @"fb_HEX_l", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONGINT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function hex overload( byval number as const any ptr ) as string '/ _
		( _
			@"hex", @"fb_HEX_p", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			1, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_VOID ) ), FB_PARAMMODE_BYVAL, FALSE, 0 ) _
			} _
		), _
		/' function hex overload( byval number as const ubyte, byval digits as const long ) as string '/ _
		( _
			@"hex", @"fb_HEXEx_b", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_UBYTE ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function hex overload( byval number as const ushort, byval digits as const long ) as string '/ _
		( _
			@"hex", @"fb_HEXEx_s", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_USHORT ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function hex overload( byval number as const ulong, byval digits as const long ) as string '/ _
		( _
			@"hex", @"fb_HEXEx_i", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONG ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function hex overload( byval number as const ulongint, byval digits as const long ) as string '/ _
		( _
			@"hex", @"fb_HEXEx_l", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONGINT ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function hex overload( byval number as const any ptr, byval digits as const long ) as string '/ _
		( _
			@"hex", @"fb_HEXEx_p", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			2, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_VOID ) ), FB_PARAMMODE_BYVAL, FALSE, 0 ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function whex overload( byval number as const ubyte ) as wstring '/ _
		( _
			@"whex", @"fb_WstrHex_b", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_UBYTE ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function whex overload( byval number as const ushort ) as wstring '/ _
		( _
			@"whex", @"fb_WstrHex_s", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_USHORT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function whex overload( byval number as const ulong ) as wstring '/ _
		( _
			@"whex", @"fb_WstrHex_i", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function whex overload( byval number as const ulongint ) as wstring '/ _
		( _
			@"whex", @"fb_WstrHex_l", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONGINT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function whex overload( byval number as const any ptr ) as wstring '/ _
		( _
			@"whex", @"fb_WstrHex_p", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_VOID ) ), FB_PARAMMODE_BYVAL, FALSE, 0 ) _
			} _
		), _
		/' function whex overload( byval number as const ubyte, byval digits as const long ) as wstring '/ _
		( _
			@"whex", @"fb_WstrHexEx_b", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_UBYTE ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function whex overload( byval number as const ushort, byval digits as const long ) as wstring '/ _
		( _
			@"whex", @"fb_WstrHexEx_s", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_USHORT ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function whex overload( byval number as const ulong, byval digits as const long ) as wstring '/ _
		( _
			@"whex", @"fb_WstrHexEx_i", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONG ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function whex overload( byval number as const ulongint, byval digits as const long ) as wstring '/ _
		( _
			@"whex", @"fb_WstrHexEx_l", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONGINT ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function whex overload( byval number as const any ptr, byval digits as const long ) as wstring '/ _
		( _
			@"whex", @"fb_WstrHexEx_p", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_VOID ) ), FB_PARAMMODE_BYVAL, FALSE, 0 ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function oct overload( byval number as const ubyte ) as string '/ _
		( _
			@"oct", @"fb_OCT_b", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_UBYTE ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function oct overload( byval number as const ushort ) as string '/ _
		( _
			@"oct", @"fb_OCT_s", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_USHORT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function oct overload( byval number as const ulong ) as string '/ _
		( _
			@"oct", @"fb_OCT_i", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function oct overload( byval number as const ulongint ) as string '/ _
		( _
			@"oct", @"fb_OCT_l", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONGINT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function oct overload( byval number as const any ptr ) as string '/ _
		( _
			@"oct", @"fb_OCT_p", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			1, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_VOID ) ), FB_PARAMMODE_BYVAL, FALSE, 0 ) _
			} _
		), _
		/' function oct overload( byval number as const ubyte, byval digits as const long ) as string '/ _
		( _
			@"oct", @"fb_OCTEx_b", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_UBYTE ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function oct overload( byval number as const ushort, byval digits as const long ) as string '/ _
		( _
			@"oct", @"fb_OCTEx_s", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_USHORT ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function oct overload( byval number as const ulong, byval digits as const long ) as string '/ _
		( _
			@"oct", @"fb_OCTEx_i", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONG ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function oct overload( byval number as const ulongint, byval digits as const long ) as string '/ _
		( _
			@"oct", @"fb_OCTEx_l", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONGINT ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function oct overload( byval number as const any ptr, byval digits as const long ) as string '/ _
		( _
			@"oct", @"fb_OCTEx_p", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			2, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_VOID ) ), FB_PARAMMODE_BYVAL, FALSE, 0 ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function woct overload( byval number as const ubyte ) as wstring '/ _
		( _
			@"woct", @"fb_WstrOct_b", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_UBYTE ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function woct overload( byval number as const ushort ) as wstring '/ _
		( _
			@"woct", @"fb_WstrOct_s", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_USHORT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function woct overload( byval number as const ulong ) as wstring '/ _
		( _
			@"woct", @"fb_WstrOct_i", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function woct overload( byval number as const ulongint ) as wstring '/ _
		( _
			@"woct", @"fb_WstrOct_l", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONGINT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function woct overload( byval number as const any ptr ) as wstring '/ _
		( _
			@"woct", @"fb_WstrOct_p", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_VOID ) ), FB_PARAMMODE_BYVAL, FALSE, 0 ) _
			} _
		), _
		/' function woct overload( byval number as const ubyte, byval digits as const long ) as wstring '/ _
		( _
			@"woct", @"fb_WstrOctEx_b", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_UBYTE ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function woct overload( byval number as const ushort, byval digits as const long ) as wstring '/ _
		( _
			@"woct", @"fb_WstrOctEx_s", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_USHORT ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function woct overload( byval number as const ulong, byval digits as const long ) as wstring '/ _
		( _
			@"woct", @"fb_WstrOctEx_i", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONG ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function woct overload( byval number as const ulongint, byval digits as const long ) as wstring '/ _
		( _
			@"woct", @"fb_WstrOctEx_l", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONGINT ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function woct overload( byval number as const any ptr, byval digits as const long ) as wstring '/ _
		( _
			@"woct", @"fb_WstrOctEx_p", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_VOID ) ), FB_PARAMMODE_BYVAL, FALSE, 0 ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function bin overload( byval number as const ubyte ) as string '/ _
		( _
			@"bin", @"fb_BIN_b", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_UBYTE ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function bin overload( byval number as const ushort ) as string '/ _
		( _
			@"bin", @"fb_BIN_s", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_USHORT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function bin overload( byval number as const ulong ) as string '/ _
		( _
			@"bin", @"fb_BIN_i", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function bin overload( byval number as const ulongint ) as string '/ _
		( _
			@"bin", @"fb_BIN_l", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONGINT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function bin overload( byval number as const any ptr ) as string '/ _
		( _
			@"bin", @"fb_BIN_p", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_VOID ) ), FB_PARAMMODE_BYVAL, FALSE, 0 ) _
			} _
		), _
		/' function bin overload( byval number as const ubyte, byval digits as const long ) as string '/ _
		( _
			@"bin", @"fb_BINEx_b", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_UBYTE ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function bin overload( byval number as const ushort, byval digits as const long ) as string '/ _
		( _
			@"bin", @"fb_BINEx_s", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_USHORT ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function bin overload( byval number as const ulong, byval digits as const long ) as string '/ _
		( _
			@"bin", @"fb_BINEx_i", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONG ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function bin overload( byval number as const ulongint, byval digits as const long ) as string '/ _
		( _
			@"bin", @"fb_BINEx_l", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONGINT ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function bin overload( byval number as const any ptr, byval digits as const long ) as string '/ _
		( _
			@"bin", @"fb_BINEx_p", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_VOID ) ), FB_PARAMMODE_BYVAL, FALSE, 0 ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function wbin overload( byval number as const ubyte ) as wstring '/ _
		( _
			@"wbin", @"fb_WstrBin_b", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_UBYTE ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function wbin overload( byval number as const ushort ) as wstring '/ _
		( _
			@"wbin", @"fb_WstrBin_s", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_USHORT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function wbin overload( byval number as const ulong ) as wstring '/ _
		( _
			@"wbin", @"fb_WstrBin_i", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function wbin overload( byval number as const ulongint ) as wstring '/ _
		( _
			@"wbin", @"fb_WstrBin_l", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONGINT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function wbin overload( byval number as const any ptr ) as wstring '/ _
		( _
			@"wbin", @"fb_WstrBin_p", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_VOID ) ), FB_PARAMMODE_BYVAL, FALSE, 0 ) _
			} _
		), _
		/' function wbin overload( byval number as const ubyte, byval digits as const long ) as wstring '/ _
		( _
			@"wbin", @"fb_WstrBinEx_b", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_UBYTE ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function wbin overload( byval number as const ushort, byval digits as const long ) as wstring '/ _
		( _
			@"wbin", @"fb_WstrBinEx_s", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_USHORT ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function wbin overload( byval number as const ulong, byval digits as const long ) as wstring '/ _
		( _
			@"wbin", @"fb_WstrBinEx_i", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONG ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function wbin overload( byval number as const ulongint, byval digits as const long ) as wstring '/ _
		( _
			@"wbin", @"fb_WstrBinEx_l", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_ULONGINT ), FB_PARAMMODE_BYVAL, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function wbin overload( byval number as const any ptr, byval digits as const long ) as wstring '/ _
		( _
			@"wbin", @"fb_WstrBinEx_p", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeAddrOf( typeSetIsConst( FB_DATATYPE_VOID ) ), FB_PARAMMODE_BYVAL, FALSE, 0 ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_MKD( byval number as const double ) as string '/ _
		( _
			@FB_RTL_MKD, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_DOUBLE ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_MKS( byval number as const single ) as string '/ _
		( _
			@FB_RTL_MKS, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_SINGLE ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_MKSHORT( byval number as const short ) as string '/ _
		( _
			@FB_RTL_MKSHORT, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_SHORT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_MKI( byval number as const integer ) as string '/ _
		( _
			@FB_RTL_MKI, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_MKL( byval number as const long ) as string '/ _
		( _
			@FB_RTL_MKL, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_MKLONGINT( byval number as const longint ) as string '/ _
		( _
			@FB_RTL_MKLONGINT, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_LONGINT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function left overload( byref str as const string, byval chars as const integer ) as string '/ _
		( _
			@"left", @"fb_LEFT", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function left overload( byref str as const wstring, byval chars as const integer ) as wstring '/ _
		( _
			@"left", @"fb_WstrLeft", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function left overload( byref str as const native wstring, byval chars as const integer ) as native wstring '/ _
		( _
			@"left", @"fb_WstrDynLeftResult", _
			FB_DATATYPE_WSTRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' sub fb_leftself overload( byref str as string, byval chars as const integer )'/ _
		( _
			@"fb_LeftSelf", @"fb_LEFTSELF", _
			FB_DATATYPE_VOID, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( FB_DATATYPE_STRING, FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function right overload( byref str as const string, byval chars as const integer ) as string '/ _
		( _
			@"right", @"fb_RIGHT", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_STRSUFFIX, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function right overload( byref str as const wstring, byval chars as const integer ) as wstring '/ _
		( _
			@"right", @"fb_WstrRight", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function right overload( byref str as const native wstring, byval chars as const integer ) as native wstring '/ _
		( _
			@"right", @"fb_WstrDynRightResult", _
			FB_DATATYPE_WSTRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_OVER or FB_RTL_OPT_NOQB, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WSTRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function space( byval chars as const integer ) as string '/ _
		( _
			@"space", @"fb_SPACE", _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_STRSUFFIX, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function wspace( byval chars as const integer ) as wstring '/ _
		( _
			@"wspace", @"fb_WstrSpace", _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_INTEGER ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_StrLcase2( byref src as const string, byval mode as const long = 0 ) as string '/ _
		( _
			@FB_RTL_STRLCASE2, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, TRUE, 0 ) _
			} _
		), _
		/' function fb_WstrLcase2( byref str as const wstring, byval mode as const long = 0 ) as wstring '/ _
		( _
			@FB_RTL_WSTRLCASE2, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, TRUE, 0 ) _
			} _
		), _
		/' function fb_StrUcase2( byref src as const string, byval mode as const long = 0 ) as string '/ _
		( _
			@FB_RTL_STRUCASE2, NULL, _
			FB_DATATYPE_STRING, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, TRUE, 0 ) _
			} _
		), _
		/' function fb_WstrUcase2( byref str as const wstring, byval mode as const long = 0 ) as wstring '/ _
		( _
			@FB_RTL_WSTRUCASE2, NULL, _
			FB_DATATYPE_WCHAR, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
			{ _
				( typeSetIsConst( FB_DATATYPE_WCHAR ), FB_PARAMMODE_BYREF, FALSE ), _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, TRUE, 0 ) _
			} _
		), _
		/' function fb_CVD( byref str as const string ) as double '/ _
		( _
			@FB_RTL_CVD, @"fb_CVD", _
			FB_DATATYPE_DOUBLE, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_CVS( byref str as const string ) as single '/ _
		( _
			@FB_RTL_CVS, @"fb_CVS", _
			FB_DATATYPE_SINGLE, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_CVSHORT( byref str as const string ) as short '/ _
		( _
			@FB_RTL_CVSHORT, @"fb_CVSHORT", _
			FB_DATATYPE_SHORT, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_CVL( byref str as const string ) as long '/ _
		( _
			@FB_RTL_CVL, NULL, _
			FB_DATATYPE_LONG, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_CVLONGINT( byref str as const string ) as longint '/ _
		( _
			@FB_RTL_CVLONGINT, @"fb_CVLONGINT", _
			FB_DATATYPE_LONGINT, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_STRING ), FB_PARAMMODE_BYREF, FALSE ) _
			} _
		), _
		/' function fb_CVDFROMLONGINT( byval num as const longint ) as double '/ _
		( _
			@FB_RTL_CVDFROMLONGINT, @"fb_CVDFROMLONGINT", _
			FB_DATATYPE_DOUBLE, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_LONGINT ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_CVSFROML( byref num as const long ) as single '/ _
		( _
			@FB_RTL_CVSFROML, @"fb_CVSFROML", _
			FB_DATATYPE_SINGLE, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_LONG ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_CVLFROMS( byval num as const single ) as long '/ _
		( _
			@FB_RTL_CVLFROMS, @"fb_CVLFROMS", _
			FB_DATATYPE_LONG, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_SINGLE ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' function fb_CVLONGINTFROMD( byval num as const double ) as longint '/ _
		( _
			@FB_RTL_CVLONGINTFROMD, @"fb_CVLONGINTFROMD", _
			FB_DATATYPE_LONGINT, FB_FUNCMODE_FBCALL, _
			NULL, FB_RTL_OPT_NOQB, _
			1, _
			{ _
				( typeSetIsConst( FB_DATATYPE_DOUBLE ), FB_PARAMMODE_BYVAL, FALSE ) _
			} _
		), _
		/' EOL '/ _
		( _
			NULL _
		) _
	 }

'':::::
sub rtlStringModInit( )

	rtlAddIntrinsicProcs( @funcdata(0) )

end sub

'':::::
sub rtlStringModEnd( )

	'' procs will be deleted when symbEnd is called

end sub

'':::::
function rtlStrCompare _
	( _
		byval str1 as ASTNODE ptr, _
		byval sdtype1 as integer, _
		byval str2 as ASTNODE ptr, _
		byval sdtype2 as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as longint str1len = any, str2len = any

	function = NULL

	''
	proc = astNewCALL( PROCLOOKUP( STRCOMPARE ) )

	'' always calc len before pushing the param
	str1len = rtlCalcStrLen( str1, sdtype1 )
	str2len = rtlCalcStrLen( str2, sdtype2 )

	'' byref str1 as any
	if( astNewARG( proc, str1, sdtype1 ) = NULL ) then
		exit function
	end if

	'' byval str1_len as integer
	if( astNewARG( proc, astNewCONSTi( str1len ) ) = NULL ) then
		exit function
	end if

	'' byref str2 as any
	if( astNewARG( proc, str2, sdtype2 ) = NULL ) then
		exit function
	end if

	'' byval str2_len as integer
	if( astNewARG( proc, astNewCONSTi( str2len ) ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
function rtlDynWstrCompare _
	( _
		byval str1 as ASTNODE ptr, _
		byval str2 as ASTNODE ptr _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any

	function = NULL

	proc = astNewCALL( PROCLOOKUP( DWSTRCOMPARE ) )

	'' byref lhs as const managed wstring
	if( astNewARG( proc, str1, FB_DATATYPE_WSTRING ) = NULL ) then
		exit function
	end if

	'' byref rhs as const managed wstring
	if( astNewARG( proc, str2, FB_DATATYPE_WSTRING ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
function rtlWstrCompare _
	( _
		byval str1 as ASTNODE ptr, _
		byval str2 as ASTNODE ptr _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any

	function = NULL

	''
	proc = astNewCALL( PROCLOOKUP( WSTRCOMPARE ) )

	'' byval str1 as wstring ptr
	if( astNewARG( proc, str1 ) = NULL ) then
		exit function
	end if

	'' byval str2 as wstring ptr
	if( astNewARG( proc, str2 ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
function rtlStrConcat _
	( _
		byval str1 as ASTNODE ptr, _
		byval sdtype1 as integer, _
		byval str2 as ASTNODE ptr, _
		byval sdtype2 as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as longint str1len = any, str2len = any
	dim as FBSYMBOL ptr tmp = any

	function = NULL

	proc = astNewCALL( PROCLOOKUP( STRCONCAT ) )

	'' byref dst as string (must be cleaned up due the rtlib assumptions about destine)
	tmp = symbAddTempVar( FB_DATATYPE_STRING )

	if( astNewARG( proc, _
		astNewLINK( astBuildTempVarClear( tmp ), _
			astNewVAR( tmp ), _
			AST_LINK_RETURN_RIGHT ) ) = NULL ) then
		exit function
	end if

	'' always calc len before pushing the param
	str1len = rtlCalcStrLen( str1, sdtype1 )
	str2len = rtlCalcStrLen( str2, sdtype2 )

	'' byref str1 as any
	if( astNewARG( proc, str1, sdtype1 ) = NULL ) then
		exit function
	end if

	'' byval str1_len as integer
	if( astNewARG( proc, astNewCONSTi( str1len ) ) = NULL ) then
		exit function
	end if

	'' byref str2 as any
	if( astNewARG( proc, str2, sdtype2 ) = NULL ) then
		exit function
	end if

	'' byval str2_len as integer
	if( astNewARG( proc, astNewCONSTi( str2len ) ) = NULL ) then
		exit function
	end if

	function = proc
end function

'':::::
function rtlWstrConcatWA _
	( _
		byval str1 as ASTNODE ptr, _
		byval str2 as ASTNODE ptr, _
		byval sdtype2 as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as longint str2len = any

	function = NULL

	proc = astNewCALL( PROCLOOKUP( WSTRCONCATWA ) )

	'' byval str1 as wstring ptr
	if( astNewARG( proc, str1 ) = NULL ) then
		exit function
	end if

	'' always calc len before pushing the param
	str2len = rtlCalcStrLen( str2, sdtype2 )

	'' byref str2 as any
	if( astNewARG( proc, str2, sdtype2 ) = NULL ) then
		exit function
	end if

	'' byval str2_len as integer
	if( astNewARG( proc, astNewCONSTi( str2len ) ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
function rtlWstrConcatAW _
	( _
		byval str1 as ASTNODE ptr, _
		byval sdtype1 as integer, _
		byval str2 as ASTNODE ptr _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as longint str1len = any

	function = NULL

	proc = astNewCALL( PROCLOOKUP( WSTRCONCATAW ) )

	'' always calc len before pushing the param
	str1len = rtlCalcStrLen( str1, sdtype1 )

	'' byref str1 as any
	if( astNewARG( proc, str1, sdtype1 ) = NULL ) then
		exit function
	end if

	'' byval str1_len as integer
	if( astNewARG( proc, astNewCONSTi( str1len ) ) = NULL ) then
		exit function
	end if

	'' byval str2 as wstring ptr
	if( astNewARG( proc, str2 ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
function rtlWstrConcat _
	( _
		byval str1 as ASTNODE ptr, _
		byval sdtype1 as integer, _
		byval str2 as ASTNODE ptr, _
		byval sdtype2 as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any

	function = NULL

	'' both not wstrings?
	if( typeGetDtAndPtrOnly( sdtype1 ) <> typeGetDtAndPtrOnly( sdtype2 ) ) then
		'' left ?
		if( typeGet( sdtype1 ) = FB_DATATYPE_WCHAR ) then
			return rtlWstrConcatWA( str1, str2, sdtype2 )

		'' right..
		else
			return rtlWstrConcatAW( str1, sdtype1, str2 )
		end if
	end if

	'' both wstrings..
	proc = astNewCALL( PROCLOOKUP( WSTRCONCAT ) )

	'' byval str1 as wstring ptr
	if( astNewARG( proc, str1 ) = NULL ) then
		exit function
	end if

	'' byval str2 as wstring ptr
	if( astNewARG( proc, str2 ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
function rtlStrConcatAssign _
	( _
		byval dst as ASTNODE ptr, _
		byval src as ASTNODE ptr, _
		byval isConcatByref as integer = FALSE _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as integer ddtype = any, sdtype = any
	dim as longint lgt = any

	function = NULL

	if( isConcatByref ) then
		proc = astNewCALL( PROCLOOKUP( STRCONCATBYREF ) )
	else
		proc = astNewCALL( PROCLOOKUP( STRCONCATASSIGN ) )
	end if

	ddtype = astGetDataType( dst )

	'' always calc len before pushing the param
	lgt = rtlCalcStrLen( dst, ddtype )

	'' dst as any
	if( astNewARG( proc, dst, ddtype ) = NULL ) then
		exit function
	end if

	'' byval dstlen as integer
	if( astNewARG( proc, astNewCONSTi( lgt ) ) = NULL ) then
		exit function
	end if

	'' always calc len before pushing the param
	sdtype = astGetDataType( src )
	lgt = rtlCalcStrLen( src, sdtype )

	'' src as any
	if( astNewARG( proc, src, sdtype ) = NULL ) then
		exit function
	end if

	'' byval srclen as integer
	if( astNewARG( proc, astNewCONSTi( lgt ) ) = NULL ) then
		exit function
	end if

	'' byval fillrem as integer
	if( astNewARG( proc, astNewCONSTi( ddtype = FB_DATATYPE_FIXSTR ) ) = NULL ) then
		exit function
	end if

	''
	function = proc

end function

'':::::
function rtlWstrConcatAssign _
	( _
		byval dst as ASTNODE ptr, _
		byval src as ASTNODE ptr _
	) as ASTNODE ptr static

	dim as ASTNODE ptr proc
	dim as longint lgt = any

	function = NULL

	proc = astNewCALL( PROCLOOKUP( WSTRCONCATASSIGN ) )

	'' always calc len before pushing the param
	lgt = rtlCalcStrLen( dst, FB_DATATYPE_WCHAR )

	'' byval dst as wstring ptr
	if( astNewARG( proc, dst ) = NULL ) then
		exit function
	end if

	'' byval dstlen as integer
	if( astNewARG( proc, astNewCONSTi( lgt ) ) = NULL ) then
		exit function
	end if

	'' byval src as wstring ptr
	if( astNewARG( proc, src ) = NULL ) then
		exit function
	end if

	''
	function = proc

end function

'':::::
function rtlWstrAssignWA _
	( _
		byval dst as ASTNODE ptr, _
		byval src as ASTNODE ptr, _
		byval sdtype as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as longint dstlen = any, srclen = any

	function = NULL

	proc = astNewCALL( PROCLOOKUP( WSTRASSIGNWA ) )

	'' always calc len before pushing the param
	dstlen = rtlCalcStrLen( dst, FB_DATATYPE_WCHAR )
	srclen = rtlCalcStrLen( src, sdtype )

	'' byval dst as wstring ptr
	if( astNewARG( proc, dst ) = NULL ) then
		exit function
	end if

	'' byval dstlen as integer
	if( astNewARG( proc, astNewCONSTi( dstlen ) ) = NULL ) then
		exit function
	end if

	'' byref src as any
	if( astNewARG( proc, src ) = NULL ) then
		exit function
	end if

	'' byval srclen as integer
	if( astNewARG( proc, astNewCONSTi( srclen ) ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
function rtlWstrAssignAW _
	( _
		byval dst as ASTNODE ptr, _
		byval ddtype as integer, _
		byval src as ASTNODE ptr, _
		byval is_ini as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as longint lgt = any

	function = NULL

	proc = astNewCALL( iif( is_ini, _
				PROCLOOKUP( WSTRASSIGNAW_INIT ), _
				PROCLOOKUP(  WSTRASSIGNAW ) ) )

	'' always calc len before pushing the param
	lgt = rtlCalcStrLen( dst, ddtype )

	'' byref dst as any
	if( astNewARG( proc, dst ) = NULL ) then
		exit function
	end if

	'' byval dstlen as integer
	if( astNewARG( proc, astNewCONSTi( lgt ) ) = NULL ) then
		exit function
	end if

	'' byval src as wstring ptr
	if( astNewARG( proc, src ) = NULL ) then
		exit function
	end if

	'' byval fillrem as integer
	if( astNewARG( proc, astNewCONSTi( ddtype = FB_DATATYPE_FIXSTR ) ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
function rtlStrAssign _
	( _
		byval dst as ASTNODE ptr, _
		byval src as ASTNODE ptr, _
		byval is_ini as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as integer ddtype = any, sdtype = any
	dim as longint lgt = any

	function = NULL

	ddtype = astGetDataType( dst )
	sdtype = astGetDataType( src )

	'' wstring source?
	if( sdtype = FB_DATATYPE_WCHAR ) then
		return rtlWstrAssignAW( dst, ddtype, src, is_ini )

	'' destine?
	elseif( ddtype = FB_DATATYPE_WCHAR ) then
		return rtlWstrAssignWA( dst, src, sdtype )
	end if

	'' both strings
	proc = astNewCALL( iif( is_ini, _
				PROCLOOKUP( STRINIT ), _
				PROCLOOKUP( STRASSIGN ) ) )

	'' always calc len before pushing the param

	lgt = rtlCalcStrLen( dst, ddtype )

	'' dst as any
	if( astNewARG( proc, dst, astGetDataType( dst ) ) = NULL ) then
		exit function
	end if

	'' byval dstlen as integer
	if( astNewARG( proc, astNewCONSTi( lgt ) ) = NULL ) then
		exit function
	end if

	'' always calc len before pushing the param
	lgt = rtlCalcStrLen( src, sdtype )

	'' src as const any
	if( astNewARG( proc, src ) = NULL ) then
		exit function
	end if

	'' byval srclen as integer
	if( astNewARG( proc, astNewCONSTi( lgt ) ) = NULL ) then
		exit function
	end if

	'' byval fillrem as integer
	if( astNewARG( proc, astNewCONSTi( ddtype = FB_DATATYPE_FIXSTR ) ) = NULL ) then
		exit function
	end if

	'' always discard result, even though actual rtlib returns a ptr to destination
	'' it will never be used anywhere
	astSetType( proc, FB_DATATYPE_VOID, NULL )

	function = proc

end function

'':::::
private function hNativeWstrKnownSpanLen( byval src as ASTNODE ptr ) as longint
	dim as FBSYMBOL ptr lit = astGetStrLitSymbol( src )
	if( lit <> NULL ) then
		'' symbGetWStrLength() measures the compiler's *escaped* literal storage.
		'' That is not the logical WCHAR count (\uXXXX expands, and embedded NUL
		'' is legal for native counted WSTRING).  hUnescapeW() already exposes the
		'' exact unescaped code-unit count explicitly -- use it instead of strlen.
		dim as integer textlen
		hUnescapeW( symbGetVarLitTextW( lit ), textlen )
		return textlen
	end if
	if( astIsCALL( src ) ) then
		if( src->sym = PROCLOOKUP( WSTRCHR ) ) then
			return src->call.args - 1
		end if
	end if
	return -1
end function

function rtlDynWstrAssign _
	( _
		byval dst as ASTNODE ptr, _
		byval src as ASTNODE ptr, _
		byval src_len_override as longint = -2, _
		byval is_ini as integer = FALSE _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = NULL
	dim as integer sdtype = astGetDataType( src )
	dim as longint lgt = any

	function = NULL
	assert( astGetDataType( dst ) = FB_DATATYPE_WSTRING )

	select case sdtype
	case FB_DATATYPE_WSTRING
		proc = astNewCALL( iif( is_ini, PROCLOOKUP( DWSTRINIT ), PROCLOOKUP( DWSTRASSIGN ) ) )
		if( astNewARG( proc, dst, FB_DATATYPE_WSTRING ) = NULL ) then exit function
		if( astNewARG( proc, src, FB_DATATYPE_WSTRING ) = NULL ) then exit function

	case FB_DATATYPE_WCHAR
		lgt = hNativeWstrKnownSpanLen( src )
		if( lgt >= 0 ) then
			proc = astNewCALL( iif( is_ini, PROCLOOKUP( DWSTRINITWN ), PROCLOOKUP( DWSTRASSIGNWN ) ) )
		else
			proc = astNewCALL( iif( is_ini, PROCLOOKUP( DWSTRINITW ), PROCLOOKUP( DWSTRASSIGNW ) ) )
		end if
		if( astNewARG( proc, dst, FB_DATATYPE_WSTRING ) = NULL ) then exit function
		if( astNewARG( proc, src ) = NULL ) then exit function
		if( lgt >= 0 ) then
			if( astNewARG( proc, astNewCONSTi( lgt ) ) = NULL ) then exit function
		end if

	case FB_DATATYPE_STRING, FB_DATATYPE_FIXSTR, FB_DATATYPE_CHAR
		proc = astNewCALL( iif( is_ini, PROCLOOKUP( DWSTRINITA ), PROCLOOKUP( DWSTRASSIGNA ) ) )
		if( astNewARG( proc, dst, FB_DATATYPE_WSTRING ) = NULL ) then exit function
		if( src_len_override <> -2 ) then
			lgt = src_len_override
		else
			lgt = rtlCalcStrLen( src, sdtype )
		end if
		if( astNewARG( proc, src ) = NULL ) then exit function
		if( astNewARG( proc, astNewCONSTi( lgt ) ) = NULL ) then exit function

	case else
		'' No generic scalar-to-managed-WSTRING escape hatch.  Keep assignment
		'' legality aligned with STRING; explicit conversion producers must have
		'' produced a supported string-family AST before reaching this helper.
		exit function
	end select

	function = proc
end function

function rtlDynWstrInit( byval dst as ASTNODE ptr, byval src as ASTNODE ptr ) as ASTNODE ptr
	dim as ASTNODE ptr proc = astNewCALL( PROCLOOKUP( DWSTRINIT ) )
	function = NULL
	assert( astGetDataType( dst ) = FB_DATATYPE_WSTRING )
	assert( astGetDataType( src ) = FB_DATATYPE_WSTRING )
	if( astNewARG( proc, dst, FB_DATATYPE_WSTRING ) = NULL ) then exit function
	if( astNewARG( proc, src, FB_DATATYPE_WSTRING ) = NULL ) then exit function
	function = proc
end function

function rtlDynWstrMoveInit( byval dst as ASTNODE ptr, byval src as ASTNODE ptr ) as ASTNODE ptr
	dim as ASTNODE ptr proc = astNewCALL( PROCLOOKUP( DWSTRMOVEINIT ) )
	function = NULL
	assert( astGetDataType( dst ) = FB_DATATYPE_WSTRING )
	assert( astGetDataType( src ) = FB_DATATYPE_WSTRING )
	if( astNewARG( proc, dst, FB_DATATYPE_WSTRING ) = NULL ) then exit function
	if( astNewARG( proc, src, FB_DATATYPE_WSTRING ) = NULL ) then exit function
	function = proc
end function

function rtlDynWstrMoveAssign( byval dst as ASTNODE ptr, byval src as ASTNODE ptr ) as ASTNODE ptr
	dim as ASTNODE ptr proc = astNewCALL( PROCLOOKUP( DWSTRMOVEASSIGN ) )
	function = NULL
	assert( astGetDataType( dst ) = FB_DATATYPE_WSTRING )
	assert( astGetDataType( src ) = FB_DATATYPE_WSTRING )
	if( astNewARG( proc, dst, FB_DATATYPE_WSTRING ) = NULL ) then exit function
	if( astNewARG( proc, src, FB_DATATYPE_WSTRING ) = NULL ) then exit function
	function = proc
end function

function rtlDynWstrConcatAssignPair( byval dst as ASTNODE ptr, byval lhs as ASTNODE ptr, byval rhs as ASTNODE ptr ) as ASTNODE ptr
	dim as ASTNODE ptr proc = astNewCALL( PROCLOOKUP( DWSTRCATPAIR ) )
	function = NULL
	assert( astGetDataType( dst ) = FB_DATATYPE_WSTRING )
	assert( astGetDataType( lhs ) = FB_DATATYPE_WSTRING )
	assert( astGetDataType( rhs ) = FB_DATATYPE_WSTRING )
	if( astNewARG( proc, dst, FB_DATATYPE_WSTRING ) = NULL ) then exit function
	if( astNewARG( proc, lhs, FB_DATATYPE_WSTRING ) = NULL ) then exit function
	if( astNewARG( proc, rhs, FB_DATATYPE_WSTRING ) = NULL ) then exit function
	function = proc
end function

function rtlDynWstrConcatInitPair( byval dst as ASTNODE ptr, byval lhs as ASTNODE ptr, byval rhs as ASTNODE ptr ) as ASTNODE ptr
	dim as ASTNODE ptr proc = astNewCALL( PROCLOOKUP( DWSTRCATINITPAIR ) )
	function = NULL
	assert( astGetDataType( dst ) = FB_DATATYPE_WSTRING )
	assert( astGetDataType( lhs ) = FB_DATATYPE_WSTRING )
	assert( astGetDataType( rhs ) = FB_DATATYPE_WSTRING )
	if( astNewARG( proc, dst, FB_DATATYPE_WSTRING ) = NULL ) then exit function
	if( astNewARG( proc, lhs, FB_DATATYPE_WSTRING ) = NULL ) then exit function
	if( astNewARG( proc, rhs, FB_DATATYPE_WSTRING ) = NULL ) then exit function
	function = proc
end function

function rtlDynWstrDelete( byval expr as ASTNODE ptr ) as ASTNODE ptr
	dim as ASTNODE ptr proc = astNewCALL( PROCLOOKUP( DWSTRDELETE ) )
	function = NULL
	assert( astGetDataType( expr ) = FB_DATATYPE_WSTRING )
	if( astNewARG( proc, expr, FB_DATATYPE_WSTRING ) = NULL ) then exit function
	function = proc
end function

function rtlDynWstrLen( byval expr as ASTNODE ptr ) as ASTNODE ptr
	dim as ASTNODE ptr proc = astNewCALL( PROCLOOKUP( DWSTRLEN ) )
	function = NULL
	assert( astGetDataType( expr ) = FB_DATATYPE_WSTRING )
	if( astNewARG( proc, expr, FB_DATATYPE_WSTRING ) = NULL ) then exit function
	function = proc
end function

function rtlDynWstrConcatAssign( byval dst as ASTNODE ptr, byval src as ASTNODE ptr ) as ASTNODE ptr
	dim as ASTNODE ptr proc = NULL
	dim as integer sdtype = astGetDataType( src )
	dim as longint lgt = any
	function = NULL
	assert( astGetDataType( dst ) = FB_DATATYPE_WSTRING )
	select case sdtype
	case FB_DATATYPE_WSTRING
		proc = astNewCALL( PROCLOOKUP( DWSTRCAT ) )
		if( astNewARG( proc, dst, FB_DATATYPE_WSTRING ) = NULL ) then exit function
		if( astNewARG( proc, src, FB_DATATYPE_WSTRING ) = NULL ) then exit function
	case FB_DATATYPE_WCHAR
		lgt = hNativeWstrKnownSpanLen( src )
		if( lgt >= 0 ) then
			proc = astNewCALL( PROCLOOKUP( DWSTRCATWN ) )
		else
			proc = astNewCALL( PROCLOOKUP( DWSTRCATW ) )
		end if
		if( astNewARG( proc, dst, FB_DATATYPE_WSTRING ) = NULL ) then exit function
		if( astNewARG( proc, src ) = NULL ) then exit function
		if( lgt >= 0 ) then
			if( astNewARG( proc, astNewCONSTi( lgt ) ) = NULL ) then exit function
		end if
	case FB_DATATYPE_STRING, FB_DATATYPE_FIXSTR, FB_DATATYPE_CHAR
		proc = astNewCALL( PROCLOOKUP( DWSTRCATA ) )
		if( astNewARG( proc, dst, FB_DATATYPE_WSTRING ) = NULL ) then exit function
		lgt = rtlCalcStrLen( src, sdtype )
		if( astNewARG( proc, src ) = NULL ) then exit function
		if( astNewARG( proc, astNewCONSTi( lgt ) ) = NULL ) then exit function
	case else
		exit function
	end select
	function = proc
end function

'':::::
'' Build a native counted-WSTRING concatenation expression using a real
'' descriptor temporary.  The normal AST destructor list owns the temporary,
'' so nested concatenations and early expression exits do not need fake-WSTRING
'' pointer lifetime rules.
function rtlDynWstrConcat( byval lhs as ASTNODE ptr, byval rhs as ASTNODE ptr ) as ASTNODE ptr
	dim as FBSYMBOL ptr tmp = symbAddTempVar( FB_DATATYPE_WSTRING )
	dim as ASTNODE ptr t = NULL
	dim as ASTNODE ptr step1 = any, step2 = any

	astDtorListAdd( tmp )

	'' Initialize the result owner from the first operand; initialization must not
	'' inspect any prior descriptor state, mirroring STRING temporary creation.
	step1 = rtlDynWstrAssign( astNewVAR( tmp ), lhs, -2, TRUE )
	if( step1 = NULL ) then return NULL
	t = astNewLINK( t, step1, AST_LINK_RETURN_NONE )

	step2 = rtlDynWstrConcatAssign( astNewVAR( tmp ), rhs )
	if( step2 = NULL ) then return NULL
	t = astNewLINK( t, step2, AST_LINK_RETURN_NONE )

	'' Expression value is the descriptor itself; statement-level dtor flushing
	'' will delete it only after the consumer has copied/used it.
	function = astNewLINK( t, astNewVAR( tmp ), AST_LINK_RETURN_RIGHT )
end function

private function rtlDynWstrMidResult _
	( byval src as ASTNODE ptr, byval startx as ASTNODE ptr, byval lenx as ASTNODE ptr ) as ASTNODE ptr
	dim as ASTNODE ptr proc = astNewCALL( PROCLOOKUP( DWSTRMID ) )
	if( astNewARG( proc, src, FB_DATATYPE_WSTRING ) = NULL ) then return NULL
	if( astNewARG( proc, startx ) = NULL ) then return NULL
	if( astNewARG( proc, lenx ) = NULL ) then return NULL
	function = proc
end function

private function rtlDynWstrCaseResult _
	( byval src as ASTNODE ptr, byval mode as ASTNODE ptr, byval is_lcase as integer ) as ASTNODE ptr
	dim as ASTNODE ptr proc = astNewCALL( PROCLOOKUP( DWSTRCASE ) )
	if( mode = NULL ) then mode = astNewCONSTi( 0, FB_DATATYPE_LONG )
	if( astNewARG( proc, src, FB_DATATYPE_WSTRING ) = NULL ) then return NULL
	if( astNewARG( proc, mode ) = NULL ) then return NULL
	if( astNewARG( proc, astNewCONSTi( iif( is_lcase, 1, 0 ), FB_DATATYPE_LONG ) ) = NULL ) then return NULL
	function = proc
end function

private function rtlDynWstrTrimSimpleResult _
	( byval src as ASTNODE ptr, byval side as integer ) as ASTNODE ptr
	dim as ASTNODE ptr proc = astNewCALL( PROCLOOKUP( DWSTRTRIMSIMPLE ) )
	if( astNewARG( proc, src, FB_DATATYPE_WSTRING ) = NULL ) then return NULL
	if( astNewARG( proc, astNewCONSTi( side, FB_DATATYPE_LONG ) ) = NULL ) then return NULL
	function = proc
end function

function rtlDynWstrFill( byval chars as ASTNODE ptr, byval c as ASTNODE ptr ) as ASTNODE ptr
	dim as ASTNODE ptr proc = any
	if( astGetDataType( c ) = FB_DATATYPE_WSTRING ) then
		proc = astNewCALL( PROCLOOKUP( DWSTRFILLWSTR ) )
		if( astNewARG( proc, chars ) = NULL ) then return NULL
		if( astNewARG( proc, c, FB_DATATYPE_WSTRING ) = NULL ) then return NULL
	else
		proc = astNewCALL( PROCLOOKUP( DWSTRFILL ) )
		if( astNewARG( proc, chars ) = NULL ) then return NULL
		if( astNewARG( proc, c ) = NULL ) then return NULL
	end if
	function = proc
end function

function rtlDynWstrChr( byval args as integer, exprtb() as ASTNODE ptr ) as ASTNODE ptr
	dim as ASTNODE ptr proc = astNewCALL( PROCLOOKUP( DWSTRCHR ) )
	if( astNewARG( proc, astNewCONSTi( args, FB_DATATYPE_LONG ), FB_DATATYPE_LONG ) = NULL ) then return NULL
	for i as integer = 0 to args-1
		if( astNewARG( proc, exprtb(i) ) = NULL ) then return NULL
	next
	function = proc
end function

'':::::
'' Function-return adapter remains only for user procedures returning a managed
'' WString owner; built-in producers above already return tagged temporaries.
'':::::
function rtlDynWstrAllocTempResult( byval expr as ASTNODE ptr ) as ASTNODE ptr
	dim as ASTNODE ptr proc = astNewCALL( PROCLOOKUP( DWSTRTEMPRESULT ) )
	if( astNewARG( proc, expr, FB_DATATYPE_WSTRING ) = NULL ) then return NULL
	function = proc
end function

function rtlDynWstrAsc( byval expr as ASTNODE ptr, byval posexpr as ASTNODE ptr ) as ASTNODE ptr
	dim as ASTNODE ptr proc = any
	function = NULL
	assert( astGetDataType( expr ) = FB_DATATYPE_WSTRING )
	proc = astNewCALL( PROCLOOKUP( DWSTRASC ) )
	if( astNewARG( proc, expr, FB_DATATYPE_WSTRING ) = NULL ) then exit function
	if( posexpr = NULL ) then posexpr = astNewCONSTi( 1 )
	if( astNewARG( proc, posexpr ) = NULL ) then exit function
	function = proc
end function

private function hDynWstrCoerceForCompare _
	( _
		byval src as ASTNODE ptr, _
		byref prep as ASTNODE ptr _
	) as ASTNODE ptr

	if( astGetDataType( src ) = FB_DATATYPE_WSTRING ) then
		return src
	end if

	dim as FBSYMBOL ptr tmp = symbAddTempVar( FB_DATATYPE_WSTRING )
	dim as ASTNODE ptr assign = any
	astDtorListAdd( tmp )
	assign = rtlDynWstrAssign( astNewVAR( tmp ), src, -2, TRUE )
	if( assign = NULL ) then return NULL
	prep = astNewLINK( prep, assign, AST_LINK_RETURN_NONE )
	function = astNewVAR( tmp )
end function

private function rtlDynWstrTrimPatternResult _
	( byval src as ASTNODE ptr, byval patt as ASTNODE ptr, byval side as integer, byval is_any as integer ) as ASTNODE ptr
	dim as ASTNODE ptr prep = NULL
	patt = hDynWstrCoerceForCompare( patt, prep )
	if( patt = NULL ) then return NULL
	dim as ASTNODE ptr proc = astNewCALL( PROCLOOKUP( DWSTRTRIMPATTERN ) )
	if( astNewARG( proc, src, FB_DATATYPE_WSTRING ) = NULL ) then return NULL
	if( astNewARG( proc, patt, FB_DATATYPE_WSTRING ) = NULL ) then return NULL
	if( astNewARG( proc, astNewCONSTi( side, FB_DATATYPE_LONG ) ) = NULL ) then return NULL
	if( astNewARG( proc, astNewCONSTi( iif( is_any, 1, 0 ), FB_DATATYPE_LONG ) ) = NULL ) then return NULL
	if( prep <> NULL ) then
		function = astNewLINK( prep, proc, AST_LINK_RETURN_RIGHT )
	else
		function = proc
	end if
end function
'':::::
'' Native counted WSTRING assignment entry point
'':::::

function rtlWstrAssign _
	( _
		byval dst as ASTNODE ptr, _
		byval src as ASTNODE ptr, _
		byval is_ini as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as integer ddtype = any, sdtype = any
	dim as longint lgt = any

	function = NULL

	ddtype = astGetDataType( dst )
	sdtype = astGetDataType( src )

	'' both not wstrings?
	if( ddtype <> sdtype ) then
		'' left ?
		if( ddtype = FB_DATATYPE_WCHAR ) then
			return rtlWstrAssignWA( dst, src, sdtype )
		'' right..
		else
			return rtlWstrAssignAW( dst, ddtype, src, is_ini )
		end if
	end if

	'' both wstrings..
	proc = astNewCALL( PROCLOOKUP( WSTRASSIGN ) )

	'' always calc len before pushing the param
	lgt = rtlCalcStrLen( dst, ddtype )

	'' byval dst as wstring ptr
	if( astNewARG( proc, dst ) = NULL ) then
		exit function
	end if

	'' byval dstlen as integer
	if( astNewARG( proc, astNewCONSTi( lgt ) ) = NULL ) then
		exit function
	end if

	'' byval src as wstring ptr
	if( astNewARG( proc, src ) = NULL ) then
		exit function
	end if

	function = proc

end function

function rtlStrDelete( byval expr as ASTNODE ptr ) as ASTNODE ptr
	dim as FBSYMBOL ptr proc = any
	dim as ASTNODE ptr call_ = any
	dim as integer dtype = any

	function = NULL

	dtype = astGetDataType( expr )

	'' Handling WCHAR PTR because that's what we use for fake dynamic
	'' wstrings, and it's also the real type of functions returning dynamic
	'' wstrings. All wstring types should have been remapped to WCHAR PTR.
	assert( dtype <> FB_DATATYPE_WCHAR )
	if( dtype = typeAddrOf( FB_DATATYPE_WCHAR ) ) then
		proc = PROCLOOKUP( WSTRDELETE )
	else
		assert( dtype = FB_DATATYPE_STRING )
		if( astIsCALL( expr ) ) then
			'' Temporary string function result
			proc = PROCLOOKUP( HSTRDELTEMP )
		else
			'' Normal string variable
			proc = PROCLOOKUP( STRDELETE )
		end if
	end if

	call_ = astNewCALL( proc )

	'' byref str as string|wstring
	if( astNewARG( call_, expr, dtype ) = NULL ) then
		exit function
	end if

	function = call_
end function

'':::::
function rtlStrAllocTempResult _
	( _
		byval strg as ASTNODE ptr _
	) as ASTNODE ptr static

	dim as ASTNODE ptr proc

	function = NULL

	''
	proc = astNewCALL( PROCLOOKUP( STRALLOCTEMPRES ), NULL )

	'' src as string
	if( astNewARG( proc, strg, FB_DATATYPE_STRING ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
function rtlStrAllocTempDesc _
	( _
		byval strexpr as ASTNODE ptr _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as integer dtype = any
	dim as longint lgt = any
	dim as FBSYMBOL ptr litsym = any

	function = NULL

	''
	dtype = astGetDataType( strexpr )

	select case as const dtype
	case FB_DATATYPE_CHAR

		'' literal?
		litsym = astGetStrLitSymbol( strexpr )
		if( litsym = NULL ) then
			proc = astNewCALL( PROCLOOKUP( STRALLOCTEMPDESCZ ) )
		else
			proc = astNewCALL( PROCLOOKUP( STRALLOCTEMPDESCZEX ) )
		end if

		'' byval str as zstring ptr
		if( astNewARG( proc, strexpr ) = NULL ) then
			exit function
		end if

		'' length is known at compile-time
		if( litsym <> NULL ) then
			lgt = symbGetStrLength( litsym )

			'' byval len as integer
			if( astNewARG( proc, astNewCONSTi( lgt ) ) = NULL ) then
				exit function
			end if
		end if

	case FB_DATATYPE_FIXSTR
		proc = astNewCALL( PROCLOOKUP( STRALLOCTEMPDESCF ) )

		'' always calc len before pushing the param
		lgt = rtlCalcStrLen( strexpr, dtype )

		'' str as any
		if( astNewARG( proc, strexpr ) = NULL ) then
			exit function
		end if

		'' byval strlen as integer
		if( astNewARG( proc, astNewCONSTi( lgt ) ) = NULL ) then
			exit function
		end if

	end select

	''
	function = proc

end function

'':::::
function rtlWstrAlloc _
	( _
		byval lenexpr as ASTNODE ptr _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any

	function = NULL

	proc = astNewCALL( PROCLOOKUP( WSTRALLOC ) )

	'' byval len as integer
	if( astNewARG( proc, lenexpr ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
function rtlWstrToA _
	( _
		byval expr as ASTNODE ptr _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any

	function = NULL

	proc = astNewCALL( PROCLOOKUP( WSTR2STR ) )

	'' byval str as wstring ptr
	if( astNewARG( proc, expr ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
function rtlDynWstrToA _
	( _
		byval expr as ASTNODE ptr _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any

	function = NULL
	proc = astNewCALL( PROCLOOKUP( DWSTRTOSTR ) )

	'' byref src as const native counted WSTRING
	if( astNewARG( proc, expr, FB_DATATYPE_WSTRING ) = NULL ) then
		exit function
	end if

	function = proc
end function

'':::::
function rtlAToWstr _
	( _
		byval expr as ASTNODE ptr _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any

	function = NULL

	proc = astNewCALL( PROCLOOKUP( STR2WSTR ) )

	'' byval str as zstring ptr
	if( astNewARG( proc, expr ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
function rtlToStr _
	( _
		byval expr as ASTNODE ptr, _
		byval pad as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as FBSYMBOL ptr f = any, litsym = any
	dim as integer dtype = any

	function = NULL

	dtype = astGetDatatype( expr )

	'' constant? evaluate
	if( astIsCONST( expr ) ) then
		dim s As String
		if( astGetDataType( expr ) = FB_DATATYPE_BOOLEAN ) then

		else
			if( pad ) then
				if( typeIsSigned( astGetDataType( expr ) ) ) then
					if astConstGetAsDouble( expr ) >= 0 then
						s = " "
					end if
				else
					s = " "
				end if
			end if
		end if
		s += astConstFlushToStr( expr )
		return astNewCONSTstr( s )
	end if

	'' wstring literal? convert from unicode at compile-time
	if( dtype = FB_DATATYPE_WCHAR ) then
		litsym = astGetStrLitSymbol( expr )
		if( litsym <> NULL ) then
			if( env.wcharconv <> FB_WCHARCONV_NEVER ) then
				litsym = symbAllocStrConst( str( *symbGetVarLitTextW( litsym ) ), _
				                            symbGetWstrLength( litsym ) )

				return astNewVAR( litsym )
			end if
		end if
	end if

	astTryOvlStringCONV( expr )

	dtype = astGetDataType( expr )

	''
	select case as const astGetDataClass( expr )
	case FB_DATACLASS_INTEGER

		'' Convert pointer to uinteger
		if( typeIsPtr( dtype ) ) then
			expr = astNewCONV( FB_DATATYPE_UINT, NULL, expr )
			dtype = astGetDatatype( expr )
		end if

		select case( dtype )
		'' zstring? do nothing
		case FB_DATATYPE_CHAR
			return expr
		'' wstring? convert..
		case FB_DATATYPE_WCHAR
			return rtlWStrToA( expr )
		'' boolean?
		case FB_DATATYPE_BOOLEAN
			f = PROCLOOKUP( BOOL2STR )
		case else
			select case as const( typeGetSizeType( dtype ) )
			case FB_SIZETYPE_INT64
				f = iif( pad = FALSE, PROCLOOKUP( LONGINT2STR ), PROCLOOKUP( LONGINT2STR_QB ) )
			case FB_SIZETYPE_UINT64
				f = iif( pad = FALSE, PROCLOOKUP( ULONGINT2STR ), PROCLOOKUP( ULONGINT2STR_QB ) )
			case FB_SIZETYPE_UINT8, FB_SIZETYPE_UINT16, FB_SIZETYPE_UINT32
				f = iif( pad = FALSE, PROCLOOKUP( UINT2STR ), PROCLOOKUP( UINT2STR_QB ) )
			case else
				f = iif( pad = FALSE, PROCLOOKUP( INT2STR ), PROCLOOKUP( INT2STR_QB ) )
			end select
		end select

	case FB_DATACLASS_FPOINT
		if( astGetDataType( expr ) = FB_DATATYPE_SINGLE ) then
			f = iif( pad = FALSE, _
			         PROCLOOKUP( FLT2STR ), _
			         PROCLOOKUP( FLT2STR_QB ) )
		else
			f = iif( pad = FALSE, _
			         PROCLOOKUP( DBL2STR ), _
			         PROCLOOKUP( DBL2STR_QB ) )
		end if

	case FB_DATACLASS_STRING
		'' (fork) a managed bare WSTRING is not a narrow string: hand
		'' back a real narrow conversion.  Returning the expression
		'' unchanged would leak UTF-16 bytes into zstring ptr parameters
		'' (FileCopy/FileExists/FileLen/FileDateTime/Dir/Open filenames).
		if( astGetDataType( expr ) = FB_DATATYPE_WSTRING ) then
			return rtlDynWstrToA( expr )
		end if

		'' do nothing
		return expr

	'' UDT's, classes: try cast(string) op overloading
	case FB_DATACLASS_UDT
		return astNewCONV( FB_DATATYPE_STRING, NULL, expr )

	'' anything else, can't convert
	case else
		return NULL
	end select

	''
	proc = astNewCALL( f )

	''
	if( astNewARG( proc, expr ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
'' Internal implementation for legacy raw WCHAR/NUL materialization.
'' Kept private; callers outside this module must use rtlWstrRawBoundary().
private function hLegacyWstrFromExpr _
	( _
		byval expr as ASTNODE ptr _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as FBSYMBOL ptr f = any, litsym = any
	dim as integer dtype

	function = NULL

	dtype = astGetDataType( expr )

	'' Compatibility bridge: WSTR(native-counted-WSTRING) historically yields
	'' an owned legacy WSTRING temporary.  Keep the native descriptor ABI while
	'' returning the logical FB_DATATYPE_WCHAR expected by old WSTR consumers.
	if( dtype = FB_DATATYPE_WSTRING ) then
		proc = astNewCALL( PROCLOOKUP( DWSTRTOWSTR ) )
		if( astNewARG( proc, expr, FB_DATATYPE_WSTRING ) = NULL ) then exit function
		return proc
	end if

	'' constant? evaluate
	if( astIsCONST( expr ) ) then
		return astNewCONSTwstr( astConstFlushToWstr( expr ) )
	end if

	'' string literal? convert to unicode at compile-time
	if( dtype = FB_DATATYPE_CHAR ) then
		litsym = astGetStrLitSymbol( expr )
		if( litsym <> NULL ) then
			if( env.wcharconv <> FB_WCHARCONV_NEVER ) then
				litsym = symbAllocWstrConst( wstr( *symbGetVarLitText( litsym ) ), _
				                             symbGetStrLength( litsym ) )
				return astNewVAR( litsym )
			end if
		end if
	end if

	astTryOvlStringCONV( expr )

	dtype = astGetDataType( expr )

	select case as const astGetDataClass( expr )
	case FB_DATACLASS_INTEGER
		'' Convert pointer to uinteger
		if( typeIsPtr( dtype ) ) then
			expr = astNewCONV( FB_DATATYPE_UINT, NULL, expr )
			dtype = astGetDatatype( expr )
		end if

		select case( dtype )
		'' wstring? do nothing
		case FB_DATATYPE_WCHAR
			return expr
		'' zstring? convert..
		case FB_DATATYPE_CHAR
			return rtlAToWstr( expr )
		'' boolean?
		case FB_DATATYPE_BOOLEAN
			f = PROCLOOKUP( BOOL2WSTR )
		case else
			select case as const( typeGetSizeType( dtype ) )
			case FB_SIZETYPE_INT64
				f = PROCLOOKUP( LONGINT2WSTR )
			case FB_SIZETYPE_UINT64
				f = PROCLOOKUP( ULONGINT2WSTR )
			case FB_SIZETYPE_UINT8, FB_SIZETYPE_UINT16, FB_SIZETYPE_UINT32
				f = PROCLOOKUP( UINT2WSTR )
			case else
				f = PROCLOOKUP( INT2WSTR )
			end select
		end select
	case FB_DATACLASS_FPOINT
		if( astGetDataType( expr ) = FB_DATATYPE_SINGLE ) then
			f = PROCLOOKUP( FLT2WSTR )
		else
			f = PROCLOOKUP( DBL2WSTR )
		end if

	case FB_DATACLASS_STRING
		'' convert
		return rtlAToWstr( expr )

	'' UDT's, classes: try cast(wstring ptr) op overloading
	case FB_DATACLASS_UDT
		return astNewCONV( typeAddrOf( FB_DATATYPE_WCHAR ), NULL, expr )

	'' anything else: can't convert
	case else
		return NULL
	end select

	''
	proc = astNewCALL( f )

	''
	if( astNewARG( proc, expr ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
'' Explicit string-family/managed-WSTRING -> raw WCHAR/NUL compatibility boundary.
function rtlWstrRawBoundary _
	( _
		byval expr as ASTNODE ptr _
	) as ASTNODE ptr

	function = hLegacyWstrFromExpr( expr )
end function

'':::::
'' Materialize an expression as managed FBWSTRING.  Any scalar->raw conversion
'' needed to reuse legacy numeric formatting remains private inside this helper.
function rtlDynWstrFromExpr( byval src as ASTNODE ptr ) as ASTNODE ptr
	if( src = NULL ) then return NULL

	'' Materialize into managed FBWSTRING without routing scalar values through
	'' the legacy raw-WCHAR formatter.  Numeric/boolean/pointer formatting is
	'' deliberately delegated to the mature FBSTRING conversion pipeline, then
	'' widened through the existing FBSTRING -> FBWSTRING assignment bridge.
	''
	'' UDTs are different: a legacy "extends WString" UDT may expose a genuine
	'' ByRef raw-WSTRING cast.  Resolve that cast by type here; it is a real raw
	'' compatibility boundary, not a scalar-formatting intermediate.
	'' First classify by concrete string-family dtype.  FB_DATATYPE_WCHAR is
	'' represented by the INTEGER dataclass internally, but semantically it is a
	'' raw wide-string expression here and must never be numeric-formatted.
	select case as const astGetDataType( src )
	case FB_DATATYPE_WSTRING, FB_DATATYPE_WCHAR, FB_DATATYPE_STRING, _
	     FB_DATATYPE_FIXSTR, FB_DATATYPE_CHAR
		'' Already a string-family expression; rtlDynWstrAssign() below selects
		'' the managed/native/raw boundary from the AST dtype.

	case else
		select case as const astGetDataClass( src )
		case FB_DATACLASS_INTEGER, FB_DATACLASS_FPOINT
			src = rtlToStr( src, FALSE )
			if( src = NULL ) then return NULL

		case FB_DATACLASS_UDT
			if( astTryOvlStringCONV( src ) = FALSE ) then return NULL

		case else
			return NULL
		end select
	end select

	dim as FBSYMBOL ptr tmp = symbAddTempVar( FB_DATATYPE_WSTRING )
	dim as ASTNODE ptr proc = rtlDynWstrAssign( astNewVAR( tmp ), src, -2, TRUE )
	if( proc = NULL ) then return NULL
	astDtorListAdd( tmp )
	function = astNewLINK( proc, astNewVAR( tmp ), AST_LINK_RETURN_RIGHT )
end function

'':::::
function rtlStrToVal _
	( _
		byval expr as ASTNODE ptr, _
		byval to_dtype as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as FBSYMBOL ptr f = any, s = any
	dim as FB_CALL_ARG arg = any
	dim as FB_ERRMSG err_num = any

	function = NULL

	'' Convert pointer to uinteger
	if( typeIsPtr( to_dtype ) ) then
		expr = astNewCONV( FB_DATATYPE_UINT, NULL, expr )
	end if

	select case as const typeGet( to_dtype )
	case FB_DATATYPE_SINGLE, FB_DATATYPE_DOUBLE
		f = PROCLOOKUP( STR2DBL )

	case FB_DATATYPE_BOOLEAN
		f = PROCLOOKUP( STR2BOOL )

	case FB_DATATYPE_BYTE, FB_DATATYPE_UBYTE, _
	     FB_DATATYPE_SHORT, FB_DATATYPE_USHORT, _
	     FB_DATATYPE_INTEGER, FB_DATATYPE_ENUM, FB_DATATYPE_UINT, _
	     FB_DATATYPE_LONG, FB_DATATYPE_ULONG, FB_DATATYPE_POINTER, _
	     FB_DATATYPE_LONGINT, FB_DATATYPE_ULONGINT

		select case as const( typeGetSizeType( to_dtype ) )
		case FB_SIZETYPE_INT64
			f = PROCLOOKUP( STR2LNG )
		case FB_SIZETYPE_UINT64
			f = PROCLOOKUP( STR2ULNG )
		case FB_SIZETYPE_INT8, FB_SIZETYPE_INT16, FB_SIZETYPE_INT32
			f = PROCLOOKUP( STR2INT )
		case FB_SIZETYPE_UINT8, FB_SIZETYPE_UINT16, FB_SIZETYPE_UINT32
			f = PROCLOOKUP( STR2UINT )
		end select

	'' UDT's, classes: try cast(to_dtype) op overloading
	case FB_DATATYPE_STRUCT ', FB_DATATYPE_CLASS
		return astNewCONV( to_dtype, NULL, expr )

	case else
		'' anything else..
		exit function
	end select

	'' resolve zstring or wstring
	arg.expr = expr
	arg.mode = INVALID
	arg.next = NULL
	f = symbFindClosestOvlProc( f, 1, @arg, @err_num )
	if( f = NULL ) then
		exit function
	end if

	proc = astNewCALL( f )

	''
	if( astNewARG( proc, expr ) = NULL ) then
		exit function
	end if

	function = astNewCONV( to_dtype, NULL, proc )

end function

'':::::
function rtlStrMid _
	( _
		byval expr1 as ASTNODE ptr, _
		byval expr2 as ASTNODE ptr, _
		byval expr3 as ASTNODE ptr _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any

	function = NULL

	astTryOvlStringCONV( expr1 )

	if( astGetDataType( expr1 ) = FB_DATATYPE_WSTRING ) then
		return rtlDynWstrMidResult( expr1, expr2, expr3 )
	end if

	if( astGetDataType( expr1 ) <> FB_DATATYPE_WCHAR ) then
		proc = astNewCALL( PROCLOOKUP( STRMID ) )
	else
		proc = astNewCALL( PROCLOOKUP( WSTRMID ) )
	end if

	''
	if( astNewARG( proc, expr1 ) = NULL ) then
		exit function
	end if

	if( astNewARG( proc, expr2 ) = NULL ) then
		exit function
	end if

	if( astNewARG( proc, expr3 ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
function rtlStrAssignMid _
	( _
		byval expr1 as ASTNODE ptr, _
		byval expr2 as ASTNODE ptr, _
		byval expr3 as ASTNODE ptr, _
		byval expr4 as ASTNODE ptr _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as longint dst_len = any

	function = NULL

	astTryOvlStringCONV( expr1 )

	'' Native counted WSTRING MID assignment uses descriptor lengths and never
	'' changes dst.len; embedded NUL is ordinary content.
	if( astGetDataType( expr1 ) = FB_DATATYPE_WSTRING ) then
		dim as ASTNODE ptr prep = NULL
		expr4 = hDynWstrCoerceForCompare( expr4, prep )
		if( expr4 = NULL ) then exit function
		proc = astNewCALL( PROCLOOKUP( DWSTRMIDASSIGN ) )
		if( astNewARG( proc, expr1, FB_DATATYPE_WSTRING ) = NULL ) then exit function
		if( astNewARG( proc, expr2 ) = NULL ) then exit function
		if( astNewARG( proc, expr3 ) = NULL ) then exit function
		if( astNewARG( proc, expr4, FB_DATATYPE_WSTRING ) = NULL ) then exit function
		astAdd( astNewLINK( prep, proc, AST_LINK_RETURN_NONE ) )
		function = proc
		exit function
	end if

	''
	if( astGetDataType( expr1 ) <> FB_DATATYPE_WCHAR ) then
		proc = astNewCALL( PROCLOOKUP( STRASSIGNMID ) )
		dst_len = -1
	else
		proc = astNewCALL( PROCLOOKUP( WSTRASSIGNMID ) )
		'' Raw WString * N / WString Ptr is a compatibility boundary.  A managed
		'' bare-WString RHS is converted here (and only here) to the NUL-terminated
		'' WCHAR view expected by the legacy MID runtime, mirroring String/ZString
		'' boundary materialization instead of changing the WChr()/IIF producer.
		if( astGetDataType( expr4 ) = FB_DATATYPE_WSTRING ) then
			expr4 = rtlWstrRawBoundary( expr4 )
			if( expr4 = NULL ) then exit function
		end if
		'' always calc len before pushing the param
		dst_len = rtlCalcStrLen( expr1, FB_DATATYPE_WCHAR )
	end if

	''
	if( astNewARG( proc, expr1 ) = NULL ) then
		exit function
	end if

	''
	if( dst_len <> -1 ) then
		if( astNewARG( proc, astNewCONSTi( dst_len ) ) = NULL ) then
			exit function
		end if
	end if

	if( astNewARG( proc, expr2 ) = NULL ) then
		exit function
	end if

	if( astNewARG( proc, expr3 ) = NULL ) then
		exit function
	end if

	if( astNewARG( proc, expr4 ) = NULL ) then
		exit function
	end if

	''
	astAdd( proc )

	function = proc

end function

'':::::
function rtlStrLRSet _
	( _
		byval dstexpr as ASTNODE ptr, _
		byval srcexpr as ASTNODE ptr, _
		byval is_rset as integer _
	) as integer

	dim as ASTNODE ptr proc = any
	dim as integer ddtype = any
	dim as longint dst_size = any

	function = FALSE

	ddtype = astGetDataType( dstexpr )

	select case ddtype
	case FB_DATATYPE_WSTRING
		proc = astNewCALL( PROCLOOKUP( DWSTRLRSET ) )
	case FB_DATATYPE_WCHAR
		proc = astNewCALL( iif( is_rset, _
		                        PROCLOOKUP( WSTRRSET ), _
		                        PROCLOOKUP( WSTRLSET ) ) )
	case FB_DATATYPE_FIXSTR
		proc = astNewCALL( iif( is_rset, _
		                        PROCLOOKUP( STRRSETANA ), _
		                        PROCLOOKUP( STRLSETANA ) ) )
	case else
		proc = astNewCALL( iif( is_rset, _
		                        PROCLOOKUP( STRRSET ), _
		                        PROCLOOKUP( STRLSET ) ) )
	end select

	'' dst as string | dst as any
	if( astNewARG( proc, dstexpr ) = NULL ) then
		exit function
	end if

	if( ddtype = FB_DATATYPE_FIXSTR ) then
		'' always calc len before pushing the param
		dst_size = rtlCalcStrLen( dstexpr, ddtype )

		'' byval dst_size as integer
		if( astNewARG( proc, astNewCONSTi( dst_size ) ) = NULL ) then
			exit function
		end if
	end if

	'' src as string/native wstring
	if( astNewARG( proc, srcexpr ) = NULL ) then
		exit function
	end if

	if( ddtype = FB_DATATYPE_WSTRING ) then
		if( astNewARG( proc, astNewCONSTi( iif( is_rset, 1, 0 ), FB_DATATYPE_LONG ), FB_DATATYPE_LONG ) = NULL ) then
			exit function
		end if
	end if

	''
	astAdd( proc )

	function = TRUE

end function

'':::::
function rtlStrFill _
	( _
		byval expr1 as ASTNODE ptr, _
		byval expr2 as ASTNODE ptr _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as FBSYMBOL ptr f = any

	function = NULL

	select case astGetDataType( expr2 )
	case FB_DATATYPE_STRING, FB_DATATYPE_FIXSTR, FB_DATATYPE_CHAR
		f = PROCLOOKUP( STRFILL2 )
	case else
		f = PROCLOOKUP( STRFILL1 )
	end select

	proc = astNewCALL( f )

	''
	if( astNewARG( proc, expr1 ) = NULL ) then
		exit function
	end if

	if( astNewARG( proc, expr2 ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
function rtlWstrFill _
	( _
		byval expr1 as ASTNODE ptr, _
		byval expr2 as ASTNODE ptr _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as FBSYMBOL ptr f = any

	function = NULL

	if( astGetDataType( expr2 ) = FB_DATATYPE_WCHAR ) then
		f = PROCLOOKUP( WSTRFILL2 )
	else
		f = PROCLOOKUP( WSTRFILL1 )
	end if

	proc = astNewCALL( f )

	''
	if( astNewARG( proc, expr1 ) = NULL ) then
		exit function
	end if

	if( astNewARG( proc, expr2 ) = NULL ) then
		exit function
	end if

	function = proc

end function

function rtlStrLen( byval expr as ASTNODE ptr ) as ASTNODE ptr
	dim as ASTNODE ptr proc = any
	dim as longint length = any

	function = NULL

	proc = astNewCALL( PROCLOOKUP( STRLEN ) )

	'' always calc len before pushing the param
	length = rtlCalcStrLen( expr, astGetDataType( expr ) )

	'' str as any
	if( astNewARG( proc, expr, FB_DATATYPE_STRING ) = NULL ) then
		exit function
	end if

	'' byval strlen as integer
	if( astNewARG( proc, astNewCONSTi( length ) ) = NULL ) then
		exit function
	end if

	function = proc
end function

function rtlWstrLen( byval expr as ASTNODE ptr ) as ASTNODE ptr
	dim as ASTNODE ptr proc = any

	function = NULL

	proc = astNewCALL( PROCLOOKUP( WSTRLEN ) )

	'' byval str as wchar ptr
	if( astNewARG( proc, expr ) = NULL ) then
		exit function
	end if

	function = proc
end function

'':::::
function rtlStrAsc _
	( _
		byval expr as ASTNODE ptr, _
		byval posexpr as ASTNODE ptr _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any

	function = NULL

	astTryOvlStringCONV( expr )

	''
	if( astGetDataType( expr ) = FB_DATATYPE_WSTRING ) then
		return rtlDynWstrAsc( expr, posexpr )
	elseif( astGetDataType( expr ) <> FB_DATATYPE_WCHAR ) then
		proc = astNewCALL( PROCLOOKUP( STRASC ) )
	else
		proc = astNewCALL( PROCLOOKUP( WSTRASC ) )
	end if

	'' src as string
	if( astNewARG( proc, expr ) = NULL ) then
		exit function
	end if

	'' byval pos as integer
	if( posexpr = NULL ) then
		posexpr = astNewCONSTi( 1 )
	end if

	if( astNewARG( proc, posexpr ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
function rtlStrChr _
	( _
		byval args as integer, _
		exprtb() as ASTNODE ptr, _
		byval is_wstr as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any, expr = any
	dim as integer dtype = any

	function = NULL

	if( is_wstr = FALSE ) then
		proc = astNewCALL( PROCLOOKUP( STRCHR ) )
	else
		proc = astNewCALL( PROCLOOKUP( WSTRCHR ) )
	end if

	'' byval args as integer
	if( astNewARG( proc, astNewCONSTi( args ) ) = NULL ) then
		exit function
	end if

	'' ...
	for i as integer = 0 to args-1
		expr = exprtb(i)
		dtype = astGetDatatype( expr )

		'' check if non-numeric
		if( astGetDataClass( expr ) >= FB_DATACLASS_STRING ) then
			errReportEx( FB_ERRMSG_PARAMTYPEMISMATCHAT, "at parameter: " + str( i+1 ) )
			exit function
		end if

		'' don't allow w|zstring's either..
		select case as const dtype
		case FB_DATATYPE_CHAR, FB_DATATYPE_WCHAR
			errReportEx( FB_ERRMSG_PARAMTYPEMISMATCHAT, "at parameter: " + str( i+1 ) )
			exit function

		case FB_DATATYPE_INTEGER

		'' convert to int as chr() is a varargs function
		case else
			expr = astNewCONV( FB_DATATYPE_INTEGER, NULL, expr )
		end select

		if( astNewARG( proc, expr, FB_DATATYPE_INTEGER ) = NULL ) then
			exit function
		end if
	next

	function = proc

end function

'':::::
function rtlStrInstr _
	( _
		byval nd_start as ASTNODE ptr, _
		byval nd_text as ASTNODE ptr, _
		byval nd_pattern as ASTNODE ptr, _
		byval search_any as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as FBSYMBOL ptr f = any
	dim as integer dtype = any

	function = NULL

	astTryOvlStringCONV( nd_text )
	if( nd_pattern ) then
		astTryOvlStringCONV( nd_pattern )
	end if

	dtype = astGetDataType( nd_text )

	'' Native counted WSTRING: preserve embedded NUL by coercing only the
	'' pattern into a native descriptor and using explicit descriptor lengths.
	if( dtype = FB_DATATYPE_WSTRING ) then
		dim as ASTNODE ptr prep = NULL
		nd_pattern = hDynWstrCoerceForCompare( nd_pattern, prep )
		if( nd_pattern = NULL ) then exit function
		f = iif( search_any, PROCLOOKUP( DWSTRINSTRANY ), PROCLOOKUP( DWSTRINSTR ) )
		proc = astNewCALL( f )
		if( astNewARG( proc, nd_start ) = NULL ) then exit function
		if( astNewARG( proc, nd_text, FB_DATATYPE_WSTRING ) = NULL ) then exit function
		if( astNewARG( proc, nd_pattern, FB_DATATYPE_WSTRING ) = NULL ) then exit function
		return astNewLINK( prep, proc, AST_LINK_RETURN_RIGHT )
	end if

	''
	if( search_any ) then
		if( dtype <> FB_DATATYPE_WCHAR ) then
			f = PROCLOOKUP( STRINSTRANY )
		else
			f = PROCLOOKUP( WSTRINSTRANY )
		end if
	else
		if( dtype <> FB_DATATYPE_WCHAR ) then
			f = PROCLOOKUP( STRINSTR )
		else
			f = PROCLOOKUP( WSTRINSTR )
		end if
	end if

	proc = astNewCALL( f )

	''
	if( astNewARG( proc, nd_start ) = NULL ) then
		exit function
	end if

	if( astNewARG( proc, nd_text ) = NULL ) then
		exit function
	end if

	if( astNewARG( proc, nd_pattern ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
function rtlStrInstrRev _
	( _
		byval nd_start as ASTNODE ptr, _
		byval nd_text as ASTNODE ptr, _
		byval nd_pattern as ASTNODE ptr, _
		byval search_any as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as FBSYMBOL ptr f = any
	dim as integer dtype = any

	function = NULL

	astTryOvlStringCONV( nd_text )
	if( nd_pattern ) then
		astTryOvlStringCONV( nd_pattern )
	end if

	dtype = astGetDataType( nd_text )

	if( dtype = FB_DATATYPE_WSTRING ) then
		dim as ASTNODE ptr prep = NULL
		nd_pattern = hDynWstrCoerceForCompare( nd_pattern, prep )
		if( nd_pattern = NULL ) then exit function
		f = iif( search_any, PROCLOOKUP( DWSTRINSTRREVANY ), PROCLOOKUP( DWSTRINSTRREV ) )
		proc = astNewCALL( f )
		if( astNewARG( proc, nd_text, FB_DATATYPE_WSTRING ) = NULL ) then exit function
		if( astNewARG( proc, nd_pattern, FB_DATATYPE_WSTRING ) = NULL ) then exit function
		if( astNewARG( proc, nd_start ) = NULL ) then exit function
		return astNewLINK( prep, proc, AST_LINK_RETURN_RIGHT )
	end if

	''
	if( search_any ) then
		if( dtype <> FB_DATATYPE_WCHAR ) then
			f = PROCLOOKUP( STRINSTRREVANY )
		else
			f = PROCLOOKUP( WSTRINSTRREVANY )
		end if
	else
		if( dtype <> FB_DATATYPE_WCHAR ) then
			f = PROCLOOKUP( STRINSTRREV )
		else
			f = PROCLOOKUP( WSTRINSTRREV )
		end if
	end if

	proc = astNewCALL( f )

	if( astNewARG( proc, nd_text ) = NULL ) then
		exit function
	end if

	if( astNewARG( proc, nd_pattern ) = NULL ) then
		exit function
	end if

	''
	if( astNewARG( proc, nd_start ) = NULL ) then
		exit function
	end if

	function = proc

end function

'':::::
function rtlStrTrim _
	( _
		byval nd_text as ASTNODE ptr, _
		byval nd_pattern as ASTNODE ptr, _
		byval is_any as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as FBSYMBOL ptr f = any
	dim as integer dtype = any

	function = NULL

	astTryOvlStringCONV( nd_text )
	if( nd_pattern ) then
		astTryOvlStringCONV( nd_pattern )
	end if

	dtype = astGetDataType( nd_text )

	if( dtype = FB_DATATYPE_WSTRING ) then
		if( (nd_pattern = NULL) and (is_any = FALSE) ) then
			return rtlDynWstrTrimSimpleResult( nd_text, 0 )
		else
			return rtlDynWstrTrimPatternResult( nd_text, nd_pattern, 0, is_any )
		end if
	end if

	''
	if( is_any ) then
		if( dtype <> FB_DATATYPE_WCHAR ) then
			f = PROCLOOKUP( STRTRIMANY )
		else
			f = PROCLOOKUP( WSTRTRIMANY )
		end if
	elseif( nd_pattern <> NULL ) then
		if( dtype <> FB_DATATYPE_WCHAR ) then
			f = PROCLOOKUP( STRTRIMEX )
		else
			f = PROCLOOKUP( WSTRTRIMEX )
		end if
	else
		if( dtype <> FB_DATATYPE_WCHAR ) then
			f = PROCLOOKUP( STRTRIM )
		else
			f = PROCLOOKUP( WSTRTRIM )
		end if
	end if
	proc = astNewCALL( f )

	''
	if( astNewARG( proc, nd_text ) = NULL ) then
		exit function
	end if

	if( nd_pattern<>NULL or is_any ) then
		if( astNewARG( proc, nd_pattern ) = NULL ) then
			exit function
		end if
	end if

	function = proc

end function

'':::::
function rtlStrRTrim _
	( _
		byval nd_text as ASTNODE ptr, _
		byval nd_pattern as ASTNODE ptr, _
		byval is_any as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as FBSYMBOL ptr f = any
	dim as integer dtype = any

	function = NULL

	astTryOvlStringCONV( nd_text )
	if( nd_pattern ) then
		astTryOvlStringCONV( nd_pattern )
	end if

	dtype = astGetDataType( nd_text )

	if( dtype = FB_DATATYPE_WSTRING ) then
		if( (nd_pattern = NULL) and (is_any = FALSE) ) then
			return rtlDynWstrTrimSimpleResult( nd_text, 1 )
		else
			return rtlDynWstrTrimPatternResult( nd_text, nd_pattern, 1, is_any )
		end if
	end if

	''
	if( is_any ) then
		if( dtype <> FB_DATATYPE_WCHAR ) then
			f = PROCLOOKUP( STRRTRIMANY )
		else
			f = PROCLOOKUP( WSTRRTRIMANY )
		end if
	elseif( nd_pattern <> NULL ) then
		if( dtype <> FB_DATATYPE_WCHAR ) then
			f = PROCLOOKUP( STRRTRIMEX )
		else
			f = PROCLOOKUP( WSTRRTRIMEX )
		end if
	else
		if( dtype <> FB_DATATYPE_WCHAR ) then
			f = PROCLOOKUP( STRRTRIM )
		else
			f = PROCLOOKUP( WSTRRTRIM )
		end if
	end if
	proc = astNewCALL( f )

	''
	if( astNewARG( proc, nd_text ) = NULL ) then
		exit function
	end if

	if( nd_pattern<>NULL or is_any ) then
		if( astNewARG( proc, nd_pattern ) = NULL ) then
			exit function
		end if
	end if

	function = proc

end function

'':::::
function rtlStrLTrim _
	( _
		byval nd_text as ASTNODE ptr, _
		byval nd_pattern as ASTNODE ptr, _
		byval is_any as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as FBSYMBOL ptr f = any
	dim as integer dtype = any

	function = NULL

	astTryOvlStringCONV( nd_text )
	if( nd_pattern ) then
		astTryOvlStringCONV( nd_pattern )
	end if

	dtype = astGetDataType( nd_text )

	if( dtype = FB_DATATYPE_WSTRING ) then
		if( (nd_pattern = NULL) and (is_any = FALSE) ) then
			return rtlDynWstrTrimSimpleResult( nd_text, -1 )
		else
			return rtlDynWstrTrimPatternResult( nd_text, nd_pattern, -1, is_any )
		end if
	end if

	''
	if( is_any ) then
		if( dtype <> FB_DATATYPE_WCHAR ) then
			f = PROCLOOKUP( STRLTRIMANY )
		else
			f = PROCLOOKUP( WSTRLTRIMANY )
		end if
	elseif( nd_pattern <> NULL ) then
		if( dtype <> FB_DATATYPE_WCHAR ) then
			f = PROCLOOKUP( STRLTRIMEX )
		else
			f = PROCLOOKUP( WSTRLTRIMEX )
		end if
	else
		if( dtype <> FB_DATATYPE_WCHAR ) then
			f = PROCLOOKUP( STRLTRIM )
		else
			f = PROCLOOKUP( WSTRLTRIM )
		end if
	end if
	proc = astNewCALL( f )

	''
	if( astNewARG( proc, nd_text ) = NULL ) then
		exit function
	end if

	if( nd_pattern<>NULL or is_any ) then
		if( astNewARG( proc, nd_pattern ) = NULL ) then
			exit function
		end if
	end if

	function = proc

end function

'' Takes the text from a string literal symbol and performs ASCII-only
'' Lcase/Ucase on it. The result is a new literal symbol holding the
'' lcased/ucased text.
private function hEvalAscCase _
	( _
		byval literal as FBSYMBOL ptr, _
		byval is_lcase as integer _
	) as FBSYMBOL ptr

	dim as wstring ptr w = any
	dim as zstring ptr z = any
	dim as integer reallength = any, internallength = any
	dim as integer char = any, chara = any, charz = any, chardiff = any

	function = NULL

	'' Convert to lower case?
	if( is_lcase ) then
		chara = asc( "A" )
		charz = asc( "Z" )
		chardiff = asc( "a" ) - asc( "A" )
	else
		chara = asc( "a" )
		charz = asc( "z" )
		chardiff = cint( asc( "A" ) ) - cint( asc( "a" ) )
	end if

	if( symbGetType( literal ) = FB_DATATYPE_WCHAR ) then
		w = symbGetVarLitTextW( literal )
		internallength = len( *w )
		w = hUnescapeW( w )
		reallength = symbGetWstrLength( literal )

		if( internallength <> reallength ) then
			exit function
		end if

		for i as integer = 0 to reallength - 1
			char = (*w)[i]
			if( (char >= chara) and (char <= charz) ) then
				char += chardiff
			end if
			(*w)[i] = char
		next

		function = symbAllocWstrConst( w, reallength )
	else
		z = symbGetVarLitText( literal )
		internallength = len( *z )
		z = hUnescape( z )
		reallength = symbGetStrLength( literal )

		'' Don't do it if it includes internal escape sequences,
		'' handling these here would be quite hard... (TODO)
		'' On one hand we should handle "A" disguised as !"\&h41" which
		'' internally is something involving FB_INTSCAPECHAR; on the
		'' other hand to do that we'd have to solve the internal escape
		'' sequences, do the lcase/ucase, and then re-create internal
		'' escape sequences where needed.
		if( internallength <> reallength ) then
			exit function
		end if

		for i as integer = 0 to reallength - 1
			char = (*z)[i]
			if( (char >= chara) and (char <= charz) ) then
				char += chardiff
			end if
			(*z)[i] = char
		next

		function = symbAllocStrConst( z, reallength )
	end if
end function

function rtlStrCase _
	( _
		byval expr as ASTNODE ptr, _
		byval mode as ASTNODE ptr, _
		byval is_lcase as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr proc = any
	dim as FBSYMBOL ptr f = any, literal = any

	'' Evalute ASCII-only Lcase/Ucase at compile-time if possible.

	'' Mode given?
	if( mode ) then
		'' Constant string?
		literal = astGetStrLitSymbol( expr )
		if( literal ) then
			'' Constant mode?
			if( astIsCONST( mode ) ) then
				'' ASCII-only mode (1)?
				if( astConstGetAsInt64( mode ) = 1 ) then
					literal = hEvalAscCase( literal, is_lcase )
					if( literal ) then
						return astNewVAR( literal )
					end if
				end if
			end if
		end if
	end if

	astTryOvlStringCONV( expr )

	if( astGetDataType( expr ) = FB_DATATYPE_WSTRING ) then
		return rtlDynWstrCaseResult( expr, mode, is_lcase )
	end if

	if( is_lcase ) then
		if( astGetDataType( expr ) = FB_DATATYPE_WCHAR ) then
			f = PROCLOOKUP( WSTRLCASE2 )
		else
			f = PROCLOOKUP( STRLCASE2 )
		end if
	else
		if( astGetDataType( expr ) = FB_DATATYPE_WCHAR ) then
			f = PROCLOOKUP( WSTRUCASE2 )
		else
			f = PROCLOOKUP( STRUCASE2 )
		end if
	end if

	proc = astNewCALL( f )

	if( astNewARG( proc, expr ) = NULL ) then
		exit function
	end if

	'' mode can be NULL, in which case the param's default arg will be used
	if( astNewARG( proc, mode ) = NULL ) then
		exit function
	end if

	function = proc
end function

'':::::
function rtlStrSwap _
	( _
		byval str1 as ASTNODE ptr, _
		byval str2 as ASTNODE ptr _
	) as integer

	function = FALSE

	var proc = astNewCALL( PROCLOOKUP( STRSWAP ) )

	'' always calc len before pushing the param
	var dtype1 = astGetDataType( str1 )
	var length1 = rtlCalcStrLen( str1, dtype1 )

	'' always calc len before pushing the param
	var dtype2 = astGetDataType( str2 )
	var length2 = rtlCalcStrLen( str2, dtype2 )

	'' byref str1 as any
	if( astNewARG( proc, str1, FB_DATATYPE_STRING ) = NULL ) then
		exit function
	end if

	'' byval len1 as integer
	if( astNewARG( proc, astNewCONSTi( length1 ) ) = NULL ) then
		exit function
	end if

	'' byval fillrem1 as integer = 1
	if( astNewARG( proc, astNewCONSTi( (dtype1 = FB_DATATYPE_FIXSTR) ) ) = NULL ) then
		exit function
	end if

	'' byref str2 as any
	if( astNewARG( proc, str2, FB_DATATYPE_STRING ) = NULL ) then
		exit function
	end if

	'' byval len2 as integer
	if( astNewARG( proc, astNewCONSTi( length2 ) ) = NULL ) then
		exit function
	end if

	'' byval fillrem2 as integer = 1
	if( astNewARG( proc, astNewCONSTi( (dtype2 = FB_DATATYPE_FIXSTR) ) ) = NULL ) then
		exit function
	end if

	astAdd( proc )

	function = TRUE
end function

'':::::
function rtlWstrSwap _
	( _
		byval str1 as ASTNODE ptr, _
		byval str2 as ASTNODE ptr _
	) as integer

	function = FALSE

	var proc = astNewCALL( PROCLOOKUP( WSTRSWAP ) )

	'' always calc len before pushing the param
	var length = rtlCalcStrLen( str1, astGetDataType( str1 ) )

	'' byval str1 as wstring ptr
	if( astNewARG( proc, str1 ) = NULL ) then
		exit function
	end if

	'' byval len1 as integer
	if( astNewARG( proc, astNewCONSTi( length ) ) = NULL ) then
		exit function
	end if

	'' always calc len before pushing the param
	length = rtlCalcStrLen( str2, astGetDataType( str2 ) )

	'' byval str2 as wstring ptr
	if( astNewARG( proc, str2 ) = NULL ) then
		exit function
	end if

	'' byval len2 as integer
	if( astNewARG( proc, astNewCONSTi( length ) ) = NULL ) then
		exit function
	end if

	astAdd( proc )

	function = TRUE
end function
