/* read stmt for native counted WSTRING */

#include "fb.h"

FBCALL void fb_DataReadDynWstr( FBWSTRING *dst )
{
    FB_LOCK();

    if( __fb_data_ptr ) {
        if( __fb_data_ptr->len == FB_DATATYPE_OFS ) {
            /* Keep the same unimplemented OFFSET behaviour as fb_DataReadWstr(). */
            fb_WstrDynAssignWN( dst, NULL, 0 );
        } else if( __fb_data_ptr->len & FB_DATATYPE_WSTR ) {
            ssize_t len = (ssize_t)(((unsigned short)__fb_data_ptr->len) & ~FB_DATATYPE_WSTR);
            fb_WstrDynAssignWN( dst, __fb_data_ptr->wstr, len );
        } else {
            /* Narrow DATA items carry an explicit byte length. */
            fb_WstrDynAssignA( dst, __fb_data_ptr->zstr, __fb_data_ptr->len );
        }
    } else {
        fb_WstrDynAssignWN( dst, NULL, 0 );
    }

    fb_DataNext();
    FB_UNLOCK();
}
