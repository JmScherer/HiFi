//
//  MLCoreLocation.h
//  SocialLubrication
//
//  Created by James Scherer on 4/15/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CoreLocationControllerDelegate <NSObject>

@required

-(void)locationUpdate:(CLLocation *)location;
-(void)locationError:(NSError *)error;

@end

@interface MLCoreLocation : NSObject

@property (strong, nonatomic) CLLocationManager *locMgr;
@property (weak, nonatomic) id delegate;

@end
