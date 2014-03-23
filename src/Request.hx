package ;

import haxe.ds.StringMap;
#if php
import php.Web;
import php.Lib;
import php.Lib.print;
#elseif neko
import neko.Web;
import neko.Lib;
import neko.Lib.print;
#end

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
