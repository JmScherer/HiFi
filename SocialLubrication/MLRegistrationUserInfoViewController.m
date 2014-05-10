//
//  MLRegistrationUserInfoViewController.m
//  SocialLubrication
//
//  Created by James Scherer on 2/3/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLRegistrationUserInfoViewController.h"
#import "MLUser.h"


@interface MLRegistrationUserInfoViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (strong, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (strong, nonatomic) IBOutlet UITextField *textFieldRetypePassword;
@property (strong, nonatomic) IBOutlet UIDatePicker *birthdayDatePicker;

@property (strong, nonatomic) IBOutlet UISegmentedControl *genderSegmentSelector;

@property (strong, nonatomic) NSDictionary *userRegistrationInfo;


@property (strong, nonatomic) IBOutlet UILabel *errorRegistartionLabel;

@end

@implementation MLRegistrationUserInfoViewController

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
    
    [self subscribeToKeyboardEvents:YES];
    
    [scroller setScrollEnabled:YES];
    scroller.contentSize = CGSizeMake(320, 568);
	// Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.hidden = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [scroller addGestureRecognizer:tap];
    
    self.textFieldUsername.delegate = self;
    self.textFieldPassword.delegate = self;
    self.textFieldRetypePassword.delegate = self;
    self.textFieldEmail.delegate = self;
    
    self.errorRegistartionLabel.hidden = YES;
    
    [self.genderSegmentSelector setSelectedSegmentIndex:-1];
    
    [self checkBirthday];
    
    scroller.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;

    
}

-(void)viewWillDisappear:(BOOL)animated{
    [self subscribeToKeyboardEvents:NO];
     self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)subscribeToKeyboardEvents:(BOOL)subscribe{
    
    if(subscribe){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
}

- (void) keyboardDidShow:(NSNotification *)nsNotification {
    
    NSDictionary * userInfo = [nsNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect newFrame = [scroller frame];
    
    CGFloat kHeight = kbSize.height;
    
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        kHeight = kbSize.width;
    }
    
    newFrame.size.height -= kHeight;
    
    [scroller setFrame:newFrame];
    
}

-(void)keyboardWillHide:(NSNotification *)nsNotification {
        
        NSDictionary * userInfo = [nsNotification userInfo];
        CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        CGRect newFrame = [scroller frame];
        
        CGFloat kHeight = kbSize.height;
        
        if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
            kHeight = kbSize.width;
        }
        
        newFrame.size.height += kHeight;
        
        // save the content offset before the frame change
        CGPoint contentOffsetBefore = scroller.contentOffset;
        
        [scroller setHidden:YES];
        
        // set the new frame
        [scroller setFrame:newFrame];
        
        // get the content offset after the frame change
        CGPoint contentOffsetAfter =  scroller.contentOffset;
        
        // content offset initial state
        [scroller setContentOffset:contentOffsetBefore];
        
        [scroller setHidden:NO];
        
        [UIView animateWithDuration:0.25
                         animations:^{
                             [scroller setContentOffset:contentOffsetAfter];
                         }
                         completion:^(BOOL finished){
                             // do nothing for the time being...                         
                         }
         ];
        
}

#pragma mark - Segue Methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.destinationViewController isKindOfClass:[MLRegistrationImageViewController class]]){
        
        MLRegistrationImageViewController *registrationImageVC = segue.destinationViewController;
        
        MLUser *user = [self assignUserInfo];
        
        registrationImageVC.userCredentials = user;
       
        registrationImageVC.delegate = self;
    }
    
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
   
    if([self userFieldEvaluation] == NO){
        return NO;
    }
    
    else {
        
        return YES;
    }
    
}

#pragma mark - Helper Methods

-(BOOL)userFieldEvaluation{
    
    
    [self checkUserName];
    [self checkUserEmail];
    [self checkUserPassword];
    [self checkPasswordRetype];
    [self checkGender];
    
    if([self checkUserName] == NO || [self checkUserEmail] == NO || [self checkUserPassword] == NO || [self checkPasswordRetype] == NO || [self checkPasswordMatch] == NO || [self checkGender] == NO){
        
        self.errorRegistartionLabel.hidden = NO;
        return NO;
    }
    else{
        
        [self assignUserInfo];
        
        return YES;
    }
}

