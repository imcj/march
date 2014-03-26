package handler;

#if php
import php.Web;
import php.Lib;
import php.Lib.print;
#elseif neko
import neko.Web;
import neko.Lib;
import neko.Lib.print;
#end


class Handler
{
	public function new()
	{
	}

	public function sendNoCacheHeaders() {
		try {
			Web.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
			Web.setHeader("Pragma", "no-cache");
			Web.setHeader("Expires", "-1");
			Web.setHeader("P3P", "CP=\"ALL DSP COR NID CURa OUR STP PUR\"");
			Web.setHeader("Content-Type", "text/html; Charset=UTF-8");
			Web.setHeader("Expires", "Mon, 26 Jul 1997 05:00:00 GMT");
		} catch( e : Dynamic ) {
		}
	}

	public function render(template, context:Dynamic)
	{
		sendNoCacheHeaders();
		var template = 'templates/$template';
		if (Sys.getEnv("MOD_NEKO") == "2")
			template = '/var/www/haxe-china.org/${template}';
		
	    return mustache.Mustache.render(
				sys.io.File.getContent(template), context);
	}
}
