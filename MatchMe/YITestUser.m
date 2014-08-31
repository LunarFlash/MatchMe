//
//  YITestUser.m
//  MatchMe
//
//  Created by Yi Wang on 8/27/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "YITestUser.h"
#import "YIConstants.h"
#import <Parse/Parse.h>

@implementation YITestUser

+ (void)saveTestUserToParse {
    PFUser *newUser = [PFUser user];
    newUser.username = @"user1";
    newUser.password = @"password1";
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSDictionary *profile = @{@"age" : @28, @"birthday" : @"11/22/1985", @"first_name" : @"Mindy", @"gender" : @"female", @"location" : @"Paris, France", @"name" : @"Mindy Swan"};  // "@28" create NSNumber
            [newUser setObject:profile forKey:kYIUserProfileKey];
            [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                UIImage *profileImage = [UIImage imageNamed:@"ProfileImage1.jpg"];
                NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
                PFFile *photoFile = [PFFile fileWithData:imageData];
                [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        PFObject *photo = [PFObject objectWithClassName:kYIPhotoClassKey];
                        [photo setObject:newUser forKey:kYIPhotoUserKey];
                        [photo setObject:photoFile forKey:kYIPhotoPictureKey];
                        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            NSLog(@"photo saved successfully");
                        }];
                    }
                }];
                
            }];
        }
    }];
}

@end
