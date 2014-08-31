//
//  YIMatchesViewController.m
//  MatchMe
//
//  Created by Yi Wang on 8/29/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "YIMatchesViewController.h"
#import "YIConstants.h"
#import "YIChatViewController.h"
#import <Parse/Parse.h>
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>

@interface YIMatchesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *availableChatrooms;



// background images views

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *foregroundImageView; //transparent black image size of the screen


@end

@implementation YIMatchesViewController

#pragma mark - Lazy Instantiation

- (NSMutableArray *)availableChatrooms {
    if (!_availableChatrooms) {
        _availableChatrooms = [[NSMutableArray alloc] init];
    }
    return _availableChatrooms;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self updateAvailableChatRooms];
    [self setupBackground];
}


- (void) setupBackground {
    
    
    // download my own image
    
    
    
    // Get profile picture
    PFQuery *query = [PFQuery queryWithClassName:kYIPhotoClassKey];
    [query whereKey:kYIPhotoUserKey equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kYIPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
                
                
                [self.backgroundImageView setImageToBlur:self.backgroundImageView.image blurRadius:kLBBlurredImageDefaultBlurRadius completionBlock:nil];
                self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
                
                
                [self.tableView setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:0.5]];
                
                [self.view addSubview:self.backgroundImageView];
                [self.view sendSubviewToBack:self.backgroundImageView];
                
            }];
        }
    }];

   
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    YIChatViewController *chatVC = segue.destinationViewController;
    NSIndexPath *indexPath = sender;
    chatVC.chatRoom = self.availableChatrooms[indexPath.row];
}


#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.availableChatrooms count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *chatRoom = [self.availableChatrooms objectAtIndex:indexPath.row];
    
    PFUser *likedUser;
    PFUser *currentUser = [PFUser currentUser];
    PFUser *testUser1 = chatRoom[@"user1"];
    if ([testUser1.objectId isEqual:currentUser.objectId]) {  // must compare Parse objects using objectId
        likedUser = [chatRoom objectForKey:@"user2"];
    } else {
        likedUser = [chatRoom objectForKey:@"user1"];
    }
    
    cell.textLabel.text = likedUser[@"profile"][@"first_name"];
    
    PFQuery *queryForPhoto = [PFQuery queryWithClassName:@"Photo"];
    [queryForPhoto whereKey:@"user" equalTo:likedUser];
    [queryForPhoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kYIPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                cell.imageView.image = [UIImage imageWithData:data];
                cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            }];
        }
    }];
    
    // set cell background color to clear
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.layer.cornerRadius = 25.0;
    
    return cell;
}

#pragma mark - UITableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"matchesToChatSegue" sender:indexPath];

}



#pragma mark - Helper Methods

- (void) updateAvailableChatRooms {
    PFQuery *query = [PFQuery queryWithClassName:@"ChatRoom"];
    [query whereKey:@"user1" equalTo:[PFUser currentUser]];
    
    PFQuery *queryInverse = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryInverse whereKey:@"user2" equalTo:[PFUser currentUser]];
    
    PFQuery *queryCombined = [PFQuery orQueryWithSubqueries:@[query, queryInverse]];
    [queryCombined includeKey:@"chat"];  //get back the complete Chat class, not just the pointer
    [queryCombined includeKey:@"user1"];
    [queryCombined includeKey:@"user2"];
    
    [queryCombined findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.availableChatrooms removeAllObjects];
            self.availableChatrooms = [objects mutableCopy];
            [self.tableView reloadData];
            
        } else {
            NSLog(@"%@", error);
        }
    }];
    
    
}








@end
