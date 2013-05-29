/**
	Hooks on the neko vm to allow access to complementary information about
	thread and its vm
	
	Copyright (c) 2013, Jonas Malaco Filho
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

	  - Redistributions of source code must retain the above copyright
	    notice, this list of conditions and the following disclaimer.
	  - Redistributions in binary form must reproduce the above copyright
	    notice, this list of conditions and the following disclaimer in the
	    documentation and/or other materials provided with the distribution.

	THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS "AS IS" AND ANY
	EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR
	ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
	DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
	OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
	DAMAGE.

	(The BSD 2-Clause License.)
**/

/* Std imports */
#include <stdlib.h>
#include <stdio.h>

/* Basic neko cffi imports */
#include <neko.h>

/* Additional neko imports (this requires access to full neko source tree) */
#include <neko_vm.h>

/* Type and imports borrowed from libs/std/thread.c */
#ifdef NEKO_WINDOWS
#	include <windows.h>
	typedef HANDLE vlock;
#else
#	include <pthread.h>
#	include <sys/time.h>
	typedef struct _vlock {
		pthread_mutex_t lock;
		pthread_cond_t cond;
		int counter;
	} *vlock;
#endif
typedef struct _tqueue {
	value msg;
	struct _tqueue *next;
} tqueue;
typedef struct {
	tqueue *first;
	tqueue *last;
#	ifdef NEKO_WINDOWS
	CRITICAL_SECTION lock;
	HANDLE wait;
#	else
	pthread_mutex_t lock;
	pthread_cond_t wait;
#	endif
} vdeque;
typedef struct {
#	ifdef NEKO_WINDOWS
	DWORD tid;
#	else
	pthread_t phandle;
#	endif
	value v;
	vdeque q;
	neko_vm *vm;
} vthread;

/**
	Prints (to a string) the contents of the native thread handle.

	params:
		[handle]: Haxe handle, received during thread creation, of a LIVE thread;
		          it should be a vthread pointer.
	returns:
		string with the hexadecimal representation of the handle.
	
	There is no assurance of endianess or size of the returned string. It will
	just be a representation of whatever is the native handle, be it a thread id
	(Windows/simple pthread implementations) or a complex pthread_t handle.
	Therefore, it should be used only for comparission with other handles.
**/
value str_thread_handle( value handle ) {
	vthread *t = (vthread*)val_data( handle );
	char *buf;
#	ifdef NEKO_WINDOWS
	failure( "not implemented for Windows threads yet" );
#	else
	buf = (char*)malloc( sizeof( t->phandle ) + 3 );
	unsigned char *cph = (unsigned char*)(void*)(&t->phandle);
	size_t i;
	sprintf( (char*)(buf), "0x" );
	for ( i=0; i<sizeof( t->phandle ); i++ ) {
		sprintf( &buf[i+2], "%2.2x", cph[i] );
	}
	buf[i+2] = 0;
#	endif
	value str = alloc_string( buf );
	free( buf );
	return str;
}
DEFINE_PRIM( str_thread_handle, 1 );

/**
	Prints (to a string) the address of the vm used by this thread

	params:
		[handle]: Haxe handle, received during thread creation, of a LIVE thread;
		          it should be a vthread pointer.
	returns:
		string with a dexadecimal representation of the vm pointer
**/
value str_thread_vm_address( value handle ) {
	vthread *t = (vthread*)val_data( handle );
	char *buf = malloc( sizeof( size_t ) + 3 );
	sprintf( buf, "%p", t->vm );
	value str = alloc_string( buf );
	free( buf );
	return str;
}
DEFINE_PRIM( str_thread_vm_address, 1 );

/**
	Prints (to a string) the address of the current vm

	returns:
		string with a dexadecimal representation of the current vm pointer
**/
value str_current_vm_address() {
	char *buf = malloc( sizeof( size_t ) + 3 );
	sprintf( buf, "%p", neko_vm_current() );
	value str = alloc_string( buf );
	free( buf );
	return str;
}
DEFINE_PRIM( str_current_vm_address, 0 );
