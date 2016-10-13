package httpSocket;

class URLParser
{
    // Publics
    public var url : String;
    public var source : String;
    public var protocol : String;
    public var authority : String;
    public var userInfo : String;
    public var user : String;
    public var password : String;
    public var host : String;
    public var port : String;
    public var relative : String;
    public var path : String;
    public var directory : String;
    public var file : String;
    public var query : String;
    public var anchor : String;
 
    private static var parts : Array<String> = ["source","protocol","authority","userInfo","user","password","host","port","relative","path","directory","file","query","anchor"];

    public function new(url:String)
    {
        // Save for 'ron
        this.url = url;
 
        // The almighty regexp (courtesy of http://blog.stevenlevithan.com/archives/parseuri)
        var r : EReg = ~/^(?:(?![^:@]+:[^:@\/]*@)([^:\/?#.]+):)?(?:\/\/)?((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#\/]*\.[^?#\/.]+(?:[?#]|$)))*\/?)?([^?#\/]*))(?:\?([^#]*))?(?:#(.*))?)/;
 
        // Match the regexp to the url
        r.match(url);
 
        // Use reflection to set each part
        for (i in 0...parts.length)
        {
            Reflect.setField(this, parts[i],  r.matched(i));
        }
    }
 
    public function toString() : String
    {
        var s : String = "For Url -> " + url + "\n";
        for (i in 0...parts.length)
        {
            s += parts[i] + ": " + Reflect.field(this, parts[i]) + (i==parts.length-1?"":"\n");
        }
        return s;
    }
 
    public static function parse(url:String) : URLParser
    {
        return new URLParser(url);
    }
}