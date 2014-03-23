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


class Cookie
{
    var cookies:StringMap<String>;

    public function new()
    {
        cookies = Web.getCookies();
    }

    public function set(key:String, value:String, ?expire:Date=null,
        ?domain:String=null, ?path:String=null, ?secure:Bool=null, 
        ?httpOnly:Bool=null)
    {
        Web.setCookie(key, value, expire, domain, path, secure, httpOnly);
    }

    public function get(key):String
    {
        return cookies.get(key);
    }
}
