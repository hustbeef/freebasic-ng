'' quirk conditional statement (IIF) parsing
''
'' chng: sep/2004 written [v1ctor]


#include once "fb.bi"
#include once "fbint.bi"
#include once "parser.bi"
#include once "ast.bi"
#include once "rtl.bi"

'' cIIFFunct  =  IIF '(' condition-expr ',' true-expr ',' false-expr ')' .
function cIIFFunct() as ASTNODE ptr
	dim as ASTNODE ptr expr = any, truexpr = any, falsexpr = any
	dim as integer truecookie = any, falsecookie = any

	function = NULL

	'' The condition expression is always executed,
	'' the true/false expressions only conditionally though.

	'' IIF
	lexSkipToken( LEXCHECK_POST_SUFFIX )

	'' '('
	hMatchLPRNT( )

	'' condition-expr
	hMatchExpressionEx( expr, FB_DATATYPE_INTEGER )

	'' ','
	hMatchCOMMA( )

	'' true-expr
	'' Wide-string producers decide their own managed/raw representation.  IIF
	'' only parses branches and resolves their common AST type; it must not peek
	'' at source tokens or manufacture a representation context.
	astDtorListScopeBegin( )
	truexpr = hMatchExpr( FB_DATATYPE_INTEGER )
	truecookie = astDtorListScopeEnd( )
	if( truexpr = NULL ) then
		exit function
	end if

	'' ','
	hMatchCOMMA( )

	'' false-expr
	astDtorListScopeBegin( )
	falsexpr = hMatchExpr( astGetDataType( truexpr ) )
	falsecookie = astDtorListScopeEnd( )
	if( falsexpr = NULL ) then
		exit function
	end if

	'' String-family branches must unify: a narrow literal alongside a
	'' managed WSTRING widens to managed WSTRING, so both
	'' IIf(c, "lit", wstr) and IIf(c, wstr, "lit") select the wide owner
	'' form instead of failing the branch-type match.
	dim as integer truedt = any, falsedt = any
	truedt = astGetDataType( truexpr )
	falsedt = astGetDataType( falsexpr )
	if( truedt <> falsedt ) then
		select case as const truedt
		case FB_DATATYPE_STRING, FB_DATATYPE_FIXSTR, FB_DATATYPE_CHAR, FB_DATATYPE_WCHAR
			select case as const falsedt
			case FB_DATATYPE_STRING, FB_DATATYPE_FIXSTR, FB_DATATYPE_CHAR, FB_DATATYPE_WCHAR
			case FB_DATATYPE_WSTRING
				'' Widen inside the true-branch dtor-list scope: the
				'' materialization temp must be destructed only on the
				'' branch that evaluates it.  Registered at the statement
				'' level instead, its descriptor would be uninitialized
				'' stack memory whenever the other branch was taken.
				astDtorListScopeBegin( truecookie )
				truexpr = rtlDynWstrFromExpr( truexpr )
				truecookie = astDtorListScopeEnd( )
			end select

		case FB_DATATYPE_WSTRING
			select case as const falsedt
			case FB_DATATYPE_STRING, FB_DATATYPE_FIXSTR, FB_DATATYPE_CHAR, FB_DATATYPE_WCHAR
				'' Same as above, for the false branch.
				astDtorListScopeBegin( falsecookie )
				falsexpr = rtlDynWstrFromExpr( falsexpr )
				falsecookie = astDtorListScopeEnd( )
			end select
		end select
	end if

	'' ')'
	hMatchRPRNT( )

	expr = astNewIIF( expr, truexpr, truecookie, falsexpr, falsecookie )
	if( expr = NULL ) then
		errReport( FB_ERRMSG_INVALIDDATATYPES, TRUE )
		'' error recovery: fake an expr
		expr = astNewCONSTi( 0 )
	end if

	function = expr
end function
