package httpSocket;

class Http {

	///////////////////////////////////////////////////////////////////////////	
	///////////////////////////////////////////////////////////////////////////	

	public var onSuccess:Http->String->Void = null;
	public var onError:Http->String->Void = null;

	public var url(default,null):String = null;
	public var data:haxe.io.Bytes = null;
	public var status:String = null;

	public var responseHeaders(default,null):Array<String> = null;
	public var requestHeaders:Map<String,String> = null;

	public var blocking:Bool = true;
	public var timeout:Float = -1;

	///////////////////////////////////////////////////////////////////////////	

	public function new(url:String,onSuccess:Http->String->Void = null ,onError:Http->String->Void = null){
		this.url = url;
		this.onSuccess = onSuccess;
		this.onError = onError;
		requestHeaders = new Map<String,String>();
	}

	///////////////////////////////////////////////////////////////////////////	


	private function callback(c:Http->String->Void,msg:String):Void{
		if(c==null) return;
		#if openfl
			if(blocking){
				c(this,msg);
			} else{
				haxe.Timer.delay(function(){c(this,msg);},1);				
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
		if(url == null) return false;
		if(!blocking && !fromThread){
			ThreadedHttp.request(this);
			return true;
		}
		var s:sys.net.Socket = null;
		try {
			var t1:Float = Sys.time();
			var parsed:URLParser = URLParser.parse(url);
			if(parsed.protocol != 'http'){
				callback(onError,'http-socket does supports only HTTP protocol!');
				return false;
			}
			var port:Int = 80;
			if(parsed.port!=null) port = Std.parseInt(parsed.port);

			if(!requestHeaders.exists("User-Agent")) addHeader('User-Agent',USER_AGENT);
			if(!requestHeaders.exists("Host")) addHeader('Host',parsed.host+(parsed.port!=null?(":"+parsed.port):''));

			var requestString:String = "GET "+url+" HTTP/1.1\n";
			for(key in requestHeaders.keys()){
				requestString += key+": "+requestHeaders.get(key)+"\n";
			}
			requestString += "\n";

			trace(requestString);

			s = new sys.net.Socket();
			if(timeout>0) s.setTimeout(timeout);
			s.setBlocking(true);
			s.connect(new sys.net.Host(parsed.host),port);
			s.write(requestString);
			s.shutdown(false,true);
			s.waitForRead();
			responseHeaders = new Array<String>();
			var line = '';
			do{
				line = s.input.readLine();
				addResponseHeader(line);
			}while(line!='');
			data = s.input.readAll();
			s.close();
			var t2:Float = Sys.time();
			if(status.charAt(0) == "2"){
				callback(onSuccess,responseHeaders[0]+" - "+Math.round((t2-t1)*1000)+"ms");
			}else{
				callback(onError,responseHeaders[0]+" - "+Math.round((t2-t1)*1000)+"ms");
			}
		} catch(e:Dynamic) {
			callback(onError,'httpSocket exception: '+e);
			if(s!=null) s.close();
			return false;
		}
		return true;
	}

	///////////////////////////////////////////////////////////////////////////

	private function addResponseHeader(h:String){
		responseHeaders.push(h);
		if(responseHeaders.length==1 && h.substr(0,4)=='HTTP'){
			var aux = h.split(' ');
			if(aux.length>=2) status = aux[1];
		}
	}

	///////////////////////////////////////////////////////////////////////////	
	///////////////////////////////////////////////////////////////////////////	

	public static inline var USER_AGENT:String = "Haxe HTTP-SOCKET 0.0.1";

	///////////////////////////////////////////////////////////////////////////	

	public static function requestUrl(url:String):String {
		var http = new Http(url,null,null);
		if(!http.request()) return null;
		return http.data.toString();
	}

	///////////////////////////////////////////////////////////////////////////	
}