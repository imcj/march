package ;

import org.mongodb.Collection;

class MongoDBSession extends Session
{
    var collection:Collection;

    public function new(request:Request, collection:Collection)
    {
        super(request);
        this.collection = collection;
    }

    override public function get(key:String):String
    {
        var document = collection.findOne({"key":key, haxe_id: haxe_id});
        if (null == document)
            return null;
        return document.value;
    }

    override public function set(key:String, value:String):Void
    {
        collection.update(
            {"key": key, haxe_id: haxe_id},
            {"$set": {
                "haxe_id": haxe_id,
                "key": key,
                "value": value
            }}, true, false);
    }
}
