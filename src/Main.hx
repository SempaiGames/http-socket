package ;

import httpSocket.Http;
import httpSocket.ThreadedHttp;

class Main {
	
	public static function main() {
		// The super simple way
		var data = Http.requestUrl('http://www.google.com.ar/search?q=haxe');
		trace(data);
		
		// The powerful way
		var http = new Http('http://api.haxe.org/sys/net/Socket.html',onSuccess,onError);
		http.timeout = 5;
		// You can set UserAgent plus other headers like this
		// http.addHeader('User-Agent',"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36");
		// http.addHeader('Referer','http://api.haxe.org/haxe/Timer.html');
		// http.addHeader('Accept-Language','es,en-US;q=0.8,en;q=0.6,gl;q=0.4');
		http.request();

		// By default, requests are blocking.
		// You can set the request as NonBlocking by calling http.blocking = false
		// for example:
		var http2 = new Http('http://api.haxe.org/sys/net/Socket3.html',onSuccess,onError);
		http2.timeout = 5;
		http2.blocking = false;
		http2.request();

		// Or you can call directly to the ThrededHttp object directly to get non-blocking request like this		
		ThreadedHttp.requestUrl('http://api.haxe.org/sys/net/Socket.html', onSuccess, onError);
		
		var http3 = new Http('http://api.haxe.org/sys/net/Socket3.html',onSuccess,onError);
		http3.timeout = 5;
		http3.blocking = false;
		ThreadedHttp.request(http3);

		// By default, there will be a maximum of 5 threads to share between requests.
		// To increase or decrease the max number of threads to use for requests,
		// you can call:
		// ThreadedHttp.maxThreads = 10; // Must be set before calling the request methods

		var i:Int =0;
		while(ThreadedHttp.getQueueSize()>0){
			Sys.sleep(0.1);
		}
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