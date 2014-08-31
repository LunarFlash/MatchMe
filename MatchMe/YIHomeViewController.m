//
//  YIHomeViewController.m
//  MatchMe
//
//  Created by Yi Wang on 8/26/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "YIHomeViewController.h"
#import <Parse/Parse.h>
#import "YIConstants.h"
#import "YITestUser.h"
#import "YIProfileViewController.h"
#import "YIMatchViewController.h"
#import <Mixpanel.h>
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>

@interface YIHomeViewController () <YIMatchViewControllerDelegate, YIProfileViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;

@property (strong, nonatomic) NSArray *photos;  // store all photos we get back from Parse
@property (strong, nonatomic) PFObject *photo;  // current photo on screen
@property (strong, nonatomic) NSMutableArray *activities; // keep track of activities

@property (nonatomic) int currentPhotoIndex;    // keep track of current photo in the photos array
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDislikedByCurrentUser;

// container views

@property (strong, nonatomic) IBOutlet UIView *labelContainerView;
@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;


// background images views

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *foregroundImageView; //transparent black image size of the screen

@end

@implementation YIHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
}

-(void)viewDidAppear:(BOOL)animated {
    self.photoImageView.image = nil;
    self.firstNameLabel.text = nil;
    self.ageLabel.text = nil;
    
    
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:kYIPhotoClassKey];
    [query whereKey:kYIPhotoUserKey notEqualTo:[PFUser currentUser]];
    [query includeKey:kYIPhotoUserKey];  // include the actual User object when we retrieve a photo
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.photos = objects;
            
            if ([self allowPhoto] == NO) {
                [self setupNextPhoto];
            } else {
                 [self queryForCurrentPhotoIndex];
            }
        } else {
            NSLog(@"Error:%@", error);
        }
    }];

}

- (void)setupViews {
    [self addShadowForView:self.labelContainerView];
    [self.labelContainerView setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:0.5]];
    [self.buttonContainerView setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:0.5]];
    [self addShadowForView:self.buttonContainerView];
    self.photoImageView.layer.masksToBounds = YES;
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    
}

- (void)addShadowForView:(UIView *)view {
    view.layer.masksToBounds = NO; // any subviews will be clipped
    view.layer.cornerRadius = 4;   // rounded corners
    view.layer.shadowRadius = 1;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowOpacity = 0.25;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"homeToProfileSegue"]) {
        YIProfileViewController *profileVC = segue.destinationViewController;
        profileVC.photo = self.photo;
        profileVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"homeToMatchSegue"]) {
        YIMatchViewController *matchVC = segue.destinationViewController;
        matchVC.matchedUserImage = self.photoImageView.image;
        matchVC.delegate = self;
    }
}

#pragma mark - IBActions
- (IBAction)likeButtonPressed:(UIButton *)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance]; // singleton
    [mixpanel track:@"Like"];
    [mixpanel flush];
    
    [self checkLike];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Dislike"];
    [mixpanel flush];
    
    [self checkDislike];
}

- (IBAction)infoButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"homeToProfileSegue" sender:nil];
}

- (IBAction)settingsBarButtonItemPressed:(UIBarButtonItem *)sender {
}

- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:self];
}




#pragma mark - Helper Methods
- (void) setupBackgroundViews {
    UIImage *background = self.photoImageView.image;
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    //self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.backgroundImageView setImageToBlur:background blurRadius:kLBBlurredImageDefaultBlurRadius completionBlock:nil];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
}


