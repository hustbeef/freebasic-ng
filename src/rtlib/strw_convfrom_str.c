/* ascii to unicode string convertion function */

#include "fb.h"

#if defined HOST_WIN32
#include <windows.h>
#include <locale.h>
#endif

#if !defined( HOST_DOS )

static ssize_t fb_wstr_ConvFromA_nomultibyte(FB_WCHAR *dst, ssize_t dst_chars, const char *src)
{
	/* mbstowcs() must have failed; translate at least ASCII chars
	   and write out '?' for the others */
	FB_WCHAR *origdst = dst;
	FB_WCHAR *dstlimit = dst + dst_chars;
	while (dst < dstlimit) {
		unsigned char c = *src++;
		if (c == 0)
			break;
		if (c > 127)
			c = '?';
		*dst++ = c;
	}
	*dst = _LC('\0');
	return dst - origdst;
}

#endif

/* dst_chars == room in dst buffer without null terminator. Thus, the dst buffer
   must be at least (dst_chars + 1) * sizeof(FB_WCHAR).
   src must be null-terminated.
   result = number of chars written, excluding null terminator that is always written */
ssize_t fb_wstr_ConvFromA(FB_WCHAR *dst, ssize_t dst_chars, const char *src)
{
	if (src == NULL) {
		*dst = _LC('\0');
		return 0;
	}

#if defined DISABLE_WCHAR
	ssize_t chars = strlen(src);
	if (chars > dst_chars) {
		chars = dst_chars;
	}
	memcpy(dst, src, chars + 1);

	/* ensure that the null terminator is written, string may have been truncated */
	dst[chars] = '\0';
	return chars;
#else
	/* plus the null-term (note: "n" in chars, not bytes!) */
	ssize_t chars = mbstowcs(dst, src, dst_chars + 1);

	/* worked? */
	if (chars >= 0) {
		/* a null terminator won't be added if there was not
		   enough space, so do it manually (this will cut off the last
		   char, but what can you do) */
		if (chars == (dst_chars + 1)) {
			dst[dst_chars] = _LC('\0');
			return dst_chars - 1;
		}
		return chars;
	}

	/* mbstowcs() failed?; translate at least ASCII chars
	** and write out '?' for the others
	*/
	return fb_wstr_ConvFromA_nomultibyte( dst, dst_chars, src );

#endif
}

/* Explicit-length STRING -> WSTRING conversion for native counted WSTRING.
   Unlike fb_wstr_ConvFromA(), embedded NUL bytes are data and do not terminate
   the source.  Conversion otherwise follows the current C locale semantics. */
ssize_t fb_wstr_ConvFromAN(FB_WCHAR *dst, ssize_t dst_chars, const char *src, ssize_t src_bytes)
{
    ssize_t out = 0;
    ssize_t pos = 0;

    if( dst == NULL || dst_chars < 0 )
        return 0;
    if( src == NULL || src_bytes <= 0 ) {
        dst[0] = _LC('\0');
        return 0;
    }

#if defined DISABLE_WCHAR
    while( pos < src_bytes && out < dst_chars )
        dst[out++] = (unsigned char)src[pos++];
#else
    /* PERF5: fast-path counted 7-bit STRING -> WSTRING while preserving legacy
       conversion for every non-ASCII byte and unusual locale. */
    {
        int ascii_fast_ok = (MB_CUR_MAX == 1);
#if defined HOST_WIN32
        if( !ascii_fast_ok ) {
            unsigned int cp = ___lc_codepage_func();
            if( cp == GetACP() || cp == GetOEMCP() || cp == CP_UTF8 )
                ascii_fast_ok = 1;
        }
#endif
        if( ascii_fast_ok ) {
            ssize_t n = src_bytes;
            ssize_t i;
            if( n > dst_chars ) n = dst_chars;
            for( i = 0; i < n; ++i ) if( ((unsigned char)src[i]) > 127 ) break;
            if( i == n ) {
                for( i = 0; i < n; ++i ) dst[i] = (FB_WCHAR)(unsigned char)src[i];
                dst[n] = _LC('\0');
                return n;
            }
        }
    }

    {
        mbstate_t state;
        memset( &state, 0, sizeof(state) );

        while( pos < src_bytes && out < dst_chars ) {
            wchar_t wc;
            size_t n;
            unsigned char c = (unsigned char)src[pos];

            /* mbrtowc() reports 0 for NUL.  In a counted STRING that is a
               character, not an end marker; consume exactly one byte and keep
               converting the remainder. */
            if( c == 0 ) {
                dst[out++] = _LC('\0');
                ++pos;
                memset( &state, 0, sizeof(state) );
                continue;
            }

            n = mbrtowc( &wc, src + pos, (size_t)(src_bytes - pos), &state );
            if( n == (size_t)-1 || n == (size_t)-2 ) {
                /* Match fb_wstr_ConvFromA()'s best-effort fallback: preserve
                   ASCII and replace an invalid/non-convertible byte by '?'. */
                dst[out++] = (c <= 127) ? (FB_WCHAR)c : (FB_WCHAR)'?';
                ++pos;
                memset( &state, 0, sizeof(state) );
                continue;
            }
            if( n == 0 ) {
                dst[out++] = _LC('\0');
                ++pos;
                memset( &state, 0, sizeof(state) );
                continue;
            }

            dst[out++] = (FB_WCHAR)wc;
            pos += (ssize_t)n;
        }
    }
#endif

    dst[out] = _LC('\0');
    return out;
}

FBCALL FB_WCHAR *fb_StrToWstr( const char *src )
{
	FB_WCHAR *dst;
	ssize_t chars;

	if( src == NULL )
		return NULL;

#if defined HOST_DOS
	/* on DOS, mbstowcs() simply calls memcpy() and won't compute
	length  see fb_unicode.h */
	chars = strlen( src );
#else
	chars = mbstowcs( NULL, src, 0 );

	/* invalid multibyte characters? get the plain old NUL terminated 
	** string length and allocate a buffer for at least the ASCII chars 
	*/
	if( chars < 0 ) {
		chars = strlen( src );
		dst = fb_wstr_AllocTemp( chars );
		if( dst == NULL ) {
			return NULL;
		}
		/* don't bother calling fb_wstr_ConvFromA() it will just call the trivial conversion anyway */
		fb_wstr_ConvFromA_nomultibyte( dst, chars, src );
		return dst;
	}

#endif
	if( chars == 0 )
		return NULL;

	dst = fb_wstr_AllocTemp( chars );
	if( dst == NULL ) {
		return NULL;
	}

	fb_wstr_ConvFromA( dst, chars, src );

	return dst;
}
