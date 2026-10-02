/* Native counted WSTRING descriptor support.
 *
 * Unlike the legacy NUL-terminated WSTRING API, FBWSTRING::len is the
 * authoritative logical length.  A trailing NUL is maintained only as a
 * compatibility sentinel for raw WCHAR APIs.
 */
#include "fb.h"
#include <stddef.h>
#include <stdint.h>
#include <limits.h>
#if defined HOST_WIN32
#include <windows.h>
#include <locale.h>
#endif

#ifndef SSIZE_MAX
#define SSIZE_MAX ((ssize_t)(SIZE_MAX >> 1))
#endif

/* Managed-WSTRING temporary descriptors mirror the FBSTRING temporary
   descriptor pool.  Keep a separate pool so String implementation and
   descriptor semantics remain untouched. */
typedef struct _FB_WSTR_TMPDESC {
    FB_LISTELEM elem;
    FBWSTRING desc;
} FB_WSTR_TMPDESC;

static FB_LIST wtmpdsList = { 0, NULL, NULL, NULL };
static FB_WSTR_TMPDESC fb_wtmpdsTB[FB_STR_TMPDESCRIPTORS];

FBCALL FBWSTRING *fb_hWstrDynAllocTempDesc( void )
{
    FB_WSTR_TMPDESC *dsc;

    FB_STRLOCK();
    if( (wtmpdsList.fhead == NULL) && (wtmpdsList.head == NULL) )
        fb_hListInit( &wtmpdsList, fb_wtmpdsTB,
                      sizeof(FB_WSTR_TMPDESC), FB_STR_TMPDESCRIPTORS );

    dsc = (FB_WSTR_TMPDESC *)fb_hListAllocElem( &wtmpdsList );
    if( dsc != NULL ) {
        dsc->desc.data = NULL;
        dsc->desc.len = 0;
        dsc->desc.size = FB_TEMPWSTRBIT;
    }
    FB_STRUNLOCK();

    return dsc ? &dsc->desc : NULL;
}

static int hWstrDynFreeTempDesc( FBWSTRING *str )
{
    FB_WSTR_TMPDESC *item;

    if( str == NULL )
        return -1;

    item = (FB_WSTR_TMPDESC *)((char *)str - offsetof(FB_WSTR_TMPDESC, desc));
    if( (item < fb_wtmpdsTB) || (item >= fb_wtmpdsTB + FB_STR_TMPDESCRIPTORS) )
        return -1;

    FB_STRLOCK();
    fb_hListFreeElem( &wtmpdsList, &item->elem );
    item->desc.data = NULL;
    item->desc.len = 0;
    item->desc.size = 0;
    FB_STRUNLOCK();
    return 0;
}

static ssize_t hWstrDynCapacityFor( ssize_t needed )
{
    ssize_t cap;
    if( needed <= 0 )
        return 0;
    if( needed > SSIZE_MAX - 16 )
        return -1;

    /* Geometric growth for append-heavy workloads; minimum quantum 16. */
    cap = 16;
    while( cap < needed ) {
        ssize_t half = cap >> 1;
        ssize_t next;
        if( cap > SSIZE_MAX - half ) {
            cap = needed;
            break;
        }
        next = cap + half;
        if( next <= cap ) {
            cap = needed;
            break;
        }
        cap = next;
    }
    return cap;
}

static int hWstrDynEnsure( FBWSTRING *dst, ssize_t needed )
{
    ssize_t newcap;
    FB_WCHAR *p;
    size_t count;
    int is_temp;

    if( dst == NULL || needed < 0 )
        return FB_FALSE;
    if( needed <= FB_WSTRDYN_CAPACITY( dst ) )
        return FB_TRUE;
    is_temp = FB_WSTRDYN_ISTEMP( dst );

    newcap = hWstrDynCapacityFor( needed );
    if( newcap < needed )
        return FB_FALSE;
    count = (size_t)newcap + 1u;
    if( count > SIZE_MAX / sizeof(FB_WCHAR) )
        return FB_FALSE;

    p = (FB_WCHAR *)realloc( dst->data, count * sizeof(FB_WCHAR) );
    if( p == NULL )
        return FB_FALSE;
    dst->data = p;
    dst->size = newcap | (is_temp ? FB_TEMPWSTRBIT : 0);
    return FB_TRUE;
}

static void hWstrDynSetEmpty( FBWSTRING *dst )
{
    if( dst == NULL )
        return;
    dst->len = 0;
    if( dst->data != NULL )
        dst->data[0] = 0;
}

FBCALL void fb_WstrDynDeleteTemp( const FBWSTRING *src )
{
    FBWSTRING *tmp = (FBWSTRING *)src;
    if( tmp == NULL || !FB_WSTRDYN_ISTEMP( tmp ) )
        return;
    free( tmp->data );
    tmp->data = NULL;
    tmp->len = 0;
    tmp->size = FB_TEMPWSTRBIT;
    hWstrDynFreeTempDesc( tmp );
}

FBCALL void fb_WstrDynDelete( FBWSTRING *dst )
{
    int is_temp;
    if( dst == NULL )
        return;
    is_temp = FB_WSTRDYN_ISTEMP( dst );
    free( dst->data );
    dst->data = NULL;
    dst->len = 0;
    dst->size = 0;
    if( is_temp )
        hWstrDynFreeTempDesc( dst );
}

/* CDECL adapter for the generic object-array lifetime engine.  FBCALL is
   __stdcall on 32-bit Windows, while FB_DEFCTOR callbacks are plain CDECL. */
void fb_WstrDynArrayDtor( void *this_ )
{
    fb_WstrDynDelete( (FBWSTRING *)this_ );
}

/* Consume a temporary-result descriptor into a normal managed owner.
   This is the FBWSTRING mirror of fb_StrAssignEx() stealing FBSTRING temps.
   The temp marker lives in size, so len remains the authoritative logical
   character count with no masking in normal string operations. */
static int hWstrDynTakeTemp( FBWSTRING *dst, const FBWSTRING *src, int is_init )
{
    FBWSTRING *tmp;

    if( !FB_WSTRDYN_ISTEMP( src ) )
        return FB_FALSE;

    tmp = (FBWSTRING *)src;
    if( dst == NULL ) {
        fb_WstrDynDeleteTemp( tmp );
        return FB_TRUE;
    }
    if( dst == tmp )
        return FB_TRUE;

    if( !is_init )
        fb_WstrDynDelete( dst );

    dst->data = tmp->data;
    dst->len = tmp->len;
    dst->size = FB_WSTRDYN_CAPACITY( tmp );

    tmp->data = NULL;
    tmp->len = 0;
    tmp->size = FB_TEMPWSTRBIT;
    hWstrDynFreeTempDesc( tmp );
    return FB_TRUE;
}

