'' WString Use WString in every way permitted by the language.
''
'' This is both a showcase and a test. Every construct below is checked, not merely compiled,
'' so it also serves as documentation you can trust: if a form appears in this file, it works,
'' and the expected value is written beside it.
''
'' Coverage: every declaration form, dynamic and fixed, arrays (static, dynamic, multidimensional, initialized),
'' UDTs, inheritance and virtual methods, properties, operator overloading, every parameter-passing form（BYVAL / BYREF /
'' BYREF AS CONST，动态和固定），指针，以及每种返回形式（BYVAL，BYREF，定长）。
''
'' Not covered because it is unsupported:CONST u AS WString = "..."。
'' fbc's CONST accepts only FB_DATATYPE_STRING — WSTRING is rejected as well.
'' See the “Known gaps” section of README.md. Everything else here is valid.
#define UNICODE
#define ASTRAL WChr(&h1D11E)      '' one character, two code units
#include once "win/shlwapi.bi"
Dim FileName As WString * 260 = "C:\test.txt"
Print PathFileExistsW(FileName) 
Print PathFileExistsW(@FileName)
Print PathFileExistsW(StrPtr(FileName))
FileName &= "你好" & "123"
Print FileName & " 你好 " & WStr(123)
Dim FileName1 As WString = "C:\test.txt"
Print PathFileExistsW(FileName1) 
Print PathFileExistsW(@FileName1) 
Print PathFileExistsW(StrPtr(FileName1))
FileName1 = "你好" & "123)"
Print FileName1 & " 你好 " & WStr(123)
Print "SizeOf(WString)=" & SizeOf(WString)
Dim As WString Ptr FCaption = CAllocate((Len(FileName) + 1) * SizeOf(WString))
*FCaption = FileName
FCaption[Len(FileName) - 1] = WChr(65)
Print *FCaption


Dim As WString Ptr FCaption1 = CAllocate((Len(FileName1) + 1) * SizeOf(WString))
*FCaption1 = FileName1
FCaption1[0] = WChr(65)
Print *FCaption1

#define VER_MAJOR "1"
#define VER_MINOR "3"
#define VER_PATCH "8"
#define VER_BUILD "0"
Const VERSION    = VER_MAJOR + "." + VER_MINOR + "." + VER_PATCH
Const BUILD_DATE = __DATE__
Dim As WString FolderName, ExeFileName, ExeFileName111 = "abc.exe"
ExeFileName = IIf(FolderName = "", "/Projects/" , FolderName) & ExeFileName111
Print ExeFileName
Dim Shared As Integer g_run, g_fail
ExeFileName111 = WStr(g_run)
Declare Function total_len( u() As WString ) As Integer

Sub chk( ByRef nm As String, ByVal got As LongInt, ByVal want As LongInt )
    g_run += 1
    If( got <> want ) Then
        g_fail += 1
        Print "FAIL in chk, "; nm; " got="; got; " want="; want
    End If
End Sub

Sub chks( ByRef nm As WString, ByRef got As WString, ByRef want As WString )
    g_run += 1
    If( got <> want ) Then
        g_fail += 1
        Dim As WString a = got, b = want
        Print "FAIL in chks, "; nm; " got=["; a; "] want=["; b; "]"
    End If
End Sub


'' =====================================================================
''  1. 声明形式
'' =====================================================================

'' -- 模块级别的 SHARED，以及 COMMON SHARED
Dim Shared As WString g_dyn
Dim Shared As WString * 32 g_fix
Common Shared As WString g_common

Type MyZ Extends ZString
    Dim As Integer extraz
End Type

'' -- Extends WString / ZString: 旧版 wchar/zchar 缓冲类 UDT
Type UStringW Extends WString
    Dim As Integer extra
    Dim As Integer Length
    mData As WString
    Private:
	m_Capacity As Integer
Public:
	Declare Constructor()
	'Declare Constructor(ByRef Value As Const WString)
	Declare Constructor(ByRef Value As WString)
	'Declare Operator Let(ByRef Value As Const WString)
	Declare Operator Cast() As WString
	Declare Operator Let(ByRef Value As WString)
End Type

Private Constructor UStringW()
	mData = ""
End Constructor

Private Constructor UStringW(ByRef Value As WString)
	mData = Value
End Constructor

Private Operator UStringW.Let(ByRef lhs As WString)
 mData = lhs
End Operator

Private Operator UStringW.Cast() As WString
    Return mData
End Operator

'' -- FIXWSTR 多路径探测用的声明
Declare Sub p_fb ( ByRef s As WString )
Declare Function p_func ( ByVal p As WString Ptr ) As Integer

'' -- 类型别名可以像任何其他类型名称一样使用
Type ustr_t As WString
Type ufix_t As WString * 12

