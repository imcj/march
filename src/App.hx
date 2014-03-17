package ;

import handler.Handler;

class App extends Handler
{
    public function new()
    {
        super();

        free("signup", sigup); 
        free("default", doDefault);
    }

    public function sigup()
    {
        render('user/sigup.html', {});
    }

    public function doDefault()
    {
        render('default.mtt', {});
    }

	static public function main()
	{
        mtwin.templo.Loader.BASE_DIR = "G:\\march\\templates\\";
        mtwin.templo.Loader.TMP_DIR = "G:\\march\\";
        context = {};

        var request = new mtwin.web.Request();
        var level = if (request.getPathInfoPart(0) == "app.n") 1 else 0;
        new App().execute(request, level);
	}
}