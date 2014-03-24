package ;

class EMail
{
    static public function fetch(content:String, remove:Bool=false)
    {
        var regular = ~/([\w0-9\._-]+@[\w0-9.-]+\.\w{2,4})/;
        var pos = {pos: 0, len: 0};
        var emails:Array<String> = [];
        var returns:String = "";
        var previous;
        while (true) {
            var match = regular.matchSub(content, pos.pos + pos.len);
            if (!match)
                break;
            previous = pos;
            pos = regular.matchedPos();
            if (remove)
                returns += content.substr(previous.pos, pos.pos)
                        +  content.substr(pos.pos + pos.len);
            emails.push(regular.matched(1));
        }


        return {
            content: returns,
            emails: emails
        };
    }
}
