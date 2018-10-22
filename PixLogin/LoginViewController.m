//
//  LoginViewController.m
//  PixLogin
//
//  Created by Dave Scruton on 5/29/18.
//  Copyright © 2018 huedoku. All rights reserved.
//
//  Parse URL http://ec2-52-42-95-208.us-west-2.compute.amazonaws.com
//   NOTE: Changes EVERY TIME you restart!
//    davesky/dogdog12!
//  Reset Email Failure, (fix?)
//  An appName, publicServerURL, and emailAdapter are required
//   for password reset and email verification functionality...
//  https://stackoverflow.com/questions/36764372/enabling-reset-password-and-email-verification-for-parse-server-hosted-locally


#import "LoginViewController.h"

@implementation LoginViewController

//Remove at integration time (use plixaKeys)
NSString *const _PuserPortraitKey       = @"userPortrait";


//----LoginViewController---------------------------------
-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder])
    {
        lastPage    = 4;
        animSpeed   = 0.5;
        newUser     = true;
        avatarNum   = 0; //Unselected...
        avatarImage = nil;
        returningFromPhotoPicker = false;
        bkgdTropo = [UIImage imageNamed:@"intermed2.jpg"];
        bkgdTilt  = [UIImage imageNamed:@"tiltbkgd"];

    }
    return self;
    
} //end initWithCoder



//----LoginViewController---------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    ai = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 180, 180)];
    ai.hidesWhenStopped = true;
    ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [_activityView addSubview:ai];
    _activityView.layer.borderWidth = 2;
    _activityView.layer.borderColor = [UIColor whiteColor].CGColor;
    _activityView.hidden = TRUE;

    _nameText.delegate  = self;
    _pwText.delegate    = self;
    _emailText.delegate = self;

    
}

//----LoginViewController---------------------------------
-(void) loadView
{
    [super loadView];
    CGSize csz   = [UIScreen mainScreen].bounds.size;
    viewWid = (int)csz.width;
    viewHit = (int)csz.height;
    viewW2  = viewWid/2;
    viewH2  = viewHit/2;
    _portraitImage.clipsToBounds = TRUE;
    _portraitImage.layer.cornerRadius = _portraitImage.frame.size.width * 0.01 * PORTRAIT_PERCENT;

}


//----LoginViewController---------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!returningFromPhotoPicker) [self reset];
}

//----LoginViewController---------------------------------
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!returningFromPhotoPicker) //Entering this UI first time?
    {
        if ([_entryMode containsString : @"onboarding"])
        {
            page = 0;
            [self firstPage];
        }
        else //Login for returning user?
        {
            page = 1;
            newUser = FALSE; // assume existing user, skip first page
            [self secondPage];
        }

    }
    else [self thirdPage]; //Returning from photo picker!
    returningFromPhotoPicker = false;
}



//----LoginViewController---------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//----LoginViewController---------------------------------
-(void) reset
{
    page = 0;
    _obscura.hidden      = false;
    _obscura.alpha       = 0;
    [self setControlAlphasToZero];
}  //end reset

//----LoginViewController---------------------------------
-(void) setControlAlphasToZero
{
    _welcomeLabel.alpha  = 0;
    _portraitImage.alpha = 0;
    _logoImage.alpha     = 0;
    _lsButtonView.alpha  = 0;
    _userPwView.alpha    = 0;
    _faceView.alpha      = 0;
    _leftButton.alpha    = 0;
    _rightButton.alpha   = 0;
    _uploadButton.alpha  = 0;
    _chooseLabel.alpha   = 0;
    _resetPasswordButton.hidden = true; //Special control...
    
}  //end setControlAlphasToZero


//----LoginViewController---------------------------------
-(void) gotoPreviousPage
{
    if (page == 0)
        [self dismissViewControllerAnimated:true completion:nil];
    else
    {
        page--;
        [self obscureOutToNextPage];
    }
}  //end gotoPreviousPage

