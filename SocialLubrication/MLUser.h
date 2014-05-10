//
//  MLUser.h
//  SocialLubrication
//
//  Created by James Scherer on 2/19/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLUser : NSObject

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userPassword;
@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) NSString *userGender;
@property (strong, nonatomic) NSDate *userBirthday;

@property (strong, nonatomic) NSData *userPhoto;

@property (strong, nonatomic) NSString *userLocation;

+(MLUser*)sharedInstance;

@end
