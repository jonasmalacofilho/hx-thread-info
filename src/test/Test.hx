/**
	Test/example of accessing complementary information about threads and their
	vms
	
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

import neko.vm.Lock;
import neko.vm.Thread;

/**
	Test/example of accessing complementary information about threads and their
	vms
**/
class Test {

	static inline var NTHREADS = 30;
	static var mainThread:Thread;

	static function main() {
		tryCurrentVm();
		tryOtherThreadInfos();
		mainThread = Thread.current();
		tryMulti();
	}

	static function tryCurrentVm() {
		trace( "Current VM address is: "+Thread.currentVmAddress() );
		trace( "Current VM address is: "+Thread.currentVmAddress() );
	}

	static function tryOtherThreadInfos() {
		trace( "<Current thread>.threadHandle is: "+Thread.current().threadHandle );
		trace( "<Current thread>.threadHandle is: "+Thread.current().threadHandle );
		trace( "<Current thread>.vmAddress is: "+Thread.current().vmAddress );
		trace( "<Current thread>.vmAddress is: "+Thread.current().vmAddress );
	}

	static function tryMulti() {
		trace( "Begin tryMulti" );
		var tmap = new Map<String,Int>();
		tmap.set( mainThread.threadHandle, -1 ); // -1 is main
		for ( i in 0...NTHREADS ) {
			var t = Thread.create( tryMulti_threadMain );
			t.sendMessage( mainThread );
			if ( tmap.exists( t.threadHandle ) )
				trace( "Warning: handle "+t.threadHandle+" already known" );
			tmap.set( t.threadHandle, i );
			trace( "Created thread "+i+": handle "+t.threadHandle+", vm "+t.vmAddress );
		}
		trace( tmap );
		trace( "Waiting" );
		var done = 0;
		wait( 1.05 );
		for ( i in 0...NTHREADS ) {
			var t:Thread = Thread.readMessage( false ); // typing is important:
			                                            // the magic happens in
			                                            // the property getter
			if ( t != null && tmap.exists( t.threadHandle ) ) {
				var j = tmap.get( t.threadHandle );
				tmap.remove( t.threadHandle );
				trace( "Done "+j+": handle "+t.threadHandle+", vm "+t.vmAddress );
				done++;
				t.sendMessage( null );
			}
		}
		var error = false;
		for ( x in tmap )
			if ( x > 0 ) {
				trace( "Thread "+x+" was still active." );
				error = true;
			}
		if ( error )
			trace( "End tryMulti: FAILED..." );
		else if ( done != NTHREADS )
			trace( "End tryMulti: FAILED... probably we found threads that shared handles" );
		else
			trace( "End tryMulti: success!" );
	}

	static function wait( s:Float ) {
		new Lock().wait( s );
	}

	static function tryMulti_threadMain() {
		var m:Thread = Thread.readMessage( true );
		wait( Math.random()*.95+.05 );
		m.sendMessage( Thread.current() );
		Thread.readMessage( true ); // this is important: it makes sure the
		                            // recipient of the message can still use
		                            // its threadHandle and vmAddress properties
	}

}

#if !haxe3
typedef Map<String,V> = Hash<V>;
#end
