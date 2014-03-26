package ;

typedef Match = {
    var position:Int;
    var length:Int;
}

class EMail
{
    static public function extract(content:String, remove:Bool=false)
    {
        var regular = ~/([\w0-9\._-]+@[\w0-9.-]+\.\w{2,4})/;
        var matched = { position: 0, length: 0 };
        var emails:Array<String> = [];
        var returns:String = "";
        var is_matched:Bool;
        var matches:Array<Match> = [];

        while (true) {
            is_matched = regular.matchSub(content, 
                matched.position + matched.length);
            if (!is_matched)
                break;
            var regular_matched = regular.matchedPos();
            matched = {
                position: regular_matched.pos, 
                length: regular_matched.len
            };
            if (remove) {
                matches.push(matched);
            }
            emails.push(regular.matched(1));
        }

        returns = content.substring(0);

        for (i in 0...matches.length) {
            var match = matches[i];
            var next:Match = matches[i + 1];
            if (i + 1 == matches.length) {
                returns += content.substring(match.position + match.length);
                break;
            }
            if (0 == i) {
                returns = content.substring(0, match.position);
            }
            var part = content.substring(
                match.position + match.length, next.position);
            returns += part;
        }


        return {
            content: returns,
            emails: emails
        };
    }
}
