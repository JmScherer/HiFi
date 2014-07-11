//
//  MLChatRoomViewController.m
//  SocialLubrication
//
//  Created by James Scherer on 4/6/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLChatRoomViewController.h"

@interface MLChatRoomViewController ()

@property (strong, nonatomic) PFUser *withUser;
@property (strong, nonatomic) PFUser *currentUser;

@property (strong, nonatomic) PFObject *currentUserAvatar;
@property (strong, nonatomic) PFObject *withUserAvatar;

@property (strong, nonatomic) UIImage *currentUserAvatarImage;
@property (strong, nonatomic) UIImage *withUserAvatarImage;

@property (strong, nonatomic) NSTimer *chatTimer;
@property (nonatomic) BOOL initialLoadComplete;

@property (strong, nonatomic) NSMutableArray *chats;
@property (strong, nonatomic) NSMutableArray *JSQChatArray;
@property (strong, nonatomic) UIBarButtonItem *imageToggle;

@end

@implementation MLChatRoomViewController

-(NSMutableArray *)JSQChatArray {
    if(!_JSQChatArray){
        _JSQChatArray = [[NSMutableArray alloc] init];
    }
    
    return _JSQChatArray;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.outgoingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    self.incomingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    self.currentUser = [PFUser currentUser];
    PFUser *testUser1 = self.chatRoom[@"user1"];
    if([testUser1.objectId isEqual:self.currentUser.objectId]){
        self.withUser = self.chatRoom[@"user2"];
        self.currentUserAvatar = self.chatRoom[@"user1Avatar"];
        self.withUserAvatar = self.chatRoom[@"user2Avatar"];
    }
    else {
        self.withUser = self.chatRoom[@"user1"];
        self.currentUserAvatar = self.chatRoom[@"user2Avatar"];
        self.withUserAvatar = self.chatRoom[@"user1Avatar"];
    }
    self.title = self.withUser.username;
    self.initialLoadComplete = NO;
    
    [self checkForNewChats];
    
    self.chatTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForNewChats) userInfo:nil repeats:YES];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cool"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(imageToggle:)];
    
    //self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    
    //self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    CGFloat outgoingDiameter = self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width;
    
    //    UIImage *jsqImage = [JSQMessagesAvatarFactory avatarWithUserInitials:@"JSQ"
    //                                                         backgroundColor:[UIColor colorWithWhite:0.85f alpha:1.0f]
    //                                                               textColor:[UIColor colorWithWhite:0.60f alpha:1.0f]
    //                                                                    font:[UIFont systemFontOfSize:14.0f]
    //                                                                diameter:outgoingDiameter];
    
    CGFloat incomingDiameter = self.collectionView.collectionViewLayout.incomingAvatarViewSize.width;
    
    PFQuery *currentUser = [PFQuery queryWithClassName:@"Photo"];
    [currentUser whereKey:@"user" equalTo:[PFUser currentUser]];
    [currentUser getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFFile *currentUserImage = object[@"image"];
        [currentUserImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *tmpImg = [UIImage imageWithData:data];
            
            self.currentUserAvatarImage = [JSQMessagesAvatarFactory avatarWithImage:tmpImg diameter:outgoingDiameter];
        }];
    }];
    
    PFQuery *withUser = [PFQuery queryWithClassName:@"Photo"];
    [withUser whereKey:@"user" equalTo:self.withUser];
    [withUser getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFFile *withUserImage = object[@"image"];
        [withUserImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *tmpImg = [UIImage imageWithData:data];
            
            self.withUserAvatarImage = [JSQMessagesAvatarFactory avatarWithImage:tmpImg diameter:incomingDiameter];
        }];
    }];

//    self.currentUserAvatarImage = [JSQMessagesAvatarFactory avatarWithImage:[UIImage imageNamed:@"placeholder.jpg"] diameter:outgoingDiameter];
//    self.withUserAvatarImage = [JSQMessagesAvatarFactory avatarWithImage:[UIImage imageNamed:@"placeholder.jpg"] diameter:incomingDiameter];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is YES.
     *  For best results, toggle from `viewDidAppear:`
     */
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

#pragma mark - View Controller Buttons

