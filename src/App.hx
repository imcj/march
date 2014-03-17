package ;

import handler.Handler;

import neko.Web;
import org.mongodb.Mongo;

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

        free("sigup", sigup); 
        free("default", doDefault);
        free("post", post);
    }

    public function post()
    {
        var context:Dynamic = {};
        if ("POST" == req.method) {
            var title = req.post.get("title");
            var content = req.post.get("content");
            var invalid = false;
            if (0 >= title.length) {
                context.error_title = '标题大于1个字母。';
                invalid = true;
            }
            if (0 >= content.length) {
                context.error_content = '必需填写内容。';
                invalid = true;
            }

            var user = mongo.march.users.findOne({"id": Std.parseInt(req.session.get("user"))});

            if (null == user) {
                invalid = true;
                context.error_validation = '没有登录';
            }

            if (invalid) {
                render('post.html', context);
            } else {
                mongo.march.config.update({"key": "post"},{"$inc": {"ids": 1}}, true);
                var id = mongo.march.config.findOne({"key": "post"}).ids;
                mongo.march.posts.insert(
                    {"title": title, 
                     "content": content,
                     "create_at": Date.now(),
                     "author": req.session.get("user"),
                     "id": id});
                Web.redirect("/");
            }
        } else
            render('post.html', {});
    }

    public function sigup()
    {
        var context:Dynamic = {};
        if ("POST" == req.method) {
            var username = req.post.get("username");
            var password = req.post.get("password");
            var invalid = false;
            if (0 >= username.length) {
                context.error_username = '用户名大于1个字母。';
                invalid = true;
            }
            if (0 >= password.length) {
                context.error_password = '必需填写密码。';
                invalid = true;
            }

            if (null != mongo.march.users.findOne({"username": username})) {
                context.error_username = '已经存在的用户。';
                invalid = true;
            }

            if (invalid) {
                render('user/sigup.html', context);
            } else {
                mongo.march.config.update({"key": "user"},{"$inc": {"ids": 1}}, true);
                var id = mongo.march.config.findOne({"key": "user"}).ids;
                mongo.march.users.insert(
                    {"username": username, "password": password, "id": id});
                req.session.set("user", id);
                Web.redirect("/");
            }
        } else
            render('user/sigup.html', {});
    }

    public function doDefault()
    {
        var posts = [];
        for (post in mongo.march.posts.find())
            posts.push(post);

        render('default.html', {
            "posts": posts,
            'tests': [{"name":1},{name:2}]
            });
    }

    static public function assert(a, b)
    {
        if (a!=b)
            throw "error";
    }

    static public function testSigup()
    {
        var app = new App();

        app.req = new mock.SigupInputModel();
        app.sigup();
    }

    static public function testPost()
    {
        var app = new App();

        app.req = new mock.PostInputModel();
        app.post();
    }

    static public function testSession()
    {
        var session = new MongoDBSession(new Request(), new Mongo().march.sessions);
        session.set("username", "cj");
        trace(session.get("username"));
        assert("cj", session.get("username"));
    }

    static public function testDefault()
    {
        var app = new App();
        app.doDefault();
    }

	static public function main()
	{
        mtwin.templo.Loader.BASE_DIR = "./templates/";
        mtwin.templo.Loader.TMP_DIR = "./tmp";

        // testSigup();
        // testSession();
        // testPost();
        // testDefault();

        var _request = new mtwin.web.Request();
        var level = if (_request.getPathInfoPart(0) == "app.n") 1 else 0;
        new App().execute(_request, level);
	}
}