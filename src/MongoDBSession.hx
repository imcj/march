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
        return collection.findOne({"key":key}).value;
    }

    override public function set(key:String, value:String):Void
    {
        collection.update(
            {"key": key},
            {"$set": {
                "key": key,
                "value": value
            }}, true, false);
    }
}