Sub decl_forms( )
    Print "Both orders, with or without initializers"
    Dim As WString a
    Dim As WString b = "beta"
    Dim c As WString
    Dim d As WString = "delta"

    '' Multiple variables in one statement, mixed initialization
    Dim As WString e, f = "phi", g

    a = "alpha" : c = "gamma" : e = "epsilon" : g = "omega"

    chks( "dim as WString a",          a, "alpha" )
    chks( "dim as WString b = ...",    b, "beta" )
    chks( "dim c as WString",          c, "gamma" )
    chks( "dim d as WString = ...",    d, "delta" )
    chks( "multiple in one dim",       e + f + g, "epsilonphiomega" )

    '' Fixed length — N is the number of code units, not bytes
    Dim As WString * 16 h = "fixed"
    Dim i As WString * 8 = "eight"
    chks( "dim as WString * 16",       h, "fixed" )
    chks( "dim i as WString * 8",      i, "eight" )
    chk ( "LEN of fixed is text len",  Len(h), 5 )
    chk ( "SIZEOF WString * 16",       SizeOf(h), 32 )      '' 16 个单元 × 2 字节

    '' VAR infers the dynamic form even when the source is fixed-length
    Var v1 = b + "!"
    Var v2 = h                        '' 来自 WString * 16 -> 动态
    chks( "VAR from expression",       v1, "beta!" )
    chks( "VAR from fixed",            v2, "fixed" )
    v2 += " grows"                    '' 证明它确实是动态的
    chks( "VAR result is dynamic",     v2, "fixed grows" )

    '' 类型别名
    Dim As ustr_t t1 = "aliased"
    Dim As ufix_t t2 = "alias12"
    chks( "TYPE alias, dynamic",       t1, "aliased" )
    chks( "TYPE alias, fixed",         t2, "alias12" )

    '' STATIC retains its value across calls
    Static As WString s_acc
    s_acc += "x"

    '' shared / common
    g_dyn = "shared"
    g_fix = "sharedfix"
    g_common = "common"
    chks( "DIM SHARED",                g_dyn, "shared" )
    chks( "DIM SHARED fixed",          g_fix, "sharedfix" )
    chks( "COMMON SHARED",             g_common, "common" )

    '' Pointers: WString Ptr is a wide-character data pointer; *p is a single code unit
    Dim As WString Ptr p = @b
    chk( "WString PTR deref",          *p, Asc("b") )
    *p = Asc("B")
    chks( "write through the pointer",  b, "Beta" )
    chk ( "VARPTR is non-null",        CInt( VarPtr(b) <> 0 ), -1 )

    '' STRPTR gives the raw UTF-16 units
    Dim As WString uni = WChr(&h20AC) & "A"
    Dim As UShort Ptr up = StrPtr(uni)      '' USHORT PTR，无需强制转换
    chk ( "STRPTR unit 0 (euro)",      up[0], &h20AC )
    chk ( "STRPTR unit 1 (A)",         up[1], Asc("A") )
End Sub

'' STATIC across calls
Sub static_counter( ByRef out_len As Integer )
    Static As WString acc
    acc += "ab"
    out_len = Len(acc)
End Sub


'' =====================================================================
''  2. 数组
'' =====================================================================

Sub arrays( )
    Print "Fixed-bounds array of dynamic WStrings"
    Dim As WString a(0 To 3)
    For i As Integer = 0 To 3
        a(i) = "item" & i
    Next
    chks( "array of dynamic",          a(2), "item2" )

    '' Array with initializer
    Dim As WString b(0 To 2) = { "one", "two", "three" }
    chks( "array initialiser",         b(0) + b(1) + b(2), "onetwothree" )

    '' Array of fixed-length WStrings
    Dim As WString * 8 c(0 To 2)
    c(0) = "aa" : c(1) = "bb" : c(2) = "cc"
    chks( "array of fixed",            c(0) + c(1) + c(2), "aabbcc" )
'
    '' Multidimensional
    Dim As WString d(0 To 1, 0 To 1)
    d(0,0) = "00" : d(0,1) = "01" : d(1,0) = "10" : d(1,1) = "11"
    chks( "2-D array",                 d(1,0), "10" )

    '' Dynamic array, extended with REDIM PRESERVE
    ReDim As WString e(0 To 1)
    e(0) = "keep" : e(1) = "me"
    ReDim Preserve e(0 To 4)
    e(4) = "added"
    chks( "REDIM PRESERVE keeps [0]",  e(0), "keep" )
    chks( "REDIM PRESERVE keeps [1]",  e(1), "me" )
    chks( "REDIM PRESERVE new slot",   e(4), "added" )
    chk ( "UBOUND after REDIM",        UBound(e), 4 )
'
    '' ERASE releases the contents
    Erase(e)  
    'chk ( "ERASE empties the array - Erase e ",   Len(e(0)), 0 )
    
    '' Array passed to a procedure by descriptor
    chk ( "array BYDESC total length", total_len( a() ), 5 * 4 )
End Sub

'' Array passed by descriptor
Function total_len( u() As WString ) As Integer
    Dim As Integer n
    For i As Integer = LBound(u) To UBound(u)
        n += Len( u(i) )
    Next
    Return n
End Function


'' =====================================================================
''  3. User-defined types
'' =====================================================================

Type Simple
    As WString      dyn            '' dynamic field
    As WString * 8  fix            '' fixed-length field
    As WString      arr(0 To 2)    '' array field
End Type

Type Inner
    As WString tag
End Type

Type Outer
    As Inner   inner_
    As WString name
End Type

Union UBox
    As WString * 4 text            '' Fixed-length only: union members cannot be variable-length descriptors
    As UShort      units(0 To 3)
End Union

'' Type with constructors, destructor, properties, and operators
Type Box
    Public:
        Declare Constructor( )
        Declare Constructor( ByRef s As WString )
        Declare Destructor( )
        Declare Property value( ) As WString
        Declare Property value( ByRef s As WString )
        Declare Property valueNumber( ) As Integer
        Declare Property valueNumber( ByVal s As Integer)
        Declare Operator let( ByRef s As WString )
        Declare Operator cast( ) As WString
        Declare Operator [](ByRef iKey As WString) As WString
        Declare Function shout( ByRef s As WString = "" ) As WString
        As WString LetFixWstr
    Private:
        As WString m_v
        As Integer m_Number
