package ;

#if php
import php.Web;
import php.Lib;
import php.Lib.print;
#elseif neko
import neko.Web;
import neko.Lib;
import neko.Lib.print;
#end
import handler.Handler;
import haxe.web.Dispatch;

import org.mongodb.Mongo;
import org.mongodb.Cursor;

using StringTools;

class CursorHelper
{
    static public function array(cursor:Cursor):Array<Dynamic>
    {
        var items:Array<Dynamic> = [];
        for (item in cursor) {
            items.push(item);
        }
        return items;
    }
}

class GlobalContext
{
    public var user:Dynamic;
    public var header:Dynamic;
    public var authorize:Bool;
    public var not_authorize:Bool;
    public var test:String;
    public var page_header(get, null):String;
    public var page_footer(get, null):String;
    public var url:String;

    var handler:Handler;

    public function new(request, mongo:Mongo)
    {
        handler = new Handler();

        var user_id_string = request.session.get("user");
        var user_id:Int;

        header = {};
        header.title = "Haxe China";

        if (null == user_id_string)
            user_id = null;
        else 
            user_id = Std.parseInt(user_id_string); 
        if (null == user_id) {
            user = null;
            authorize = false;
        } else {
            user = mongo.march.users.findOne({"id": user_id});
            authorize = true;
        }

        Reflect.setField(this, "authorize?", authorize);
        Reflect.setField(this, "not_authorize?", !authorize);

        #if debug
        Reflect.setField(this, "debug?", true);
        Reflect.setField(this, "release?", false);
        #else
        Reflect.setField(this, "debug?", false);
        Reflect.setField(this, "release?", true);
        #end

        #if debug
        url = "http://test.haxe-china.org";
        #else
        url = "http://haxe-china.qiniudn.com";
        #end
    }

    public function get_page_header():String
    {
        return handler.render('header.html', this);       
    }

    public function get_page_footer():String
    {
        return handler.render('footer.html', this);
    }
}

class App extends Handler
{
    public var req:Request;
    public var mongo:Mongo;

    public function new()
    {
        super();
        req = new Request();
        mongo = new Mongo();
        req.session = new MongoDBSession(req, mongo.march.sessions);
    }

    function hash_md5(text:String):String
    {
        return haxe.crypto.Md5.encode(text);
    }

    function get_context():Dynamic
    {
        return new GlobalContext(req, mongo);
    }

    public function doT(post_id:Int)
    {
        doPostView(post_id);
    }


    public function doPostView(post_id:Int)
    {
        var context:Dynamic = get_context();

        context.error_title = context.error_content = "";

        context.title = context.content = "";

        var errors:Array<Dynamic> = [];
        Reflect.setField(context, "errors", errors);
        Reflect.setField(context, "errors?", false);
        var user = mongo.march.users.findOne(
            {"id": Std.parseInt(req.session.get("user"))});


        if ("POST" == req.method) {
            var content = req.post.get("content");
            var invalid = false;
            if (0 >= content.length) {
                context.error_content = '必需填写内容。';
                errors.push({error:context.error_content});
                invalid = true;
            }

            if (null == user) {
                invalid = true;
                context.error_validation = '没有登录';
            }

            if (invalid) {
                print(render('reply.html', context));
            } else {
                mongo.march.config.update({"key": "reply"},{"$inc": {"ids": 1}}, true);
                var id = mongo.march.config.findOne({"key": "reply"}).ids;
                mongo.march.replies.insert(
                    {
                        "content": content,
                        "encoded_content": encodeContent(content),
                        "post_id": post_id,
                        "create_at": Date.now(),
                        "author_id": req.session.get("user"),
                        "author": user.username,
                        "author_email": user.email,
                        "id": id
                    }
                );

                mongo.march.posts.update(
                    {id: post_id},
                    {
                        "$set": {
                            last_reply_at: Date.now(),
                            last_reply_author: user.username,
                            last_reply_author_id: user.id,
                            last_reply_author_email: user.email,
                            last_reply_author_email_hash: hash_md5(user.email),
                        },
                        "$inc": {
                            { replies: 1 }
                        }
                    });
                Web.redirect('/t/$post_id/');
            }
        } else {

            mongo.march.posts.update(
                {id: post_id},
                {
                    "$inc": {
                        visit: 1
                    }
                }
            );

            var post = mongo.march.posts.findOne({"id": post_id});
            post.pretty_date = PrettyDate.pretty(post.create_at.getTime());
            var replies:Dynamic = [];
            context.post = post;

            for (reply in mongo.march.replies.find({"post_id": post_id})) {
                reply.pretty_date = PrettyDate.pretty(reply.create_at.getTime());
                replies.push(reply);
            }

            context.replies = replies; //CursorHelper.array(replies);


            context.header.title = '${post.title} - Haxe China';

            Reflect.setField(context, "moderator?", 
                user != null && post.author_id == user.id);
            print(render("view.html", context));
        

        }
    }

