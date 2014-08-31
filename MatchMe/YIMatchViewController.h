//
//  YIMatchViewController.h
//  MatchMe
//
//  Created by Yi Wang on 8/29/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YIMatchViewControllerDelegate <NSObject>

- (void)presentMatchesViewController;

@end


@interface YIMatchViewController : UIViewController

@property (strong, nonatomic) UIImage *matchedUserImage;  // allow us to pass user from feed to this controller (save download operation)

// delegate property has to be weak, the variable name we use here is delegate
@property (weak) id <YIMatchViewControllerDelegate> delegate;


@end
