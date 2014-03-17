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


        free("sigup", sigup); 
        free("default", doDefault);
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
                mongo.march.users.insert(
                    {"username": username, "password": password});
                Web.redirect("/");
            }
        } else
            render('user/sigup.html', {});
    }

    public function doDefault()
    {
        render('default.mtt', {});
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

    static public function testSession()
    {
        var session = new MongoDBSession(new Request(), new Mongo().march.sessions);
        session.set("username", "cj");
        trace(session.get("username"));
        assert("cj", session.get("username"));
    }

	static public function main()
	{
        mtwin.templo.Loader.BASE_DIR = "./templates/";
        mtwin.templo.Loader.TMP_DIR = "./tmp";

        // testSigup();
        testSession();

        var _request = new mtwin.web.Request();
        var level = if (_request.getPathInfoPart(0) == "app.n") 1 else 0;
        new App().execute(_request, level);
	}
}