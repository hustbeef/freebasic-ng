/* LINE INPUT for native counted WSTRING */
#include "fb.h"

FBCALL int fb_FileLineInputDynWstr( int fnum, FBWSTRING *dst )
{
    FB_FILE *handle = FB_FILE_TO_HANDLE(fnum);
    int res = FB_RTERROR_OK;

    if( !FB_HANDLE_USED(handle) )
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );

    FB_LOCK();
    fb_WstrDynAssignWN( dst, NULL, 0 );

    /* Read decoded WCHARs one at a time.  This preserves embedded NUL and
       avoids imposing the fixed-buffer limit of legacy LINE INPUT WSTRING. */
    while( TRUE ) {
        FB_WCHAR c;
        size_t len = 0;
        res = fb_FileGetDataEx( handle, 0, &c, 1, &len, FALSE, TRUE );
        if( (res != FB_RTERROR_OK) || (len == 0) )
            break;
        if( c == _LC('\r') ) {
            FB_WCHAR n;
            size_t nlen = 0;
            int r2 = fb_FileGetDataEx( handle, 0, &n, 1, &nlen, FALSE, TRUE );
            if( (r2 == FB_RTERROR_OK) && (nlen == 1) && (n != _LC('\n')) )
                fb_FilePutBackEx( handle, &n, 1 );
            break;
        }
        if( c == _LC('\n') )
            break;
        fb_WstrDynConcatAssignWN( dst, &c, 1 );
    }
    FB_UNLOCK();

    if( res == FB_RTERROR_ENDOFFILE )
        return fb_ErrorSetNum( FB_RTERROR_OK );
    return fb_ErrorSetNum( res );
}
