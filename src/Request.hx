package ;

import haxe.ds.StringMap;
import neko.Web;

class Request
{
    public var post:StringMap<String>;
    public var get:StringMap<String>;
    public var method(get,null):String;
    public var cookie:Cookie;
    public var session:Session;

    public function new()
    {
        get = post = Web.getParams();
        cookie = new Cookie();
    }

    function get_method():String
    {
        return Web.getMethod();
    }
}