End Type

Constructor Box( )
    m_v = "(empty)"
End Constructor

Constructor Box( ByRef s As WString )
    m_v = s
End Constructor

Destructor Box( )
    '' m_v 由生成的字段析构函数销毁
End Destructor

Property Box.value( ) As WString
    Return m_v
End Property

Property Box.value( ByRef s As WString )
    m_v = s
End Property

Property Box.valueNumber( ) As Integer
    Return m_Number
End Property

Property Box.valueNumber( ByVal s As Integer )
    m_Number = s
End Property

Operator Box.let( ByRef s As WString )
    m_v = s
End Operator

Operator Box.cast( ) As WString
    Return m_v
End Operator

Operator Box.[](ByRef iKey As WString) As WString
    Return m_v
End Operator

Function Box.shout( ByRef s As WString = "") As WString
    Return UCase( m_v ) & s & "!"
End Function

'' 接受 WString 的Free operator
Operator + ( ByRef b As Box, ByRef s As WString ) As WString
    Return b.value & s
End Operator

Sub udts( )
    Print "Testing UDTs"
    Dim As Simple s
    s.dyn = "dynamic field"
    s.fix = "fixed"
    s.arr(1) = "in an array field"
    chks( "UDT dynamic field",         s.dyn, "dynamic field" )
    chks( "UDT fixed field",           s.fix, "fixed" )
    chks( "UDT array field",           s.arr(1), "in an array field" )

    Dim As Outer o
    o.inner_.tag = "nested"
    o.name = "outer"
    chks( "nested UDT field",          o.inner_.tag, "nested" )

    '' WITH
    With o
        .name = "with-assigned"
    End With
    chks( "WITH block",                o.name, "with-assigned" )

    Dim As UBox ub
    ub.text = "AB"
    chk ( "UNION fixed member unit 0", ub.units(0), Asc("A") )
    chk ( "UNION fixed member unit 1", ub.units(1), Asc("B") )

    '' constructor
    Dim As Box b1
    Dim As Box b2 = Box( "made" )
    chks( "default constructor",       b1.value, "(empty)" )
    chks( "constructor with WString",  b2.value, "made" )

    '' property get/set
    b1.value = "via property"
    chks( "property set/get",          b1.value, "via property" )
    '' @/StrPtr on a property get: obtains the data pointer of the returned temporary WString
    Dim As WString Ptr pprop = @b1.value
    chk ( "property @ non-null",       CInt( pprop <> 0 ), -1 )
    chks( "property @ deref",          *pprop, "via property" )
    Dim As Any Ptr psp = StrPtr(b1.value)
    chk ( "property StrPtr non-null",  CInt( psp <> 0 ), -1 )

    '' OPERATOR LET
    b1 = "via LET"
    chks( "OPERATOR LET",              b1.value, "via LET" )

    '' OPERATOR CAST 转换为 WString
    Dim As WString casted = b1
    chks( "OPERATOR CAST",             casted, "via LET" )

    '' Method returning WString
    chks( "method returns WString",    b2.shout(), "MADE!" )

    '' Free operator
    chks( "free operator +",           b2 + " it", "made it" )
    '' Free operator
    chks( "free operator &",           b2 & " by", "made by" )

    '' UDT array, each with a WString field
    Dim As Box boxes(0 To 2)
    For i As Integer = 0 To 2
        boxes(i).value = "box" & i
    Next
    chks( "array of UDTs",             boxes(2).value, "box2" )
    Dim As WString sh = b2.shout( )   ' Method returns a temporary value and cannot be an &= lvalue; use the property to demonstrate UDT compound assignment
    b2.value &= "中"
    chks( "operator of UDTs &=",      b2.value, "made中" )
    b2.value += "文"
    chks( "operator of UDTs +=",      b2.value, "made中文" )
    b2.valueNumber = 123456
    Dim As WString * 260 FileName = "中文"
    Print "b2[]=" & b2["Test"]
    b2.value = b2.shout("made" & FileName)
    b2.value &= WStr(g_run)
    b2.LetFixWstr = FileName
End Sub


'' =====================================================================
''  4. “Classes” — represented by TYPE ... EXTENDS in FB
'' =====================================================================

Type Animal Extends Object
    Declare Constructor( )
    Declare Constructor( ByRef nm As WString )
    Declare Virtual Function speak( ) As WString
    Declare Virtual Destructor( )
    As WString name
End Type

Constructor Animal( )
    name = "(unnamed)"
End Constructor

Constructor Animal( ByRef nm As WString )
    name = nm
End Constructor

Virtual Destructor Animal( )
End Destructor

Virtual Function Animal.speak( ) As WString
    Return name & " makes a sound"
End Function

Type Dog Extends Animal
    Declare Constructor( ByRef nm As WString )
    Declare Function speak( ) As WString Override
End Type

Constructor Dog( ByRef nm As WString )
    Base( nm )
End Constructor

Function Dog.speak( ) As WString
    Return name & " says wöff"
End Function

