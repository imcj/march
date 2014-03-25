package ;

class Mail
{
    static public function sendmail(to:String, subject:String, content:String,
        ?text_content:String="")
    {
        var from = "notifications@haxe-china.org";
        var p = new mtwin.mail.Part("multipart/alternative");
        p.setHeader("From",from);
        p.setHeader("To",to);
        p.setDate();
        p.setHeader("Subject", subject);
        var h = p.newPart("text/html");
        var t = p.newPart("text/plain");
        h.setContent(content);
        t.setContent(text_content);

        mtwin.mail.Smtp.send("127.0.0.1", from, to, p.get(), 8025);
    }
}