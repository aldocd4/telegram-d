import std.stdio;

import std.concurrency;
import std.string;
import std.process;

import telegram.Client;

import telegram.update_listeners;
import telegram.types;

void main()
{	
	auto client = new Client("yourToken");
	client.onMessageEvent = (in ref Message message) 
	{
		string content = message.text;

		string user = "%s (%s)".format(message.chat.username, message.chat.first_name);

		client.sendMessage("Message received from %s: %s".format(user, content), message.chat.id);
	};

	client.listenForUpdates!(BasicUpdateListener);
}