/* Initialize a previously-uninitialized managed WSTRING from a persistent
   source.  Unlike assignment, this must not inspect/free any old dst state. */
FBCALL void fb_WstrDynInit( FBWSTRING *dst, const FBWSTRING *src )
{
    ssize_t n;
    size_t count;

    if( dst == NULL ) {
        hWstrDynTakeTemp( NULL, src, FB_TRUE );
        return;
    }
    if( hWstrDynTakeTemp( dst, src, FB_TRUE ) )
        return;

    dst->data = NULL;
    dst->len = 0;
    dst->size = 0;

    if( src == NULL || src->len <= 0 || src->data == NULL )
        return;

    n = src->len;
    count = (size_t)n + 1u;
    if( count > SIZE_MAX / sizeof(FB_WCHAR) )
        return;

    dst->data = (FB_WCHAR *)malloc( count * sizeof(FB_WCHAR) );
    if( dst->data == NULL )
        return;

    memmove( dst->data, src->data, (size_t)n * sizeof(FB_WCHAR) );
    dst->data[n] = 0;
    dst->len = n;
    dst->size = n;
}

/* Initialize by transferring a compiler-proven disposable temporary.  The
   source descriptor is cleared so its already-registered destructor is a
   harmless no-op, mirroring fb_StrInit()'s temp ownership transfer. */
FBCALL void fb_WstrDynMoveInit( FBWSTRING *dst, FBWSTRING *src )
{
    if( dst == NULL ) {
        hWstrDynTakeTemp( NULL, src, FB_TRUE );
        return;
    }
    if( hWstrDynTakeTemp( dst, src, FB_TRUE ) )
        return;

    if( src == NULL || src == dst ) {
        if( src == NULL ) {
            dst->data = NULL;
            dst->len = 0;
            dst->size = 0;
        }
        return;
    }

    dst->data = src->data;
    dst->len = src->len;
    dst->size = src->size;

    src->data = NULL;
    src->len = 0;
    src->size = 0;
}

/* Replace an already-initialized managed owner by transferring ownership
   from a compiler-proven disposable descriptor temporary.  Unlike move-init,
   assignment must release the old destination payload first.  The source is
   cleared so its registered destructor becomes a no-op.  This primitive is
   intentionally descriptor-level: the compiler only selects it after
   astGetResultTempSym() proves that src is disposable. */
FBCALL void fb_WstrDynMoveAssign( FBWSTRING *dst, FBWSTRING *src )
{
    int dst_is_temp;
    int src_is_temp;

    if( dst == NULL ) {
        if( src != NULL )
            fb_WstrDynDelete( src );
        return;
    }
    if( src == NULL ) {
        hWstrDynSetEmpty( dst );
        return;
    }
    if( dst == src )
        return;

    dst_is_temp = FB_WSTRDYN_ISTEMP( dst );
    src_is_temp = FB_WSTRDYN_ISTEMP( src );

    free( dst->data );
    dst->data = src->data;
    dst->len = src->len;
    dst->size = FB_WSTRDYN_CAPACITY( src ) |
                (dst_is_temp ? FB_TEMPWSTRBIT : 0);

    src->data = NULL;
    src->len = 0;
    src->size = src_is_temp ? FB_TEMPWSTRBIT : 0;
    if( src_is_temp )
        hWstrDynFreeTempDesc( src );
}

/* Build lhs & rhs directly into an already-initialized destination.
   This primitive is intentionally limited to managed descriptor operands.
   It is alias-safe for every descriptor identity combination, including
   dst == lhs, dst == rhs, lhs == rhs and dst == lhs == rhs.  In particular,
   the dst == rhs path grows first, shifts the old rhs payload to the right,
   and only then writes lhs into the prefix, so no RHS bytes are destroyed
   before they are consumed. */
FBCALL void fb_WstrDynConcatAssignPair( FBWSTRING *dst, const FBWSTRING *lhs, const FBWSTRING *rhs )
{
    ssize_t llen, rlen, total;
    const FB_WCHAR *lp, *rp;

    if( dst == NULL )
        return;

    llen = (lhs != NULL && lhs->data != NULL && lhs->len > 0) ? lhs->len : 0;
    rlen = (rhs != NULL && rhs->data != NULL && rhs->len > 0) ? rhs->len : 0;
    if( llen > SSIZE_MAX - rlen )
        return;
    total = llen + rlen;

    if( dst == lhs ) {
        /* Existing concat-assign already handles dst == rhs (self append),
           growth/realloc and counted embedded-NUL payloads. */
        fb_WstrDynConcatAssign( dst, rhs );
        return;
    }

    if( dst == rhs ) {
        /* Preserve old rhs in-place.  hWstrDynEnsure() may realloc dst, but
           after it returns the rhs payload is still at dst->data[0..rlen). */
        if( llen <= 0 )
            return;
        if( !hWstrDynEnsure( dst, total ) )
            return;
        memmove( dst->data + llen, dst->data, (size_t)rlen * sizeof(FB_WCHAR) );
        if( lhs != NULL && lhs->data != NULL )
            memmove( dst->data, lhs->data, (size_t)llen * sizeof(FB_WCHAR) );
        dst->len = total;
        dst->data[total] = 0;
        return;
    }

    if( total <= 0 ) {
        hWstrDynSetEmpty( dst );
        return;
    }

    lp = (llen > 0) ? lhs->data : NULL;
    rp = (rlen > 0) ? rhs->data : NULL;
    if( !hWstrDynEnsure( dst, total ) )
        return;
    if( llen > 0 )
        memmove( dst->data, lp, (size_t)llen * sizeof(FB_WCHAR) );
    if( rlen > 0 )
        memmove( dst->data + llen, rp, (size_t)rlen * sizeof(FB_WCHAR) );
    dst->len = total;
    dst->data[total] = 0;
}

/* Initialize a new managed owner directly from lhs & rhs.  Unlike the
   assignment pair primitive, dst is semantically uninitialized and therefore
   must never be inspected or freed.  The compiler only selects this helper for
   a fresh simple destination that cannot be either source descriptor. */
