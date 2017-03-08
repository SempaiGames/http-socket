package httpSocket;

import sys.net.Host;

class Http {

	///////////////////////////////////////////////////////////////////////////	
	///////////////////////////////////////////////////////////////////////////	

	public var onSuccess:Http->String->Void = null;
	public var onError:Http->String->Void = null;

	public var url(default,null):String = null;
	public var data:haxe.io.Bytes = null;
	public var status:String = null;

	public var responseHeaders(default,null):Map<String,String> = null;
	public var requestHeaders:Map<String,String> = null;

	public var blocking:Bool = true;
	public var timeout:Float = -1;

	private var hostMap:Map<String, Host>;

	///////////////////////////////////////////////////////////////////////////	

	public function new(url:String,onSuccess:Http->String->Void = null ,onError:Http->String->Void = null){
		this.url = url;
		this.onSuccess = onSuccess;
		this.onError = onError;
		requestHeaders = new Map<String,String>();
		hostMap = new Map<String, Host>();
	}

	///////////////////////////////////////////////////////////////////////////	


	private function callback(c:Http->String->Void,msg:String):Void{
		if(c==null) return;
		#if openfl
			if(blocking){
				c(this,msg);
			} else{
				haxe.Timer.delay(function(){c(this,msg);},0);				
			}
		#else
			c(this,msg);
		#end
	}

	///////////////////////////////////////////////////////////////////////////	

	public function addHeader(key:String,value:String){
		requestHeaders.set(StringTools.trim(key),StringTools.trim(value));
	}

	///////////////////////////////////////////////////////////////////////////	

	public function request(fromThread:Bool=false):Bool{
		#if (cpp || neko)
		if(url == null) return false;
		if(!blocking && !fromThread){
			ThreadedHttp.request(this);
			return true;
		}
		var s:sys.net.Socket = null;
		try {
			var t1:Float = Sys.time();
			var parsed:URLParser = URLParser.parse(url);
			if(parsed.protocol != 'http' && parsed.protocol != 'https'){
				callback(onError,'http-socket supports only HTTP and HTTPS protocols!');
				return false;
			}
			var port:Int = -1;
			if(parsed.port!=null) port = Std.parseInt(parsed.port);

			if(!requestHeaders.exists("User-Agent")) addHeader('User-Agent',USER_AGENT);
			if(!requestHeaders.exists("Host")) addHeader('Host',parsed.host+(parsed.port!=null?(":"+parsed.port):''));

			var requestString:String = "GET "+parsed.relative+" HTTP/1.1\n";
			for(key in requestHeaders.keys()){
				requestString += key+": "+requestHeaders.get(key)+"\n";
			}
			requestString += "\n";

			if(parsed.protocol == 'http') {
				s = new sys.net.Socket();
				if(port == -1) port=80;
			} else if(parsed.protocol == 'https') {
				s = new sys.ssl.Socket();
				if(port == -1) port=443;
			}
			if(timeout>0) s.setTimeout(timeout);
			s.setBlocking(true);
			s.connect(getHost(parsed.host),port);
			s.write(requestString);
			responseHeaders = new Map<String,String>();
			var chunked:Bool = false;
			var line:String = '';
			do{
				line = s.input.readLine();
				if(line == "Transfer-Encoding: chunked") chunked = true;
				addResponseHeader(line);
			}while(line!='');
			s.shutdown(false,true);
			if(!chunked){
				data = s.input.readAll();
			} else {
				var buffer:String = '';
				var l:Int = 0;
				do{
					l = Std.parseInt('0x'+s.input.readLine());
					buffer+=s.input.read(l).toString();
				}while(l>0);
				data = haxe.io.Bytes.ofString(buffer);
				buffer = null;
			}
			s.close();
			var t2:Float = Sys.time();
			if(status.charAt(0) == "2"){
				callback(onSuccess,responseHeaders.exists('@@status@@')+" - "+Math.round((t2-t1)*1000)+"ms");
			}else{
				callback(onError,responseHeaders.exists('@@status@@')+" - "+Math.round((t2-t1)*1000)+"ms");
			}
		} catch(e:Dynamic) {
			callback(onError,'httpSocket exception: '+e);
			if(s!=null) s.close();
			return false;
		}
		return true;

		#else // JS, PHP, etc...

			var t1:Float = haxe.Timer.stamp();
			var http:haxe.Http = new haxe.Http(url);
			#if (python || java || macro || lua || php || cs)
				if (timeout>0) http.cnxTimeout = timeout;
			#end
			#if (js)
				http.async = !blocking;
			#end
			if(!requestHeaders.exists("User-Agent")) addHeader('User-Agent',USER_AGENT);
			for(key in requestHeaders.keys()){
				http.addHeader(key,requestHeaders.get(key));
			}
			http.onStatus = function(status:Int){
				this.status = ''+status;
			}
			http.onData = function(data:String){
				var t2:Float = haxe.Timer.stamp();
				#if js
				responseHeaders = null;
				#else
				responseHeaders = http.responseHeaders;
				#end
				if(data!=null) this.data = haxe.io.Bytes.ofString(data);
				var status = (responseHeaders!=null && responseHeaders.exists('@@status@@'))?responseHeaders.get('@@status@@'):'@unknow status@';
				callback(onSuccess,status+" - "+Math.round((t2-t1)*1000)+"ms");
			}
			http.onError = function(msg:String){
				var t2:Float = haxe.Timer.stamp();
				#if js
				responseHeaders = null;
				#else
				responseHeaders = http.responseHeaders;
				#end
				data = null;
				var status = (responseHeaders!=null && responseHeaders.exists('@@status@@'))?responseHeaders.get('@@status@@'):'@unknow status@';
				callback(onError,status+" - "+Math.round((t2-t1)*1000)+"ms");
			}
			http.request();
			return true;
		#end
	}

	///////////////////////////////////////////////////////////////////////////

	private function getHost(hostName:String):Host{
		if(hostMap.exists(hostName)) return hostMap.get(hostName);
		else {
			var h = new Host(hostName);
			hostMap.set(hostName, h);
			return h;
		}
	}

	///////////////////////////////////////////////////////////////////////////

	private function addResponseHeader(h:String){
		if(h=='' || h==null) return;
		if(!responseHeaders.exists('@@status@@') && h.substr(0,4)=='HTTP'){
			var aux = h.split(' ');
			if(aux.length>=2) status = aux[1];
			responseHeaders.set('@@status@@',h);
		} else {
			var pos = h.indexOf(':',0);
			if(pos>0) responseHeaders.set(h.substr(0,pos),h.substr(pos+1));
		}
	}

	///////////////////////////////////////////////////////////////////////////	
	///////////////////////////////////////////////////////////////////////////	

	public static inline var USER_AGENT:String = "Haxe HTTP-SOCKET 1.0.2";

	///////////////////////////////////////////////////////////////////////////	

	public static function requestUrl(url:String):String {
		#if (cpp || neko)
			var http = new Http(url,null,null);
			if(!http.request()) return null;
			return http.data.toString();
		#else
			return haxe.Http.requestUrl(url);
		#end
	}

	///////////////////////////////////////////////////////////////////////////	
}