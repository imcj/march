package ;

class Worker
{
    public function new()
    {

    }

    static public function main()
    {
        var w = new Worker();

        while (true) {
            var message = pop();
            if ("user_signup" == message.action)
                w.user_signup(message.body)
            else if ("post" == message.action)
                w.post(message.body);
            else if ("reply" == message.action)
                w.reply(message.body);
        }
    }
}