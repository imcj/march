package ;

class Mail
{
    static public function sendmail(to:String, content:String,
        text_content:String) 
    {
        var from = "notifications@haxe-china.org";
        var p = new mtwin.mail.Part("multipart/alternative");
        p.setHeader("From",from);
        p.setHeader("To",to);
        p.setDate();
        p.setHeader("Subject","A Haxe e-mail !");
        var h = p.newPart("text/html");
        var t = p.newPart("text/plain");
        h.setContent(content);
        t.setContent(text_content);

        mtwin.mail.Smtp.send("192.168.4.108", from, to, p.get());
    }
}