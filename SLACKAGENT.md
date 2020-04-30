# OTRS-Ticket-Notification-To-Slack-Users
- Built for OTRS CE v 6.0.x
- This module extend Ticket Notification module to send notification to Slack users (agent).
- **Require CustomMessage API**  

1. Create New Slack App. Reference: https://api.slack.com/apps


2. Create Incoming Webhook in your App above. (Add features and functionality)


3. Create Bots in your App above. (Add features and functionality)


4. Manage Permissions in Your App above. (Add features and functionality)

- Get your Bot User OAuth Access Token

[![s3.png](https://i.postimg.cc/sXCWrmrK/s3.png)](https://postimg.cc/SXVRLWjz)

- Configure your Bot Token Scope to have these permissions

[![s4.png](https://i.postimg.cc/RZc9YLgv/s4.png)](https://postimg.cc/185Lnwxd)


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

[![s6.png](https://i.postimg.cc/QN4pBpkN/s6.png)](https://postimg.cc/dDC7pZxg)
