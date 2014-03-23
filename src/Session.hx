package ;

class Session
{
    var request:Request;
    var haxe_id:String;

    public function new(request:Request)
    {
        this.request = request;
        haxe_id = request.cookie.get("haxe_id");
        if (null == haxe_id) {
            var expire = Date.fromTime(
                (Date.now().getTime() + 60 * 60 * 24 * 30 * 1000));
            haxe_id = haxe.crypto.Md5.encode(Std.string(Math.random()));
            request.cookie.set("haxe_id", haxe_id, expire);
        } else {
            haxe_id = request.cookie.get("haxe_id");
        }
    }

    public function get(key:String):String
    {
        return null;
    }

    public function set(key:String, value:String):Void
    {

    }
}
