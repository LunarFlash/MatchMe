//
//  YIConstants.m
//  MatchMe
//
//  Created by Yi Wang on 8/25/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "YIConstants.h"

@implementation YIConstants

#pragma mark - User Class

NSString *const kYIUserTagLineKey                       = @"tagLine";

NSString *const kYIUserProfileKey                       = @"profile";
NSString *const kYIUserProfileNameKey                   = @"name";
NSString *const kYIUserProfileFirstNameKey              = @"first_name";
NSString *const kYIUserProfileLocationKey               = @"location";
NSString *const kYIUserProfileGenderKey                 = @"gender";
NSString *const kYIUserProfileBirthdayKey               = @"birthday";
NSString *const kYIUserProfileInterestedInKey           = @"interested_in";
NSString *const kYIUserProfilePictureURL                = @"pictureURL";
NSString *const kYIUserProfileRelationshipStatusKey     = @"relationshipStatus";
NSString *const kYIUserProfileAgeKey                    = @"age";


#pragma mark - Photo Class
NSString *const kYIPhotoClassKey                        = @"Photo";
NSString *const kYIPhotoUserKey                         = @"user";
NSString *const kYIPhotoPictureKey                      = @"image";


#pragma mark - Activity Class
NSString *const kYIActivityClassKey                     = @"Activity";
NSString *const kYIActivityTypeKey                      = @"type";
NSString *const kYIActivityFromUserKey                  = @"fromUser";
NSString *const kYIActivityToUserKey                    = @"toUser";
NSString *const kYIActivityPhotoKey                     = @"photo";
NSString *const kYIActivityTypeLikeKey                  = @"like";
NSString *const kYIActivityTypeDislikeKey               = @"dislike";


#pragma mark - Settings
NSString *const kYIMenEnabledKey                        = @"men";
NSString *const kYIWomenEnabledKey                      = @"women";
NSString *const kYISingleEnabledKey                     = @"single";
NSString *const kYIAgeMaxKey                            = @"ageMax";


#pragma mark - ChatRoom
NSString *const kYIChatRoomClassKey                     = @"ChatRoom";
NSString *const kYIChatRoomUser1Key                     = @"user1";
NSString *const kYIChatRoomUser2Key                     = @"user2";


#pragma mark - Chat
NSString *const kYIChatClassKey                         = @"Chat";
NSString *const kYIChatChatRoomKey                      = @"chatRoom";
NSString *const kYIChatFromUserKey                      = @"fromUser";
NSString *const kYIChatToUserKey                        = @"toUser";
NSString *const kYIChatTextKey                          = @"text";


@end