//----LoginViewController---------------------------------
-(void) gotoNextPage
{
    NSLog(@" nextpage %d vs %d",page,lastPage);
    //Do we need to perform login / signup ???
    if (page == 1) //Page 1 just has login/signup buttons now
    {
        if (newUser)
        {
            if (![self getNameAndEmailFields]) return;
        }
        else
        {
            [self loginUser];  // dismisses ui if ok
            return;
        }
    }
    page++;
    if (page == lastPage) //Last page? Bail!
    {
        if (newUser)
        {
            if (![self getPasswordField]) return;
            [self signupUser];  // dismisses ui if ok
        }
        return;
    }
    [self obscureOutToNextPage];
    
} //end gotoNextPage


//----LoginViewController---------------------------------
-(void) obscureOutToNextPage
{
    //...continuing, animate into next page now
    float duration = animSpeed;
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _obscura.alpha = 1;
                         _rightButton.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [self gotoNextPagePartTwo];
                     }
     ];

}

//----LoginViewController---------------------------------
-(void) gotoNextPagePartTwo
{
    //_progressBar.progress = (float)page / (float)(lastPage-1);
    [self setControlAlphasToZero];
    switch(page)
    {
        case 0: //This only gets hit on a "back"...
            [self animateInOut:_obscura       : 0 : 0.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
            [self firstPage];
            break;
        case 1: [self secondPage];break;
        case 2: [self thirdPage];break;
        case 3: [self fourthPage];break;
       // case 4: [self fifthPage];break;
        default:
            [self dismissViewControllerAnimated : YES completion:nil];break;
    }
} //end gotoNextPagePartTwo

//----LoginViewController---------------------------------
// Direction 0 = animate out, 1 = animate in...
-(void) animateInOut : (id) child : (int) dir : (float) dtime : (float) atime
                     : (NSUInteger) options : (BOOL) clearAnimFlag
{
    if( [child isKindOfClass:[UIView class]])
    {
        dtime*=animSpeed;
        atime*=animSpeed;
        
        UIView* uie = (UIView *) child;
        float startAlpha = 1.0; //Assume animate out by default
        float endAlpha   = 0.0;
        if (dir == 1)  //Animate in?
        {
            startAlpha = 0.0;
            endAlpha   = 1.0;
        }
        uie.alpha = startAlpha;
        [UIView animateWithDuration:atime
                              delay:dtime
                            options:options
                         animations:^{
                             uie.alpha = endAlpha;
                         }
                         completion:^(BOOL finished){
                             if (clearAnimFlag) animating = FALSE;
                         }
         ];
    }
} //end animateIn


//----LoginViewController---------------------------------
// Opener...
-(void) firstPage
{
    NSLog(@" page 1");
    animating = TRUE;
    _leftButton.hidden  = TRUE;
    _rightButton.hidden = TRUE;
    failCount = 0;
    //First page: Clear out text fields ALWAYS
    _nameText.text  = @"";
    _pwText.text    = @"";
    _emailText.text = @"";
    _background.image = bkgdTropo;

   // _welcomeLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"vangogh120"]];
    
    BOOL login_hidden = TRUE;
    if ([_entryMode containsString : @"onboarding"])
    {
        _welcomeLabel.text = @"Add your\nColor Profile";
        _bottomLabel.text = @"to create\nbrilliant puzzles";
    }
    else
    {
        _welcomeLabel.text = @"Welcome";
        login_hidden = FALSE;
    }
    _loginButton.hidden     = login_hidden;
    _createButton.hidden    = !login_hidden;
    _anonymousButton.hidden = !login_hidden;

    //These only get animated in ONCE...
    [self animateInOut:_logoImage     : 1 : 0.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_welcomeLabel  : 1 : 0.3 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_bottomLabel   : 1 : 0.5 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_lsButtonView  : 1 : 1.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];

} //end firstPage

//----LoginViewController---------------------------------
// Either get login info or signup info...
-(void) secondPage
{
    //NSLog(@" page 2");
    //Redundant??  _emailLabel.hidden   = !newUser;
    _logoImage.hidden     = TRUE;
    _userPwView.hidden    = FALSE;
    _pwText.hidden        = newUser;
    _pwLabel.hidden       = newUser;
    _nameLabel.hidden     = FALSE;
    _emailLabel.hidden    = FALSE;
    _leftButton.hidden    = FALSE;
    _rightButton.hidden   = FALSE;
    _resetPasswordButton.hidden = TRUE;
    _background.image     = bkgdTilt;
    _bottomLabel.hidden   = FALSE;

    [_leftButton setTitle:@"cancel" forState:UIControlStateNormal];

    NSString *itxt = @"";
    if (newUser)
    {
        _welcomeLabel.text = @"Create your profile\n"; // linebreak keeps label at top VP
        itxt = @"Choose a username and add your email address";
    }
    else{
        _welcomeLabel.text = @"Login";
    }
    _bottomLabel.text = itxt;

    [_rightButton setTitle:@"next" forState:UIControlStateNormal];
    //This animates obscura OUT...
    [self animateInOut:_obscura       : 0 : 0.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    //These get animated IN...
    [self animateInOut:_logoImage     : 1 : 0.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_welcomeLabel  : 1 : 0.3 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_userPwView    : 1 : 0.5 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_bottomLabel   : 1 : 0.7 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_leftButton    : 1 : 0.9 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_rightButton   : 1 : 0.9 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];

} //end secondPage


//----LoginViewController---------------------------------
// Avatar Time...
-(void) thirdPage
{
    _bottomLabel.hidden  = TRUE;
    _uploadButton.hidden = FALSE;
    _chooseLabel.hidden  = FALSE;
    _faceView.hidden     = FALSE;

    animating = TRUE;
    _welcomeLabel.text = [NSString stringWithFormat:@"%@\n",_userName]; // add linefeed to keep label at top of its VP
   // _portraitImage.image = [UIImage imageNamed:@"emptyUser"];
    [_rightButton setTitle:@"next" forState:UIControlStateNormal];

    //This animates obscura OUT...
    [self animateInOut:_obscura       : 0 : 0.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    //These get animated IN...
    [self animateInOut:_portraitImage : 1 : 0.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_welcomeLabel  : 1 : 0.3 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_chooseLabel   : 1 : 0.5 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_uploadButton  : 1 : 0.7 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_faceView      : 1 : 0.9 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];
    
    
    [self animateInOut:_leftButton     : 1 : 1.2 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_rightButton    : 1 : 1.2 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];

} //end thirdPage


//----LoginViewController---------------------------------
// Password Time...
-(void) fourthPage
{
    //Hide stuff from last page
    _faceView.hidden     = TRUE;
    _uploadButton.hidden = TRUE;
    _chooseLabel.hidden  = TRUE;

    //Show pw view and bottom label...
    _userPwView.hidden   = FALSE;
    _bottomLabel.hidden  = FALSE;

    //Just show password fields
    _nameLabel.hidden     = TRUE;
    _nameText.hidden      = TRUE;
    _emailLabel.hidden    = TRUE;
    _emailText.hidden     = TRUE;
    _pwLabel.hidden       = FALSE;
    _pwText.hidden        = FALSE;

    animating = TRUE;
    _bottomLabel.text = @"Make sure your password is at least eight characters";
    [_rightButton setTitle:@"finish" forState:UIControlStateNormal];
    //This animates obscura OUT...
    [self animateInOut:_obscura       : 0 : 0.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    //These get animated IN...
    [self animateInOut:_portraitImage : 1 : 0.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_welcomeLabel  : 1 : 0.3 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_userPwView    : 1 : 0.5 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_bottomLabel   : 1 : 0.7 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_leftButton    : 1 : 0.9 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_rightButton   : 1 : 0.9 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];

} //end fourthPage


//----LoginViewController---------------------------------
-(BOOL) getNameAndEmailFields
{
    [_nameText  resignFirstResponder]; //Make sure any keyboards are gone...
    [_emailText resignFirstResponder];
    _userName = _nameText.text;
    _emailString = _emailText.text;
    if ([_userName isEqualToString:@""]    ||
        [_emailString isEqualToString:@""] )
    {
        [self pixAlertDEBUG:self :@"Empty Field(s)" :@"Please enter a Username and Email" :false];
        return false;
    }
    if (newUser)
    {
        if (![self validateEmailWithString : _emailString])
        {
            [self pixAlertDEBUG:self :@"Email Address looks wrong" :@"Your email must contain letters or numbers, a dot and the @ character" :false];
            return false;
        }
    }
    //Check validity...
    return true;
    
} //end getNameAndEmailFields

//----LoginViewController---------------------------------
-(BOOL) getPasswordField
{
    [_pwText    resignFirstResponder];
    _password = _pwText.text;
    if ([_password isEqualToString:@""])
    {
        [self pixAlertDEBUG:self :@"Empty Field(s)" :@"Please enter a Password" :false];
        return false;
    }
    if (newUser)
    {
        if (_password.length < 8)
        {
            [self pixAlertDEBUG:self :@"Password too short" :@"Please create a password with at least 8 characters" :false];
            return false;
        }
    }
    //Check validity...
    return true;
    
} //end getPasswordField


//----LoginViewController---------------------------------
- (IBAction)uploadSelect:(id)sender
{
    NSLog(@" UploadSelect");
    [self displayPhotoPicker];
}

//----LoginViewController---------------------------------
- (IBAction)facesSelect:(id)sender
{
    NSLog(@" facesSelect");
}

//----LoginViewController---------------------------------
// THis is the next button's target
- (IBAction)saveSelect:(id)sender
{
}



- (IBAction)resetPasswordSelect:(id)sender
{
    //Get and validate email addy...
    _emailString = _emailText.text; //Get fresh email...
    if (![self validateEmailWithString : _emailString] || [_emailString isEqualToString:@""])
    {
        [self pixAlertDEBUG:self :@"Bad Email Address" :@"Your email must be contain letters or numbers, a dot and the @ character" :false];
        return;
    }
    //Addy legal? Try reset! asdf
    _activityView.hidden = FALSE;
    [ai startAnimating];
    
    [UIApplication.sharedApplication beginIgnoringInteractionEvents];
    [PFUser requestPasswordResetForEmailInBackground:_emailString
         block:^(BOOL succeeded, NSError *error) {
             if (!error)
             {
                 NSLog(@" reset OK");
                 [self pixAlertDEBUG:self :@"Reset Successful" : @"Check your email to complete the password reset process." :false];
             }
             else
             {
                 NSLog(@"reset err:%@", [error userInfo]);
                 [self pixAlertDEBUG:self :@"Reset Failed" : error.localizedDescription :false];
             }
             _activityView.hidden = TRUE;
             [ai stopAnimating];
             [UIApplication.sharedApplication endIgnoringInteractionEvents];
             [self reset];
             [self firstPage];
         }];
} //end resetPasswordSelect

//----LoginViewController---------------------------------
-(void) setupCannedAvatar : (int) which : (id)sender
{
    avatarNum = which;
    UIButton *button = (UIButton *)sender;
    avatarImage = button.currentBackgroundImage;
    avatarImage = [avatarImage imageByScalingAndCroppingForSize :
                   CGSizeMake(LOGIN_AVATAR_SIZE, LOGIN_AVATAR_SIZE)  ];
    _portraitImage.image = avatarImage; //[UIImage imageNamed : name];
    if (_rightButton.alpha == 0) //Only animate button in if not yet visible...
        [self animateInOut:_rightButton    : 1 : 1.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];
} //end setupCannedAvatar

//----LoginViewController---------------------------------
- (IBAction)face1Select:(id)sender
{
    [self setupCannedAvatar : 1 : sender]; //OKeefe
}

//----LoginViewController---------------------------------
- (IBAction)face2Select:(id)sender
{
    [self setupCannedAvatar : 2 : sender];  // Faithringgold
}

//----LoginViewController---------------------------------
- (IBAction)face3Select:(id)sender 
{
    [self setupCannedAvatar : 3 : sender];  // nelson256
}

//----LoginViewController---------------------------------
- (IBAction)face4Select:(id)sender
{
    [self setupCannedAvatar : 4 : sender];  // "Albers"
}

//----LoginViewController---------------------------------
- (IBAction)face5Select:(id)sender
{
    [self setupCannedAvatar : 5 : sender];  // Frida
}

//----LoginViewController---------------------------------
- (IBAction)face6Select:(id)sender
{
    [self setupCannedAvatar : 6 : sender];  // monet
}

//----LoginViewController---------------------------------
// First page button....
- (IBAction)loginSelect:(id)sender
{
    if (animating) return;
    newUser = false;
    [self gotoNextPage];
//    NSLog(@" process login here...");
//    if (![self getNameAndEmailFields]) return;
//    [self loginUser];  // dismisses ui if ok
}

//----LoginViewController---------------------------------
// First page button....
- (IBAction)signupSelect:(id)sender
{
    if (animating) return;
    newUser = true;
    [self gotoNextPage];
//    NSLog(@" signup new user here...");
//    [self gotoNextPage];
}

//----LoginViewController---------------------------------

- (IBAction)leftSelect:(id)sender {
    if (page == 1)
    {
      [self anonymousInfoAlert:self];
    }
    else
    {
        //Go back one page...
        NSLog(@" go back one page??.., page %d",page);
        [self gotoPreviousPage];
    }

}

//----LoginViewController---------------------------------
- (IBAction)rightSelect:(id)sender
{
    NSLog(@" right button hit...");
    [self gotoNextPage];

}

//----LoginViewController---------------------------------
// User doesn't want to register: Pass in as HueGogh
- (IBAction)anonymousSelect:(id)sender
{
    NSLog(@" set up HueGogh here...");
    [self anonymousInfoAlert:self];
}


//----LoginViewController---------------------------------
-(void) displayPhotoPicker
{
    //NSLog(@" photo picker...");
    UIImagePickerController *imgPicker;
    imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.allowsEditing = YES;
    imgPicker.delegate      = self;
    imgPicker.sourceType    = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    returningFromPhotoPicker = true;
    [self presentViewController:imgPicker animated:NO completion:nil];
} //end displayPhotoPicker

//----LoginViewController---------------------------------
- (void)imagePickerController:(UIImagePickerController *)Picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Makes poppy squirrel sound!
   // [_sfx makeTicSoundWithPitchandLevel:7 :70 : 40];
    [Picker dismissViewControllerAnimated:NO completion:^{
        avatarImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
        avatarImage = [avatarImage imageByScalingAndCroppingForSize :
                       CGSizeMake(LOGIN_AVATAR_SIZE, LOGIN_AVATAR_SIZE)  ];
        _portraitImage.image = avatarImage;
        if (_rightButton.alpha == 0) //Only animate button in if not yet visible...
            [self animateInOut:_rightButton    : 1 : 1.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];
    }];
} //end didFinishPickingMediaWithInfo

//======(PixUtils)==========================================
// For user choosing anonymous play...
-(void) anonymousInfoAlert : (UIViewController *) parent
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Anonymous Play has its limits..."
                                 message:@"If you don't create a Color Profile,\nyou cannot create puzzles..."
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //use fbcache, set avatar and name? Or is it huegogh by default?
                                    [self dismissViewControllerAnimated : YES completion:nil];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Go Back"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [parent presentViewController:alert animated:YES completion:nil];

} //end anonymousInfoAlert




//======(PixUtils)==========================================
// Pull on delivery, use pixAlert from pixUtils...
-(void) pixAlertDEBUG : (UIViewController *) parent : (NSString *) title : (NSString *) message : (BOOL) yesnoOption
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    if (yesnoOption)
    {
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Yes"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                    }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"No"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                                   }];
        [alert addAction:yesButton];
        [alert addAction:noButton];
    }
    else //Just put up OK?
    {
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                    }];
        
        [alert addAction:yesButton];
    }
    if (parent == nil) //Invoked from a non-UI object?
    {
        UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [vc presentViewController:alert animated:YES completion:nil];
    }
    else
        [parent presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - UITextFieldDelegate

//======(PixUtils)==========================================
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

//==========loginTestVC=========================================================================
- (void)loginUser
{
    _activityView.hidden = FALSE;
    [ai startAnimating];
    [UIApplication.sharedApplication beginIgnoringInteractionEvents];
    [PFUser logInWithUsernameInBackground:_userName password:_password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        BOOL bailit = false;
        if (user != nil)
        {
            NSLog(@"user logged in...");
            NSLog(@" userobjectid %@",PFUser.currentUser.objectId);
            bailit = true;
        }
        else
        {
            [self pixAlertDEBUG:self :@"Error Logging In" : error.localizedDescription :false];
            failCount++;
            if (failCount > 2) //Third fail? OUCH! We need a reset!
            {
                //Reconfigure UI for email reset...
                _emailText.hidden = FALSE;
                _resetPasswordButton.hidden = FALSE;
                _nameText.hidden = TRUE;
                _pwText.hidden = TRUE;
                
                _welcomeLabel.text = @"Enter Email";
            }
        }
        _activityView.hidden = TRUE;
        [ai stopAnimating];
        [UIApplication.sharedApplication endIgnoringInteractionEvents];
        if (bailit)            //all done?
            [self dismissViewControllerAnimated : YES completion:nil];
    }];
}  //end loginUser