-(MLUser *)assignUserInfo{
    
    MLUser *userRegistration = [[MLUser alloc] init];
    
    userRegistration.userName = self.textFieldUsername.text;
    userRegistration.userPassword = self.textFieldPassword.text;
    userRegistration.userEmail = self.textFieldEmail.text;
    userRegistration.userBirthday = self.birthdayDatePicker.date;
    if(self.genderSegmentSelector.selectedSegmentIndex == 0) {
        userRegistration.userGender = @"female";
    }
    if(self.genderSegmentSelector.selectedSegmentIndex == 1){
        userRegistration.userGender = @"male";
    }
    
    return userRegistration;
}

#pragma mark - Account Validation Methods

-(BOOL)checkUserName{
    
    if([self.textFieldUsername.text isEqualToString:@""]){
        [UIView animateWithDuration:2.5 animations:^{
            self.textFieldUsername.backgroundColor = [UIColor colorWithRed:255.0 green:0 blue:0 alpha:.1];
        }];
    return NO;
}
    [UIView animateWithDuration:0.1 animations:^{
        self.textFieldUsername.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    }];
    
    return YES;
}

-(BOOL)checkUserEmail{
    if([self.textFieldEmail.text isEqualToString:@""]){
        [UIView animateWithDuration:2.5 animations:^{
            self.textFieldEmail.backgroundColor = [UIColor colorWithRed:255.0 green:0 blue:0 alpha:.1];
        }];
    return NO;
}
    [UIView animateWithDuration:0.1 animations:^{
        self.textFieldEmail.backgroundColor = [UIColor clearColor];
    }];
    
    return YES;
}

-(BOOL)checkUserPassword{
    if([self.textFieldPassword.text isEqualToString:@""]){
        [UIView animateWithDuration:2.5 animations:^{
            self.textFieldPassword.backgroundColor = [UIColor colorWithRed:255.0 green:0 blue:0 alpha:.1];
        }];
    return NO;
}
    [UIView animateWithDuration:0.1 animations:^{
        self.textFieldPassword.backgroundColor = [UIColor clearColor];
    }];
    
    return YES;
}

-(BOOL)checkPasswordRetype{
    if([self.textFieldRetypePassword.text isEqualToString:@""]){
        [UIView animateWithDuration:2.5 animations:^{
            self.textFieldRetypePassword.backgroundColor = [UIColor colorWithRed:255.0 green:0 blue:0 alpha:.1];
        }];
    return NO;
}
    
    [UIView animateWithDuration:0.1 animations:^{
        self.textFieldRetypePassword.backgroundColor = [UIColor clearColor];
    }];
    
    return YES;
}

-(BOOL)checkPasswordMatch{
    
    NSLog(@"Password: %@ & Retyped Password: %@", self.textFieldPassword, self.textFieldRetypePassword);
    
    if([self.textFieldPassword.text isEqualToString:self.textFieldRetypePassword.text]){
    return YES;
}
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passwords do not match" message:@"" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:  nil];
    [alert show];
    
    return NO;
}

-(BOOL)checkGender{
    
    if(self.genderSegmentSelector.selectedSegmentIndex == -1){
        
        [UIView animateWithDuration:2.5 animations:^{
            self.genderSegmentSelector.backgroundColor = [UIColor colorWithRed:255.0 green:0 blue:0 alpha:.1];
        }];
        
        return NO;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        self.genderSegmentSelector.backgroundColor = [UIColor clearColor];
    }];
    
    return YES;
}

-(void)checkBirthday{
    
    self.birthdayDatePicker.datePickerMode = UIDatePickerModeDate;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate = [NSDate date];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:-18];
    
    NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    
    [self.birthdayDatePicker setMaximumDate:maxDate];
    
}

#pragma mark - Clean Up Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.textFieldUsername resignFirstResponder];
    [self.textFieldPassword resignFirstResponder];
    [self.textFieldRetypePassword resignFirstResponder];
    [self.textFieldEmail resignFirstResponder];
    return YES;
}

-(void)dismissKeyboard{
    [self.textFieldUsername resignFirstResponder];
    [self.textFieldPassword resignFirstResponder];
    [self.textFieldRetypePassword resignFirstResponder];
    [self.textFieldEmail resignFirstResponder];
}

#pragma mark - MLRegisterUserImageViewControllerDelegate

-(void)finalizeAccount{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