- (void)queryForCurrentPhotoIndex {
    if ([self.photos count] > 0) {
        self.photo = self.photos[self.currentPhotoIndex];
        PFFile *file = self.photo[kYIPhotoPictureKey];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                self.photoImageView.image = image;
                [self updateView];
                
                [self setupBackgroundViews];
                
            } else NSLog(@"Failed to download photo:%@", error);
        }];
        
        PFQuery *queryForLike = [PFQuery queryWithClassName:kYIActivityClassKey];
        [queryForLike whereKey:kYIActivityTypeKey equalTo:kYIActivityTypeLikeKey];
        [queryForLike whereKey:kYIActivityPhotoKey equalTo:self.photo];
        [queryForLike whereKey:kYIActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *queryForDislike = [PFQuery queryWithClassName:kYIActivityClassKey];
        [queryForDislike whereKey:kYIActivityTypeKey equalTo:kYIActivityTypeDislikeKey];
        [queryForDislike whereKey:kYIActivityPhotoKey equalTo:self.photo];
        [queryForDislike whereKey:kYIActivityFromUserKey equalTo:[PFUser currentUser]];
        
        // Join the 2 queries
        PFQuery *likeAndDislikeQuery = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDislike]];
        [likeAndDislikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.activities = [objects mutableCopy];
                if ([self.activities count] == 0) {
                    self.isLikedByCurrentUser = NO;
                    self.isDislikedByCurrentUser = NO;
                } else {
                    // does in fact have either a like or dislike
                    PFObject *activity = self.activities[0];
                    if ([activity[kYIActivityTypeKey] isEqualToString:kYIActivityTypeLikeKey]) {
                        self.isLikedByCurrentUser = YES;
                        self.isDislikedByCurrentUser = NO;
                    } else if ([activity[kYIActivityTypeKey] isEqualToString:kYIActivityTypeDislikeKey]) {
                        self.isLikedByCurrentUser = NO;
                        self.isDislikedByCurrentUser = YES;
                    } else {
                        // some sort of other activity
                    }
                    
                }
                self.likeButton.enabled = YES;
                self.dislikeButton.enabled = YES;
                self.infoButton.enabled = YES;
            } else {
                NSLog(@"%@", error);
            }
        }];
    }
}

- (void) updateView {
    self.firstNameLabel.text = self.photo[kYIPhotoUserKey][kYIUserProfileKey][kYIUserProfileFirstNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[kYIPhotoUserKey][kYIUserProfileKey][kYIUserProfileAgeKey]];  // we use string with format here because age is an int
}

- (void)setupNextPhoto {
    if (self.currentPhotoIndex + 1 < [self.photos count]) {
        self.currentPhotoIndex++;
        
        if ([self allowPhoto] == NO) {
            [self setupNextPhoto];
        } else {
            [self queryForCurrentPhotoIndex];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No More Users to View" message:@"Check back later for more people!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (BOOL)allowPhoto {
    
    int maxAge = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kYIAgeMaxKey];
    BOOL men = [[NSUserDefaults standardUserDefaults] boolForKey:kYIMenEnabledKey];
    BOOL women = [[NSUserDefaults standardUserDefaults] boolForKey:kYIWomenEnabledKey];
    BOOL single = [[NSUserDefaults standardUserDefaults] boolForKey:kYISingleEnabledKey];
    
    // get info about current user
    PFObject *photo = self.photos[self.currentPhotoIndex];
    PFUser *user = photo[kYIPhotoUserKey];
    
    int userAge = [user[kYIUserProfileAgeKey][kYIUserProfileAgeKey] intValue];
    NSString *gender = user[kYIUserProfileKey][kYIUserProfileGenderKey];
    NSString *relationshipStatus = user[kYIUserProfileKey][kYIUserProfileRelationshipStatusKey];
    
    
    if (userAge > maxAge) {
        return NO;
    } else if (men == NO && [gender isEqualToString:@"male"]){
        return NO;
    } else if (women == NO && [gender isEqualToString:@"female"]) {
        return NO;
    } else if (single == NO && ([relationshipStatus isEqualToString:@"single"] || relationshipStatus == nil)) {
        return NO;
    } else {
        return YES;
    }
}







- (void)saveLike {
    PFObject *likeActivity = [PFObject objectWithClassName:kYIActivityClassKey];
    [likeActivity setObject:kYIActivityTypeLikeKey forKey:kYIActivityTypeKey];
    [likeActivity setObject:[PFUser currentUser] forKey:kYIActivityFromUserKey];
    [likeActivity setObject:self.photo[kYIPhotoUserKey] forKey:kYIActivityToUserKey];
    [likeActivity setObject:self.photo forKey:kYIActivityPhotoKey];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = YES;
        self.isDislikedByCurrentUser = NO;
        [self.activities addObject:likeActivity];
        [self checkForPhotoUserLikes];  // possibly create chatroom if there is mutual like
        [self setupNextPhoto];
    }];
}

