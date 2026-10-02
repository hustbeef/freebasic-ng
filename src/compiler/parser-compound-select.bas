'' SELECT CASE [AS CONST]..CASE..END SELECT compound statement parsing
''
'' chng: sep/2004 written [v1ctor]


#include once "fb.bi"
#include once "fbint.bi"
#include once "parser.bi"
#include once "ast.bi"
#include once "rtl.bi"

enum FB_CASETYPE
	FB_CASETYPE_SINGLE
	FB_CASETYPE_RANGE
	FB_CASETYPE_IS
	FB_CASETYPE_ELSE
end enum

const FB_MAXCASEEXPR    = 1024

type FBCASECTX
	typ         as FB_CASETYPE
	op          as integer
	expr1       as ASTNODE ptr
	expr2       as ASTNODE ptr
	dtor1       as ASTNODE ptr
	dtor2       as ASTNODE ptr
end type

type FBCTX
	base        as integer
	caseTB(0 to FB_MAXCASEEXPR-1) as FBCASECTX
end type

'' globals
	dim shared ctx as FBCTX

sub parserSelectStmtInit( )
	ctx.base = 0
end sub

sub parserSelectStmtEnd( )
end sub

'' SelectStatement  =  SELECT CASE (AS CONST)? Expression .
sub cSelectStmtBegin( )
	dim as ASTNODE ptr expr = any
	dim as integer dtype = any, options = any
	dim as FBSYMBOL ptr sym = any, el = any, subtype = any
	dim as FB_CMPSTMTSTK ptr stk = any

	'' SELECT
	lexSkipToken( LEXCHECK_POST_SUFFIX )

	'' CASE
	if( hMatch( FB_TK_CASE, LEXCHECK_POST_SUFFIX ) = FALSE ) then
		errReport( FB_ERRMSG_EXPECTEDCASE )
	end if

	'' AS?
	if( lexGetToken( ) = FB_TK_AS ) then
		lexSkipToken( LEXCHECK_POST_SUFFIX )

		'' CONST?
		if( hMatch( FB_TK_CONST, LEXCHECK_POST_SUFFIX ) ) then
			cSelConstStmtBegin()
			return
		end if

		errReport( FB_ERRMSG_SYNTAXERROR )
	end if

	''
	'' Open outer scope
	''
	'' This is used to enclose the temporary created below, to make sure
	'' it's destroyed at the END SELECT, not later. And scoping the temp
	'' also frees up its stack space later.
	''
	'' The scope must be created before parsing the expression given to
	'' SELECT, otherwise any temporaries it uses would be destroyed too
	'' early by astScopeBegin() because that flushes the AST dtor list.
	''
	dim as ASTNODE ptr outerscopenode = astScopeBegin( )
	if( outerscopenode = NULL ) then
		errReport( FB_ERRMSG_RECLEVELTOODEEP )
	end if

	'' Expression representation is determined by the producer/type system.
	expr = cExpression( )
	if( expr = NULL ) then
		errReport( FB_ERRMSG_EXPECTEDEXPRESSION )
		'' error recovery: fake an expr
		expr = astNewCONSTi( 0 )
	end if

	astTryOvlStringCONV( expr )

	'' can't be an UDT
	if( astGetDataType( expr ) = FB_DATATYPE_STRUCT ) then
		errReport( FB_ERRMSG_INVALIDDATATYPES )
		astDelTree( expr )
		'' error recovery: fake an expr
		expr = astNewCONSTi( 0 )
	end if

	'' add exit label
	el = symbAddLabel( NULL, FB_SYMBOPT_NONE )

	sym = NULL
	dtype = astGetFullType( expr )
	subtype = astGetSubType( expr )

	var effectiveexpr = astGetEffectiveNode( expr )
	if( astIsVAR( effectiveexpr ) ) then
		sym = astGetSymbol( effectiveexpr )
	end if
	if( (sym <> NULL) andalso (symbIsTemp( sym ) = FALSE) ) then
		'' No need to copy to a temp var when the expression is a real
		'' user/implicit variable already.  A native WSTRING expression may
		'' expose a compiler temporary as its effective node; that temporary
		'' is owned by the AST dtor list and must be copied into SELECT's
		'' outer-scope variable before the dtor list is flushed.
		astAdd( astRebuildWithoutEffectivePart( expr ) )
	else
		sym = NULL
		'' Store expression into a temp var
		select case typeGet( dtype )
		'' fixed-len or zstring? temp will be a var-len string..
		case FB_DATATYPE_FIXSTR, FB_DATATYPE_CHAR
			dtype = FB_DATATYPE_STRING
		end select

		options = 0
		if( fbLangOptIsSet( FB_LANG_OPT_SCOPE ) = FALSE ) then
			options or= FB_SYMBOPT_UNSCOPE
		end if

		'' not a wstring?
		if( typeGet( dtype ) <> FB_DATATYPE_WCHAR ) then
			'' dim temp as dtype = expr
			sym = symbAddImplicitVar( dtype, subtype, options )

			'' Only need to clear if it's a string because of the
			'' fb_StrDelete() calls at scope breaks; integers don't
			'' have clean up, and UDTs aren't supported anyways.
			'' This also silences the "branch crossing" warnings for
			'' integers, they aren't needed since integer vars won't
			'' be accessed anymore once a CASE body was reached,
			'' unlike string temp vars and their fb_StrDelete().
			if( symbTypeIsManagedStringOwner( dtype ) = FALSE ) then
				symbSetDontInit( sym )
			end if

			if( options and FB_SYMBOPT_UNSCOPE ) then
				'' Clear at procedure-level if needed,
				'' and do a normal assignment here
				astAddUnscoped( astNewDECL( sym, TRUE ) )
				astAdd( astNewASSIGN( astNewVAR( sym ), expr ) )
			else
				dim as ASTNODE ptr initexpr = astNewASSIGN( astNewVAR( sym ), expr, AST_OPOPT_ISINI )
				astAdd( astNewLINK( _
					astNewDECL( sym, FALSE ), _
					initexpr, AST_LINK_RETURN_NONE ) )
			end if
		else
			'' The wstring expression must be copied into a
			'' dynamically allocated buffer, just like with string
			'' expressions, so it can be preserved for comparison
			'' at every CASE.

			'' dim temp as wstring ptr = expr
			sym = symbAddImplicitVar( typeAddrOf( FB_DATATYPE_WCHAR ), NULL, options )

			'' Mark it as "dynamic wstring" so it will be
			'' deallocated with fb_WstrDelete() at scope breaks
			symbSetIsTemporary( sym )

			if( options and FB_SYMBOPT_UNSCOPE ) then
				'' Clear the pointer at procedure-level,
				'' and do a normal assignment here
				astAddUnscoped( astNewDECL( sym, TRUE ) )
				astAdd( astBuildFakeWstringAssign( sym, expr ) )
			else
				'' Just the assignment, used as initializer
				astAdd( astNewLINK( _
					astNewDECL( sym, FALSE ), _
					astBuildFakeWstringAssign( sym, expr, AST_OPOPT_ISINI ), AST_LINK_RETURN_NONE ) )
			end if
		end if
	end if

	'' push to stmt stack
	stk = cCompStmtPush( FB_TK_SELECT, _
						 FB_CMPSTMT_MASK_NOTHING ) '' nothing allowed but CASE's
	stk->select.isconst = FALSE
	stk->select.sym = sym
	stk->select.casecnt = 0
	stk->select.cmplabel = symbAddLabel( NULL, FB_SYMBOPT_NONE )
	stk->select.endlabel = el
	stk->select.outerscopenode = outerscopenode
