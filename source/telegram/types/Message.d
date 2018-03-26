module telegram.types.Message;

import telegram.types.Chat;
import telegram.types.User;

struct Message
{
    public Chat chat;
    public int date;
    public User from;
    public int message_id;
    public string text;
}