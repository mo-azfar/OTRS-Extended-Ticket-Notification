# OTRS-Ticket-Notification-To-Slack-Users
- Built for OTRS CE v 6.0.x
- This module extend Ticket Notification module to send notification to Slack users (agent).
- **Require CustomMessage API**  

1. Create New Slack App. Reference: https://api.slack.com/apps


2. Create incoming webhooks via Your App Name > Add features and functionality > Create Incoming Webhook > Activate Incoming Webhooks

3. Create Bots via Your App Name > Add features and functionality > Bots

4. Manage you app permissions via in Your App Name > Add features and functionality > Permissions  


- Here you can get your Bot User OAuth Access Token

[![s3.png](https://i.postimg.cc/sXCWrmrK/s3.png)](https://postimg.cc/SXVRLWjz)

- Here, there is a need to configure your 'Bot Token Scope' to have these permissions

[![bot-scope.png](https://i.postimg.cc/VNpyqDBJ/bot-scope.png)](https://postimg.cc/qtsZ0cFr)


5. Update the Slack Bot User OAuth Access Token at System Configuration > SlackAgent::BotToken  

Format : Bearer YOUR_BOT_TOKEN  


6. Update the field name that holds the Slack Member ID for agent at System Configuration > SlackAgent::MemberIDField   

Default: UserSlackMemberID  


7. Obtain the Slack Member ID for the agent, and update it into Agent Profile in 'Slack Member ID' field (as per no 6). 	

- Click on a user name within Slack.  
- Click on "View profile" in the menu that appears.  
- Click the more icon "..."  
- Click on "Copy Member ID."  


8. Create a new Ticket Notification  

- Select 'Slack Agent' as notification method.  
- Only supported recipient type : Agent  

[![slack.png](https://i.postimg.cc/63TG456r/slack.png)](https://postimg.cc/TLMPZxD1)
