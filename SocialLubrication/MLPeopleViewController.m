//
//  MLPeopleViewController.m
//  SocialLubrication
//
//  Created by James Scherer on 2/26/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLPeopleViewController.h"

@interface MLPeopleViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *userImage1;
@property (strong, nonatomic) IBOutlet UIImageView *userImage2;
@property (strong, nonatomic) IBOutlet UIImageView *userImage3;
@property (strong, nonatomic) IBOutlet UIImageView *userImage4;
@property (strong, nonatomic) IBOutlet UIImageView *userImage5;

@property (strong, nonatomic) NSMutableArray *userImageArray;
@property (strong, nonatomic) NSArray *gestureArray;
@property (strong, nonatomic) NSMutableArray *userImages;

@property (nonatomic) BOOL correctUser;

- (IBAction)userImagePickerButtonPressed:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *cancelButtonPressed;


@end

@implementation MLPeopleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Selected User: %@", self.selectedUser);
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    tap1.cancelsTouchesInView = YES;
    tap1.numberOfTapsRequired = 1;

    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    tap2.cancelsTouchesInView = YES;
    tap2.numberOfTapsRequired = 1;
    
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    tap3.cancelsTouchesInView = YES;
    tap3.numberOfTapsRequired = 1;
    
    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    tap4.cancelsTouchesInView = YES;
    tap4.numberOfTapsRequired = 1;
    
    UITapGestureRecognizer *tap5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    tap5.cancelsTouchesInView = YES;
    tap5.numberOfTapsRequired = 1;
    
    self.gestureArray = @[tap1, tap2, tap3, tap4, tap5];
    self.userImageArray = [@[self.userImage1, self.userImage2, self.userImage3, self.userImage4, self.userImage5] mutableCopy];
    
    self.correctUser = NO;
    
    PFQuery *selectedUserImageSearch = [PFQuery queryWithClassName:@"Photo"];
    [selectedUserImageSearch whereKey:@"user" equalTo:self.selectedUser];
    [selectedUserImageSearch getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFObject *selectedUserImage = object;
        PFFile *selectedPhoto = selectedUserImage[@"image"];

        [selectedPhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImageView *tempUserImage = self.userImageArray[0];

            tempUserImage.userInteractionEnabled = YES;
            [tempUserImage addGestureRecognizer:self.gestureArray[0]];
            tempUserImage.image = [UIImage imageWithData:data];
            tempUserImage.layer.cornerRadius = 5.0;
            tempUserImage.layer.masksToBounds = YES;
            tempUserImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
            tempUserImage.layer.borderWidth = 2.0;
            [tempUserImage setTag:0];
            
            PFQuery *imageQuery = [PFQuery queryWithClassName:@"Photo"];
            [imageQuery whereKey:@"user" notEqualTo:self.selectedUser];
            [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                self.userImages = [objects mutableCopy];
                //[self shuffle:self.userImages];
                for(int i = 1; i < 5; i++){
                    PFObject *image = self.userImages[i];
                    PFFile *imageFile = image[@"image"];
                    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        UIImageView *tempImage = self.userImageArray[i];
                        tempImage.userInteractionEnabled = YES;
                        [tempImage addGestureRecognizer:self.gestureArray[i]];
                        tempImage.image = [UIImage imageWithData:data];
                        tempImage.layer.cornerRadius = 5.0;
                        tempImage.layer.masksToBounds = YES;
                        tempImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
                        tempImage.layer.borderWidth = 2.0;
                        [tempImage setTag:i];
                    }];
                }
            }];
        }];
        [self shuffle:self.userImageArray];

    }];
    

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) handleImageTap:(UIGestureRecognizer *)sender {
    UIView* view = sender.view;
    
    NSLog(@"Button Tag: %i", [sender.view tag]);

    
    if(view.layer.borderColor == [UIColor lightGrayColor].CGColor){
    
        if(view.tag == 0){
            if(self.correctUser == NO){
                
            self.correctUser = YES;
        }
        else self.correctUser = NO;
        }
    
    view.layer.borderColor = [UIColor blueColor].CGColor;
    }
    else{
        if(view.tag == 0){
            if(self.correctUser == YES){
                
                self.correctUser = NO;
            }
            else self.correctUser = YES;
        }
        view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    //object of view which invoked this
    NSLog(@"%hhd", self.correctUser);
}
-(void)shuffle:(NSMutableArray *)userImageArray{
    
    NSUInteger count = [userImageArray count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = arc4random_uniform(nElements) + i;
        [userImageArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}


- (IBAction)userImagePickerButtonPressed:(UIButton *)sender {
    
    [self.delegate userInviteApproval:self.correctUser];
}


- (IBAction)cancelButtonPressed:(UIButton *)sender {
    [self.delegate cancelInvite];
    
}

@end
