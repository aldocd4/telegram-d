module telegram.update_listeners.BasicUpdateListener;

import std.json;
import std.concurrency;

import telegram.Client;
import telegram.ApiResponse;

import telegram.types;

interface IUpdateListener
{
    public static void worker(shared Client);
}

class BasicUpdateListener : IUpdateListener
{
    public static void worker(Tid parentTid, shared Client c)
    {
        auto client = cast(Client) c;

        import std.stdio;

        debug writeln("Listening for updates...");

        int lastUpdateId = 0;

        while(client.listening)
        {
            try
            {
                auto request = client.getUpdates(100, lastUpdateId);
                
                if(request.ok)
                {
                    auto response = request.result;

                    lastUpdateId = client.getLastUpdateId(response) + 1;

                    send(parentTid, response[0].message);
                }
            }
            catch(Throwable e)
            {
                debug writeln(e.message);
            }
        }

        debug writeln("Done !");        
    }
}