- (void)imageToggle:(UIBarButtonItem *)sender
{
    PFUser *testUser1 = self.chatRoom[@"user1"];
    if([testUser1.objectId isEqual:self.currentUser.objectId]){
        if([self.currentUserAvatar isEqual:@NO]){
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
            [self.chatRoom setObject:@YES forKey:@"user1Avatar"];
            self.currentUserAvatar = self.chatRoom[@"user1Avatar"];
            NSLog(@"Current User Avatar 1: %@", self.currentUserAvatar);
            
        }
        else {
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor redColor];
            [self.chatRoom setObject:@NO forKey:@"user1Avatar"];
            self.currentUserAvatar = self.chatRoom[@"user1Avatar"];
            NSLog(@"Current User Avatar 2: %@", self.currentUserAvatar);
        }
    }
    else {
        if([self.currentUserAvatar isEqual:@NO]){
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
            [self.chatRoom setObject:@YES forKey:@"user2Avatar"];
            self.currentUserAvatar = self.chatRoom[@"user2Avatar"];
            NSLog(@"Current User Avatar 3: %@", self.currentUserAvatar);
        }
        else {
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor redColor];
            [self.chatRoom setObject:@NO forKey:@"user2Avatar"];
            self.currentUserAvatar = self.chatRoom[@"user2Avatar"];
            NSLog(@"Current User Avatar 4: %@", self.currentUserAvatar);
        }
    }
    
    [self.chatRoom saveInBackground];
    [self.collectionView reloadData];
}

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                    sender:(NSString *)sender
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    if(text.length != 0){
        PFObject *chat = [PFObject objectWithClassName:@"Chat"];
        [chat setObject:self.chatRoom forKey:@"chatroom"];
        [chat setObject:self.currentUser  forKey:@"fromUser"];
        [chat setObject:self.withUser forKey:@"toUser"];
        [chat setObject:text forKey:@"text"];
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.chats addObject:chat];
            JSQMessage *message = [[JSQMessage alloc] initWithText:text sender:self.currentUser.username date:date];
            [self.JSQChatArray addObject:message];
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
            [self.collectionView reloadData];
            [self finishSendingMessage];
            [self scrollToBottomAnimated:YES];
        }];
    }
    
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.JSQChatArray objectAtIndex:indexPath.item];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     */
    
    /**
     *  Reuse created bubble images, but create new imageView to add to each cell
     *  Otherwise, each cell would be referencing the same imageView and bubbles would disappear from cells
     */
    
    JSQMessage *message = [self.JSQChatArray objectAtIndex:indexPath.item];
    
    if ([message.sender isEqualToString:self.currentUser.username]) {
        return [[UIImageView alloc] initWithImage:self.outgoingBubbleImageView.image
                                 highlightedImage:self.outgoingBubbleImageView.highlightedImage];
    }
    
    return [[UIImageView alloc] initWithImage:self.incomingBubbleImageView.image
                             highlightedImage:self.incomingBubbleImageView.highlightedImage];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Reuse created avatar images, but create new imageView to add to each cell
     *  Otherwise, each cell would be referencing the same imageView and avatars would disappear from cells
     *
     *  Note: these images will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    
    JSQMessage *message = [self.JSQChatArray objectAtIndex:indexPath.item];
    
    UIImage *avatarImage = [[UIImage alloc] init];
    
    if([message.sender isEqual:self.currentUser.username]){
        avatarImage = self.currentUserAvatarImage;
    }
    else avatarImage = self.withUserAvatarImage;
    
        return [[UIImageView alloc] initWithImage:avatarImage];
    
    
    
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.JSQChatArray objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.JSQChatArray objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.sender isEqualToString:self.sender]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.JSQChatArray objectAtIndex:indexPath.item - 1];
        if ([[previousMessage sender] isEqualToString:message.sender]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.sender];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.JSQChatArray count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.JSQChatArray objectAtIndex:indexPath.item];
    
    if ([msg.sender isEqualToString:self.sender]) {
        cell.textView.textColor = [UIColor blackColor];
    }
    else {
        cell.textView.textColor = [UIColor whiteColor];
    }
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.JSQChatArray objectAtIndex:indexPath.item];
    if ([[currentMessage sender] isEqualToString:self.sender]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.JSQChatArray objectAtIndex:indexPath.item - 1];
        if ([[previousMessage sender] isEqualToString:[currentMessage sender]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

#pragma mark - Factory Methods

-(void)checkForNewChats{
    int oldChatCount = [self.chats count];
    
    
    PFQuery *queryForChats = [PFQuery queryWithClassName:@"Chat"];
    [queryForChats whereKey:@"chatroom" equalTo:self.chatRoom];
    [queryForChats orderByAscending:@"createdAt"];
    [queryForChats findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            if(self.initialLoadComplete == NO || oldChatCount != [objects count]){
                self.chats = [objects mutableCopy];
                
                NSLog(@"self.chats: %@", self.chats);
                
                for(int i = 0; i < [self.chats count]; i++){
                    
                    NSLog(@"i: %i", i);
                    PFObject *chat = self.chats[i];
                    NSLog(@"chat: %@", chat);
                    PFUser *testFromUser = chat[@"fromUser"];
                    NSLog(@"testFromUser: %@", testFromUser);
                    PFUser *currentUser = [PFUser currentUser];
                    NSLog(@"currentUser: %@", currentUser);
                    
                    if([testFromUser.objectId isEqual:currentUser.objectId]){
                        
                        [self.JSQChatArray addObject:[[JSQMessage alloc] initWithText:chat[@"text"] sender:self.currentUser.username date:chat.createdAt]];
                    }
                    else {
                        [self.JSQChatArray addObject:[[JSQMessage alloc] initWithText:chat[@"text"] sender:self.withUser.username date:chat.createdAt]];
                    }
                }
                
                NSLog(@"self.JSQChatArray: %@", self.JSQChatArray);
                
                [self.collectionView reloadData];
                
                if(self.initialLoadComplete == YES){
                    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                }
                
                self.initialLoadComplete = YES;
                [self scrollToBottomAnimated:YES];
            }
        }
    }];
    
}

@end