FBCALL void fb_WstrDynConcatInitPair( FBWSTRING *dst, const FBWSTRING *lhs, const FBWSTRING *rhs )
{
    ssize_t llen, rlen, total;
    size_t count;
    FB_WCHAR *data;

    if( dst == NULL )
        return;

    llen = (lhs != NULL && lhs->data != NULL && lhs->len > 0) ? lhs->len : 0;
    rlen = (rhs != NULL && rhs->data != NULL && rhs->len > 0) ? rhs->len : 0;

    /* Establish a valid empty owner before any possible allocation failure. */
    dst->data = NULL;
    dst->len = 0;
    dst->size = 0;

    if( llen > SSIZE_MAX - rlen )
        return;
    total = llen + rlen;
    if( total <= 0 )
        return;

    count = (size_t)total + 1u;
    if( count > SIZE_MAX / sizeof(FB_WCHAR) )
        return;

    data = (FB_WCHAR *)malloc( count * sizeof(FB_WCHAR) );
    if( data == NULL )
        return;

    if( llen > 0 )
        memmove( data, lhs->data, (size_t)llen * sizeof(FB_WCHAR) );
    if( rlen > 0 )
        memmove( data + llen, rhs->data, (size_t)rlen * sizeof(FB_WCHAR) );
    data[total] = 0;

    dst->data = data;
    dst->len = total;
    dst->size = total;
}

FBCALL void fb_WstrDynInitW( FBWSTRING *dst, const FB_WCHAR *src )
{
    if( dst == NULL )
        return;
    dst->data = NULL;
    dst->len = 0;
    dst->size = 0;
    fb_WstrDynAssignW( dst, src );
}

FBCALL void fb_WstrDynInitWN( FBWSTRING *dst, const FB_WCHAR *src, ssize_t src_len )
{
    if( dst == NULL )
        return;
    dst->data = NULL;
    dst->len = 0;
    dst->size = 0;
    fb_WstrDynAssignWN( dst, src, src_len );
}

FBCALL void fb_WstrDynInitA( FBWSTRING *dst, void *src, ssize_t src_size )
{
    if( dst == NULL ) {
        if( src_size == FB_STRSIZEVARLEN )
            fb_hStrDelTemp( (FBSTRING *)src );
        return;
    }
    dst->data = NULL;
    dst->len = 0;
    dst->size = 0;
    fb_WstrDynAssignA( dst, src, src_size );
}

FBCALL void fb_WstrDynAssign( FBWSTRING *dst, const FBWSTRING *src )
{
    ssize_t n;
    const FB_WCHAR *p;

    if( dst == NULL ) {
        hWstrDynTakeTemp( NULL, src, FB_FALSE );
        return;
    }
    if( src == dst )
        return;
    if( hWstrDynTakeTemp( dst, src, FB_FALSE ) )
        return;
    if( src == NULL || src->len <= 0 || src->data == NULL ) {
        hWstrDynSetEmpty( dst );
        return;
    }

    n = src->len;
    p = src->data;
    if( !hWstrDynEnsure( dst, n ) )
        return;
    memmove( dst->data, p, (size_t)n * sizeof(FB_WCHAR) );
    dst->data[n] = 0;
    dst->len = n;
}

FBCALL void fb_WstrDynCopyToW( FB_WCHAR *dst, ssize_t dst_chars, const FBWSTRING *src )
{
    ssize_t n;
    if( dst == NULL )
        goto done;
    n = (src != NULL && src->data != NULL && src->len > 0) ? src->len : 0;
    if( dst_chars > 0 ) {
        ssize_t cap = dst_chars - 1;
        if( n > cap )
            n = cap;
    }
    if( n > 0 )
        memmove( dst, src->data, (size_t)n * sizeof(FB_WCHAR) );
    dst[n] = 0;
done:
    fb_WstrDynDeleteTemp( src );
}

FBCALL void fb_WstrDynAssignW( FBWSTRING *dst, const FB_WCHAR *src )
{
    ssize_t n;
    if( dst == NULL )
        return;
    if( src == NULL ) {
        hWstrDynSetEmpty( dst );
        return;
    }

    /* Legacy/raw WSTRING sources have no descriptor, so their contract remains
       NUL-terminated.  Native-to-native copies use fb_WstrDynAssign(). */
    n = fb_wstr_Len( src );
    if( n <= 0 ) {
        hWstrDynSetEmpty( dst );
        return;
    }
    if( !hWstrDynEnsure( dst, n ) )
        return;
    memmove( dst->data, src, (size_t)n * sizeof(FB_WCHAR) );
    dst->data[n] = 0;
    dst->len = n;
}

FBCALL void fb_WstrDynAssignWN( FBWSTRING *dst, const FB_WCHAR *src, ssize_t src_len )
{
    if( dst == NULL )
        return;
    if( src == NULL || src_len <= 0 ) {
        hWstrDynSetEmpty( dst );
        return;
    }
    if( !hWstrDynEnsure( dst, src_len ) )
        return;
    memmove( dst->data, src, (size_t)src_len * sizeof(FB_WCHAR) );
    dst->len = src_len;
    dst->data[src_len] = 0;
}

FBCALL void fb_WstrDynAssignA( FBWSTRING *dst, void *src, ssize_t src_size )
{
    char *src_ptr;
    ssize_t src_chars, written;

    if( dst == NULL )
        return;

    FB_STRSETUP_FIX( src, src_size, src_ptr, src_chars );
    if( src_ptr == NULL || src_chars <= 0 ) {
        hWstrDynSetEmpty( dst );
        if( src_size == FB_STRSIZEVARLEN )
            fb_hStrDelTemp( (FBSTRING *)src );
        return;
    }

    /* src_chars is a safe upper bound for multibyte -> FB_WCHAR conversion. */
    if( !hWstrDynEnsure( dst, src_chars ) ) {
        if( src_size == FB_STRSIZEVARLEN )
            fb_hStrDelTemp( (FBSTRING *)src );
        return;
    }

    written = fb_wstr_ConvFromAN( dst->data, src_chars, src_ptr, src_chars );
    if( written < 0 )
        written = 0;
    dst->len = written;
    dst->data[written] = 0;

    if( src_size == FB_STRSIZEVARLEN )
        fb_hStrDelTemp( (FBSTRING *)src );
}

