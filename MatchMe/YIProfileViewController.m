//
//  YIProfileViewController.m
//  MatchMe
//
//  Created by Yi Wang on 8/26/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "YIProfileViewController.h"

@interface YIProfileViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;

@end

@implementation YIProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    PFFile *pictureFile = self.photo[kYIPhotoPictureKey];  //give us back PFFile from photo
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.profilePictureImageView.image = [UIImage imageWithData:data];
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
