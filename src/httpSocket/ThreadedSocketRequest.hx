package httpSocket;

#if cpp
import cpp.vm.Thread;
#elseif neko
import neko.vm.Thread;
#end

class ThreadedSocketRequest {

	#if ( cpp || neko )
	
	private static var thread:Thread;
	private static var initted:Bool=false;	
	
	public static function init() {
		if(initted) return;
		initted=true;
		thread = Thread.create(onThreadMessage);
	}

	private static function onThreadMessage(){
		var url:String = null;
		while(true){
			try {
				url = Thread.readMessage(true);
				if ( url == null ) continue;
				var http = new Http(url, onSuccess, onError);
				http.threaded = true;
				http.request();
			} catch(e:Dynamic) {
				trace("Exception: "+e);
			}
		}	
	}

	#end

	public static var onSuccess:Http->String->Void = null;
	public static var onError:Http->String->Void = null;

	public static function request(url:String){
		#if ( cpp || neko )
			init();
			thread.sendMessage(url);
		#end
	}

}
