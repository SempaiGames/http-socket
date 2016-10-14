package httpSocket;

#if cpp
import cpp.vm.Thread;
import cpp.vm.Mutex;
#elseif neko
import neko.vm.Thread;
import neko.vm.Mutex;
#end

class ThreadedHttp {

	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////

	#if ( cpp || neko )
	
	private static var threadPool:Array<ThreadedHttp>;
	private var thread:Thread;
	private var queueSize:Int;

	///////////////////////////////////////////////////////////////////////////

	private function new() {
		queueSize = 0;
		thread = Thread.create(onThreadMessage);
		threadPool.push(this);
	}

	///////////////////////////////////////////////////////////////////////////

	private function onThreadMessage(){
		var http:Http = null;
		while(true){
			try {
				http = Thread.readMessage(true);
				if ( http == null ) continue;
				http.request(true);
				queueSize--;
			} catch(e:Dynamic) {
				trace("Exception: "+e);
			}
		}	
	}

	private function queue(http:Http){
		queueSize++;
		thread.sendMessage(http);
	}

	#end

	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////

	#if ( cpp || neko )
	private static function pickThread():ThreadedHttp{
		if(threadPool == null){
			threadPool = new Array<ThreadedHttp>();
			return new ThreadedHttp();
		}
		var best:ThreadedHttp = threadPool[0];
		for(t in threadPool){
			if(t.queueSize <= 0) return t;
			if(t.queueSize < best.queueSize) best = t;
		}
		if(threadPool.length < maxThreads) return new ThreadedHttp();
		return best;
	}
	#end

	///////////////////////////////////////////////////////////////////////////

	public static var maxThreads:Int = 5;

	///////////////////////////////////////////////////////////////////////////

	public static function getQueueSize():Int {
		var queueSize:Int = 0;
		#if ( cpp || neko )
		for(t in threadPool) queueSize += t.queueSize;
		#end
		return queueSize;
	}

	///////////////////////////////////////////////////////////////////////////

	public static function requestUrl(url:String, onSuccess:Http->String->Void, onError:Http->String->Void){
		#if ( cpp || neko )
			var http = new Http(url, onSuccess, onError);
			http.blocking = false;
			pickThread().queue(http);
		#end
	}

	///////////////////////////////////////////////////////////////////////////

	public static function request(http:Http){
		#if ( cpp || neko )
			http.blocking = false;
			pickThread().queue(http);
		#end
	}

}
