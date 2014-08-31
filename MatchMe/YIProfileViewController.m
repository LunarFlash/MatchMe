//
//  YIProfileViewController.m
//  MatchMe
//
//  Created by Yi Wang on 8/26/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "YIProfileViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>

@interface YIProfileViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;



@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;
@property (strong, nonatomic) IBOutlet UIView *labelContainerView;

// background images views
@property (nonatomic, strong) UIImageView *backgroundImageView; // //transparent black image size of the screen

@end

@implementation YIProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    PFFile *pictureFile = self.photo[kYIPhotoPictureKey];  //give us back PFFile from photo
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.profilePictureImageView.image = [UIImage imageWithData:data];
        [self setupBackgroundViews];
    }];

    PFUser *user = self.photo[kYIPhotoUserKey];
    self.locationLabel.text = user[kYIUserProfileKey][kYIUserProfileLocationKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", user[kYIUserProfileKey][kYIUserProfileAgeKey]];
    
    if (user[kYIUserProfileKey][kYIUserProfileRelationshipStatusKey] == nil) {
        self.statusLabel.text = @"Single";
    } else {
        self.statusLabel.text = user[kYIUserProfileKey][kYIUserProfileRelationshipStatusKey];
    }
    
    self.tagLineLabel.text = user[kYIUserTagLineKey];
    
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];  // light grey
    self.title = user[kYIUserProfileKey][kYIUserProfileFirstNameKey];
    
    [self addShadowForView:self.labelContainerView];
    [self addShadowForView:self.buttonContainerView];
    [self.buttonContainerView setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:0.5]];
    [self.labelContainerView setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:0.5]];
    

}

- (void)addShadowForView:(UIView *)view {
    view.layer.masksToBounds = NO; // any subviews will be clipped
    view.layer.cornerRadius = 4;   // rounded corners
    view.layer.shadowRadius = 1;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowOpacity = 0.25;
    
}



- (void) setupBackgroundViews {
    UIImage *background = self.profilePictureImageView.image;
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    //self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.backgroundImageView setImageToBlur:background blurRadius:kLBBlurredImageDefaultBlurRadius completionBlock:nil];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBActions

- (IBAction)likeButtonPressed:(UIButton *)sender {
    [self.delegate didPressLike];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    [self.delegate didPressDislike];
}


@end
