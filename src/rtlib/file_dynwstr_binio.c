/* binary GET/PUT for native counted WSTRING */
#include "fb.h"

/* Convert a logical WCHAR count to a byte count without relying on signed
   ssize_t multiplication.  This matters especially on Win32 where ssize_t
   is 32-bit and a valid positive descriptor length can overflow a signed
   `chars * sizeof(FB_WCHAR)` expression even though the corresponding
   size_t byte count is representable. */
static int hDynWstrBytesFor( ssize_t chars, size_t *bytes )
{
    if( bytes == NULL || chars < 0 )
        return FB_FALSE;
    if( (size_t)chars > SIZE_MAX / sizeof(FB_WCHAR) )
        return FB_FALSE;
    *bytes = (size_t)chars * sizeof(FB_WCHAR);
    return FB_TRUE;
}

static int hPutDyn( FB_FILE *handle, fb_off_t pos, const FBWSTRING *src )
{
    if( !FB_HANDLE_USED(handle) )
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
    size_t bytes;
    if( src == NULL || src->data == NULL || src->len <= 0 )
        return fb_ErrorSetNum( FB_RTERROR_OK );
    if( !hDynWstrBytesFor( src->len, &bytes ) )
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
    return fb_FilePutDataEx( handle, pos, src->data, bytes, TRUE, TRUE, FALSE );
}

FBCALL int fb_FilePutDynWstr( int fnum, int pos, const FBWSTRING *src )
{
    int res = hPutDyn( FB_FILE_TO_HANDLE(fnum), pos, src );
    fb_WstrDynDeleteTemp( src );
    return res;
}
FBCALL int fb_FilePutDynWstrLarge( int fnum, long long pos, const FBWSTRING *src )
{
    int res = hPutDyn( FB_FILE_TO_HANDLE(fnum), pos, src );
    fb_WstrDynDeleteTemp( src );
    return res;
}

static int hGetDyn( FB_FILE *handle, fb_off_t pos, FBWSTRING *dst, size_t *bytesread )
{
    size_t rawbytesread = 0;
    ssize_t want;
    size_t wantbytes;
    int res;
    if( bytesread != NULL )
        *bytesread = 0;
    if( !FB_HANDLE_USED(handle) || dst == NULL || dst->len < 0 )
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
    /* A zero-length destination requests zero WCHARs.  Treat it as a clean
       no-op, matching array elements and PUT, and do not require data. */
    if( dst->len == 0 )
        return fb_ErrorSetNum( FB_RTERROR_OK );
    if( dst->data == NULL )
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );

    want = dst->len;
    if( !hDynWstrBytesFor( want, &wantbytes ) )
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
    res = fb_FileGetDataEx( handle, pos, dst->data,
                            wantbytes,
                            &rawbytesread, TRUE, FALSE );
    if( res != FB_RTERROR_OK )
        return res;

    /* A partial final WCHAR is zero-padded by the file layer; count it as a
       code unit, matching legacy GET WSTRING behaviour. */
    ssize_t got = (ssize_t)(rawbytesread / sizeof(FB_WCHAR));
    if( (rawbytesread % sizeof(FB_WCHAR)) != 0 ) got += 1;
    if( got > want ) got = want;
    dst->len = got;
    dst->data[got] = 0;
    if( bytesread != NULL )
        *bytesread = rawbytesread;
    return FB_RTERROR_OK;
}
FBCALL int fb_FileGetDynWstr( int fnum, int pos, FBWSTRING *dst )
{
    return hGetDyn( FB_FILE_TO_HANDLE(fnum), pos, dst, NULL );
}
FBCALL int fb_FileGetDynWstrLarge( int fnum, long long pos, FBWSTRING *dst )
{
    return hGetDyn( FB_FILE_TO_HANDLE(fnum), pos, dst, NULL );
}
FBCALL int fb_FileGetDynWstrIOB( int fnum, int pos, FBWSTRING *dst, size_t *bytesread )
{
    return hGetDyn( FB_FILE_TO_HANDLE(fnum), pos, dst, bytesread );
}
FBCALL int fb_FileGetDynWstrLargeIOB( int fnum, long long pos, FBWSTRING *dst, size_t *bytesread )
{
    return hGetDyn( FB_FILE_TO_HANDLE(fnum), (fb_off_t)pos, dst, bytesread );
}


/* Native counted-WSTRING arrays use payload-only binary I/O.  Element
   boundaries are implicit: PUT concatenates element payloads in array order;
   GET consumes exactly each destination element's current logical length. */