    public function doChange_password()
    {
        var context = get_context();
        var errors:Array<Dynamic> = [];
        Reflect.setField(context, "errors", errors);
        Reflect.setField(context, "errors?", false);

        context.error_origin_password = context.error_password =
            context.error_repassword = context.origin_password =
            context.password = context.repassword = "";

        if ("POST" == req.method) {
            var origin_password = req.post.get("origin_password");
            var password = req.post.get("password");
            var repassword = req.post.get("repassword");
            var invalid = false;

            if (null == origin_password || 0 >= origin_password.length) {
                context.error_origin_password = '请输入原始密码。';
                errors.push({error: context.error_origin_password});
                invalid = true;
            } else {
                context.origin_password = origin_password;
            }

            if (null == password || 0 >= password.length) {
                context.error_password = '必须填写密码';
                errors.push({error: context.error_password});
                invalid = true;
            } else {
                context.password = password;
            }

            if (null == repassword || 0 >= repassword.length) {
                context.error_repassword = '密码填写重复输入密码。';
                errors.push({error: context.error_repassword});
                invalid = true;
            } else {
                context.repassword = repassword;
            }

            if (null != repassword && null != password && 
                password != repassword) {
                context.error_repassword = '两次密码输入不一致。';
                invalid = true;
            }

            if (invalid) {
                Reflect.setField(context, "errors?", errors.length > 0);
                print(render('user/change_password.html', context));
            } else {

                mongo.march.users.update(
                    {
                        id: context.user.id
                    },
                    {
                        "$set": {
                            password: hash_md5(password)
                        }
                    });

                Web.redirect("/signout");
            }
        } else {
            print(render('user/change_password.html', context));
        }
    }

    public function doSignin()
    {
        var context = get_context();
        var errors:Array<Dynamic> = [];
        Reflect.setField(context, "errors", errors);
        Reflect.setField(context, "errors?", false);
        context.error_username = context.error_password = 
            context.error_email = "";

        context.username = context.password = context.email = "";


        if ("POST" == req.method) {
            var username = req.post.get("username");
            var password = req.post.get("password");
            var email    = req.post.get("email");
            var invalid = false;

            if (null == username || 0 >= username.length) {
                context.error_username = '用户名大于1个字母。';
                errors.push({error: context.error_username}); 
                invalid = true;
            } else {
                context.username = username;
            }

            if (null == password || 0 >= password.length) {
                context.error_password = '必需填写密码。';
                errors.push({error: context.error_password});
                invalid = true;
            } else {
                context.password = password;
            }

            var user = mongo.march.users.findOne({"username": username});
            if (null == user) {
                context.error_username = '不存在的用户。';
                errors.push({error: context.error_username});
                invalid = true;
            } else {
                if (haxe.crypto.Md5.encode(password) != user.password) {
                    context.error_password = '错误的密码。';
                    errors.push({error: context.error_password});
                    invalid = true;
                }
            }
            Reflect.setField(context, "errors?", errors.length > 0);
            

            if (invalid) {
                print(render('user/signin.html', context));
            } else {
                req.session.set("user", user.id);
                Web.redirect("/");
            }
        } else
            print(render('user/signin.html', context));
    }

    function encodeContent(content:String):String
    {
        /*
        content = StringTools.htmlEscape(content);
        content = StringTools.replace(content, "\n", "<br />");
        return content;
        */
        // content = StringTools.replace(content, "<script", "%3C");
        // return Markdown.markdownToHtml(content);
        return markdown(content);
    }

    function markdown(content):String
    {
        var h = new haxe.Http("http://192.168.4.108:8080/");
        h.setPostData(content);
        var response:String = "";
        h.onData = function(data)
        {
            response = data;
        };
        h.request(true);
        return response;
    }

