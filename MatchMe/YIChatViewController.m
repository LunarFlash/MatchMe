//
//  YIChatViewController.m
//  MatchMe
//
//  Created by Yi Wang on 8/29/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "YIChatViewController.h"
#import <Parse/Parse.h>
#import "YIConstants.h"
#import  <JSMessage.h>


@interface YIChatViewController ()

@property (strong, nonatomic) PFUser *withUser;
@property (strong, nonatomic) PFUser *currentUser;

@property (strong, nonatomic) NSTimer *chatsTimer;
@property (nonatomic) BOOL initialLoadComplete;


@property (strong, nonatomic) NSMutableArray *chats;

@end

@implementation YIChatViewController

#pragma mark - Lazy Instantiation
-(NSMutableArray *)chats {
    if (!_chats) {
        _chats = [[NSMutableArray alloc] init];
    }
    return _chats;
}

- (void)viewDidLoad {
    
    // Setting JS Message View Controller
    
    // wierd bug where we need to move these up before super view did load to see ios 7 style send layout
    self.delegate = self;
    self.dataSource = self;
    
    [super viewDidLoad];
    
    
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    self.messageInputView.textView.placeHolder = @"Humble brag about something!";
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.currentUser = [PFUser currentUser];
    PFUser *testUser1 = self.chatRoom[kYIChatRoomUser1Key];
    if ([testUser1.objectId isEqual:self.currentUser.objectId]) {
        self.withUser = self.chatRoom[kYIChatRoomUser2Key];
    } else {
        self.withUser = self.chatRoom[kYIChatRoomUser1Key];
    }
    
    self.title = self.withUser[kYIUserProfileKey][kYIUserProfileFirstNameKey];
    self.initialLoadComplete = NO;
    
    [self checkForNewChats];
    self.chatsTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForNewChats) userInfo:nil repeats:YES];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated {
    [self.chatsTimer invalidate]; //turn off timer
    self.chatsTimer = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chats count];
}


#pragma mark - TableView Delegate
-(void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date
{
    if (text.length != 0) {
        PFObject *chat = [PFObject objectWithClassName:kYIChatClassKey];
        [chat setObject:self.chatRoom forKey:kYIChatChatRoomKey];
        [chat setObject:self.currentUser forKey:kYIChatFromUserKey];
        [chat setObject:self.withUser forKey:kYIChatToUserKey];
        [chat setObject:text forKey:kYIChatTextKey];
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.chats addObject:chat];
            [JSMessageSoundEffect playMessageSentSound];
            [self.tableView reloadData];
            [self finishSend];   // go ahead and animate and reset our text view
            [self scrollToBottomAnimated:YES];
        }];
    }
}

// Determine which type of message bubble is displayed based on whether we sent or recieved the message.
-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kYIChatFromUserKey];
    if ([testFromUser.objectId isEqual:self.currentUser.objectId]) {
        return JSBubbleMessageTypeOutgoing;
    } else {
        return JSBubbleMessageTypeIncoming;
    }
}

// set color of text buble
-(UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kYIChatFromUserKey];
    if ([testFromUser.objectId isEqual:self.currentUser.objectId]) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleBlueColor]];
    } else {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleLightGrayColor]];
    }
}

// -- no timestamp policy in new version?
-(JSMessageInputViewStyle)inputViewStyle {
    return JSMessageInputViewStyleFlat;
}

#pragma mark - JSMessages View Delegate Optional
-(void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
    } else {
        cell.bubbleView.textView.textColor = [UIColor blackColor];
    }
}


-(BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    return YES;
}


-(BOOL)allowsPanToDismissKeyboard {
    return YES;
}


#pragma mark - JSMessages View Data Source REQUIRED
-(id<JSMessageData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *chat = self.chats[indexPath.row];
    JSMessage *message = [[JSMessage alloc] init];
    message.text = chat[kYIChatTextKey];
    
    return message;
}


-(UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender {
    return nil;
}

#pragma mark  - Helper Methods
- (void)checkForNewChats {
    int oldChatCount = (int)[self.chats count];
    
    PFQuery *queryForChats = [PFQuery queryWithClassName:kYIChatClassKey];
    [queryForChats whereKey:kYIChatChatRoomKey equalTo:self.chatRoom];
    [queryForChats orderByAscending:@"createdAt"];
    [queryForChats findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (self.initialLoadComplete == NO || oldChatCount != [objects count]) {
                self.chats = [objects mutableCopy];
                [self.tableView reloadData];
                
                
                if (self.initialLoadComplete == YES) {
                    [JSMessageSoundEffect playMessageReceivedSound];
                }
                
                self.initialLoadComplete = YES;
                [self scrollToBottomAnimated:YES];
            }
        } else {
            NSLog(@"%@", error);
        }
    }];
    
    
}


@end
