/* print [#] functions */

#include "fb.h"

/*:::::*/
FBCALL void fb_LPrintWstr
	(
		int fnum,
		const FB_WCHAR *s,
		int mask
	)
{
    fb_LPrintInit();

    fb_PrintWstrEx( FB_FILE_TO_HANDLE(fnum),
                    s,
                    FB_PRINT_CONVERT_BIN_NEWLINE(mask) );
}

/* Native counted WSTRING printer path. */
FBCALL void fb_LPrintDynWstr
	(
		int fnum,
		const FBWSTRING *s,
		int mask
	)
{
	FB_FILE *handle;
	fb_LPrintInit();
	handle = FB_FILE_TO_HANDLE(fnum);
	mask = FB_PRINT_CONVERT_BIN_NEWLINE(mask);
	FB_LOCK();
	if( (s != NULL) && (s->data != NULL) && (s->len != 0) )
		FB_PRINTWSTR_EX( handle, s->data, s->len, 0 );
	fb_PrintVoidWstrEx( handle, mask );
	FB_UNLOCK();
	fb_WstrDynDeleteTemp( s );
}