/* Length-aware native WSTRING -> STRING conversion.  Keep this local to
   the counted-WSTRING bridge: embedded WCHAR(0) is data, while each non-NUL
   span intentionally reuses the historical locale-aware conversion helper. */
static int hWstrDynAsciiFastOK( void )
{
    int ok = (MB_CUR_MAX == 1);
#if defined HOST_WIN32
    if( !ok ) {
        unsigned int cp = ___lc_codepage_func();
        if( cp == GetACP() || cp == GetOEMCP() || cp == CP_UTF8 )
            ok = 1;
    }
#endif
    return ok;
}

static ssize_t hWstrDynConvToA( char *dst, ssize_t dst_bytes,
                                const FB_WCHAR *src, ssize_t src_chars )
{
    ssize_t inpos = 0;
    ssize_t out = 0;

    if( dst == NULL || dst_bytes < 0 )
        return 0;
    if( src == NULL || src_chars <= 0 ) {
        dst[0] = '\0';
        return 0;
    }

    /* PERF6: keep this optimization inside the managed counted-WSTRING
       bridge.  Legacy raw WSTRING conversion remains untouched.  If the
       active encoding is known to preserve 7-bit ASCII and every counted
       code unit is ASCII, copy the whole payload directly, including any
       embedded NUL code units.  Any non-ASCII code unit falls through to
       the historical span-by-span locale-aware conversion below. */
    {
        ssize_t n = src_chars;
        ssize_t i;
        if( n > dst_bytes )
            n = dst_bytes;

        /* Inspect the payload before querying locale/codepage state.  A
           non-ASCII code unit must use the legacy conversion regardless of
           locale, so avoid paying the Windows locale/API gate on that path. */
        for( i = 0; i < n; ++i ) {
            if( (uint32_t)src[i] > 127u )
                break;
        }
        if( i == n && hWstrDynAsciiFastOK() ) {
            for( i = 0; i < n; ++i )
                dst[i] = (char)(unsigned char)src[i];
            dst[n] = '\0';
            return n;
        }
    }

    while( inpos < src_chars && out < dst_bytes ) {
        ssize_t span_start;
        ssize_t written;

        if( src[inpos] == 0 ) {
            dst[out++] = '\0';
            ++inpos;
            continue;
        }

        span_start = inpos;
        while( inpos < src_chars && src[inpos] != 0 )
            ++inpos;

        /* The span is terminated either by an embedded NUL or by the native
           descriptor's maintained trailing sentinel at data[len]. */
        written = fb_wstr_ConvToA( dst + out, dst_bytes - out, src + span_start );
        if( written < 0 )
            written = 0;
        if( written > dst_bytes - out )
            written = dst_bytes - out;
        out += written;

        if( inpos < src_chars ) {
            if( out >= dst_bytes )
                break;
            /* fb_wstr_ConvToA() already wrote this terminator; advancing over
               it makes the embedded NUL part of the counted STRING payload. */
            dst[out++] = '\0';
            ++inpos;
        }
    }

    dst[out] = '\0';
    return out;
}

/* Convert a counted native WSTRING to a temporary counted FBSTRING.
   Unlike the legacy fb_WstrToStr() bridge, descriptor length remains
   authoritative, so embedded WCHAR(0) is preserved as an embedded NUL byte. */
FBCALL FBSTRING *fb_WstrDynToStr( const FBWSTRING *src )
{
    FBSTRING *dst = &__fb_ctx.null_desc;
    size_t per_char;
    size_t cap_size;
    ssize_t cap;
    ssize_t written;

    if( src == NULL || src->data == NULL || src->len <= 0 )
        goto done;

    per_char = (size_t)MB_CUR_MAX;
    if( per_char < 1u )
        per_char = 1u;
    if( per_char < 4u )
        per_char = 4u;

    if( (size_t)src->len > (size_t)SSIZE_MAX / per_char )
        goto done;
    cap_size = (size_t)src->len * per_char;
    if( cap_size > (size_t)SSIZE_MAX )
        goto done;
    cap = (ssize_t)cap_size;

    dst = fb_hStrAllocTemp( NULL, cap );
    if( dst == NULL ) {
        dst = &__fb_ctx.null_desc;
        goto done;
    }

    written = hWstrDynConvToA( dst->data, cap, src->data, src->len );
    if( written < 0 )
        written = 0;
    fb_hStrSetLength( dst, written );

done:
    fb_WstrDynDeleteTemp( src );
    return dst;
}

FBCALL void fb_WstrDynCopyToA( void *dst, ssize_t dst_size, const FBWSTRING *src )
{
    FBSTRING *tmp;
    int fill_rem;

    if( dst == NULL )
        return;

    tmp = fb_WstrDynToStr( src );
    fill_rem = ((dst_size != FB_STRSIZEVARLEN) && ((dst_size & FB_STRISFIXED) != 0));
    fb_StrAssign( dst, dst_size, tmp, FB_STRSIZEVARLEN, fill_rem );
}

/* Convert a counted native WSTRING descriptor to an owned legacy
   NUL-terminated WSTRING temporary.  This is intentionally a compatibility
   boundary: descriptor length is used for the copy, but legacy consumers
   will subsequently observe embedded NULs with their historical semantics. */
FBCALL FB_WCHAR *fb_WstrDynToWstr( const FBWSTRING *src )
{
    ssize_t n = 0;
    FB_WCHAR *dst;

    if( src != NULL && src->data != NULL && src->len > 0 )
        n = src->len;

    dst = fb_wstr_AllocTemp( n );
    if( dst != NULL )
        fb_wstr_Copy( dst, (n > 0)? src->data : NULL, n );

    fb_WstrDynDeleteTemp( src );
    return dst;
}

FBCALL ssize_t fb_WstrDynLen( const FBWSTRING *src )
{
    ssize_t result = src ? src->len : 0;
    fb_WstrDynDeleteTemp( src );
    return result;
}

