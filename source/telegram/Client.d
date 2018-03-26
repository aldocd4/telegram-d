module telegram.Client;

import std.json;
import std.string : format;
import std.concurrency;
import std.datetime;
import std.algorithm;
import std.array : array;

import core.thread;

import requests;
import asdf;

import telegram.ApiResponse;
import telegram.types;

class Client
{
    private enum TELEGRAM_API_URL = "https://api.telegram.org/";

    private string m_botURL;

    private bool m_listening;

    private alias OnMessageEvent = void delegate(in ref Message);
    private OnMessageEvent m_onMessageEvent;

    public this(in string botToken)
    {
        this.m_botURL = TELEGRAM_API_URL ~ "bot" ~ botToken ~ "/";
    }

    /**
     * Listens for all incoming updates
     */
    public void listenForUpdates(ListenerType)()
    {
        this.m_listening = true;

        spawn(&ListenerType.worker, thisTid, cast(shared) this);

        while(this.m_listening)
        {
            receive(
                (Message message) 
                {
                    if(this.m_onMessageEvent !is null) 
                    {
                        this.m_onMessageEvent(message);
                    }
                }
            );
        }
    }

    /**
     * Stops listening for incoming updates
     */
    public void stop()
    {
        this.m_listening = false;
    }

    /**
     * Returns current bot information
     */
    public string getMe()
    {
        return this.getJson("getMe");
    }

    /**
     * Returns last available updates
     * Params:
     *      timeout : time to wait before next request
     *      offset : 
     */
    public auto getUpdates(int timeout = 100, int offset = 0)
    {
        string json = this.getJson("getUpdates?timeout=%d&offset=%d".format(timeout, offset), timeout);

        auto jsonObject = json.deserialize!(ApiResponse!(MessageEntry[]));
        return jsonObject;
    }

    /**
     * Returns last update Id
     * Params:
     *      updateResult : 
     */
    public int getLastUpdateId(MessageEntry[] updates)
    {
        if(updates.length)
        {
            return updates.map!(entry => entry.update_id).array.maxElement();
        }

        return 0;
    }

    /**
     * Performs an HTTP GET request and returns a JSON value
     * Params:
     *      route :
     */
    public string getJson(in string route, in int timeout = 110)
    {
        auto request = Request();
        request.timeout = timeout.seconds;

        auto response = request.get(this.m_botURL ~ route);

        return response.responseBody.toString();
    }

    @property
    {
        public bool listening()
        {
            return this.m_listening;
        }

        public void onMessageEvent(OnMessageEvent value)
        {
            this.m_onMessageEvent = value;
        }
    }
}