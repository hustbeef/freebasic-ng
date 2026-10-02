# fbc_WString Change Log (Merged)

Covers three rounds of compiler changes from 2026-09-05 to 2026-09-06, merged from three independent logs.

The original logs are preserved in the same directory:
`CHANGELOG_20260905_addr_of_prop_assign.md`,
`CHANGELOG_20260906_byref_dynwstr_desc_leak.md`,
`CHANGELOG_20260906_redim_fixed_array_err54.md`.

**Common background:** This project is the 64-bit upgrade branch of the fbc compiler (64-bit only: fbc64 / win64 / x86_64).

All three rounds consisted of uncommitted changes in the master working tree and were built incrementally using `MakeFBC64.bat` (w64devkit64 make + VisualFBEditorPro fbc64 bootstrap). The main focus was to implement the semantics and fix crashes around "dynamic raw WSTRING and legacy raw-pointer / temporary-descriptor boundaries", along with one REDIM semantic tightening (stricter than upstream).

---

## Fix Overview (Quick Index)

| Round          | Fix                                                                                                                                       | File                                           |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| 1              | `@s` == `StrPtr(s)`: `@` applied to a dynamic raw WSTRING returns a data pointer; CALL producers are materialized first                   | parser-expr-unary.bas                          |
| 1              | `*p = dynWstr` assignment bridge (fixes error 181)                                                                                        | ast-node-assign.bas                            |
| 1              | WCHAR arguments split out from the string family into a separate case (fixes error 58)                                                    | ast-node-arg.bas                               |
| 1              | UDT property compound assignment `obj.prop op= expr`                                                                                      | parser-proccall.bas                            |
| 1              | `WChr(astral code point)` literal folding dropping the trailing code unit                                                                 | ast-node-bop.bas                               |
| 1              | `WString(n, source)` materialization (error 24); `NEW WString` legacy ABI                                                                 | parser-quirk-string.bas / parser-quirk-mem.bas |
| 1              | `Cast() As WString` (Extends WString UDT gains comparison support)                                                                        | symb-proc.bas                                  |
| 1              | IIf string-family mixed widening (error 24)                                                                                               | parser-quirk-iif.bas                           |
| 1              | `fb_WstrDynCase` switched to Win32 CharUpperW/CharLowerW                                                                                  | rtlib/strw_native.c                            |
| 1 (additional) | GAS32 backend `Select Case` (dynamic WString) dangling labels                                                                             | parser-compound-select.bas                     |
| 2              | IIf widening temporary registered in the statement-level dtor list → unconditional free of an unvisited branch causes stack-garbage crash | parser-quirk-iif.bas                           |
| 2              | ByRef LINK-wrapped call exposes pooled temporary descriptor → `WLet` memmove(NULL) crash                                                  | ast-node-arg.bas                               |
| 3              | Fixed-size array silently shadowed by redeclaration during REDIM (data loss) → add error 54 validation                                    | parser-decl-var.bas                            |

---

# I. 2026-09-05: `@s` Data-Pointer Semantics Implemented + Extended Usage Tests All Green

**Date:** 2026-09-05
**Branch:** master (uncommitted working-tree changes)
**Bootstrap build:** MakeFBC64.bat (w64devkit64 make + VisualFBEditorPro fbc64 bootstrap, incremental)

## Target Semantics (All Achieved)

For a dynamic raw `WString` variable `s` (including local variables):