FBCALL void fb_WstrDynConcatAssign( FBWSTRING *dst, const FBWSTRING *src )
{
    ssize_t oldlen, n;
    if( dst == NULL || src == NULL || src->data == NULL || src->len <= 0 )
        goto done;
    oldlen = dst->len;
    n = src->len;
    if( oldlen < 0 || n > SSIZE_MAX - oldlen )
        goto done;

    if( src == dst ) {
        if( !hWstrDynEnsure( dst, oldlen + n ) )
            goto done;
        memmove( dst->data + oldlen, dst->data, (size_t)n * sizeof(FB_WCHAR) );
    } else {
        const FB_WCHAR *p = src->data;
        if( !hWstrDynEnsure( dst, oldlen + n ) )
            goto done;
        memmove( dst->data + oldlen, p, (size_t)n * sizeof(FB_WCHAR) );
    }
    dst->len = oldlen + n;
    dst->data[dst->len] = 0;
done:
    if( src != dst )
        fb_WstrDynDeleteTemp( src );
}

FBCALL void fb_WstrDynConcatAssignW( FBWSTRING *dst, const FB_WCHAR *src )
{
    ssize_t oldlen, n;
    size_t alias_off = 0;
    int aliased = FB_FALSE;
    uintptr_t dbeg, dend, sp;

    if( dst == NULL || src == NULL )
        return;
    oldlen = dst->len;
    n = fb_wstr_Len( src );
    if( n <= 0 || oldlen < 0 || n > SSIZE_MAX - oldlen )
        return;

    if( dst->data != NULL ) {
        dbeg = (uintptr_t)dst->data;
        dend = dbeg + ((size_t)oldlen + 1u) * sizeof(FB_WCHAR);
        sp = (uintptr_t)src;
        if( sp >= dbeg && sp < dend ) {
            aliased = FB_TRUE;
            alias_off = (size_t)(sp - dbeg);
        }
    }

    if( !hWstrDynEnsure( dst, oldlen + n ) )
        return;
    if( aliased )
        src = (const FB_WCHAR *)((const unsigned char *)dst->data + alias_off);
    memmove( dst->data + oldlen, src, (size_t)n * sizeof(FB_WCHAR) );
    dst->len = oldlen + n;
    dst->data[dst->len] = 0;
}

FBCALL void fb_WstrDynConcatAssignWN( FBWSTRING *dst, const FB_WCHAR *src, ssize_t src_len )
{
    ssize_t oldlen;
    size_t alias_off = 0;
    int aliased = FB_FALSE;
    uintptr_t dbeg, dend, sp;

    if( dst == NULL || src == NULL || src_len <= 0 )
        return;
    oldlen = dst->len;
    if( oldlen < 0 || src_len > SSIZE_MAX - oldlen )
        return;

    /* Exact-span sources may legally point into dst->data.  Growth can realloc
       the descriptor, so preserve the offset and rebase afterwards. */
    if( dst->data != NULL && oldlen >= 0 ) {
        dbeg = (uintptr_t)dst->data;
        dend = dbeg + ((size_t)oldlen + 1u) * sizeof(FB_WCHAR);
        sp = (uintptr_t)src;
        if( sp >= dbeg && sp < dend ) {
            aliased = FB_TRUE;
            alias_off = (size_t)(sp - dbeg);
        }
    }

    if( !hWstrDynEnsure( dst, oldlen + src_len ) )
        return;
    if( aliased )
        src = (const FB_WCHAR *)((const unsigned char *)dst->data + alias_off);
    memmove( dst->data + oldlen, src, (size_t)src_len * sizeof(FB_WCHAR) );
    dst->len = oldlen + src_len;
    dst->data[dst->len] = 0;
}

FBCALL void fb_WstrDynConcatAssignA( FBWSTRING *dst, void *src, ssize_t src_size )
{
    char *src_ptr;
    ssize_t src_chars, oldlen, written;
    if( dst == NULL )
        return;

    FB_STRSETUP_FIX( src, src_size, src_ptr, src_chars );
    if( src_ptr == NULL || src_chars <= 0 ) {
        if( src_size == FB_STRSIZEVARLEN )
            fb_hStrDelTemp( (FBSTRING *)src );
        return;
    }

    oldlen = dst->len;
    if( oldlen < 0 || src_chars > SSIZE_MAX - oldlen ||
        !hWstrDynEnsure( dst, oldlen + src_chars ) ) {
        if( src_size == FB_STRSIZEVARLEN )
            fb_hStrDelTemp( (FBSTRING *)src );
        return;
    }

    written = fb_wstr_ConvFromAN( dst->data + oldlen, src_chars, src_ptr, src_chars );
    if( written < 0 ) written = 0;
    dst->len = oldlen + written;
    dst->data[dst->len] = 0;

    if( src_size == FB_STRSIZEVARLEN )
        fb_hStrDelTemp( (FBSTRING *)src );
}


FBCALL unsigned int fb_WstrDynAsc( const FBWSTRING *src, ssize_t pos )
{
    unsigned int result = 0;
    if( src != NULL && src->data != NULL && src->len > 0 && pos > 0 && pos <= src->len ) {
#if defined HOST_DOS
        result = (unsigned char)src->data[pos - 1];
#else
        result = (unsigned int)src->data[pos - 1];
#endif
    }
    fb_WstrDynDeleteTemp( src );
    return result;
}

FBCALL int fb_WstrDynCompare( const FBWSTRING *str1, const FBWSTRING *str2 )
{
    const FB_WCHAR *p1 = NULL, *p2 = NULL;
    ssize_t n1 = 0, n2 = 0, n, i;
    int result = 0;

    if( str1 != NULL && str1->data != NULL && str1->len > 0 ) {
        p1 = str1->data;
        n1 = str1->len;
    }
    if( str2 != NULL && str2->data != NULL && str2->len > 0 ) {
        p2 = str2->data;
        n2 = str2->len;
    }

    n = (n1 < n2) ? n1 : n2;
    for( i = 0; i < n; ++i ) {
        if( p1[i] < p2[i] ) { result = -1; goto done; }
        if( p1[i] > p2[i] ) { result = 1; goto done; }
    }
    if( n1 < n2 ) result = -1;
    else if( n1 > n2 ) result = 1;

done:
    if( str2 != str1 )
        fb_WstrDynDeleteTemp( str2 );
    fb_WstrDynDeleteTemp( str1 );
    return result;
}