end sub

'':::::
''CaseExpression  =   (Expression (TO Expression)?)?
''                |   (IS REL_OP Expression)? .
''
private sub hCaseExpression _
	( _
		byref casectx as FBCASECTX, _
		byval sym as FBSYMBOL ptr _
	)

	casectx.op = AST_OP_EQ
	casectx.dtor1 = NULL
	casectx.dtor2 = NULL

	'' IS REL_OP Expression
	if( lexGetToken( ) = FB_TK_IS ) then
		lexSkipToken( LEXCHECK_POST_SUFFIX )
		casectx.op = hFBrelop2IRrelop( lexGetToken( ) )
		lexSkipToken( )
		casectx.typ = FB_CASETYPE_IS
	else
		casectx.typ = FB_CASETYPE_SINGLE
	end if

	'' Expression.  If SELECT's control value is native WSTRING, preserve
	'' counted semantics for direct WChr()/WString()/IIF CASE producers too.
	'' Keep CASE-expression dtors in a private scope: range CASE parses both
	'' bounds before lowering the first comparison, so leaving both bounds in
	'' the global dtor list could destroy the upper bound before it is built.
	dim as integer dtorcookie = 0
	dim as integer isnativewstr = (typeGet( symbGetType( sym ) ) = FB_DATATYPE_WSTRING)
	if( isnativewstr ) then
		astDtorListScopeBegin( 0 )
	end if
	casectx.expr1 = cExpression( )
	if( isnativewstr ) then
		dtorcookie = astDtorListScopeEnd( )
		casectx.dtor1 = astDtorListFlush( dtorcookie )
	end if
	if( casectx.expr1 = NULL ) then
		errReport( FB_ERRMSG_EXPECTEDEXPRESSION )
		'' error recovery: fake an expr
		casectx.expr1 = astNewCONSTz( iif( symbGetIsTemporary( sym ), _
							FB_DATATYPE_WCHAR, _
							symbGetType( sym ) ) )
	end if

	'' TO Expression
	if( lexGetToken( ) = FB_TK_TO ) then
		lexSkipToken( LEXCHECK_POST_SUFFIX )

		if( casectx.typ <> FB_CASETYPE_SINGLE ) then
			errReport( FB_ERRMSG_SYNTAXERROR )
			'' error recovery: skip until next ',', assume single
			hSkipUntil( CHAR_COMMA )
			casectx.typ = FB_CASETYPE_SINGLE
		else
			casectx.typ = FB_CASETYPE_RANGE
			dim as integer dtorcookie = 0
			dim as integer isnativewstr = (typeGet( symbGetType( sym ) ) = FB_DATATYPE_WSTRING)
			if( isnativewstr ) then
				astDtorListScopeBegin( 0 )
			end if
			casectx.expr2 = cExpression( )
			if( isnativewstr ) then
				dtorcookie = astDtorListScopeEnd( )
				casectx.dtor2 = astDtorListFlush( dtorcookie )
			end if
			if( casectx.expr2 = NULL ) then
				errReport( FB_ERRMSG_EXPECTEDEXPRESSION )
				'' error recovery: skip until next ',', assume single
				hSkipUntil( CHAR_COMMA )
				casectx.typ = FB_CASETYPE_SINGLE
			end if
		end if

	end if
