package ;

class PrettyDate
{
    static public function pretty(input:Float)
    {
        var now = Date.now().getTime();
        var diff = now / 1000 - input / 1000;
        var days = diff / 60 / 60 / 24;

        if (diff < 10)
            return "刚才";
        else if (diff < 60)
            return '$diff秒';
        else if (diff < 120) 
            return '1分钟以前';
        else if (diff < 3600)
            return '${Std.int(diff/60)}分钟以前';
        else if (days < 1)
            return '${Std.int(diff/3600)}小时${Std.int(diff%3600/60)}分钟以前';
        else if (days < 2)
            return '昨天';
        else if (days < 8)
            return '上周';
        else if (days < 31)
            return '上个月';
        else if (days < 365)
            return '${Std.int(days/30)}个月以前';
        else if (days < 729)
            return '去年';
        else
            return '${Std.int(days/365)}年前';
        return '';
    }

    /*
    static public function main()
    {
        var now = Date.now().getTime() / 1000;
        var day:Float = 60 * 60 * 24;
        var month:Float = day * 30;
        trace(month);
        trace(preety(now));
        trace(preety(now - 59));
        trace(preety(now - 60));
        trace(preety(now - 3500));
        trace(preety(now - 7100));
        trace(preety(now - day));
        trace(preety(now - day * 7));
        trace(preety(now - month));
        trace(preety(now - month * 2));
        trace(preety(now - day * 365));
        trace(preety(now - day * 365 * 2));
    }
    */
}
