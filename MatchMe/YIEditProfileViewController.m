//
//  YIEditProfileViewController.m
//  MatchMe
//
//  Created by Yi Wang on 8/26/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "YIEditProfileViewController.h"
#import <Parse/Parse.h>
#import "YIConstants.h"

@interface YIEditProfileViewController () <UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *taglineTextView;
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;


@end

@implementation YIEditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.taglineTextView.delegate = self;
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    
    // Get profile picture
    PFQuery *query = [PFQuery queryWithClassName:kYIPhotoClassKey];
    [query whereKey:kYIPhotoUserKey equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kYIPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.profilePictureImageView.image = [UIImage imageWithData:data];
            }];
        }
    }];
    
    // update tagline
    self.taglineTextView.text = [[PFUser currentUser] objectForKey:kYIUserTagLineKey];
    
    
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

#pragma mark - UITextView Delegate
-(BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.taglineTextView resignFirstResponder];
        
        [[PFUser currentUser] setObject:self.taglineTextView.text forKey:kYIUserTagLineKey];
        [[PFUser currentUser] saveInBackground];
        [self.navigationController popViewControllerAnimated:YES];
        
        return NO;
    } else {
        return  YES;
    }
}



@end