FBCALL ssize_t fb_WstrDynInstr( ssize_t start, const FBWSTRING *src, const FBWSTRING *patt )
{
    ssize_t i, j, last, result = 0;
    if( src == NULL || patt == NULL || src->data == NULL || patt->data == NULL )
        goto done;
    if( start <= 0 || start > src->len || patt->len <= 0 || patt->len > src->len )
        goto done;
    last = src->len - patt->len;
    for( i = start - 1; i <= last; ++i ) {
        for( j = 0; j < patt->len; ++j )
            if( src->data[i+j] != patt->data[j] )
                break;
        if( j == patt->len ) { result = i + 1; break; }
    }
done:
    if( patt != src ) fb_WstrDynDeleteTemp( patt );
    fb_WstrDynDeleteTemp( src );
    return result;
}

FBCALL ssize_t fb_WstrDynInstrAny( ssize_t start, const FBWSTRING *src, const FBWSTRING *patt )
{
    ssize_t i, j, result = 0;
    if( src == NULL || patt == NULL || src->data == NULL || patt->data == NULL )
        goto done;
    if( start <= 0 || start > src->len || patt->len <= 0 )
        goto done;
    for( i = start - 1; i < src->len; ++i ) {
        for( j = 0; j < patt->len; ++j )
            if( src->data[i] == patt->data[j] ) { result = i + 1; goto done; }
    }
done:
    if( patt != src ) fb_WstrDynDeleteTemp( patt );
    fb_WstrDynDeleteTemp( src );
    return result;
}

FBCALL ssize_t fb_WstrDynInstrRev( const FBWSTRING *src, const FBWSTRING *patt, ssize_t start )
{
    ssize_t i, j, maxstart, result = 0;
    if( src == NULL || patt == NULL || src->data == NULL || patt->data == NULL )
        goto done;
    if( src->len <= 0 || patt->len <= 0 || patt->len > src->len || start == 0 )
        goto done;
    maxstart = src->len - patt->len + 1;
    if( start < 0 )
        start = maxstart;
    else if( start > src->len )
        goto done;
    else if( start > maxstart )
        start = maxstart;
    for( i = start - 1; i >= 0; --i ) {
        for( j = 0; j < patt->len; ++j )
            if( src->data[i+j] != patt->data[j] )
                break;
        if( j == patt->len ) { result = i + 1; break; }
    }
done:
    if( patt != src ) fb_WstrDynDeleteTemp( patt );
    fb_WstrDynDeleteTemp( src );
    return result;
}

FBCALL ssize_t fb_WstrDynInstrRevAny( const FBWSTRING *src, const FBWSTRING *patt, ssize_t start )
{
    ssize_t i, j, result = 0;
    if( src == NULL || patt == NULL || src->data == NULL || patt->data == NULL )
        goto done;
    if( src->len <= 0 || patt->len <= 0 || start == 0 )
        goto done;
    if( start < 0 || start > src->len )
        start = src->len;
    for( i = start - 1; i >= 0; --i ) {
        for( j = 0; j < patt->len; ++j )
            if( src->data[i] == patt->data[j] ) { result = i + 1; goto done; }
    }
done:
    if( patt != src ) fb_WstrDynDeleteTemp( patt );
    fb_WstrDynDeleteTemp( src );
    return result;
}

FBCALL void fb_WstrDynMid( FBWSTRING *dst, const FBWSTRING *src, ssize_t start, ssize_t len );
FBCALL void fb_WstrDynCase( FBWSTRING *dst, const FBWSTRING *src, int mode, int to_lower );
FBCALL void fb_WstrDynTrimSimple( FBWSTRING *dst, const FBWSTRING *src, int side );
FBCALL void fb_WstrDynTrimPattern( FBWSTRING *dst, const FBWSTRING *src, const FBWSTRING *patt, int side, int is_any );

FBCALL FBWSTRING *fb_WstrDynMidResult( const FBWSTRING *src, ssize_t start, ssize_t len )
{
    FBWSTRING *out = fb_hWstrDynAllocTempDesc();
    if( out == NULL ) { fb_WstrDynDeleteTemp( src ); return NULL; }
    fb_WstrDynMid( out, src, start, len );
    return out;
}

FBCALL FBWSTRING *fb_WstrDynCaseResult( const FBWSTRING *src, int mode, int to_lower )
{
    FBWSTRING *out = fb_hWstrDynAllocTempDesc();
    if( out == NULL ) { fb_WstrDynDeleteTemp( src ); return NULL; }
    fb_WstrDynCase( out, src, mode, to_lower );
    return out;
}

FBCALL FBWSTRING *fb_WstrDynTrimSimpleResult( const FBWSTRING *src, int side )
{
    FBWSTRING *out = fb_hWstrDynAllocTempDesc();
    if( out == NULL ) { fb_WstrDynDeleteTemp( src ); return NULL; }
    fb_WstrDynTrimSimple( out, src, side );
    return out;
}

FBCALL FBWSTRING *fb_WstrDynTrimPatternResult( const FBWSTRING *src, const FBWSTRING *patt, int side, int is_any )
{
    FBWSTRING *out = fb_hWstrDynAllocTempDesc();
    if( out == NULL ) {
        if( patt != src ) fb_WstrDynDeleteTemp( patt );
        fb_WstrDynDeleteTemp( src );
        return NULL;
    }
    fb_WstrDynTrimPattern( out, src, patt, side, is_any );
    return out;
}

FBCALL void fb_WstrDynAssignMid( FBWSTRING *dst, ssize_t start, ssize_t len, const FBWSTRING *src )
{
    ssize_t n;
    if( dst == NULL || src == NULL || dst->data == NULL || src->data == NULL )
        goto done;
    if( start <= 0 || start > dst->len || src->len <= 0 )
        goto done;
    --start;
    n = src->len;
    if( len > 0 && len < n )
        n = len;
    if( n > dst->len - start )
        n = dst->len - start;
    if( n <= 0 )
        goto done;
    memmove( dst->data + start, src->data, (size_t)n * sizeof(FB_WCHAR) );
    dst->data[dst->len] = 0;
done:
    if( src != dst ) fb_WstrDynDeleteTemp( src );
}

FBCALL void fb_WstrDynMid( FBWSTRING *dst, const FBWSTRING *src, ssize_t start, ssize_t len )
{
    ssize_t n;
    if( dst == NULL )
        goto done;
    if( src == NULL || src->data == NULL || src->len <= 0 || start <= 0 || start > src->len || len == 0 ) {
        hWstrDynSetEmpty( dst );
        goto done;
    }
    --start;
    if( len < 0 || len > src->len - start )
        n = src->len - start;
    else
        n = len;
    fb_WstrDynAssignWN( dst, src->data + start, n );
done:
    if( src != dst ) fb_WstrDynDeleteTemp( src );
}

