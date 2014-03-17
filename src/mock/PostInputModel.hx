package mock;

import haxe.ds.StringMap;

class PostInputModel extends Request
{
    public function new()
    {
        super();

        get = post = new StringMap<String>();
        post.set("title", "hello");
        post.set("content", "hello");

        session = new MongoDBSession(this, new org.mongodb.Mongo().march.sessions);
        session.set("user", "2");
    }

    override function get_method():String
    {
        return "POST";
    }
}