end sub

private function hBuildCaseBranch _
	( _
		byval expr as ASTNODE ptr, _
		byval dtors as ASTNODE ptr, _
		byval label as FBSYMBOL ptr, _
		byval is_inverse as integer _
	) as ASTNODE ptr

	if( expr = NULL ) then
		return NULL
	end if

	if( dtors = NULL ) then
		return astBuildBranch( expr, label, is_inverse, FALSE )
	end if

	'' Materialize the comparison result before destroying any temporary used
	'' to compute it.  This keeps destructor calls in front of the branch while
	'' avoiding astBuildBranch() flushing unrelated/later CASE-bound dtors.
	dim as FBSYMBOL ptr tmp = symbAddTempVar( astGetFullType( expr ), astGetSubType( expr ) )
	dim as ASTNODE ptr tree = astBuildVarAssign( tmp, expr, AST_OPOPT_ISINI )
	tree = astNewLINK( tree, dtors, AST_LINK_RETURN_NONE )
	dim as ASTNODE ptr branch = astBuildBranch( astNewVAR( tmp ), label, is_inverse, FALSE )
	if( branch = NULL ) then
		astDelTree( tree )
		return NULL
	end if

	function = astNewLINK( tree, branch, AST_LINK_RETURN_NONE )
end function

private function hFlushCaseExpr _
	( _
		byref casectx as FBCASECTX, _
		byval sym as FBSYMBOL ptr, _
		byval inilabel as FBSYMBOL ptr, _
		byval nxtlabel as FBSYMBOL ptr, _
		byval islast as integer _
	) as integer

	dim as ASTNODE ptr expr = any

	'' if it's the fake "dynamic wstring", do "if *tmp op expr"
	#define NEWCASEVAR( sym ) _
		iif( symbGetIsTemporary( sym ), _
		     astBuildFakeWstringAccess( sym ), _
		     astNewVAR( sym ) )

	expr = NEWCASEVAR( sym )

	if( casectx.typ <> FB_CASETYPE_RANGE ) then
		'' Build the comparison as a value first, then turn it into a branch.
		'' This is important for native WSTRING: CASE expressions may create
		'' descriptor temporaries, and a direct BOP-with-label branch would
		'' jump over their dtors on the taken path.  astBuildBranch() stores
		'' the condition result, flushes temp dtors, and only then branches.
		'' (fork) AST_OPOPT_ALLOCRES is required by the TAC/gas backends:
		'' without an allocated result vreg, hCMPI() would invent a
		'' symbUniqueLabel and emit a dangling "jcc" to it.
		expr = astNewBOP( casectx.op, expr, casectx.expr1, NULL, _
		                  AST_OPOPT_ALLOCRES )
		if( expr = NULL ) then
			return FALSE
		end if

		if( islast ) then
			'' Last alternative: continue to next CASE if this one did not match.
			expr = hBuildCaseBranch( expr, casectx.dtor1, nxtlabel, FALSE )
		else
			'' Earlier alternative: jump into the CASE body if it matched.
			expr = hBuildCaseBranch( expr, casectx.dtor1, inilabel, TRUE )
		end if
	else
		'' Lower bound failed? Skip this CASE.
		expr = astNewBOP( AST_OP_GE, expr, casectx.expr1, NULL, _
		                  AST_OPOPT_ALLOCRES )
		if( expr = NULL ) then
			return FALSE
		end if
		expr = hBuildCaseBranch( expr, casectx.dtor1, nxtlabel, FALSE )
		if( expr = NULL ) then
			return FALSE
		end if

		astAdd( expr )

		expr = NEWCASEVAR( sym )
		expr = astNewBOP( AST_OP_LE, expr, casectx.expr2, NULL, _
		                  AST_OPOPT_ALLOCRES )
		if( expr = NULL ) then
			return FALSE
		end if
		if( islast ) then
			expr = hBuildCaseBranch( expr, casectx.dtor2, nxtlabel, FALSE )
		else
			expr = hBuildCaseBranch( expr, casectx.dtor2, inilabel, TRUE )
		end if
	end if

	if( expr = NULL ) then
		return FALSE
	end if

	astAdd( expr )

	function = TRUE
