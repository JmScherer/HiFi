//
//  MLChatViewController.h
//  SocialLubrication
//
//  Created by James Scherer on 3/5/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "JSMessagesViewController.h"

@interface MLChatViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (strong, nonatomic) PFObject *chatRoom;

@end
