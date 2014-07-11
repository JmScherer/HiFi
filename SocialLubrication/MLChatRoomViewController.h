//
//  MLChatRoomViewController.h
//  SocialLubrication
//
//  Created by James Scherer on 4/6/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "JSQMessages.h"
#import "JSQSystemSoundPlayer.h"

@interface MLChatRoomViewController : JSQMessagesViewController


@property (copy, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) PFObject *chatRoom;

@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;

@end
