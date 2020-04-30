# OTRS-Ticket-Notification-To-RocketChat-Users
- Built for OTRS CE v 6.0.x
- This module extend Ticket Notification module to send notification to RocketChat users (agent).
- **Require CustomMessage API**  

1. RC must be configured to accept incoming webhook.  
Administration -> Integration -> New integration -> Incoming WebHook

- Enabled: True  
- Name: OTRS Notification  
- Post to channel: #helpdesk  
- Post as: rocket.cat  
- Alias: OTRS Bot

Then, submit/save. Open back this webhook, take note on the 'Webhook URL'

#bot also need to have permission in mention here and mention all


2. Update the RocketChat Webhook URL at System Configuration > RocketChatAgent::WebhookURL

3. Update the field name that holds the RocketChat username for agent at System Configuration > RocketChatAgent::UsernameField  

Default: UserRCUsername

4. Obtain the RocketChat username for the agent, and update it into Agent Profile in 'RocketChat Username' field. 

5. Create a new Ticket Notification  

- Select 'RocketChat Agent' as notification method.  
- Only supported recipient type : Agent  

[![rcdm1.png](https://i.postimg.cc/W1ZTmgNN/rcdm1.png)](https://postimg.cc/HrTqdJ8R)