    public function doPost()
    {
        var context:Dynamic = get_context();
        context.error_title = context.error_content = "";

        var post_id:Int = null;
        if (null != req.get.get("id"))
            post_id = Std.parseInt(req.get.get("id"));
        var post:Dynamic = null;
        context.post_id = post_id;
        if (null == post_id)
            context.title = context.content = "";
        else {
            post = mongo.march.posts.findOne({id: post_id});
            context.title = post.title;
            context.content = post.content;
            context.post = post;
        }

        var errors:Array<Dynamic> = [];
        Reflect.setField(context, "errors", errors);
        Reflect.setField(context, "errors?", false);

        var user = mongo.march.users.findOne(
                    {"id": Std.parseInt(req.session.get("user"))});

        var invalid = false;
        var not_editable = null != post && user.id != post.author_id;
        if (not_editable) {
            invalid = true;
            errors.push({error: "只能编辑自己的帖子。"});
            Reflect.setField(context, "errors?", true);
        }

        if (null == user) {
            invalid = true;
            context.error_validation = '没有登录';
            errors.push({error: context.error_validation});
            Reflect.setField(context, "errors?", true);
        }

        if ("POST" == req.method) {
            if (not_editable) {
                print(render('post.html', context));
                return;
            }

            var title = req.post.get("title");
            var content = req.post.get("content");
            var draft:Bool = req.post.get("draft") == null ? false :
                req.post.get("draft") == "on" ? true : false;
            var hide_email:Bool = req.post.get("hide_email") == null ? false :
                req.post.get("hide_email") == "on" ? true : false;
            var emails:Array<String>;
            if (hide_email) {
                var f = EMail.fetch(content, true);
                emails = f.emails;
                content = f.content;
            } else {
                var f = EMail.fetch(content, false);
                emails = f.emails;
            }
            if (null != req.post.get("id"))
                post_id = Std.parseInt(req.post.get("id"));

            if (null == post_id)
                post_id = 0;

            var is_edit = post_id > 0;


            if (0 >= title.length) {
                context.error_title = '标题大于1个字母。';
                invalid = true;
                errors.push({error: context.error_title});
            } else {
                context.title = title;
            }
            if (0 >= content.length) {
                context.error_content = '必需填写内容。';
                invalid = true;
                errors.push({error: context.error_content});
            } else {
                context.content = content;
            }

            if (invalid) {
                Reflect.setField(context, "errors?", errors.length > 0);
                print(render('post.html', context));
            } else {
                
                var writing:Dynamic =  {
                    "title": title, 
                    "content": content,
                    "encoded_content": encodeContent(content),
                    "update_at": Date.now(),
                    "author_id": req.session.get("user"),
                    "author": user.username,
                    "author_email": user.email,
                    "author_email_hash": hash_md5(user.email),
                    "draft": draft,
                };

                var selector:Dynamic = null;
                if (is_edit) {
                    selector = {id: post_id};
                    mongo.march.posts.update(
                        selector,
                        { "$set": writing });

                    Web.redirect("/t/" + post_id);
                } else {
                    mongo.march.config.update(
                            {"key": "post"},{"$inc": {"ids": 1}}, true);
                    var id = mongo.march.config.findOne({"key": "post"}).ids;
                    writing.id = id;
                    writing.create_at = Date.now();
                    writing.replies = 1;
                    writing.last_reply_at = Date.now();
                    writing.last_reply_author = user.username;
                    writing.last_reply_author_id = user.id;
                    writing.last_reply_author_email = user.email;
                    writing.last_reply_author_email_hash = hash_md5(user.email);
                    mongo.march.posts.insert(writing);

                    Web.redirect("/");
                }
            }
        } else {
            if (!not_editable) {
                if (Reflect.hasField(post, "draft")) {
                    var is_draft = Reflect.field(post, "draft");
                    if (is_draft)
                        context.draft_input_checked = " checked=\"checked\"";
                    else
                        context.draft_input_checked = "";
                }
            } else {
                context.draft_input_checked = "";
            }
            print(render('post.html', context));
        }
    }


    public function doSignout()
    {
        req.session.set("user", null);
        Web.redirect("/");
    }

