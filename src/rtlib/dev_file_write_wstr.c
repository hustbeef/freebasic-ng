/* wstring to ascii file writing function */

#include "fb.h"

int fb_DevFileWriteWstr( FB_FILE *handle, const FB_WCHAR* src, size_t chars )
{
    FILE *fp;
    char *buffer;
    int res;

    FB_LOCK();

    fp = (FILE*) handle->opaque;

	if( fp == NULL ) {
		FB_UNLOCK();
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
	}

	if( chars < FB_LOCALBUFF_MAXLEN )
	{
		buffer = alloca( chars + 1 );
		/* note: if out of memory on alloca, it's a stack exception */
	}
	else
	{
		buffer = malloc( chars + 1 );
		if( buffer == NULL )
		{
			FB_UNLOCK();
			return fb_ErrorSetNum( FB_RTERROR_OUTOFMEM );
		}
	}

	/* Convert to ASCII.  fb_wstr_ConvToA() is intentionally a legacy
	   NUL-terminated conversion helper, while this device hook receives an
	   explicit WCHAR count.  Preserve embedded WCHAR(0) by converting each
	   non-NUL span separately and emitting the NUL byte explicitly.  This
	   keeps the historical conversion semantics for ordinary WSTRINGs while
	   making the length contract of pfnWriteWstr() real. */
	{
		size_t inpos = 0;
		size_t outpos = 0;

		while( inpos < chars ) {
			size_t span = 0;
			while( (inpos + span < chars) && (src[inpos + span] != 0) )
				++span;

			if( span != 0 ) {
				fb_wstr_ConvToA( buffer + outpos, span, src + inpos );
				outpos += span;
				inpos += span;
			}

			if( inpos < chars ) {
				buffer[outpos++] = '\0';
				++inpos;
			}
		}

		/* pfnWriteWstr()'s ASCII device has historically emitted one byte per
		   input WCHAR; the span conversion above retains exactly that contract. */
		res = fwrite( (void *)buffer, 1, outpos, fp ) == outpos;
	}

	if( chars >= FB_LOCALBUFF_MAXLEN )
		free( buffer );

	FB_UNLOCK();

	return fb_ErrorSetNum( (res? FB_RTERROR_OK: FB_RTERROR_FILEIO) );
}
