/*
 * Standard Thread class for the neko target
 * Copyright (c) 2005, The haXe Project Contributors
 *
 * Access to complementary information about thread and its vm
 * Copyright (c) 2013, Jonas Malaco Filho
 *
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 *
 * (The BSD 2-Clause License.)
 */
package neko.vm;

enum ThreadHandle {
}

class Thread {

	var handle : ThreadHandle;

	function new(h) {
		handle = h;
	}

	/**
		Send a message to the thread queue. This message can be readed by using [readMessage].
	**/
	public function sendMessage( msg : Dynamic ) {
		thread_send(handle,msg);
	}

	/**
		Returns the current thread.
	**/
	public static function current() {
		return new Thread(thread_current());
	}

	/**
		Creates a new thread that will execute the [callb] function, then exit.
	**/
	public static function create( callb : Void -> Void ) {
		return new Thread(thread_create(function(_) { return callb(); },null));
	}

	/**
		Reads a message from the thread queue. If [block] is true, the function
		blocks until a message is available. If [block] is false, the function
		returns [null] if no message is available.
	**/
	public static function readMessage( block : Bool ) : Dynamic {
		return thread_read_message(block);
	}

	function __compare(t) {
		return untyped __dollar__compare(handle,t.handle);
	}

	static var thread_create = neko.Lib.load("std","thread_create",2);
	static var thread_current = neko.Lib.load("std","thread_current",0);
	static var thread_send = neko.Lib.load("std","thread_send",2);
	static var thread_read_message = neko.Lib.load("std","thread_read_message",1);


	// begin library hx-thread-info

	/**
		Contains a hexadecimal (string) representation of the thread handle.

		This is only available when the Thread is still running. Also, there are
		no garanties concerning size or format, only that it will be consistent
		during runtime.
	**/
	public var threadHandle( get_threadHandle, never ):String;

	function get_threadHandle() return new String( str_thread_handle( handle ) )
	static var str_thread_handle = neko.Lib.load( "hx_thread_info", "str_thread_handle", 1 );

	/**
		Contains a hexadecimal (string) representation of the thread vm address.

		This is only available when the Thread is still running. Also, there are
		no garanties concerning size or format, only that it will be consistent
		during runtime.
	**/
	public var vmAddress( get_vmAddress, never ):String;

	function get_vmAddress() return new String( str_thread_vm_address( handle ) )
	static var str_thread_vm_address = neko.Lib.load( "hx_thread_info", "str_thread_vm_address", 1 );

	/**
		Returns the hexadecimal (string) representation of the current vm address

		There are no garanties concerning size or format, only that it will be
		consistent during runtime.
	**/
	public static function currentVmAddress() {
		return new String( str_current_vm_address() );
	}

	static var str_current_vm_address = neko.Lib.load( "hx_thread_info", "str_current_vm_address", 0 );

	// end library hx-thread-info

}