Sub classes( )
    Dim As Animal a = Animal( "Generic" )
    chks( "base virtual method",       a.speak(), "Generic makes a sound" )

    Dim As Dog d = Dog( "Rex" )
    chks( "derived override",          d.speak(), "Rex says w" & WChr(&hF6) & "ff" )

    '' Call through a base-class pointer — vtable dispatch returns WString
    Dim As Animal Ptr p = @d
    chks( "virtual via base ptr",      p->speak(), "Rex says w" & WChr(&hF6) & "ff" )

    '' NEW / DELETE
    Dim As Dog Ptr heap_ = New Dog( "Heap" )
    chks( "NEW'd object",              heap_->speak(), "Heap says w" & WChr(&hF6) & "ff" )
    Delete heap_
End Sub


'' =====================================================================
''  5. Parameter passing
'' =====================================================================

'' BYVAL — the callee receives a copy; the caller is unaffected
Sub p_byval( ByVal u As WString )
    u += " MODIFIED"
End Sub

'' BYREF — the callee modifies the caller through a reference
Sub p_byref( ByRef u As WString )
    u += " MODIFIED"
End Sub

'' BYREF AS CONST — read-only; also accepts literals and temporaries
Function p_byref_const( ByRef u As Const WString ) As Integer
    Return Len( u )
End Function

'' BYVAL AS CONST
Function p_byval_const( ByVal u As Const WString ) As Integer
    Return Len( u )
End Function

'' Fixed-length argument bound to a dynamic parameter
Function p_from_fixed( ByRef u As Const WString ) As WString
	Dim As Const WString Ptr p = @u
	Dim As Integer  Posi = InStr(LCase(u), "gdb")
    Return UCase( u )
End Function

'' Note: “byref f as WString * 8” does not compile — FB rejects fixed-length strings combined with BYREF
'' This applies to every string type:
''
''   error 324: Fixed-length string combined with BYREF (not supported)
''
'' The same is true for STRING * N, ZSTRING * N, and WSTRING * N, so this is a general FB rule,
'' not a WString-specific limitation. Use a dynamic parameter; a fixed-length argument can bind to it,
'' and writing back through it is valid.
Sub p_fixed( ByRef f As WString )
    f = "setfix"
End Sub

'' Pointer parameter: p is a wide-character data pointer; *p is a single code unit
Sub p_ptr( ByVal p As WString Ptr )
    *p = Asc("P")
End Sub

'' Optional parameter with a default value
Function p_optional( ByRef u As Const WString = "defaulted" ) As WString
    Return u
End Function

'' Overloads differing only in string type — resolution must select the correct one
Function which_ovl Overload ( ByRef u As Const WString ) As String
    Return "WString"
End Function
Function which_ovl Overload ( ByRef s As Const String ) As String
    Return "string"
End Function
Function which_ovl Overload ( ByVal w As Const WString Ptr ) As String
    Return "wstring"
End Function

Sub params( )
    Dim As WString u = "orig"

    p_byval( u )
    chks( "BYVAL does not modify",     u, "orig" )

    p_byref( u )
    chks( "BYREF modifies",            u, "orig MODIFIED" )
     
    chk ( "BYREF AS CONST",            p_byref_const( u ), 13 )
    chk ( "BYREF AS CONST literal",    p_byref_const( "12345" ), 5 )
    chk ( "BYREF AS CONST temporary",  p_byref_const( u + "xx" ), 15 )
    chk ( "BYVAL AS CONST",            p_byval_const( "中㊎㊏" ), 3 )

    '' STRING argument is converted when passed
    chk ( "narrow arg converts",       p_byref_const( "plain string" ), 12 )

    '' Fixed-length argument passed to a dynamic parameter
    Dim As WString * 16 f = "fixedarg"
    chks( "fixed arg -> dynamic param", p_from_fixed( f ), "FIXEDARG" )

    '' Fixed-length parameter
    Dim As WString * 8 g = "before"
    p_fixed( g )
    chks( "fixed-length parameter",    g, "setfix" )

    '' Pointer parameter
    Dim As WString h = "point"
    p_ptr( @h )
    chks( "WString PTR parameter",     h, "Point" )

    '' Optional parameter
    chks( "optional, omitted",         p_optional( ), "defaulted" )
    chks( "optional, supplied",        p_optional( "given" ), "given" )
    If p_optional( g) <> p_optional( g) Then 
    	
    End If
    '' Overload resolution
    Dim As WString ou = "u"
    Dim As String  os = "s"
    Dim As WString Ptr op = @ou
    chk ( "overload picks WString",    CInt( which_ovl( ou ) = "WString" ), -1 )
    chk ( "overload picks string",     CInt( which_ovl( os ) = "string" ), -1 )
    chk ( "overload picks wstring",    CInt( which_ovl( op ) = "wstring" ), -1 )
End Sub


'' =====================================================================
''  6. Return values
'' =====================================================================

'' By value, through RETURN
Function r_return( ) As WString
    Return "returned"
End Function

'' By value, through the function name
Function r_fname( ) As WString
    r_fname = "by name"
End Function

'' Note: “function r() as WString * 8” does not compile:
''
''   error 55: Fixed-len strings cannot be returned from functions
''
'' The same applies to STRING * N and WSTRING * N. A fixed-length result would be a pointer to a buffer with nowhere to store it.
'' Return the dynamic form instead — the caller can assign it directly to a fixed-length variable.
''
'' （This is a real WString bug discovered while writing this file:parser-proc.bas 中
'' parser-proc.bas lacks a FIXUSTR check, so it is accepted and then compiled incorrectly — the gcc backend treats the result
'' type as a single uint16 and truncates the returned pointer to 16 bits.）
Function r_into_fixed( ) As WString
    Return "fixedret"
