# OTRS-Ticket-Notification-To-Telegram-Users  
- Built for OTRS CE v 6.0.x  
- This module extend Ticket Notification module to send notification to Telegram users (agent).  
- **Require CustomMessage API**  

1. A telegram bot must be created by chat with @FatherBot and obtain the token via Telegram.  

2. Update the telegram bot token at System Configuration > TelegramAgent::Token  

3. Update the field name that holds the telegram chat id for agent at System Configuration > TelegramAgent::ChatIDField  

Default: UserComment  
		
4. Obtain the telegram chat_id for the agent, and update it into Agent Profile in 'Comment' field (as per no 3). 	

- An agent must start the conversation with the created telegram bot (no 1) first by using telegram.  
- By using  https://api.telegram.org/bot<TOKEN>/getUpdates , we can obtain the chat_id of the agent.  

5. Create a new Ticket Notification  

- Select 'Telegram Agent' as notification method.  
- Only supported recipient type : Agent  

[![download-1.png](https://i.postimg.cc/QNf20txj/download-1.png)](https://postimg.cc/14N7zyqd)
