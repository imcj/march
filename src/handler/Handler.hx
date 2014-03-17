package handler;

class Handler extends mtwin.web.Handler<Void>
{
	public function new()
	{
		super();	
	}

	function sendNoCacheHeaders() {
		try {
			neko.Web.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
			neko.Web.setHeader("Pragma", "no-cache");
			neko.Web.setHeader("Expires", "-1");
			neko.Web.setHeader("P3P", "CP=\"ALL DSP COR NID CURa OUR STP PUR\"");
			neko.Web.setHeader("Content-Type", "text/html; Charset=UTF-8");
			neko.Web.setHeader("Expires", "Mon, 26 Jul 1997 05:00:00 GMT");
		} catch( e : Dynamic ) {
		}
	}

	function render(template, context:Dynamic)
	{
		sendNoCacheHeaders();
		var template = './templates/$template';
		neko.Lib.print(
			mustache.Mustache.render(
				sys.io.File.getContent(template), context));
	}
}