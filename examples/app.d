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

		writeln("New message : ", content);
	};

	client.listenForUpdates!(BasicUpdateListener);
}
