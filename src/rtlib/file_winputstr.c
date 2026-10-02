/* winput$ function */

#include "fb.h"

FBCALL FB_WCHAR *fb_FileWstrInput( ssize_t chars, int fnum )
{
	FB_FILE *handle;
	FB_WCHAR *dst;
	size_t len;
	int res = FB_RTERROR_OK;

	fb_DevScrnInit_ReadWstr( );

	FB_LOCK();

	handle = FB_FILE_TO_HANDLE(fnum);
	if( !FB_HANDLE_USED(handle) )
	{
		FB_UNLOCK();
		return NULL;
	}

	dst = fb_wstr_AllocTemp( chars );
	if( dst != NULL )
	{
		ssize_t read_chars = 0;
		if( FB_HANDLE_IS_SCREEN(handle) )
		{
			while( read_chars != chars )
			{
				res = fb_FileGetDataEx( handle,
					0,
					(void *)&dst[read_chars],
					chars - read_chars,
					&len,
					TRUE,
					TRUE );
				if( res != FB_RTERROR_OK )
					break;

				read_chars += len;
			}
		}
		else
		{
			res = fb_FileGetDataEx( handle,
				0,
				(void *)dst,
				chars,
				&len,
				TRUE,
				TRUE );
			read_chars = chars;
		}

		if( res == FB_RTERROR_OK )
		{
			dst[read_chars] = _LC('\0');
		}
		else
		{
			fb_wstr_Del( dst );
			dst = NULL;
		}

	}
	else
	{
		res = FB_RTERROR_OUTOFMEM;
	}

	FB_UNLOCK();

	return dst;
}


/* Native counted-WSTRING variant of WInput().  Unlike the legacy wide-string
   result above, the descriptor length comes from the actual read count, so an
   embedded WCHAR(0) remains ordinary content.  The returned descriptor follows
   the native-WSTRING temporary-result protocol and is consumed like a STRING temp. */
FBCALL FBWSTRING *fb_FileDynWstrInput( ssize_t chars, int fnum )
{
    FB_FILE *handle;
    FBWSTRING *dst;
    size_t len = 0;
    ssize_t read_chars = 0;
    int res = FB_RTERROR_OK;

    fb_DevScrnInit_ReadWstr( );

    dst = fb_hWstrDynAllocTempDesc();
    if( dst == NULL )
        return NULL;

    if( chars <= 0 )
        return dst;

    if( (size_t)chars > (SIZE_MAX / sizeof(FB_WCHAR)) - 1 ) {
        fb_WstrDynDeleteTemp( dst );
        return NULL;
    }

    dst->data = (FB_WCHAR *)malloc( ((size_t)chars + 1) * sizeof(FB_WCHAR) );
    if( dst->data == NULL ) {
        fb_WstrDynDeleteTemp( dst );
        return NULL;
    }
    dst->size = chars | FB_TEMPWSTRBIT;

    FB_LOCK();

    handle = FB_FILE_TO_HANDLE(fnum);
    if( !FB_HANDLE_USED(handle) ) {
        res = FB_RTERROR_ILLEGALFUNCTIONCALL;
    } else if( FB_HANDLE_IS_SCREEN(handle) ) {
        while( read_chars < chars ) {
            len = 0;
            res = fb_FileGetDataEx( handle,
                                    0,
                                    (void *)&dst->data[read_chars],
                                    chars - read_chars,
                                    &len,
                                    TRUE,
                                    TRUE );
            if( res != FB_RTERROR_OK || len == 0 )
                break;
            read_chars += (ssize_t)len;
        }
    } else {
        res = fb_FileGetDataEx( handle,
                                0,
                                (void *)dst->data,
                                chars,
                                &len,
                                TRUE,
                                TRUE );
        if( res == FB_RTERROR_OK )
            read_chars = (ssize_t)len;
    }

    FB_UNLOCK();

    if( res != FB_RTERROR_OK ) {
        fb_WstrDynDeleteTemp( dst );
        return NULL;
    }

    dst->len = read_chars;
    dst->data[read_chars] = 0;
    return dst;
}
