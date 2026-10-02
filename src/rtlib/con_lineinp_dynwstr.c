/* console LINE INPUT adapter for native counted WSTRING */
#include "fb.h"

FBCALL int fb_ConsoleLineInputDynWstr( const FB_WCHAR *text, FBWSTRING *dst, int addquestion, int addnewline )
{
    /* Console wide input is historically limited on these backends. Reuse the
       existing line reader with a growable narrow temporary, then convert. */
    FBSTRING tmp = { 0, 0, 0 };
    int res;
    (void)text;
    (void)addquestion;
    (void)addnewline;
#if defined( HOST_WIN32 ) || defined( HOST_DOS )
    {
        FBSTRING *p = fb_ConReadLine( FALSE );
        if( p == NULL ) return fb_ErrorSetNum( FB_RTERROR_OUTOFMEM );
        fb_WstrDynAssignA( dst, p, -1 );
        return fb_ErrorSetNum( FB_RTERROR_OK );
    }
#else
    res = fb_DevFileReadLineDumb( stdin, &tmp, NULL );
    fb_WstrDynAssignA( dst, &tmp, -1 );
    fb_StrDelete( &tmp );
    return res;
#endif
}
