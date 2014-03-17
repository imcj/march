package ;

import haxe.ds.StringMap;
import neko.Web;

class Cookie
{
    var cookies:StringMap<String>;

    public function new()
    {
        cookies = Web.getCookies();
    }

    public function set(key:String, value:String)
    {
        Web.setCookie(key, value);
    }

    public function get(key):String
    {
        return cookies.get(key);
    }
}