/* unicode to ascii string convertion function */

#include "fb.h"

#if defined HOST_WIN32
	#include <windows.h>
#endif

/* dst_chars == room in dst buffer without null terminator. Thus, the dst buffer
   must be at least dst_chars+1 bytes.
   src must be null-terminated.
   result = number of chars written, excluding null terminator that is always written */
ssize_t fb_wstr_ConvToA(char *dst, ssize_t dst_chars, const FB_WCHAR *src)
{
	if (src == NULL) {
		*dst = '\0';
		return 0;
	}

#if defined DISABLE_WCHAR
	ssize_t chars = strlen(src);
	if (chars > dst_chars)
		chars = dst_chars;

	memcpy(dst, src, chars + 1);
	return chars;
#else
	char *origdst = dst;
	char *dstlimit = dst + dst_chars;

#if defined HOST_WIN32
	/* Windows: convert through the ANSI code page, like the official
	   rtlib.  The lexer stores narrow string literals in the ANSI code
	   page too, so this keeps WSTRING -> STRING (and every filename
	   derived from a WSTRING) consistent with them.  wcstombs() depends
	   on the CRT locale, which defaults to "C" and mangles every
	   non-ASCII unit into '?'. */
	int wbytes = WideCharToMultiByte( CP_ACP, 0, src, -1, dst,
	                                  (int)dst_chars + 1, NULL, NULL );
	if( wbytes > 0 ) {
		/* WideCharToMultiByte() counted the null terminator */
		return (ssize_t)wbytes - 1;
	}
	/* conversion failed (insufficient room or best-fit loss); fall
	   through to the ASCII + '?' translation below */
#endif

	/* translate at least ASCII chars and write out '?' for the others
	   (also the truncation path, like wcstombs() does) */
	while (dst < dstlimit) {
#if defined HOST_WIN32
		UTF_16 c = *src++;
		if (c == 0)
			break;
		if (c > 127) {
			if (c >= UTF16_SUR_HIGH_START && c <= UTF16_SUR_HIGH_END)
				src++;
			c = '?';
		}
#else
		UTF_32 c = *src++;
		if (c == 0)
			break;
		if (c > 127)
			c = '?';
#endif
		*dst++ = (char)c;
	}
	*dst = '\0';
	return dst - origdst;
#endif
}

FBCALL FBSTRING *fb_WstrToStr( const FB_WCHAR *src )
{
	FBSTRING *dst;
	ssize_t chars;

    if( src == NULL )
        return &__fb_ctx.null_desc;

#if defined HOST_DOS
    /* on DOS, wcstombs() simply calls memcpy() and won't compute
       length  see fb_unicode.h */
    chars = fb_wstr_Len( src );
#else
    chars = wcstombs( NULL, src, 0 );
#endif
    if( chars == 0 )
        return &__fb_ctx.null_desc;

    dst = fb_hStrAllocTemp( NULL, chars );
    if( dst == NULL )
        return &__fb_ctx.null_desc;

    fb_wstr_ConvToA( dst->data, chars, src );

    return dst;
}