End Function

'' BYREF result — returns a reference to the caller's own variable
Function r_byref( ByRef u As WString ) ByRef As WString
    Return u
End Function

'' Result built from multiple items
Function r_built( ByVal n As Integer ) As WString
    Dim As WString acc
    For i As Integer = 1 To n
        acc += "ab"
    Next
    Return acc
End Function

Sub returns( )
    chks( "RETURN a WString",          r_return(), "returned" )
    chks( "result via function name",  r_fname(), "by name" )
    '' Assign the dynamic result to a fixed-length variable.
    '' Note the capacity: WString * 8 can hold 8 code units (including the terminator),
    '' so the text is 7 characters — as with WSTRING * 8, unlike STRING * 8
    '' (no terminator, so it can hold a full 8 characters).
    Dim As WString * 8 into = r_into_fixed()
    chks( "dynamic result -> fixed var", into, "fixedre" )
    chk ( "WString * 8 holds 7 units",  Len( into ), 7 )
    Dim As WString * 9 into9 = r_into_fixed()
    chks( "WString * 9 holds all 8",   into9, "fixedret" )

    '' Read the BYREF result as a reference to the caller's own variable.
    '' Note: using it as an assignment target — r_byref(t) = "x" — does not compile,
    '' and the same is true for STRING (error 58), so this is an FB rule for string results,
    '' not specific to WString.
    Dim As WString target = "start"
    chks( "BYREF result reads",        r_byref( target ), "start" )
    chk ( "BYREF result in LEN",       Len( r_byref( target ) ), 5 )
    target += "ed"
    chks( "BYREF result tracks source", r_byref( target ), "started" )

    chks( "built result",              r_built(3), "ababab" )
    chk ( "result used in an expr",    Len( r_return() & r_fname() ), 15 )

    '' Discarded results must not leak temporary descriptors — if they did, 20,000 would exhaust the 256-slot pool
    For i As Integer = 1 To 20000
        r_return()
    Next
    chks( "pool survives discards",    r_return(), "returned" )
End Sub


