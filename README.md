Match-Me
========

My Tinder Clone for iOS! This app allows users to like, or dislike other users, and matches users who mutually like each other. 
Once 2 users are matched, they can proceed to start a chatroom and send messages to each other.

This app uses Parse as the backend to store user data, and uses Facebook's API to pull user information such as age, location,
and relationship status. 

![alt tag](https://github.com/LunarFlash/MatchMe/blob/master/MatchMe/screenshot1.png)

![alt tag](https://github.com/LunarFlash/MatchMe/blob/master/MatchMe/screenshot2.png)

![alt tag](https://github.com/LunarFlash/MatchMe/blob/master/MatchMe/screenshot3.png)

![alt tag](https://github.com/LunarFlash/MatchMe/blob/master/MatchMe/screenshot4.png)

![alt tag](https://github.com/LunarFlash/MatchMe/blob/master/MatchMe/screenshot5.png)


Match Me app use the following libraries:
-JSMessagesViewController for sending messages
-Mixpanel for tracking usage statistics
-LBBlurredImage for the pretty image blur effects

Note: The current Parse SDK via cocoapod is missing a framework: ParseFacebookUtils. Until it is addressed, you need to add this 
frameowrk manually to your project.


Setup
=====

Podfile:

platform :ios, '8.0'

pod 'Parse'
pod 'JSMessagesViewController'
pod 'Mixpanel'
pod 'LBBlurredImage'



In AppDelegate.m update the mixpanel token in at the top of the file
In AppDelegate.m update this line with your own Parse app id and client key:
[Parse setApplicationId:@"your app id"
clientKey:@"your client key"];
In info.plist update the FacebookAppID with your own id
In info.plist update the last child of URL types with your own facebook app id like so "fb<your id>"

For more detailed instruction:
Use this instruction to setup Parse:
https://parse.com/apps/quickstart#parse_data/mobile/ios/native/existing

Use this instruction to setup Facebook authentication with Parse
http://www.raywenderlich.com/44640/integrating-facebook-and-parse-tutorial-part-1

