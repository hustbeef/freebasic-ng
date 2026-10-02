/**
 * ThreadCall: Launches any procedure as new thread, based on libffi.
 *
 * For example:
 *
 * FB code:
 *    declare sub MySub(x as integer, y as integer)
 *    thread = threadcall MySub(2, 3)
 *    threadwait thread
 *
 * Turned into this by fbc:
 *    a = 2
 *    b = 3
 *    thread = fb_ThreadCall(@MySub, STDCALL, 2, INT, @a, INT, @b)
 *    fb_ThreadWait(thread)
 *
 * fb_ThreadCall() packs the call and parameter data it's given into an array
 * of pointers and then launches a thread. The new thread reconstructs the call
 * using LibFFI and then calls the user's procedure.
 */

#include "fb.h"

#if defined DISABLE_FFI || (!defined HOST_X86 && !defined HOST_X86_64)

FBTHREAD *fb_ThreadCall( void *proc, int abi, ssize_t stack_size, int num_args, ... )
{
	return NULL;
}

#else

#include <ffi.h>

#define FB_THREADCALL_MAX_ELEMS 1024

typedef struct _FBTHREADCALL
{
	void         *proc;
	int           abi;
	int           num_args;
	ffi_type    **ffi_arg_types;
	void        **values;
	FBWSTRING   **owned_wstrs;
} FBTHREADCALL;

/* mirrored in compiler/rtl.bi */
enum {
	FB_THREADCALL_STDCALL,
	FB_THREADCALL_CDECL,
	FB_THREADCALL_INT8,
	FB_THREADCALL_UINT8,
	FB_THREADCALL_INT16,
	FB_THREADCALL_UINT16,
	FB_THREADCALL_INT32,
	FB_THREADCALL_UINT32,
	FB_THREADCALL_INT64,
	FB_THREADCALL_UINT64,
	FB_THREADCALL_FLOAT32,
	FB_THREADCALL_FLOAT64,
	FB_THREADCALL_STRUCT,
	FB_THREADCALL_PTR,
	FB_THREADCALL_DYNWSTRING
};

static void freeStruct( ffi_type *arg )
{
    int i = 0;
    ffi_type **elem = arg->elements;
    
    while( *elem != NULL )
    {
        /* cap element count to limit buffer overrun */
        if ( i >= FB_THREADCALL_MAX_ELEMS )
            break;
        
        /* free embedded types */
        if( (*elem)->type == FFI_TYPE_STRUCT )
            freeStruct( *elem );
            
        elem++;
        i++;
    }
    
    free( arg->elements );
    free( arg );
}

static ffi_type *getArgument( va_list *args_list, int *arg_type_out );

static ffi_type *getStruct( va_list *args_list )
{
    int num_elems = va_arg( (*args_list), int );
    int i, j;

    /* prepare type */
    ffi_type *ffi_arg = (ffi_type *)malloc( sizeof( ffi_type ) );
    ffi_arg->size = 0;
    ffi_arg->alignment = 0;
    ffi_arg->type = FFI_TYPE_STRUCT;
    ffi_arg->elements = 
        (ffi_type **)malloc( sizeof( ffi_type * ) * ( num_elems + 1 ) );
    ffi_arg->elements[num_elems] = NULL;
    
    /* scan elements */
    for( i=0; i<num_elems; i++ )
    {
        ffi_arg->elements[i] = getArgument( args_list, NULL );
        if( ffi_arg->elements[i] == NULL )
        {
            /* error, free memory and return NULL */
            for( j=0; j<i; j++ )
            {
                if( ffi_arg->elements[j]->type == FFI_TYPE_STRUCT )
                    freeStruct( ffi_arg );
            }
            free( ffi_arg->elements );
            free( ffi_arg );
            return NULL;
        }
    }
    
    return ffi_arg;
}

static ffi_type *getArgument( va_list *args_list, int *arg_type_out )
{
    int arg_type = va_arg( (*args_list), int );
    if( arg_type_out != NULL )
        *arg_type_out = arg_type;
    switch( arg_type )
    {
        case FB_THREADCALL_INT8:    return &ffi_type_sint8;
        case FB_THREADCALL_UINT8:   return &ffi_type_uint8;
        case FB_THREADCALL_INT16:   return &ffi_type_sint16;
        case FB_THREADCALL_UINT16:  return &ffi_type_uint16;
        case FB_THREADCALL_INT32:   return &ffi_type_sint32;
        case FB_THREADCALL_UINT32:  return &ffi_type_uint32;
        case FB_THREADCALL_INT64:   return &ffi_type_sint64;
        case FB_THREADCALL_UINT64:  return &ffi_type_uint64;
        case FB_THREADCALL_FLOAT32: return &ffi_type_float;
        case FB_THREADCALL_FLOAT64: return &ffi_type_double;
        case FB_THREADCALL_STRUCT:     return getStruct( args_list );
        case FB_THREADCALL_PTR:        return &ffi_type_pointer;
        case FB_THREADCALL_DYNWSTRING: return &ffi_type_pointer;
        default:
            return NULL;
    }
}