    public function doSignup()
    {
        var context:Dynamic = get_context();
        var errors:Array<Dynamic> = [];
        Reflect.setField(context, "errors", errors);
        Reflect.setField(context, "errors?", false);
        context.error_username = context.error_password = 
            context.error_email = "";

        context.username = context.password = context.email = "";


        if ("POST" == req.method) {
            var username = req.post.get("username");
            var password = req.post.get("password");
            var email    = req.post.get("email");
            var invalid = false;

            if (null == username || 0 >= username.length) {
                context.error_username = '用户名大于1个字母。';
                errors.push({error: context.error_username}); 
                invalid = true;
            } else {
                context.username = username;
            }

            if (null == password || 0 >= password.length) {
                context.error_password = '必需填写密码。';
                errors.push({error: context.error_password});
                invalid = true;
            } else {
                context.password = password;
            }
            if (null == email || 0 >= email.length) {
                context.error_email = '请输入正确的电子邮件';
                errors.push({error: context.error_email});
                invalid = true;
            } else {
                context.email = email;
            }

            var user = mongo.march.users.findOne({"username": username});
            if (null != user) {
                context.error_username = '已经存在的用户。';
                errors.push({error: context.error_username});
                invalid = true;
            }

            if (null != email &&
                null != mongo.march.users.findOne({"email": email})) {
                context.error_email = '邮件地址已经被使用';
                errors.push({error: context.error_email});
                invalid = true;
            }

            Reflect.setField(context, "errors?", errors.length > 0);
            

            if (invalid) {
                print(render('user/signup.html', context));
            } else {
                mongo.march.config.update({"key": "user"},{"$inc": {"ids": 1}}, true);
                var id = mongo.march.config.findOne({"key": "user"}).ids;
                mongo.march.users.insert(
                    {"username": username,
                     "password": haxe.crypto.Md5.encode(password),
                     "email": email,
                     "id": id});
                req.session.set("user", id);
                Web.redirect("/");
            }
        } else
            print(render('user/signup.html', context));
    }

    public function doDefault()
    {
        var context = get_context();
        var posts = [];
        var page_string:String = req.get.get("page");
        if (null == page_string)
            page_string = "1";
        var page:Int = Std.parseInt(page_string);
        var page_size:Int = 10;
        var skip = (page - 1) * page_size;
        var user_id = context.user == null ? 0 : context.user.id;
        
        var condition_draft_of_user:Array<Dynamic> = [
            {draft: true},
            {author_id: user_id},
        ];
        var condition:Array<Dynamic> = [
            {
                "draft": false,
            },
            {
                draft: { "$exists": false }
            },
            {
                "$and": condition_draft_of_user
            }
        ];
        var cursor = mongo.march.posts.find(
            {
                "$orderby": {"last_reply_at": -1},
                "$maxScan": skip + page_size,
                "$query": {
                    "$or": condition
                }
            },
            {
                "content": false,
            }, 
            skip);

        for (post in cursor) {
            post.author_email_hash = haxe.crypto.Md5.encode(post.author_email);
            post.pretty_date = PrettyDate.pretty(post.create_at.getTime());
            posts.push(post);
        }

        if (null == page)
            page = 1;

        var page_previous = page - 1;
        if (page_previous < 1)
            page_previous = 1;

        context.posts = posts;
        context.page_next = page + 1;
        context.page_previous = page_previous;

        print(render('default.html', context));
    }

    static public function assert(a, b)
    {
        if (a!=b)
            throw "error";
    }

    static public function testSignup()
    {
        var app = new App();

        app.req = new mock.SignupInputModel();
        app.doSignup();
    }

    static public function testPost()
    {
        var app = new App();

        app.req = new mock.PostInputModel();
        app.doPost();
    }

    static public function testSession()
    {
        var session = new MongoDBSession(new Request(), new Mongo().march.sessions);
        session.set("username", "cj");
        assert("cj", session.get("username"));
    }

    static public function testDefault()
    {
        var app = new App();
        app.doDefault();
    }

    static public function testMarkdown()
    {
        var h = new haxe.Http("http://192.168.4.108:8080/");
        h.setPostData("```python\nimport os```");
        var response:String = "";
        h.onData = function(data)
        {
            response = data;
        };
        h.request(true);
        return response;
    }

    static public function testEmailFetch()
    {
        var content = EMail.fetch("1\nnotifications@haxe-china.org\n2", true);
        trace(content);
    }

	static public function main()
	{
        // testSigup();
        // testSession();
        // testPost();
        // testDefault();
        // testMarkdown();
        // testEmailFetch();
        // return;

        var uri = Web.getURI();

        if (uri.indexOf('.php') > -1 || uri.indexOf('.n') > -1)
            uri = uri.substr(uri.indexOf("/", 1));

        #if debug
        if (uri.startsWith('/public')) {
            if (uri.endsWith('.css'))
                Web.setHeader('Content-Type', 'text/css');
            print(sys.io.File.getContent(uri.substr(1)));
            return;
        }
        #end
        Dispatch.run(uri, null, new App());
	}
}
