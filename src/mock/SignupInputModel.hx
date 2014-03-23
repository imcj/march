package mock;

import haxe.ds.StringMap;

class SignupInputModel extends Request
{
    public function new()
    {
        super();

        get = post = new StringMap<String>();
        post.set("username", "cj");
        post.set("password", "123");
    }

    override function get_method():String
    {
        return "POST";
    }
}
