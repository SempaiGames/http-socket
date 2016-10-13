package ;

import httpSocket.Http;
import httpSocket.ThreadedSocketRequest;

class Main {
	
	public static function main() {
		// The super simple way
		var data = Http.requestUrl('http://www.google.com.ar/search?q=haxe');
		trace(data);
		
		// The powerful way
		var a = new Http('http://api.haxe.org/sys/net/Socket.html',onSuccess,onError);
		a.timeout = 5;
		// You can set UserAgent plus other headers like this
		// a.addHeader('User-Agent',"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36");
		// a.addHeader('Referer','http://api.haxe.org/haxe/Timer.html');
		// a.addHeader('Accept-Language','es,en-US;q=0.8,en;q=0.6,gl;q=0.4');
		a.request();

		/*
		ThreadedSocketRequest.onSuccess = onSuccess;
		ThreadedSocketRequest.onError = onError;
		ThreadedSocketRequest.request('http://api.haxe.org/sys/net/Socket.html');
		ThreadedSocketRequest.request('http://api.haxe.org/sys/net/Socket2.html');
		ThreadedSocketRequest.request('http://api.haxe.org/sys/net/Socket3.html');
		ThreadedSocketRequest.request('http://api.haxe.org/sys/net/Socket4.html');
		var i:Int =0;
		for(i in 0...200){
			trace('.');
			Sys.sleep(0.1);
		}
		*/
	}

	public static function onSuccess(http:Http, msg:String){
		trace(msg);
		trace(http.status);
		trace(http.data);
	}

	public static function onError(http:Http, msg:String){
		trace("ERROR... something went wrong accessing "+http.url);
		trace(msg);
		trace(http.status);
		// trace(http.data); // You may have the error / not found html page on http.data
	}

}