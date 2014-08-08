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

@property (strong, nonatomic) IBOutlet UILabel *errorRegistartionLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *birthdayDatePicker;
@property (strong, nonatomic) IBOutlet UISegmentedControl *genderSegmentSelector;

@property (strong, nonatomic) NSDictionary *userRegistrationInfo;

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
    
    self.textFieldUsername.delegate = self;
    self.textFieldPassword.delegate = self;
    self.textFieldRetypePassword.delegate = self;
    self.textFieldEmail.delegate = self;
    
    /* Make sure the navigation controller is not hidden */
    self.navigationController.navigationBar.hidden = NO;
    
    
    /* Scroll view and keyboard dismissal gesture methods */
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [scroller addGestureRecognizer:tap];
    [scroller setScrollEnabled:YES];
    scroller.contentSize = CGSizeMake(320, 568);
    [self subscribeToKeyboardEvents:YES];

    /* NavBar Bottom Border */
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, 45.0f, self.view.frame.size.width, 1.0f);
    
    bottomBorder.backgroundColor = [[UIColor colorWithRed:241.0/255.0f green:242.0/255.0f blue:242.0/255.0f alpha:1.0] CGColor];
    [self.navigationController.navigationBar.layer addSublayer:bottomBorder];
    
    /* Only display error if all fields are not entered */
    self.errorRegistartionLabel.hidden = YES;
    
    /* Set gender selector to not have a default gender, user must choose one */
    
    [self.genderSegmentSelector setSelectedSegmentIndex:-1];
    
    /* Checks to see exactly what date a user would turn 18 years old */
    
    [self checkBirthday];
    
    /* If a user had set a user name in previous view, assign that username in this field */
    
    self.textFieldUsername.text = self.userText;
    NSLog(@"Username: %@", self.textFieldUsername.text);

}

-(void)viewWillDisappear:(BOOL)animated{
    
    /* Cleaning up when the view controller is dismissed: revoke keyboard events and hide the UINavigationBar */
    [self subscribeToKeyboardEvents:NO];
     self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard Events

- (void)subscribeToKeyboardEvents:(BOOL)subscribe{
    
    /* Make sure the keyboard responds to user's request to dismiss the keyboard and scroll the view if needed */
    
    
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
    
    /* Make sure the keyboard shows up and pushes the view up so the text field is not being covered by the keyboard */
    
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
    
        /* Reset the view when the keyboard is dismissed */
    
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
                         }];
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

/* Checks to see whether or not the segue should be performed and registration should be continued */

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if([self userFieldEvaluation] == NO){
        return NO;
    }
    else return YES;
}

#pragma mark - Helper Methods

/* Runs through all the user form validation checks to see whether or not a segue can be performed */

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
    else {
        
        [self assignUserInfo];
        return YES;
    }
}

/* Assigns all the user data to a user object that gets sent to the next view controller and ultimately uploaded to Parse */

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

/* All account validation methods */

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