static void freeArguments( int count, ffi_type **ffi_args, void **values, FBWSTRING **owned_wstrs )
{
    int i;

    for( i=0; i<count; i++ )
    {
        if( owned_wstrs != NULL && owned_wstrs[i] != NULL )
        {
            fb_WstrDynDelete( owned_wstrs[i] );
            free( owned_wstrs[i] );
            free( values[i] );
        }

        if( ffi_args[i]->type == FFI_TYPE_STRUCT )
            freeStruct( ffi_args[i] );
    }

    free( owned_wstrs );
    free( values );
    free( ffi_args );
}

static FBCALL void threadproc( void *param );

FBTHREAD *fb_ThreadCall( void *proc, int abi, ssize_t stack_size, int num_args, ... )
{
    ffi_type     **ffi_args;
    void         **values;
    FBWSTRING    **owned_wstrs;
    FBTHREADCALL  *param;
    FBTHREAD      *thread;
    int i;

    /* initialize lists and arrays */
    ffi_args = (ffi_type **)malloc( sizeof( ffi_type * ) * num_args );
    values = (void **)malloc( sizeof( void * ) * num_args );
    owned_wstrs = (FBWSTRING **)calloc( num_args, sizeof( FBWSTRING * ) );
    if( num_args > 0 && (ffi_args == NULL || values == NULL || owned_wstrs == NULL) )
    {
        free( owned_wstrs );
        free( values );
        free( ffi_args );
        return NULL;
    }

    va_list args_list;
    va_start(args_list, num_args);

    /* scan arguments and values from var_args */
    for( i=0; i<num_args; i++ )
    {
        int arg_type = -1;
        void *value;

        ffi_args[i] = getArgument( &args_list, &arg_type );
        if( ffi_args[i] == NULL )
        {
            va_end( args_list );
            freeArguments( i, ffi_args, values, owned_wstrs );
            return NULL;
        }

        value = va_arg( args_list, void * );
        if( arg_type == FB_THREADCALL_DYNWSTRING )
        {
            FBWSTRING *src;
            FBWSTRING *owned;
            FBWSTRING **slot;

            /* The compiler passes the address of a descriptor pointer.  The
               descriptor may be an expression-lifetime temporary, so copy it
               synchronously before fb_ThreadCall() returns. */
            if( value == NULL || *(FBWSTRING **)value == NULL )
            {
                va_end( args_list );
                freeArguments( i, ffi_args, values, owned_wstrs );
                return NULL;
            }

            src = *(FBWSTRING **)value;
            owned = (FBWSTRING *)calloc( 1, sizeof( FBWSTRING ) );
            slot = (FBWSTRING **)malloc( sizeof( FBWSTRING * ) );
            if( owned == NULL || slot == NULL )
            {
                free( slot );
                free( owned );
                va_end( args_list );
                freeArguments( i, ffi_args, values, owned_wstrs );
                return NULL;
            }

            fb_WstrDynAssign( owned, src );
            *slot = owned;
            values[i] = slot;
            owned_wstrs[i] = owned;
        }
        else
        {
            values[i] = value;
        }
    }
    va_end( args_list );

    /* pack into thread parameter */
    param = (FBTHREADCALL *)malloc( sizeof( FBTHREADCALL ) );
    if( param == NULL )
    {
        freeArguments( num_args, ffi_args, values, owned_wstrs );
        return NULL;
    }
    param->proc = proc;
    param->abi = abi;
    param->num_args = num_args;
    param->ffi_arg_types = ffi_args;
    param->values = values;
    param->owned_wstrs = owned_wstrs;

    /* actually start thread */
    thread = fb_ThreadCreate( threadproc, (void *)param, stack_size );
    if( thread == NULL )
    {
        freeArguments( num_args, ffi_args, values, owned_wstrs );
        free( param );
    }
    return thread;
}

static FBCALL void threadproc( void *param )
{
    FBTHREADCALL *info = ( FBTHREADCALL * )param;
    ffi_status status = FFI_OK;
    ffi_abi abi = -1;
    ffi_cif cif;

#ifdef HOST_X86_64
    abi = FFI_DEFAULT_ABI;
#else
    /* check calling convention */
    if( info->abi == FB_THREADCALL_CDECL )
        abi = FFI_SYSV;
#ifdef HOST_WIN32
    else if( info->abi == FB_THREADCALL_STDCALL )
        abi = FFI_STDCALL;
#endif
    else
        status = ~FFI_OK;

    /* prep FFI call interface */
    if( status == FFI_OK )
#endif
        status = ffi_prep_cif( 
            &cif,               // handle
            abi,                // ABI (CDECL or STDCALL on x86, host default on x86_64)
            info->num_args,     // number of arguments
            &ffi_type_void,     // return type
            info->ffi_arg_types // argument types
        );
        
    /* execute */
    if( status == FFI_OK )
        ffi_call( &cif, FFI_FN( info->proc ), NULL, info->values );
    

    /* free memory and exit */
    freeArguments( info->num_args, info->ffi_arg_types, info->values, info->owned_wstrs );
    free( info );
}

#endif
