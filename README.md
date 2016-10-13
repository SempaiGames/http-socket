#http-socket

Socket Based HTTP client for Haxe.

This project is a temporary solution to haxe-http / openfl-urlLoader issues on some cases where network is unstable and DNS are not working fine.

###Simple use Example:

```haxe

import httpSocket.Http;

class SimpleExample {

	public function loadSomething() {
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

		// You can also use a separate thread to queue request so your main
		// thread doesn't get blocked at all (even when resolving DNS).
		/*
		ThreadedSocketRequest.onSuccess = onSuccess;
		ThreadedSocketRequest.onError = onError;
		ThreadedSocketRequest.request('http://api.haxe.org/sys/net/Socket.html');
		ThreadedSocketRequest.request('http://api.haxe.org/sys/net/Socket2.html');
		ThreadedSocketRequest.request('http://api.haxe.org/sys/net/Socket3.html');
		ThreadedSocketRequest.request('http://api.haxe.org/sys/net/Socket4.html');
		*/
	}

	public function onSuccess(http:Http, msg:String){
		trace(msg);
		trace(http.status);
		trace(http.data);
	}

	public function onError(http:Http, msg:String){
		trace("ERROR... something went wrong accessing "+http.url);
		trace(msg);
		trace(http.status);
		// trace(http.data); // You may have the error / not found html page on http.data
	}
}

```

###How to Install:

```bash
haxelib install http-socket
```


###License

The MIT License (MIT) - [LICENSE.md](LICENSE.md)

Copyright &copy; 2016 SempaiGames (http://www.sempaigames.com)

Author: Federico Bricker