static int hDynWstrArrayCheck( const FBARRAY *a )
{
    if( a == NULL )
        return FB_RTERROR_ILLEGALFUNCTIONCALL;
    if( a->element_len != sizeof(FBWSTRING) )
        return FB_RTERROR_ILLEGALFUNCTIONCALL;
    if( a->size == 0 )
        return FB_RTERROR_OK;
    if( a->ptr == NULL || (a->size % a->element_len) != 0 )
        return FB_RTERROR_ILLEGALFUNCTIONCALL;
    return FB_RTERROR_OK;
}

static int hPutDynArray( FB_FILE *handle, fb_off_t pos, FBARRAY *src )
{
    size_t i, count;
    FBWSTRING *v;
    int res;

    if( !FB_HANDLE_USED(handle) )
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
    res = hDynWstrArrayCheck( src );
    if( res != FB_RTERROR_OK )
        return fb_ErrorSetNum( res );
    if( src->size == 0 )
        return fb_ErrorSetNum( FB_RTERROR_OK );

    count = src->size / src->element_len;
    v = (FBWSTRING *)src->ptr;
    for( i = 0; i < count; ++i ) {
        if( v[i].len < 0 || (v[i].len > 0 && v[i].data == NULL) )
            return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
        if( v[i].len == 0 )
            continue;
        size_t bytes;
        if( !hDynWstrBytesFor( v[i].len, &bytes ) )
            return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
        res = fb_FilePutDataEx( handle, pos, v[i].data,
                                bytes,
                                TRUE, TRUE, FALSE );
        if( res != FB_RTERROR_OK )
            return res;
        pos = 0;
    }
    return fb_ErrorSetNum( FB_RTERROR_OK );
}

FBCALL int fb_FilePutDynWstrArray( int fnum, int pos, FBARRAY *src )
{
    return hPutDynArray( FB_FILE_TO_HANDLE(fnum), pos, src );
}
FBCALL int fb_FilePutDynWstrArrayLarge( int fnum, long long pos, FBARRAY *src )
{
    return hPutDynArray( FB_FILE_TO_HANDLE(fnum), (fb_off_t)pos, src );
}

static int hGetDynArray( FB_FILE *handle, fb_off_t pos, FBARRAY *dst, size_t *bytesread )
{
    size_t i, j, count, raw = 0, total = 0;
    FBWSTRING *v;
    int res;

    if( bytesread != NULL )
        *bytesread = 0;
    if( !FB_HANDLE_USED(handle) )
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
    res = hDynWstrArrayCheck( dst );
    if( res != FB_RTERROR_OK )
        return fb_ErrorSetNum( res );
    if( dst->size == 0 )
        return fb_ErrorSetNum( FB_RTERROR_OK );

    count = dst->size / dst->element_len;
    v = (FBWSTRING *)dst->ptr;
    for( i = 0; i < count; ++i ) {
        ssize_t want = v[i].len;
        ssize_t got;
        size_t wantbytes;

        if( want < 0 || (want > 0 && v[i].data == NULL) )
            return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
        if( want == 0 )
            continue;
        if( !hDynWstrBytesFor( want, &wantbytes ) )
            return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
        raw = 0;
        res = fb_FileGetDataEx( handle, pos, v[i].data, wantbytes, &raw, TRUE, FALSE );
        if( res != FB_RTERROR_OK )
            return res;
        pos = 0;
        total += raw;

        got = (ssize_t)(raw / sizeof(FB_WCHAR));
        if( (raw % sizeof(FB_WCHAR)) != 0 )
            ++got;
        if( got > want )
            got = want;
        v[i].len = got;
        v[i].data[got] = 0;

        if( raw < wantbytes ) {
            for( j = i + 1; j < count; ++j ) {
                v[j].len = 0;
                if( v[j].data != NULL )
                    v[j].data[0] = 0;
            }
            break;
        }
    }
    if( bytesread != NULL )
        *bytesread = total;
    return fb_ErrorSetNum( FB_RTERROR_OK );
}

FBCALL int fb_FileGetDynWstrArray( int fnum, int pos, FBARRAY *dst )
{
    return hGetDynArray( FB_FILE_TO_HANDLE(fnum), pos, dst, NULL );
}
FBCALL int fb_FileGetDynWstrArrayLarge( int fnum, long long pos, FBARRAY *dst )
{
    return hGetDynArray( FB_FILE_TO_HANDLE(fnum), (fb_off_t)pos, dst, NULL );
}
FBCALL int fb_FileGetDynWstrArrayIOB( int fnum, int pos, FBARRAY *dst, size_t *bytesread )
{
    return hGetDynArray( FB_FILE_TO_HANDLE(fnum), pos, dst, bytesread );
}
FBCALL int fb_FileGetDynWstrArrayLargeIOB( int fnum, long long pos, FBARRAY *dst, size_t *bytesread )
{
    return hGetDynArray( FB_FILE_TO_HANDLE(fnum), (fb_off_t)pos, dst, bytesread );
}