FBCALL void fb_WstrDynCase( FBWSTRING *dst, const FBWSTRING *src, int mode, int to_lower )
{
    ssize_t i;
    FB_WCHAR c;
    if( dst == NULL )
        goto done;
    if( src == NULL || src->data == NULL || src->len <= 0 ) {
        hWstrDynSetEmpty( dst );
        goto done;
    }
    if( !hWstrDynEnsure( dst, src->len ) )
        goto done;
    for( i = 0; i < src->len; ++i ) {
        c = src->data[i];
        if( mode == 1 ) {
            if( to_lower ) {
                if( c >= _LC('A') && c <= _LC('Z') ) c += _LC('a') - _LC('A');
            } else {
                if( c >= _LC('a') && c <= _LC('z') ) c -= _LC('a') - _LC('A');
            }
        } else {
#if defined HOST_WIN32
            /* Per-unit Unicode mapping through the Win32 API: locale-
               independent, one input unit -> one output unit (u-umlaut
               -> U-umlaut, sharp s stays sharp s).  The CRT towupper()
               depends on the process locale and can return garbage
               (e.g. 0x20) for non-ASCII units. */
            if( to_lower ) {
                c = (FB_WCHAR)(ULONG_PTR)CharLowerW( (LPWSTR)(ULONG_PTR)c );
            } else {
                c = (FB_WCHAR)(ULONG_PTR)CharUpperW( (LPWSTR)(ULONG_PTR)c );
            }
#else
            if( to_lower ) {
                if( fb_wstr_IsUpper( c ) ) c = fb_wstr_ToLower( c );
            } else {
                if( fb_wstr_IsLower( c ) ) c = fb_wstr_ToUpper( c );
            }
#endif
        }
        dst->data[i] = c;
    }
    dst->len = src->len;
    dst->data[dst->len] = 0;
done:
    if( src != dst ) fb_WstrDynDeleteTemp( src );
}

FBCALL void fb_WstrDynTrimSimple( FBWSTRING *dst, const FBWSTRING *src, int side )
{
    ssize_t first = 0, last;
    if( dst == NULL )
        goto done;
    if( src == NULL || src->data == NULL || src->len <= 0 ) {
        hWstrDynSetEmpty( dst );
        goto done;
    }
    last = src->len;
    if( side <= 0 )
        while( first < last && src->data[first] == _LC(' ') ) ++first;
    if( side >= 0 )
        while( last > first && src->data[last-1] == _LC(' ') ) --last;
    fb_WstrDynAssignWN( dst, src->data + first, last - first );
done:
    if( src != dst ) fb_WstrDynDeleteTemp( src );
}

static int hWstrDynSpanEqual( const FB_WCHAR *a, const FB_WCHAR *b, ssize_t n )
{
    ssize_t i;
    for( i = 0; i < n; ++i )
        if( a[i] != b[i] ) return FB_FALSE;
    return FB_TRUE;
}

static int hWstrDynInSet( FB_WCHAR c, const FBWSTRING *patt )
{
    ssize_t i;
    for( i = 0; i < patt->len; ++i )
        if( patt->data[i] == c ) return FB_TRUE;
    return FB_FALSE;
}

FBCALL void fb_WstrDynTrimPattern( FBWSTRING *dst, const FBWSTRING *src, const FBWSTRING *patt, int side, int is_any )
{
    ssize_t first = 0, last, plen;
    if( dst == NULL ) goto done;
    if( src == NULL || src->data == NULL || src->len <= 0 ) {
        hWstrDynSetEmpty( dst );
        goto done;
    }
    if( patt == NULL || patt->data == NULL || patt->len <= 0 ) {
        fb_WstrDynAssign( dst, src );
        src = NULL; /* fb_WstrDynAssign() consumed a temp source if needed */
        goto done;
    }
    last = src->len;
    plen = patt->len;
    if( is_any ) {
        if( side <= 0 )
            while( first < last && hWstrDynInSet( src->data[first], patt ) ) ++first;
        if( side >= 0 )
            while( last > first && hWstrDynInSet( src->data[last-1], patt ) ) --last;
    } else {
        if( side <= 0 ) {
            while( last - first >= plen && hWstrDynSpanEqual( src->data + first, patt->data, plen ) )
                first += plen;
        }
        if( side >= 0 ) {
            while( last - first >= plen && hWstrDynSpanEqual( src->data + last - plen, patt->data, plen ) )
                last -= plen;
        }
    }
    fb_WstrDynAssignWN( dst, src->data + first, last - first );
done:
    if( patt != src ) fb_WstrDynDeleteTemp( patt );
    if( src != dst ) fb_WstrDynDeleteTemp( src );
}

FBCALL void fb_WstrDynFill( FBWSTRING *dst, ssize_t chars, unsigned int c )
{
    ssize_t i;
    if( dst == NULL )
        return;
    if( chars <= 0 ) {
        hWstrDynSetEmpty( dst );
        return;
    }
    if( !hWstrDynEnsure( dst, chars ) )
        return;
    for( i = 0; i < chars; ++i )
        dst->data[i] = (FB_WCHAR)c;
    dst->len = chars;
    dst->data[chars] = 0;
}

FBCALL void fb_WstrDynFillWstr( FBWSTRING *dst, ssize_t chars, const FBWSTRING *src )
{
    if( dst == NULL )
        goto done;
    if( chars <= 0 || src == NULL || src->data == NULL || src->len <= 0 ) {
        hWstrDynSetEmpty( dst );
        goto done;
    }
    fb_WstrDynFill( dst, chars, (unsigned int)src->data[0] );
done:
    if( src != dst ) fb_WstrDynDeleteTemp( src );
}

FBCALL FBWSTRING *fb_WstrDynFillResult( ssize_t chars, unsigned int c )
{
    FBWSTRING *out = fb_hWstrDynAllocTempDesc();
    if( out == NULL ) return NULL;
    fb_WstrDynFill( out, chars, c );
    return out;
}

FBCALL FBWSTRING *fb_WstrDynFillWstrResult( ssize_t chars, const FBWSTRING *src )
{
    FBWSTRING *out = fb_hWstrDynAllocTempDesc();
    if( out == NULL ) { fb_WstrDynDeleteTemp( src ); return NULL; }
    fb_WstrDynFillWstr( out, chars, src );
    return out;
}

