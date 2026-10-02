/* input function for wstring's */

#include "fb.h"

FBCALL int fb_InputWstr( FB_WCHAR *str, ssize_t length )
{
	FB_WCHAR buffer[FB_INPUT_MAXSTRINGLEN+1];

	fb_FileInputNextTokenWstr( buffer, FB_INPUT_MAXSTRINGLEN, TRUE );

	fb_WstrAssign( str, length, buffer );
	return fb_ErrorSetNum( FB_RTERROR_OK );
}

/* Native counted WSTRING input: preserve the token's explicit length, including NULs. */
FBCALL int fb_InputDynWstr( FBWSTRING *dst )
{
	FB_WCHAR buffer[FB_INPUT_MAXSTRINGLEN+1];
	ssize_t len;

	len = fb_FileInputNextTokenWstr( buffer, FB_INPUT_MAXSTRINGLEN, TRUE );
	fb_WstrDynAssignWN( dst, buffer, len );
	return fb_ErrorSetNum( FB_RTERROR_OK );
}
