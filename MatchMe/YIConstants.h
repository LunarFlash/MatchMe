//
//  YIConstants.h
//  MatchMe
//
//  Created by Yi Wang on 8/25/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YIConstants : NSObject

#pragma mark - User Class

extern NSString *const kYIUserTagLineKey;

extern NSString *const kYIUserProfileKey;
extern NSString *const kYIUserProfileNameKey;
extern NSString *const kYIUserProfileFirstNameKey;
extern NSString *const kYIUserProfileLocationKey;
extern NSString *const kYIUserProfileGenderKey;
extern NSString *const kYIUserProfileBirthdayKey;
extern NSString *const kYIUserProfileInterestedInKey;
extern NSString *const kYIUserProfilePictureURL;
extern NSString *const kYIUserProfileRelationshipStatusKey;
extern NSString *const kYIUserProfileAgeKey;


#pragma mark - Photo Class
extern NSString *const kYIPhotoClassKey;
extern NSString *const kYIPhotoUserKey;
extern NSString *const kYIPhotoPictureKey;


#pragma mark - Activity Class
extern NSString *const kYIActivityClassKey;
extern NSString *const kYIActivityTypeKey;
extern NSString *const kYIActivityFromUserKey;
extern NSString *const kYIActivityToUserKey;
extern NSString *const kYIActivityPhotoKey;
extern NSString *const kYIActivityTypeLikeKey;
extern NSString *const kYIActivityTypeDislikeKey;


#pragma mark - Settings
extern NSString *const kYIMenEnabledKey;
extern NSString *const kYIWomenEnabledKey;
extern NSString *const kYISingleEnabledKey;
extern NSString *const kYIAgeMaxKey;


#pragma mark - ChatRoom
extern NSString *const kYIChatRoomClassKey;
extern NSString *const kYIChatRoomUser1Key;
extern NSString *const kYIChatRoomUser2Key;


#pragma mark - Chat
extern NSString *const kYIChatClassKey;
extern NSString *const kYIChatChatRoomKey;
extern NSString *const kYIChatFromUserKey;
extern NSString *const kYIChatToUserKey;
extern NSString *const kYIChatTextKey;



@end