/* Native counted WChr(): unlike legacy fb_WstrChr(), embedded NUL values are
   ordinary characters and dst->len is authoritative. */
void fb_WstrDynChr( FBWSTRING *dst, int args, ... )
{
    va_list ap;
    int i;

    if( dst == NULL )
        return;
    if( args <= 0 ) {
        hWstrDynSetEmpty( dst );
        return;
    }
    if( !hWstrDynEnsure( dst, (ssize_t)args ) )
        return;

    va_start( ap, args );
    for( i = 0; i < args; ++i )
        dst->data[i] = (FB_WCHAR)va_arg( ap, unsigned int );
    va_end( ap );

    dst->len = (ssize_t)args;
    dst->data[dst->len] = 0;
}

/* Managed WChr() value result, mirroring fb_CHR(): allocate a temporary
   descriptor from the FBWSTRING temp pool and keep embedded NULs counted. */
FBCALL FBWSTRING *fb_WstrDynChrResult( int args, ... )
{
    FBWSTRING *dst;
    va_list ap;
    int i;

    dst = fb_hWstrDynAllocTempDesc();
    if( dst == NULL )
        return NULL;

    if( args <= 0 )
        return dst;

    if( !hWstrDynEnsure( dst, (ssize_t)args ) ) {
        fb_WstrDynDelete( dst );
        return NULL;
    }

    va_start( ap, args );
    for( i = 0; i < args; ++i )
        dst->data[i] = (FB_WCHAR)va_arg( ap, unsigned int );
    va_end( ap );

    dst->len = (ssize_t)args;
    dst->data[dst->len] = 0;
    return dst;
}

/* Move a function result descriptor off the callee stack into the managed
   WSTRING temporary-descriptor pool, mirroring fb_StrAllocTempResult(). */
FBCALL FBWSTRING *fb_WstrDynAllocTempResult( FBWSTRING *src )
{
    FBWSTRING *tmp = fb_hWstrDynAllocTempDesc();
    if( tmp == NULL )
        return NULL;
    if( src == NULL )
        return tmp;
    tmp->data = src->data;
    tmp->len = src->len;
    tmp->size = FB_WSTRDYN_CAPACITY( src ) | FB_TEMPWSTRBIT;
    src->data = NULL;
    src->len = 0;
    src->size = 0;
    return tmp;
}


static FBWSTRING *hWstrDynResultSlice( const FBWSTRING *src, ssize_t start, ssize_t count )
{
    FBWSTRING *out = fb_hWstrDynAllocTempDesc();
    if( out == NULL ) {
        fb_WstrDynDeleteTemp( src );
        return NULL;
    }
    if( src == NULL || src->data == NULL || src->len <= 0 || count <= 0 )
        goto done;
    if( start < 0 )
        start = 0;
    if( start >= src->len )
        goto done;
    if( count > src->len - start )
        count = src->len - start;
    if( !hWstrDynEnsure( out, count ) )
        goto done;
    memmove( out->data, src->data + start, (size_t)count * sizeof(FB_WCHAR) );
    out->len = count;
    out->data[count] = 0;
done:
    fb_WstrDynDeleteTemp( src );
    return out;
}

FBCALL FBWSTRING *fb_WstrDynLeftResult( const FBWSTRING *src, ssize_t chars )
{
    if( chars < 0 ) chars = 0;
    return hWstrDynResultSlice( src, 0, chars );
}

FBCALL FBWSTRING *fb_WstrDynRightResult( const FBWSTRING *src, ssize_t chars )
{
    ssize_t n = (src != NULL) ? src->len : 0;
    if( chars < 0 ) chars = 0;
    if( chars > n ) chars = n;
    return hWstrDynResultSlice( src, n - chars, chars );
}

FBCALL void fb_WstrDynLRSet( FBWSTRING *dst, const FBWSTRING *src, int is_rset )
{
    ssize_t dlen, slen, n, off;
    FB_WCHAR *tmp = NULL;
    if( dst == NULL ) goto done;
    dlen = dst->len;
    if( dlen <= 0 || dst->data == NULL ) goto done;
    slen = (src != NULL && src->data != NULL && src->len > 0) ? src->len : 0;
    n = (slen < dlen) ? slen : dlen;
    if( src == dst && n > 0 ) {
        tmp = (FB_WCHAR *)malloc( (size_t)n * sizeof(FB_WCHAR) );
        if( tmp == NULL ) goto done;
        memmove( tmp, src->data, (size_t)n * sizeof(FB_WCHAR) );
    }
    for( ssize_t i = 0; i < dlen; ++i ) dst->data[i] = (FB_WCHAR)' ';
    off = is_rset ? (dlen - n) : 0;
    if( n > 0 ) memmove( dst->data + off, tmp ? tmp : src->data, (size_t)n * sizeof(FB_WCHAR) );
    dst->data[dlen] = 0;
done:
    free( tmp );
    if( src != dst ) fb_WstrDynDeleteTemp( src );
}

FBCALL double fb_WstrDynVal( const FBWSTRING *src )
{
    double result = fb_WstrVal( (src && src->data) ? src->data : NULL );
    fb_WstrDynDeleteTemp( src );
    return result;
}
FBCALL char fb_WstrDynValBool( const FBWSTRING *src )
{
    char result = fb_WstrValBool( (src && src->data) ? src->data : NULL );
    fb_WstrDynDeleteTemp( src );
    return result;
}
FBCALL int fb_WstrDynValInt( const FBWSTRING *src )
{
    int result = fb_WstrValInt( (src && src->data) ? src->data : NULL );
    fb_WstrDynDeleteTemp( src );
    return result;
}
FBCALL unsigned int fb_WstrDynValUInt( const FBWSTRING *src )
{
    unsigned int result = fb_WstrValUInt( (src && src->data) ? src->data : NULL );
    fb_WstrDynDeleteTemp( src );
    return result;
}
FBCALL long long fb_WstrDynValLng( const FBWSTRING *src )
{
    long long result = fb_WstrValLng( (src && src->data) ? src->data : NULL );
    fb_WstrDynDeleteTemp( src );
    return result;
}
FBCALL unsigned long long fb_WstrDynValULng( const FBWSTRING *src )
{
    unsigned long long result = fb_WstrValULng( (src && src->data) ? src->data : NULL );
    fb_WstrDynDeleteTemp( src );
    return result;
}
