//
//  YIProfileViewController.h
//  MatchMe
//
//  Created by Yi Wang on 8/26/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YIConstants.h"
#import <Parse/Parse.h>


@protocol YIProfileViewControllerDelegate <NSObject>

- (void)didPressLike;
- (void)didPressDislike;

@end


@interface YIProfileViewController : UIViewController

@property (strong, nonatomic) PFObject *photo;
@property (weak, nonatomic) id <YIProfileViewControllerDelegate> delegate;


@end