- (void)saveDislike {
    PFObject *dislikeActivity = [PFObject objectWithClassName:kYIActivityClassKey];
    [dislikeActivity setObject:kYIActivityTypeDislikeKey forKey:kYIActivityTypeKey];
    [dislikeActivity setObject:[PFUser currentUser] forKey:kYIActivityFromUserKey];
    [dislikeActivity setObject:self.photo[kYIPhotoUserKey] forKey:kYIActivityToUserKey];
    [dislikeActivity setObject:self.photo forKey:kYIActivityPhotoKey];
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = NO;
        self.isDislikedByCurrentUser = YES;
        [self.activities addObject:dislikeActivity];
        [self setupNextPhoto];
    }];
}

// Check if we've already liked someone
- (void) checkLike {
    if (self.isLikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    } else if (self.isDislikedByCurrentUser) {
        for (PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveLike];
    } else {
        [self saveLike];
    }
}

// Check if we already disliked the user, if we have, move to next uers
// If we liked the user, delete the like from activities, and Parse, save dislike
// Otherwise, we just save the dislike
- (void) checkDislike {
    if (self.isDislikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    } else if (self.isLikedByCurrentUser) {
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveDislike];
    } else {
        [self saveDislike];
    }
}

- (void)checkForPhotoUserLikes {
    PFQuery *query = [PFQuery queryWithClassName:kYIActivityClassKey];
    // this user we are viewing as in fact liked me
    [query whereKey:kYIActivityFromUserKey equalTo:self.photo[kYIPhotoUserKey]];
    [query whereKey:kYIActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kYIActivityTypeKey equalTo:kYIActivityTypeLikeKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            // create our chat room
            [self createChatRoom];
        }
    }];
}

- (void) checkForChatRoom {
    PFQuery *query = [PFQuery queryWithClassName:kYIActivityClassKey];
    [query whereKey:kYIActivityFromUserKey equalTo:self.photo[kYIPhotoUserKey]];
    [query whereKey:kYIActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kYIActivityTypeKey equalTo:kYIActivityTypeLikeKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            [self createChatRoom];
        }
    }];
}


- (void)createChatRoom {
    
    // current user could be user 1 or user 2 so we have to check both scenarios
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:kYIChatRoomClassKey];
    [queryForChatRoom whereKey:kYIChatRoomUser1Key equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:kYIChatRoomUser2Key equalTo:self.photo[kYIPhotoUserKey]];
    
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:kYIChatRoomClassKey];
    [queryForChatRoomInverse whereKey:kYIChatRoomUser1Key equalTo:self.photo[kYIPhotoUserKey]];
    [queryForChatRoomInverse whereKey:kYIChatRoomUser2Key equalTo:[PFUser currentUser]];
    
    // combine the 2 queries
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] == 0) {
            // there is no existing chatroom, so start a new one
            PFObject *chatRoom = [ PFObject objectWithClassName:kYIChatRoomClassKey];
            [chatRoom setObject:[PFUser currentUser] forKey:kYIChatRoomUser1Key];
            [chatRoom setObject:self.photo[kYIPhotoUserKey] forKey:kYIChatRoomUser2Key];
            [chatRoom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self performSegueWithIdentifier:@"homeToMatchSegue" sender:nil];
            }];
            
        }
    }];
}

#pragma mark - YIMatchViewController Delegate
- (void)presentMatchesViewController {
    [self dismissViewControllerAnimated:NO completion:^{
       // make sure this vc is dismissed before we transition to new view controller, so we do it in the comp block
        [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
    }];
}

#pragma mark - YIProfileViewController Delegate
-(void)didPressLike {
    [self.navigationController popViewControllerAnimated:NO]; // this would be dismissing the profileviewcontroller
    [self checkLike];
}

-(void)didPressDislike {
    [self.navigationController popViewControllerAnimated:NO]; // this would be dismissing the profileviewcontroller
    [self checkDislike];
}













@end
