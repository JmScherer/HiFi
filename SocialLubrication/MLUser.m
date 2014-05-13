//
//  MLUser.m
//  SocialLubrication
//
//  Created by James Scherer on 2/19/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLUser.h"

@implementation MLUser

+(MLUser*)sharedInstance{
    
    static MLUser *myInstance = nil;
    
    if(nil == myInstance){
        
        myInstance = [[[self class] alloc] init];
        
        myInstance.userLocation = @"Home";
        
        PFQuery *locationQuery = [PFQuery queryWithClassName:@"Location"];
        [locationQuery whereKey:@"user" equalTo:[PFUser currentUser]];
        [locationQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            myInstance.userLocation = [object objectForKey:@"location"];
            NSLog(@"User Location: %@", myInstance.userLocation);
        }];
        
        
    }
    
    return myInstance;
    
}


@end