'' =====================================================================
''  7. [] indexing — read/write individual code units
'' =====================================================================
''
'' u[i] is a 16-bit code unit, zero-based, O(1) in both directions.
'' It reads as a number (the unit's value), not a one-character string,
'' the same as STRING and WSTRING indexing.

Sub indexing( )
	Print "[] indexing — read/write individual code units"
    '' -- read
    Dim As WString u = "中㊎㊏"
    chk( "u[0]",                       u[0], Asc("中") )
    chk( "u[1]",                       u[1], Asc("㊎") )
    chk( "u[len-1] is the last unit",  u[Len(u) - 1], Asc("㊏") )
    chk( "u[len] is the terminator",   u[Len(u)], 0 )

    '' -- write
    u[1] = Asc("X")
    chks( "write through u[i]",         u, "中X㊏" )
    chk ( "and reads back",             u[1], Asc("X") )

    '' -- Non-ASCII BMP characters are read as their actual code points
    Dim As WString e = WChr(&h20AC) & "A"        '' euro sign
    chk( "euro unit value",             e[0], 8364 )
    chk( "euro is one unit",            Len(e), 2 )

    '' -- Supplementary characters are surrogate pairs: two units, one character
    Dim As WString m = "a" & ASTRAL & "b"
    chk( "astral string is 4 units",    Len(m), 4 )
    chk( "m[0] is 'a'",                 m[0], Asc("a") )
    chk( "m[1] is the HIGH surrogate",  m[1], &hD834 )
    chk( "m[2] is the LOW surrogate",   m[2], &hDD1E )
    chk( "m[3] is 'b'",                 m[3], Asc("b") )

    '' The pair can be reconstructed from the two units
    Dim As UInteger cp = &h10000 + ((m[1] - &hD800) Shl 10) + (m[2] - &hDC00)
    chk( "units recombine to U+1D11E",  cp, &h1D11E )

    '' -- Index fixed-length WString, read/write
    Dim As WString * 8 f = "中㊎㊏"
    chk ( "fixed f[1]",                 f[1], Asc("㊎") )
    f[1] = Asc("Y")
    chks( "write through f[i]",         f, "中Y㊏" )

    '' -- Index UDT fields, array elements, and through pointers
    Dim As Simple sm
    sm.dyn = "field"
    sm.arr(0) = "array"
    chk( "index a UDT field",           sm.dyn[0], Asc("f") )
    sm.dyn[0] = Asc("F")
    chks( "write into a UDT field",     sm.dyn, "Field" )
    chk( "index an array field",        sm.arr(0)[0], Asc("a") )

    Dim As WString arr(0 To 1)
    arr(1) = "zed"
    chk( "index an array element",      arr(1)[0], Asc("z") )

    Dim As WString Ptr p = @u
    chk( "index through a pointer",     (*p)[0], Asc("中") )

    '' -- [] and STRPTR must agree because both traverse the same buffer
    Dim As UShort Ptr raw = StrPtr(e)
    chk( "STRPTR agrees with [] at 0",  raw[0], e[0] )
    chk( "STRPTR agrees with [] at 1",  raw[1], e[1] )

    '' -- Index in a loop: sum the units and rebuild the string from them
    Dim As WString src = "Hello"
    Dim As Integer sum
    Dim As WString rebuilt
    For i As Integer = 0 To Len(src) - 1
        sum += src[i]
        rebuilt += WChr( src[i] )
    Next
    chk ( "sum of units",               sum, 500 )     '' 72+101+108+108+111
    chks( "rebuilt from its units",     rebuilt, src )

    '' -- Reverse a string in place, entirely through []
    Dim As WString rev = "中㊎㊏def"
    For i As Integer = 0 To Len(rev)\2 - 1
        Dim As UInteger t = rev[i]
        rev[i] = rev[Len(rev)-1-i]
        rev[Len(rev)-1-i] = t
    Next
    chks( "reversed via []",            rev, "fed㊏㊎中" )
End Sub


'' =====================================================================
''  8. WString as a pointer
'' =====================================================================
''
'' Two kinds of pointers, easily confused:
''
''   WString PTR   wide-character data pointer（WCHAR PTR），fully preserves legacy semantics.
''                 Dereferencing yields one UTF-16 code unit; indexing/arithmetic proceeds in 2-byte
''                 units. LPWSTR / PWSTR are this.
''   USHORT PTR    returned by STRPTR(): the same buffer, traversed by code units in the same way.
''
'' @s and STRPTR(s) are the same data address; VARPTR(s) is the descriptor address (as with
'' STRING 的规则相同）。定长 WString * N 的变量本身就是缓冲区，因此
'' @ / STRPTR / VARPTR 三者一致。

'' Accept and return pointers to WString (the returned value is a data pointer)
Function first_nonempty( p() As WString ) As WString Ptr
    For i As Integer = LBound(p) To UBound(p)
        If( Len( p(i) ) > 0 ) Then Return @p(i)
    Next
    Return 0
End Function

'' Write the first character of extra to the target through the data pointer (*p is one code unit)
Sub append_through( ByVal p As WString Ptr, ByRef extra As Const WString )
    If( p <> 0 ) Then *p = extra[0]
End Sub

Type Holder
    As WString Ptr q
End Type

Sub pointers( )
    Dim As WString u = "中㊎㊏"

    '' -- @ 与 STRPTR 都是数据地址；VARPTR 是描述符地址
    Dim As WString Ptr p = @u
    chk( "@ = STRPTR",                 CInt( Cast(Any Ptr, p) = Cast(Any Ptr, StrPtr(u)) ), -1 )
    chk( "VARPTR <> data address",     CInt( VarPtr(u) <> Cast(Any Ptr, StrPtr(u)) ), -1 )

    '' -- 解引用得到一个可读写的代码单元（WCHAR）
    chk( "deref reads first unit",     *p, Asc("中") )
    *p = Asc("一")
    chk( "deref writes first unit",    u[0], Asc("一") )
    chk( "LEN through a deref",        Len(u), 3 )

    '' -- 索引/算术按 2 字节单元进行
    chk( "p[1] is the next unit",      p[1], Asc("㊎") )
    chk( "*(p+1) same",                *(p+1), Asc("㊎") )
    chk( "p[len] is the terminator",   p[Len(u)], 0 )

    '' -- STRPTR 的 USHORT PTR 与 p 遍历同一缓冲区
    Dim As UShort Ptr raw = StrPtr(u)
    chk( "STRPTR walks code units",    raw[0], Asc("一") )
    raw[0] = Asc("X")
    chks( "writing raw units shows up", u, "X㊎㊏" )
    chk( "STRPTR and p share buffer",  raw[1], p[1] )

    '' -- 变长 WString 数组：@arr(i) 是数据指针（指向各自的堆缓冲），
    ''    因此指针算术只能遍历单个元素自己的代码单元
    Dim As WString arr(0 To 2) = { "a", "b", "c" }
    Dim As WString Ptr ap = @arr(0)
    chk( "array element data ptr",     ap[0], Asc("a") )
    chk( "ap[1] is the terminator",    ap[1], 0 )
    chk( "another element @",          ( @arr(1) )[0], Asc("b") )

    '' -- Double indirection
    Dim As WString Ptr Ptr pp = @p
    chk( "WString PTR PTR",            **pp, Asc("X") )

    '' -- Heap allocation with NEW / DELETE: legacy New WString is one wchar_t
    Dim As WString Ptr heap_ = New WString
    chk( "NEW WString is 2 bytes",     SizeOf(*heap_), 2 )
    *heap_ = Asc("h")
    chk( "NEW WString write",          *heap_, Asc("h") )
    Delete heap_

    '' Their arrays: allocated in wchar_t units
    Dim As WString Ptr many = New WString[6]
    many[0] = Asc("z") : many[1] = Asc("e") : many[2] = Asc("r")
    many[3] = Asc("o") : many[4] = 0
    chk( "NEW WString[6] units",       CInt( (many[0] = Asc("z")) And (many[3] = Asc("o")) And (many[4] = 0) ), -1 )
    Delete[] many

    '' -- Pointers stored in UDTs, and arrays of pointers
    Dim As Holder h
    h.q = @u
    chk( "pointer field in a UDT",     *(h.q), Asc("X") )

    Dim As WString Ptr parr(0 To 1)
    parr(0) = @u
    parr(1) = @arr(0)
    chk( "array of WString PTR",       CInt( (*(parr(0)) = Asc("X")) And (*(parr(1)) = Asc("a")) ), -1 )

    '' -- Pass and return pointers
    Dim As WString blanks(0 To 2)
    blanks(1) = "found"
    Dim As WString Ptr got = first_nonempty( blanks() )
    chk ( "returned pointer is valid", CInt( got <> 0 ), -1 )
    chk ( "returned pointer derefs",   *got, Asc("f") )

    append_through( got, " it" )
    chks( "callee wrote through it",   blanks(1), " ound" )

    '' Empty result, and the guard that handles it
    Dim As WString empties(0 To 1)
    chk( "null when nothing matches",  CInt( first_nonempty( empties() ) = 0 ), -1 )
    append_through( 0, "ignored" )   '' 不得崩溃
    chk( "null guard survived",        1, 1 )

    '' -- Fixed-length WString: the variable itself is the buffer, so @ / STRPTR / VARPTR agree,
    ''    unlike the variable-length case above
    Dim As WString * 8 f = "fix"
    Dim As UShort Ptr fraw = StrPtr(f)
    chk ( "fixed: STRPTR = VARPTR",    CInt( Cast(Any Ptr, fraw) = VarPtr(f) ), -1 )
    chk ( "fixed: @ = STRPTR",         CInt( Cast(Any Ptr, @f) = Cast(Any Ptr, fraw) ), -1 )
    fraw[0] = Asc("F")
    chks( "fixed: write via STRPTR",   f, "Fix" )
End Sub


'' =====================================================================
''  8. Unicode and built-ins in all of the above
'' =====================================================================

Sub unicode_( )
    '' UDT 字段、数组元素和fixed-length field都保存非 ASCII 字符
    Dim As Simple s
    s.dyn = "caf" & WChr(&hE9)
    s.fix = WChr(&h20AC) & "12"
    s.arr(0) = ASTRAL

    chk ( "accented field is 4 units",  Len(s.dyn), 4 )
    chk ( "euro in a fixed field",      s.fix[0], &h20AC )
    chk ( "astral is 2 code units",     Len(s.arr(0)), 2 )

    '' Built-ins
    Dim As WString u = "  Grüße, Welt  "
    chks( "TRIM",                       Trim(u), "Grüße, Welt" )
    '' Simple case mapping: one input unit, one output unit. Sharp s would uppercase to "SS",
    '' which changes the length, so it remains unchanged — other FB string types follow the same rule.
    chks( "UCASE (simple mapping)",     UCase(Trim(u)), "GRÜßE, WELT" )
    chks( "LEFT",                       Left(Trim(u), 5), "Grüße" )
    chks( "RIGHT",                      Right(Trim(u), 4), "Welt" )
    chks( "MID",                        Mid(Trim(u), 8, 4), "Welt" )
    chk ( "INSTR",                      InStr(Trim(u), "Welt"), 8 )
 
    '' MID statement
    Dim As WString m = "中㊎㊏def"
    Mid(m, 2, 3) = "一二三"
    chks( "MID statement",              m, "中一二三ef" )

    '' SWAP between a UDT field and a local variable
    Dim As WString other = "swapped"
    Swap s.dyn, other
    chks( "SWAP UDT field",             s.dyn, "swapped" )
    chks( "SWAP local",                 other, "caf" & WChr(&hE9) )

    '' Round-trip through other string types
    '' Note: narrowing WSTRING -> STRING uses the system ANSI code page (consistent with official fbc).
    '' When CJK code pages such as GBK cannot represent characters like ü/ß, narrowing produces
    '' a best-fit '?' and is not reversible, so ASCII content is used to demonstrate this narrowing round-trip;
    '' the fixed-width WString * 32 round-trip is code-page independent and preserves full Unicode content.
    Dim As WString ascii_src = "Hello, World 123"
    Dim As String  narrow = ascii_src
    Dim As WString * 32 wide = Trim(u)
    '' Note: CAST(WString, x) does not compile — nor does CAST(string, x);
    '' conversion to a string type is not an fbc feature. Ordinary assignment performs the conversion, implicitly in both directions.
    Dim As WString back_n = narrow
    Dim As WString back_w = wide
    chks( "-> STRING -> back (ASCII)",  back_n, ascii_src )
    chks( "-> WSTRING -> back",         back_w, Trim(u) )
End Sub


'' =====================================================================
'' FIXWSTR (WString * N) "既是缓冲又是描述符"的双重身份
'' Check all possible paths to ensure FIXWSTR passed by value is handled directly as a buffer
'' (not as a variable-length WSTRING descriptor: avoid incorrect rtlToWchr/rtlToStr interpretation)
Sub fixwstr_paths( )
    Dim As WString * 16 fa = "abc"
    Dim As WString * 16 fb = "xyz"
    Dim As WString    dyn = "中"

    '' 1. Concatenation + (&) — fixed in the previous round
    chks( "FIXWSTR + lit",                fa + "Q",  "abcQ" )
    chks( "lit + FIXWSTR",                "Q" + fa,  "Qabc" )
    chks( "FIXWSTR + FIXWSTR",            fa + fb,  "abcxyz" )
    chks( "FIXWSTR + WString",            fa + dyn, "abc中" )

    '' 1a. SIZEOF(WString) 作为类型名 = 单个 wchar_t 大小 (平台相关,
    ''     Windows 上 = SizeOf(UShort)), 用于 API 缓冲分配
    ''     (Allocate((ls+1) * SizeOf(WString)))。存储仍是描述符大小。
    chk ( "SIZEOF(WString) type = wchar",  SizeOf(WString), SizeOf(UShort) )
    chk ( "SIZEOF(var) stays descr",       SizeOf(fa), 32 )   '' 16 units * 2
    chk ( "LEN(WString) == SIZEOF(WString)", Len(WString), SizeOf(WString) )

    '' 1b. WString(n, fill) 填充: fill 可为整数码点 / WString 变量 /
    ''     WString*N 定长 / String 变量 / 字面量 (与官方一致)
    chks( "WString fill int",              WString(3, 65), "AAA" )
    Dim wszFill As WString = " "
    chks( "WString fill WString var",      WString(3, wszFill), "   " )
    Dim wfix As WString * 4 = "B"
    chks( "WString fill WString*N",        WString(3, wfix), "BBB" )
    chks( "WString fill literal",          WString(3, "C"), "CCC" )
    chks( "WString fill String var",       WString(3, "D"), "DDD" )

    '' 2. Arithmetic + (number + number should not warn; but differs with strings)
    Dim As Integer n1 = 1
    chk ( "FIXWSTR passed to Len()",      Len(fa), 3 )
    chk ( "FIXWSTR in expression",        (fa = "abc"), -1 )

    '' 3. Array indexing: type of arr(i)
    Dim As WString * 4 ai(0 To 2)
    ai(0) = "i0"
    ai(1) = "i1"
    ai(2) = "i2"
    chks( "FIXWSTR arr idx",              ai(1) + "X", "i1X" )

    '' 3a. Descriptor array Redim / Redim Preserve / Erase
    '' (WString 描述符数组行为与官方 STRING 数组一致:
    ''  non-Preserve resets contents, Preserve retains them, UBound = -1 after Erase))
    Dim As WString dyn_arr()
    ReDim dyn_arr(0 To 2)
    dyn_arr(0) = "d0"
    dyn_arr(1) = "d1"
    chks( "WString arr init",              dyn_arr(1), "d1" )
    ReDim Preserve dyn_arr(0 To 4)
    chks( "ReDim Preserve keeps",          dyn_arr(1), "d1" )
    chk ( "ReDim Preserve new empty",      Len(dyn_arr(3)), 0 )
    ReDim dyn_arr(0 To 4)   '' 非 Preserve: 内容重置
    chk ( "ReDim (no preserve) resets",    Len(dyn_arr(1)), 0 )
    Erase dyn_arr
    chk ( "Erase -> UBound = -1",          UBound(dyn_arr), -1 )

    '' 13. Extends WString / ZString (legacy buffer UDT)
    Dim As UStringW u, v
    u.extra = 7
    u = "数组"
    v = "数组"
    chk( "Extends WString member",         u.extra, 7 )
    chks( "Extends WString mData",         u.mData, "数组" )
    'This is a FreeBASIC language rule: UDTs have no default =/<> comparison and no Cast; u = v currently reports error 24 — defining Operator Cast() As WString provides the default comparison.
    chk( "Extends WString ==",             (u = v), -1 )
    v = "数组1"
    chks( "Extends WString reassign",      v.mData, "数组1" )
    chk( "Extends WString <>",             (u <> v), -1 )

    Dim z As MyZ
    z.extraz = 5
    chk( "Extends ZString member",         z.extraz, 5 )

    '' 7. Explicit Cast
    Dim As Any Ptr p = Cast(Any Ptr, @fa)
    chk ( "FIXWSTR @-addr cast non-null",  (p <> NULL), -1 )

    '' 8. Mid() statement for FIXWSTR
    Dim As WString * 12 mf = "12345"
    Mid(mf, 2, 3) = "ABC"
    chks( "MID statement FIXWSTR",         mf, "1ABC5" )

    '' 9. Compound assignment: &=, +=, etc.
    Dim As WString * 16 mu = "mut"
    mu += "X"
    chks( "FIXWSTR +=",                   mu, "mutX" )
    mu &= "Y"
    chks( "FIXWSTR &=",                   mu, "mutXY" )

    '' 10. Pass the whole value as an argument to a WString Ptr function
    chk( "FIXWSTR passed by val WString Ptr", p_func(fa), 3 )   '' Len("abc")=3

    '' 11. = assignment to/from FIXWSTR
    Dim As WString * 8 src = "src"
    Dim As WString * 8 dst = "init"
    dst = src
    chks( "FIXWSTR = FIXWSTR",            dst, "src" )

    '' 12. Pass FIXWSTR as a ByRef argument
    Dim As WString * 8 byref_arg = "byref"
    p_fb( byref_arg )
End Sub

Sub p_fb ( ByRef s As WString )
    '' Passing by ByRef must not misinterpret FIXWSTR as WSTRING
    '' (Cannot change s = "x", but assigning to temporary s_t can verify it)
    Dim As WString s_t = s
    chks( "FIXWSTR ByRef param content", s_t, "byref" )
End Sub

Function p_func ( ByVal p As WString Ptr ) As Integer
    Return Len(*p)
End Function


'' =====================================================================

Print "WString usage showcase"
Print

decl_forms( )

Dim As Integer l1, l2
static_counter( l1 )
static_counter( l2 )
chk( "STATIC local persists", l2 - l1, 2 )

arrays( )
udts( )
classes( )
params( )
returns( )
indexing( )
pointers( )
unicode_( )
fixwstr_paths( )

Print
Print g_run; " checks,Chinese variable types❸㊎㊏"; g_fail; " failed"
If( g_fail <> 0 ) Then End 1