//==========loginTestVC=========================================================================
- (void)signupUser
{
    PFUser *user = [[PFUser alloc] init];
    user.username = _userName;
    user.password = _password;
    user.email    = _emailString;
    NSData *avatarData = UIImagePNGRepresentation(avatarImage);
    PFFile *avatarImageFile = [PFFile fileWithName : @"avatarImage.png" data:avatarData];
    user[_PuserPortraitKey] = avatarImageFile;
    //  user.email    = _userName;  //Omit: need dog@kat.com formatted email here or it fails
    NSLog(@" activity indicgor??");
    _activityView.hidden = FALSE;
    [ai startAnimating];
    [UIApplication.sharedApplication beginIgnoringInteractionEvents];
    [user signUpInBackgroundWithBlock:^(BOOL success, NSError * _Nullable error) {
        BOOL bailit = false;
        if (error != nil)
        {
            [self pixAlertDEBUG:self :@"Error Signing Up" : error.localizedDescription :false];
        }
        else
        {
            NSLog(@"user signup ok");
            bailit = true;
        }
        _activityView.hidden = TRUE;
        [ai stopAnimating];
        [UIApplication.sharedApplication endIgnoringInteractionEvents];
        if (bailit)            //all done?
            [self dismissViewControllerAnimated : YES completion:nil];
        
    }];
}  // end signupUser

//==========loginTestVC=========================================================================
- (BOOL)validateEmailWithString:(NSString*)emailIn
{
    NSLog(@"validate email %@.....",emailIn);
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
//    BOOL isgood = [emailTest evaluateWithObject:emailIn];
    return [emailTest evaluateWithObject:emailIn];
}

//==========loginTestVC=========================================================================
// Boilerplate from stackoverflow
//  https://stackoverflow.com/questions/3139619/check-that-an-email-address-is-valid-on-ios
//  https://stackoverflow.com/questions/800123/what-are-best-practices-for-validating-email-addresses-on-ios-2-0
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


//==========loginTestVC=========================================================================
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@" ended editing txt %@",textField);
    NSLog(@" annnd text is %@",textField.text);
    
}


@end