* `@s` == `StrPtr(s)`: returns the WCHAR data pointer (global / local / static local / array element (static + dynamic) / UDT field / BYREF parameter all behave consistently);
* `VarPtr(s)` continues to return the descriptor address (the descriptor's first field is the data pointer);
* Fixed-length `WString * N` remains unchanged: `@` / `VarPtr` / `StrPtr` all return the raw buffer address;
* `*p` (dereference of `WString Ptr`) retains its legacy dual semantics: in a string context it represents the entire NUL-terminated content; in a numeric context it represents a single 16-bit code unit.

## Compiler Fixes in This Round

### `src/compiler/parser-expr-unary.bas`

1. `hVarPtrBody()` adds an `is_addrof` parameter: when `@` (`ADDROFCHAR`) is applied to a dynamic raw WSTRING, it now follows `astBuildStrPtr()` (the same path as STRPTR and returns the data pointer); `VARPTR()` continues to use `astNewADDROF()` (descriptor address).

   * Pointer variables (`typeIsPtr`) are skipped: `@p` where `p` is a WString Ptr still means "the address of the pointer variable" and must not enter the data-pointer path. This corresponds to usage tests such as `Dim As WString Ptr Ptr pp = @p` and `h.q = @u`, eliminating warning 4.
2. `hMaterializeStrDataPtr()`: CALL producers such as property getters / function results are materialized into an owning temporary before obtaining the data pointer (INIT semantics, function-level stack slot, not registered for statement-level destruction), supporting GUI usage where "the pointer is stored in a variable and continues to be read across statements."

   * The category check in `hVarPtrBody()` now permits `AST_NODECLASS_CALL` (only for `@` + managed strings); the STRPTR path also permits and materializes it.

### `src/compiler/ast-node-assign.bas`

3. In the `rdtype = FB_DATATYPE_WSTRING` bridge branch of `astNewASSIGN()`: when the destination is a raw WCHAR buffer of unknown capacity (such as `*p`, where `p` is a WString Ptr) and the source is a managed WSTRING, it first goes through `rtlWstrRawBoundary()` (`fb_WstrDynToWstr`) to expose NUL-terminated data, then through `rtlWstrAssign()` (`dst_chars=0`, no truncation).

   * Fixes `*p = dynWstr` error 181; `*p = fixed-length WString / literal` continues through the existing same-family path and is unaffected.

### `src/compiler/ast-node-arg.bas`

4. `hCheckParam()` separates `FB_DATATYPE_WCHAR` arguments from the "string family" into a dedicated case:

   * Parameters of CHAR/WCHAR (including pointers): retain legacy raw-width boundary adaptation;
   * Other parameters (numeric, etc.): WCHAR is itself a 2-byte integer code unit and therefore goes through the generic numeric conversion path.
   * Fixes `chk("...", *p, Asc("b"))` error 58 (upstream also reports an error for numeric passing of `*wstring_ptr`; this is a new capability in this fork).

### `src/compiler/parser-proccall.bas`

5. UDT property compound assignment support (`obj.prop op= expr` → `obj.prop-set( obj.prop-get() op expr )`):

   * Added `hMatchPropCompoundAssign()` to detect "operator token + '='" without consuming them; note that after lexicalization, `=` is `FB_TK_ASSIGN`, not `CHAR_EQ`;
   * In the property branch of `cProcCall()`, once compound assignment is detected, two tokens are consumed, the instance expression is cloned (requiring no side effects), and the getter is called with `ISPROPGET + OPTONLY` (otherwise `hOvlProcArgList` would interpret the RHS as an argument);
   * Then `astNewBOP(op, get(), rhs)` is constructed (getter evaluated only once), followed by a setter call using the cloned instance + BOP result;
   * Before parsing the setter, `ISPROPGET/OPTONLY` are cleared; otherwise overload resolution would search for a PROPGET "getter with one argument" and report error 99;
   * Compound assignment on indexed properties is unsupported (reports INVALIDDATATYPES).

   Note: unlike the previous solution in the 2026-08-25 log, which used `cMaybeIgnoreCallResult + cAssignment` hooks, this version intercepts inside the property branch of `cProcCall()`. The semantics are equivalent; only this implementation is present in the current working tree.

### `src/compiler/ast-node-bop.bas`

6. `hWstrLiteralConcat()`: length is now calculated using the **number of decoded code units** from `hUnescapeW()` (`WChr(astral code point)` has a logical constant length of 1 but decodes into 2 code units).

   * Literal folding no longer drops the final code unit, fixing the case where `m[3]` became 0 in:
     `m = "a" & WChr(&h1D11E) & "b"`.

### `src/compiler/parser-quirk-string.bas / parser-quirk-mem.bas`

7. `WString(n, source)` filling: String/String*N/literal (narrow) and WString*N (raw wide) sources are first materialized into managed WSTRING through `rtlDynWstrFromExpr()` (consistent with upstream `String(n, str)` behavior of "taking the first character for filling"), rather than being forcibly converted to numeric values.

   * Fixes error 24.
8. `NEW WString` retains the legacy ABI: allocates one WCHAR code unit (`NEW WString[N]` allocates N units), consistent with the raw `WString Ptr` boundary (`SizeOf(*heap_) = 2`), eliminating warning 4.

### `src/compiler/symb-proc.bas`

9. `symbFindCastOvlProc()`'s VOID "most precise type" search now accepts `Cast() As WString` (allowing an Extends WString buffer UDT to gain `u = v` / `u <> v` comparison through `rtlDynWstrCompare`).

### `src/compiler/parser-quirk-iif.bas`

10. IIf string-family branches are unified: when a narrow literal and managed WSTRING are mixed, they are widened to managed WSTRING (both branch directions handled).

* `IIf(w = "", "lit", w) & x` no longer produces error 24.

### `src/rtlib/strw_native.c`

11. `fb_WstrDynCase()` (mode 0, default locale-aware path) now uses Win32 `CharUpperW()` / `CharLowerW()` for per-code-unit mapping: locale-independent, one-input/one-output mapping (`ü` → `Ü`, `ß` remains `ß`). CRT `towupper()` on the local locale had mapped non-ASCII code units to `0x20`.

## Tests

* `tests/wstring/WString_usage_test.bas` (1073 lines, comprehensive usage test): 0 compile errors, 0 warnings; **184 checks, 0 failed** (exit 0).
* `tests/wstring/addr-of-dynamic-semantics.bas` (new, fbcunit framework): 11 TESTs / 36 assertions, covering `@` / `StrPtr` / `VarPtr` semantics across all storage forms.
* Official wstring + udt-wstring suite (`make -f unit-tests.mk DIRLIST_INC=<restricted list>`): **148 tests / 127,878 assertions / 0 failures**.
* The new compiler `fbc.exe` and `fbc64.exe` are synchronized. SHA-256:
  `da4581bff7d92b9c72008e8d8921694fcbe8b7d48e41d3706a229aaca3094394`.

## Known Boundaries (Not Fixed; for Future Evaluation)

* `WChr(astral code point)` used alone as a `Dim` initializer still goes through constant folding (internal escape storage cannot carry surrogate pairs across the folding pipeline); this version only fixes length calculation in `hWstrLiteralConcat`, so `"a" & WChr(astral) & "b"` is complete. A complete fix requires changing the escape pipeline in hEscapeW/hUnescapeW/backend emission.
* `WSTRING -> STRING` narrowing uses CRT `wcstombs` under the C locale; non-ASCII characters become `?` on the local machine. This is locale-dependent behavior consistent with upstream fbc (the usage tests now use ASCII content to demonstrate this form).
* When `MakeFBC64.bat` is run from Git Bash, the modified rtlib command `ar rcs libfb.a mt/*.o` may be truncated by the busybox shell because `$(shell uname)` hits the MSYS branch. `libfb.a/libfbmt.a` were manually rebuilt this time. Pure cmd environments are unaffected.

## Build Notes

* The "The syntax of the command is incorrect" messages from the `MD -p` and `Ren bin/fbc.exe` lines in MakeFBC64.bat are cmd syntax noise and do not affect the build (standalone layout places the resulting `fbc.exe` at the top level).
* To run the test suite in a single directory:
  `cd tests && make -f unit-tests.mk DIRLIST_INC=<list file> FBC=<new fbc>`
  (`FBC` must be passed as a command-line variable because the environment variable is overridden by `fbcunit/Makefile`'s `FBC := fbc`.)

---

## Additional Fix (Same Day): GAS32 Backend Select Case (Dynamic WString) Dangling Labels

### Symptom

FBXiangQi builds with fbc32's default GAS backend, but linking fails with many:
`undefined reference to '.L_XXXXXX'` (`-gen gcc` works normally).

Minimal reproduction:
`Select Case <dynamic WString> ... Case "a" ...`, with each Case producing a dangling reference.

### Root Cause

The Case comparison BOP built by `hFlushCaseExpr()` did not have `AST_OPOPT_ALLOCRES`.

When the comparison result had neither a vreg nor a branch target, the TAC/gas32 emission chain (`hFlushCOMP` → `emitEQ` → emit_x86 `hCMPI`) would, when `rvreg = NULL` and `label = NULL`, create a new `.L_XXXX` through `symbUniqueLabel()` and emit a `jcc` targeting it. That label was never defined.

The GCC/HLC backends combine the comparison as a C expression and are therefore unaffected.

### Fix

In `src/compiler/parser-compound-select.bas`, `hFlushCaseExpr()` now adds `AST_OPOPT_ALLOCRES` to all three comparison BOPs (single-value, range lower bound GE, and range upper bound LE).

The comparison result is materialized normally and then branched through a temporary variable, consistent with the fork's existing intended sequence of "materialize first, flush destructors, then branch."

### Verification

* FBXiangQi fbc32 GAS backend complete build: rc=0, zero undefined references; `FB中国象棋32.exe` (2.6 MB) produced successfully.
* Select Case (dynamic WString) single-label / multi-label / Case Else / range: all correct.
* Chinese filename end-to-end test, usage test (184 checks, 0 failures), and WSTRING suite (148 / 127,878 / 0) all passed.

---

# II. 2026-09-05 Late Night ~ 2026-09-06 Early Morning: ByRef Managed WSTRING Pooled Temporary Descriptor Leak + IIf Widening Temporary Scope

**Date:** 2026-09-05 late night ~ 2026-09-06 early morning
**Branch:** master (uncommitted working-tree changes)
**Bootstrap build:** MakeFBC64.bat (w64devkit64 make + VisualFBEditorPro fbc64 bootstrap, incremental)

This round contained two compiler fixes, both belonging to the category of "dynamic raw WSTRING and legacy raw-pointer / temporary-descriptor boundaries."

Both were located through actual crash backtraces from VisualFBEditor (application-side), confirmed through minimal rep
