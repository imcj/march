package ;

import redis.Redis;
import org.mongodb.Mongo;
import org.mongodb.Database;

typedef Message = {
    var action:String;
    var body:String;
}

class Worker extends App
{
    public var db:Database;

    public function new()
    {
        super();
        redis = new Redis();
        db = new Mongo().getDB("march");
    }

    function pop()
    {
        var r:Array<String>;
        r = redis.brpop('message', 0);
        return { action: r[0], body: r[1] };
    }

    public function execute()
    {
        var m = pop();
        var body = haxe.Json.parse(m.body);
        
        if ("post" == body.action) {
            post(body.body);
        }
    }

    function post(body:Dynamic)
    {
        var now = Date.fromTime(body.now);
        var user = db.users.findOne({id: body.author});

        var hidden_content:String;
        var emails:Array<String>;

        if (body.hide_email) {
            var f = EMail.extract(body.content, true);
            emails = f.emails;
            hidden_content = f.content;
        } else {
            var f = EMail.extract(body.content, false);
            emails = f.emails;
            hidden_content = body.content;
        }
        trace(body.author);

        var writing:Dynamic =  {
            "title": body.title, 
            "content": body.content,
            "encoded_content": markdown(hidden_content),
            "update_at": now,
            "author_id": user.id,
            "author": user.username,
            "author_email": user.email,
            "author_email_hash": hash_md5(user.email),
            "draft": body.draft,
        };

        var is_edit = body.post_id > 0;

        var selector:Dynamic = null;
        trace(is_edit);
        if (is_edit) {
            selector = { id: body.post_id };
            db.posts.update(
                selector,
                { "$set": writing });

            writing.id = body.post_id;

            // invite_notify(emails, user, writing);
        } else {
            db.config.update(
                    {"key": "post"},{"$inc": {"ids": 1}}, true);
            var id = db.config.findOne({"key": "post"}).ids;
            writing.id = id;
            writing.create_at = now;
            writing.replies = 1;
            writing.last_reply_at = now;
            writing.last_reply_author = user.username;
            writing.last_reply_author_id = user.id;
            writing.last_reply_author_email = user.email;
            writing.last_reply_author_email_hash = hash_md5(user.email);

            db.posts.insert(writing);

            // subscribe(id, context.user);
            // invite_notify(emails, user, writing);
        }
    }

    static public function main()
    {
        var w = new Worker();

        while (true) {
            w.execute();
            // if ("user_signup" == message.action)
            //     w.user_signup(message.body)
            // else if ("post" == message.action)
            //     w.post(message.body);
            // else if ("reply" == message.action)
            //     w.reply(message.body);
        }
    }
}