end function

'' SelectStmtNext  =  CASE (ELSE | (CaseExpression (',' CaseExpression)*)) .
sub cSelectStmtNext( )
	dim as FBSYMBOL ptr il = any, nl = any
	dim as integer cnt = any, i = any, cntbase = any
	dim as FB_CMPSTMTSTK ptr stk = any

	stk = cCompStmtGetTOS( FB_TK_SELECT, FALSE )
	if( stk = NULL ) then
		errReport( FB_ERRMSG_CASEWITHOUTSELECT )
		hSkipStmt( )
		exit sub
	end if

	'' ELSE already parsed?
	if( stk->select.casecnt = -1 ) then
		errReport( FB_ERRMSG_EXPECTEDENDSELECT )
	end if

	'' default mask now allowed
	cCompSetAllowmask( stk, FB_CMPSTMT_MASK_DEFAULT )

	'' AS CONST?
	if( stk->select.isconst ) then
		cSelConstStmtNext( stk )
		exit sub
	end if

	'' CASE
	lexSkipToken( LEXCHECK_POST_SUFFIX )

	'' end scope
	if( stk->scopenode <> NULL ) then
		astScopeEnd( stk->scopenode )
		stk->scopenode = NULL
	end if

	if( stk->select.casecnt > 0 ) then
		'' break from block
		astAdd( astNewBRANCH( AST_OP_JMP, stk->select.endlabel ) )

		astAdd( astNewLABEL( stk->select.cmplabel ) )
		stk->select.cmplabel = symbAddLabel( NULL )
	end if

	'' ELSE?
	if( lexGetToken( ) = FB_TK_ELSE ) then
		lexSkipToken( LEXCHECK_POST_SUFFIX )

		'' begin scope
		stk->scopenode = astScopeBegin( )

		stk->select.casecnt = -1

		exit sub
	end if

	'' CaseExpression ((',' | TO) CaseExpression)*
	cnt = 0
	cntbase = ctx.base

	do
		hCaseExpression( ctx.caseTB(cntbase + cnt), stk->select.sym )
		cnt += 1

		if( lexGetToken( ) <> CHAR_COMMA ) then
			exit do
		end if

		lexSkipToken( )
	loop

	ctx.base += cnt

	'' add block ini label
	il = symbAddLabel( NULL )

	for i = 0 to cnt-1
		if( i < cnt-1 ) then
			'' add next label
			nl = symbAddLabel( NULL, FB_SYMBOPT_NONE )
		else
			nl = stk->select.cmplabel
		end if

		if( ctx.caseTB(cntbase+i).typ <> FB_CASETYPE_ELSE ) then
			if( hFlushCaseExpr( ctx.caseTB(cntbase+i), stk->select.sym, _
			                    il, nl, i = cnt-1 ) = FALSE ) then
				errReport( FB_ERRMSG_INVALIDDATATYPES, TRUE )
			end if
		end if

		if( i < cnt-1 ) then
			'' emit next label
			astAdd( astNewLABEL( nl ) )
		end if
	next

	ctx.base -= cnt

	'' emit init block label
	astAdd( astNewLABEL( il ) )

	'' begin scope
	stk->scopenode = astScopeBegin( )

	stk->select.casecnt += 1
end sub

'' SelectStmtEnd  =  END SELECT .
sub cSelectStmtEnd( )
	dim as FB_CMPSTMTSTK ptr stk = any

	stk = cCompStmtGetTOS( FB_TK_SELECT )
	if( stk = NULL ) then
		hSkipStmt( )
		exit sub
	end if

	'' no CASE's?
	if( stk->select.casecnt = 0 ) then
		errReport( FB_ERRMSG_EXPECTEDCASE )
	end if

	'' AS CONST?
	if( stk->select.isconst ) then
		cSelConstStmtEnd( stk )
		exit sub
	end if

	'' END SELECT
	lexSkipToken( LEXCHECK_POST_SUFFIX )
	lexSkipToken( LEXCHECK_POST_SUFFIX )

	'' end scope
	if( stk->scopenode <> NULL ) then
		astScopeEnd( stk->scopenode )
	end if

	'' emit end label
	astAdd( astNewLABEL( stk->select.cmplabel ) )
	astAdd( astNewLABEL( stk->select.endlabel ) )

	'' Close the outer scope block
	if( stk->select.outerscopenode <> NULL ) then
		astScopeEnd( stk->select.outerscopenode )
	end if

	'' pop from stmt stack
	cCompStmtPop( stk )
end sub
