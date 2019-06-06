//
//  LoginViewController.m
//  PixLogin
//
//  Created by Dave Scruton on 5/29/18.
//  Copyright © 2018 huedoku. All rights reserved.
//
//  Sashido email templates:
//   https://blog.sashido.io/emails-and-custom-user-facing-pages/
//  Figma design link:
//  https://www.figma.com/file/OzHOCvGVRUruUDXUduFleDZT/Pix2019?node-id=0%3A1
//  Look for emailVerified column in PFUser table to tell if email verification went thru
//  4/29 new  bkgd
//  5/24 overhaul, new state transitions
//  5/27 now only 2 text fields, top/bottom
//  6/2  Ignore user events? What about timeouts or hangs? user is stuck!
#import "LoginViewController.h"


#define DONOT_IGNOREUSEREVENTS
@implementation LoginViewController

//Remove at integration time (use plixaKeys)
NSString *const _PuserPortraitKey       = @"userPortrait";


//----LoginViewController---------------------------------
-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder])
    {
        lastPage    = 4;
        animSpeed   = 0.5;
        avatarNum   = 0; //Unselected...
        avatarImage = nil;
//        bkgdTropo   = [UIImage imageNamed:@"intermed2.jpg"];
        bkgdGradient   = [UIImage imageNamed:@"pixlogin_bkgd"];
        needPwReset = false;
        returningFromPhotoPicker = false;

        state = 1; //Initial state...
        //These are the pages we will switch between while creating an account
        //NOTE: state 0 DOES NOT EXIST, states are from 1 to 11!
        for (int i=0;i<=7;i++) createAccountStates[i] = i;
        //Login state
        loginState = 5;
        //States for resetting the password
        for (int i=9;i<=10;i++) resetPasswordStates[i] = i;
        //Skip account setup
        skipState = 11;
        DBBeingAccessed = FALSE;
    }
    return self;
    
} //end initWithCoder



//----LoginViewController---------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    //5/27
    _topTextField.delegate    = self;
    _bottomTextField.delegate = self;
    
 
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

    //Spinning activity view
    spv = [[spinnerView alloc] initWithFrame:CGRectMake(0, 0, viewWid, viewHit)];
    [self.view addSubview:spv];

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
        state = 1; //Initial state...
        [self getPageForState];
        [self gotoNthPage];
    }
    else     //Returning from photo picker!
    {
        state = 4;
        [self getPageForState];
        [self gotoNthPage];
    }
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
    _portraitImage.alpha = 0;
    _lsButtonView.alpha  = 0;
    _userPwView.alpha    = 0;
    _faceView.alpha      = 0;
    _chooseLabel.alpha   = 0;
    _bottomButtonView.hidden = TRUE; //Does this get alphad in?
    _topLabel.hidden = TRUE;
    _bottomLabel.hidden = TRUE;
    _uploadButton.hidden = TRUE;
    _emailConfLabel.hidden = TRUE;
}  //end setControlAlphasToZero

//----LoginViewController---------------------------------
-(void)gotoPageForState : (int)s
{
    state = s;
    [self getPageForState];
    [self gotoNthPage];
}

//----LoginViewController---------------------------------
-(void) getPageForState
{
    if ([_entryMode containsString : PL_SIGNUP_MODE])
    {
        page = createAccountStates[state];
    }
    else if ([_entryMode containsString : PL_AVATAR_MODE])  //Change user avatar?
    {
        _userName = PFUser.currentUser.username; //Make sure username is set up!
        page = 4; //???? Need to fit this into our new state system
    }
    else if ([_entryMode containsString : PL_LOGIN_MODE])  //Login for returning user?
    {
        page = loginState;
    }

}



//----LoginViewController---------------------------------
-(void) gotoNthPage
{
    switch(page)
    {
        case 1: [self firstPage];   break;
        case 2: [self secondPage];  break;
        case 3: [self thirdPage];   break;
        case 4: [self fourthPage];  break;
        case 5: [self fifthPage];   break;
        case 6: [self sixthPage];   break;
        case 7: [self seventhPage]; break;
        //etc...
    }
} //end gotoNthPage


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
                             if (clearAnimFlag) self->animating = FALSE;
                         }
         ];
    }
} //end animateIn

//----LoginViewController---------------------------------
-(void) loadCurrentUserInfo
{
    PFUser *user = PFUser.currentUser;
    _userName    = PFUser.currentUser.username;
    avatarImage  = [UIImage imageNamed:@"vangogh120"];
    PFFile *pff  = user[@"userPortrait"]; //replace with portraitkey at integrate time
    [pff getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@" error fetching avatar...");
        }
        else
        {
            self->avatarImage = [UIImage imageWithData:data];
        }
        self->_portraitImage.image = self->avatarImage;
    }];
    
} //end loadCurrentUserInfo

//----LoginViewController---------------------------------
-(void) updateUserAvatar
{
    PFUser *user = PFUser.currentUser;
    NSData *avatarData = UIImagePNGRepresentation(avatarImage);
    PFFile *avatarImageFile = [PFFile fileWithName : @"avatarImage.png" data:avatarData];
    user[_PuserPortraitKey] = avatarImageFile;
    [spv start : @"Updating your profile"];
    [ai startAnimating];
    DBBeingAccessed = FALSE;

#ifdef IGNOREUSEREVENTS
    [UIApplication.sharedApplication beginIgnoringInteractionEvents];
#endif
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self->spv stop];
        self->DBBeingAccessed = FALSE;
        if (succeeded)
        {
            //This has 2 modes: user signup or updating avatar!
            if ([self->_entryMode containsString : PL_AVATAR_MODE])  //Reset avatar? Dismiss UI
                [self dismissViewControllerAnimated : YES completion:nil];
            else { //Creating account?
                [PFUser logOut]; //Log us out!
                [self gotoPageForState:self->state+1];  //udderwise goto next state...
            }
        }
        else
        {
            [self pixAlertDEBUG:self :@"Could not save Avatar" : error.localizedDescription :false];
        }
#ifdef IGNOREUSEREVENTS
        [UIApplication.sharedApplication endIgnoringInteractionEvents];
#endif

    }];
    
} //end updateUserAvatar



//----LoginViewController---------------------------------
// Opener...
-(void) firstPage
{
    
    //First, hide fields we don't need...
    _portraitImage.hidden   = TRUE;
    _userPwView.hidden      = TRUE;
    _faceView.hidden        = TRUE;
    _uploadButton.hidden    = TRUE;
    _bottomLabel.hidden     = TRUE;
    _emailConfLabel.hidden  = TRUE; //DO I need this?
    _forgotButton.hidden    = TRUE;

    //Now show fields we DO need...
    _topLabel.hidden         = FALSE;
    _topSmallLabel.hidden    = FALSE;
    _lsButtonView.hidden     = FALSE;
    _bottomButtonView.hidden = FALSE;
    _anonymousButton.hidden  = FALSE;
    _orLabel.hidden          = FALSE;
    _LSBottomButton.hidden   = FALSE;
    
    //Clear all user login fields...
    avatarImage = [UIImage imageNamed:@"emptyUser"];
    _userName    = @"";
    _password    = @"";
    _emailString = @"";

    //Set text fields...
    _topLabel.text = @"Hue Know This\n ";
    _topSmallLabel.text = @"Get in here, login or create\nan account if you are new";

    animating = TRUE;
    //These only get animated in ONCE...
    [self animateInOut:_topLabel          : 1 : 0.5 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_topSmallLabel     : 1 : 0.7 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_lsButtonView      : 1 : 1.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_bottomButtonView  : 1 : 1.2 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];

} //end firstPage

//----LoginViewController---------------------------------
// Create Profile: Gets username
-(void) secondPage
{
    //First, hide fields we don't need...
    _portraitImage.hidden    = TRUE;
    _faceView.hidden         = TRUE;
    _uploadButton.hidden     = TRUE;
    _bottomLabel.hidden      = TRUE;
    _orLabel.hidden          = TRUE;
    _LSBottomButton.hidden   = TRUE;
    _emailConfLabel.hidden   = TRUE; //DO I need this?
    _topTextLabel.hidden     = TRUE;
    _bottomTextLabel.hidden  = TRUE;
    _bottomTextField.hidden  = TRUE;
    _bottomButtonView.hidden = TRUE;

    //Now show fields we DO need...
    _topLabel.hidden         = FALSE;
    _topSmallLabel.hidden    = FALSE;
    _lsButtonView.hidden     = FALSE;
    _topTextField.hidden     = FALSE;
    _userPwView.hidden       = FALSE;
    
    //Set text fields...
    _topLabel.text      = @"create account\n ";
    _topSmallLabel.text = @"choose your username";
    _topTextField.text  = @"";
    _topTextField.placeholder = @"enter username";
    [_LSTopButton setTitle:@"Next" forState:UIControlStateNormal];
    [_LSTopButton setEnabled:FALSE];
    
    animating = TRUE;
    //These only get animated in ONCE...
    [self animateInOut:_topLabel          : 1 : 0.5 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_topSmallLabel     : 1 : 0.7 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_lsButtonView      : 1 : 1.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_userPwView        : 1 : 1.2 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_bottomButtonView  : 1 : 1.4 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];

} //end secondPage


//----LoginViewController---------------------------------
// Get email and password strings...
-(void) thirdPage
{
    //First, hide fields we don't need...
    _portraitImage.hidden   = TRUE;
    _faceView.hidden        = TRUE;
    _uploadButton.hidden    = TRUE;
    _bottomLabel.hidden     = TRUE;
    _orLabel.hidden         = TRUE;
    _LSBottomButton.hidden  = TRUE;
    _emailConfLabel.hidden  = TRUE; //DO I need this?
    _topTextLabel.hidden    = TRUE;
    _bottomTextLabel.hidden = TRUE;
    _bottomButtonView.hidden= TRUE;
    
    //Now show fields we DO need...
    _topLabel.hidden         = FALSE;
    _topSmallLabel.hidden    = FALSE;
    _lsButtonView.hidden     = FALSE;
    _userPwView.hidden       = FALSE;
    _topTextField.hidden     = FALSE;
    _bottomTextField.hidden  = FALSE;
    //Set text fields...
    _topLabel.text = _userName;
    _topSmallLabel.text = @"password must be\n8 characters or more";
    _topTextField.text = @"";
    _topTextField.placeholder    = @"enter email";
    _bottomTextField.text = @"";
    _bottomTextField.placeholder = @"choose a password";
    [_LSTopButton setTitle:@"Next" forState:UIControlStateNormal];
    
    animating = TRUE;
    //These only get animated in ONCE...
    [self animateInOut:_topLabel          : 1 : 0.5 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_topSmallLabel     : 1 : 0.7 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_lsButtonView      : 1 : 1.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_userPwView        : 1 : 1.2 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_bottomButtonView  : 1 : 1.4 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];
} //end thirdPage


//----LoginViewController---------------------------------
// Avatar Time...
-(void) fourthPage
{
    //First, hide fields we don't need...
    _topSmallLabel.hidden    = TRUE;
    _userPwView.hidden       = TRUE;
    _emailConfLabel.hidden   = TRUE;
    _bottomButtonView.hidden = TRUE;
    _topTextField.hidden     = TRUE;
    _bottomLabel.hidden      = TRUE;
    _LSTopButton.hidden      = TRUE; //Hidden initially, shown later
    _LSBottomButton.hidden   = TRUE;
    _orLabel.hidden          = TRUE;

    //Now show fields we DO need...
    _topLabel.hidden         = FALSE;
    _portraitImage.hidden    = FALSE;
    _chooseLabel.hidden      = FALSE;
    _faceView.hidden         = FALSE;
    _uploadButton.hidden     = FALSE;
    _lsButtonView.hidden     = FALSE;

    NSString* nameWithCR = [NSString stringWithFormat:@"%@\n",_userName]; //Add CR for formatting
    _topLabel.text = nameWithCR;
    [_LSTopButton setTitle:@"Next" forState:UIControlStateNormal];

    if ([_entryMode containsString : PL_AVATAR_MODE])
    {
        if (!returningFromPhotoPicker) [self loadCurrentUserInfo];
    }
    else //Do I need to do something in signup mode?
    {
    }
    
    animating = TRUE;

    //This animates obscura OUT...
    [self animateInOut:_obscura       : 0 : 0.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    //These get animated IN...
    [self animateInOut:_portraitImage : 1 : 0.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_chooseLabel   : 1 : 0.5 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_lsButtonView  : 1 : 0.7 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_faceView      : 1 : 0.9 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];
    

} //end fourthPage



//----LoginViewController---------------------------------
// Login Entry point...
-(void) fifthPage
{
    //First, hide fields we don't need...
    _portraitImage.hidden   = TRUE;
    _faceView.hidden        = TRUE;
    _uploadButton.hidden    = TRUE;
    _bottomLabel.hidden     = TRUE;
    _orLabel.hidden         = TRUE;
    _LSBottomButton.hidden  = TRUE;
    _emailConfLabel.hidden  = TRUE; //DO I need this?
    _topTextLabel.hidden    = TRUE;
    _bottomTextLabel.hidden = TRUE;
    _anonymousButton.hidden = TRUE;
    
    //Now show fields we DO need...
    _topLabel.hidden         = FALSE;
    _topSmallLabel.hidden    = FALSE;
    _lsButtonView.hidden     = FALSE;
    _forgotButton.hidden     = FALSE;
    _userPwView.hidden       = FALSE;
    _topTextField.hidden     = FALSE;
    _bottomTextField.hidden  = FALSE;
    _bottomButtonView.hidden = FALSE;
    
    //Set text fields...
    _topLabel.text = @"color is relative";
    _topSmallLabel.text = @"get in here\n\n";
    _topTextField.text = @"";
    _topTextField.placeholder    = @"username";
    _bottomTextField.text = @"";
    _bottomTextField.placeholder = @"password";
    [_LSTopButton setTitle:@"Login" forState:UIControlStateNormal];
    
    animating = TRUE;
    //These only get animated in ONCE...
    [self animateInOut:_topLabel          : 1 : 0.5 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_topSmallLabel     : 1 : 0.7 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_lsButtonView      : 1 : 1.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_userPwView        : 1 : 1.2 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_bottomButtonView  : 1 : 1.4 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];
    if ([_entryMode containsString : PL_SIGNUP_MODE]) //Signup? user needs to verify first
        [self emailVerifyAlert]; //We need an alert over this page!

} //end fifthPage

//----LoginViewController---------------------------------
// Password Reset...
-(void) sixthPage
{
    //First, hide fields we don't need...
    _portraitImage.hidden    = TRUE;
    _faceView.hidden         = TRUE;
    _uploadButton.hidden     = TRUE;
    _bottomLabel.hidden      = TRUE;
    _orLabel.hidden          = TRUE;
    _LSBottomButton.hidden   = TRUE;
    _emailConfLabel.hidden   = TRUE;
    _topTextLabel.hidden     = TRUE;
    _bottomTextLabel.hidden  = TRUE;
    _bottomTextField.hidden  = TRUE;
    _bottomButtonView.hidden = TRUE;
    
    //Now show fields we DO need...
    _topLabel.hidden         = FALSE;
    _topSmallLabel.hidden    = FALSE;
    _lsButtonView.hidden     = FALSE;
    _topTextField.hidden     = FALSE;
    _userPwView.hidden       = FALSE;
    
    //Set text fields...
    _topLabel.text      = @"what\'s\nyour email? ";
    _topSmallLabel.text = @"Login not working? No Worries!\n";
    _topTextField.text  = @"";
    _topTextField.placeholder = @"enter email";
    [_LSTopButton setTitle:@"reset password" forState:UIControlStateNormal];
    [_LSTopButton setEnabled:FALSE];
    
    animating = TRUE;
    //These only get animated in ONCE...
    [self animateInOut:_topLabel          : 1 : 0.5 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_topSmallLabel     : 1 : 0.7 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_lsButtonView      : 1 : 1.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_userPwView        : 1 : 1.2 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_bottomButtonView  : 1 : 1.4 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];

} //end sixthPage

//----LoginViewController---------------------------------
// Skip page...
-(void) seventhPage
{
    //First, hide fields we don't need...
    _portraitImage.hidden    = TRUE;
    _faceView.hidden         = TRUE;
    _userPwView.hidden       = TRUE;
    _uploadButton.hidden     = TRUE;
    _orLabel.hidden          = TRUE;
    _LSBottomButton.hidden   = TRUE;
    _emailConfLabel.hidden   = TRUE; //DO I need this?
    _topTextLabel.hidden     = TRUE;
    _bottomTextLabel.hidden  = TRUE;
    _bottomTextField.hidden  = TRUE;
    _bottomButtonView.hidden = TRUE;
    
    //Now show fields we DO need...
    _topLabel.hidden         = FALSE;
    _topSmallLabel.hidden    = FALSE;
    _lsButtonView.hidden     = FALSE;
    _bottomLabel.hidden      = FALSE;

    //Set text fields...
    _topLabel.text      = @"Oh nohue\ndi\'nt";
    _topSmallLabel.text = @"As HueGogh you can play,\n but can\'t create,share,\n or get a power color.";
    _bottomLabel.text = @"You can always create an account later";
    [_LSTopButton setTitle:@"play anyway" forState:UIControlStateNormal];
    
    animating = TRUE;
    //These only get animated in ONCE...
    [self animateInOut:_topLabel          : 1 : 0.5 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_topSmallLabel     : 1 : 0.7 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_lsButtonView      : 1 : 1.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_userPwView        : 1 : 1.2 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_bottomLabel       : 1 : 1.4 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_bottomButtonView  : 1 : 1.6 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];

} //end seventhPage


//----LoginViewController---------------------------------
//  Get email / password fields, validates both, then does signup
-(void) checkEmailAndPasswordforSignup
{
    NSString *topString = _topTextField.text;
    NSString *botString = _bottomTextField.text;
    if (botString.length < 8)
    {
        [self pixAlertDEBUG:self :@"Password too short" : @"Your password must be at least 8 characters" :false];
    }
    else{ //PW OK? keep checking
        if ([self validateEmailWithString:topString]) //Legit?
        {
                _emailString = topString;
                _password    = botString; //Load up final fields
                [self signupUser]; //This accesses DB... continues after success
        }
        else{
            [self pixAlertDEBUG:self :@"Bad Email Address" : @"It looks like you have bad characters in your email address" :false];
        }
    }
} //end checkEmailAndPasswordforSignup

//----LoginViewController---------------------------------
//  Get email field,
-(void) checkEmailforPasswordReset
{
    NSString *topString = _topTextField.text;
    if ([self validateEmailWithString:topString]) //Legit?
    {
        _emailString = topString; //Load up final fields
        [self performPasswordReset]; //This accesses DB... continues after success
    }
    else{
        [self pixAlertDEBUG:self :@"Bad Email Address" : @"It looks like you have bad characters in your email address" :false];
    }
} //end checkEmailforPasswordReset


//----LoginViewController---------------------------------
//  Get email / password fields, validates both, then does signup
-(void) getUsernameAndPasswordAndLogin
{
    _userName = _topTextField.text;
    _password = _bottomTextField.text;
    [self loginUser];
} //end getUsernameAndPasswordAndLogin

//----LoginViewController---------------------------------
//  Get username field, check for obvious errors / punc,
//   then see if it already is in use
-(void) checkUsername
{
    NSString *testName = _topTextField.text;
    if ([self validateUsernameWithString:testName]) //Legit?
    {
        [spv start : @"Check availability"];
        DBBeingAccessed = TRUE;

#ifdef IGNOREUSEREVENTS
        [UIApplication.sharedApplication beginIgnoringInteractionEvents];
#endif
        PFQuery *query= [PFUser query];
        [query whereKey:@"username" equalTo:testName];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
            if (object == nil) //Username available? goto next state...
            {
                self->_userName = testName; //Set username now
                [self gotoPageForState:self->state+1];
            }
            else
                [self pixAlertDEBUG:self :@"Username Already Taken" : @"Please try a different username" :false];
#ifdef IGNOREUSEREVENTS
            [UIApplication.sharedApplication endIgnoringInteractionEvents];
#endif
            [self->spv stop];
            self->DBBeingAccessed = FALSE;

        }];
    }
    else
        [self pixAlertDEBUG:self :@"Bad Characters" : @"Username must be composed of letters and/or numbers" :false];
} //end checkUsername

//----LoginViewController---------------------------------
// This button has multiple uses, sometimes its Next,
//  sometimes its Login
- (IBAction)LSTopSelect:(id)sender
{
    //NSLog(@" LSTopSelect state %d",state);
    if (DBBeingAccessed) return; //DO not advance while DB in progress!
    //Handle signup sequence...
    if ([_entryMode containsString : PL_SIGNUP_MODE])
    {
        if (state == 1)
        {
            _entryMode = PL_LOGIN_MODE;
            [self gotoPageForState:5]; //Goto login page
        }
        else if (state == 2) [self checkUsername];
        else if (state == 3) [self checkEmailAndPasswordforSignup];
        else if (state == 4) [self updateUserAvatar];
        else if (state == 5) [self getUsernameAndPasswordAndLogin];
        else if (state == 7) [self dismissViewControllerAnimated : YES completion:nil];
        else [self gotoNthPage];
    }
    else if ([_entryMode containsString : PL_LOGIN_MODE]) //Login? only one place to go!
    {
        if (state == 6) [self checkEmailforPasswordReset];
        else            [self getUsernameAndPasswordAndLogin];
    }
    else if ([_entryMode containsString : PL_AVATAR_MODE]) //Avatar? reset it
        [self updateUserAvatar];
}

//----LoginViewController---------------------------------
// This button is only used as a create account button for now...
- (IBAction)LSBottomSelect:(id)sender
{
    NSLog(@" LSBottomSelect");
    [self gotoPageForState:2];
}

//----LoginViewController---------------------------------
- (IBAction)anonymousSelect:(id)sender
{
    [self gotoPageForState:7]; //Goto anon page...
}



//----LoginViewController---------------------------------
// Goes to reset pw page...
- (IBAction)resetPasswordSelect:(id)sender
{
    page = state = 6; //Hard coded, state may be weird. just go to the right page
    [self gotoNthPage];
} //end resetPasswordSelect

//----LoginViewController---------------------------------
-(void)performPasswordReset
{
#ifdef IGNOREUSEREVENTS
    [UIApplication.sharedApplication beginIgnoringInteractionEvents];
#endif
    [PFUser requestPasswordResetForEmailInBackground:_emailString
         block:^(BOOL succeeded, NSError *error) {
             if (!error)
             {
                 [self pixAlertDEBUG:self :@"Reset Successful" : @"Check your email to complete the password reset process." :false];
             }
             else
             {
                 [self pixAlertDEBUG:self :@"Reset Failed" : error.localizedDescription :false];
             }
#ifdef IGNOREUSEREVENTS
             [UIApplication.sharedApplication endIgnoringInteractionEvents];
#endif
             self->page = self->state = 5;
             [self gotoNthPage]; //Go to Login page now...
         }];
} //end performPasswordReset

//----LoginViewController---------------------------------
-(void) setupCannedAvatar : (int) which : (id)sender
{
    avatarNum = which;
    UIButton *button = (UIButton *)sender;
    avatarImage = button.currentBackgroundImage;
    avatarImage = [avatarImage imageByScalingAndCroppingForSize :
                   CGSizeMake(LOGIN_AVATAR_SIZE, LOGIN_AVATAR_SIZE)  ];
    _portraitImage.image = avatarImage; //[UIImage imageNamed : name];
    _LSTopButton.hidden  = FALSE; //User can now proceed...

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
// Upload button...
- (IBAction)uploadSelect:(id)sender
{
   [self displayPhotoPicker];
}

//----LoginViewController---------------------------------
- (IBAction)backSelect:(id)sender {
    BOOL bailit = FALSE;
    
    //This mode has lots of states
    if ([_entryMode containsString : PL_SIGNUP_MODE])
    {
        if (state == 1) //5/27 this is same as "skip"
        {
            [self gotoPageForState:7];
        }
        else if (state == 7) // Bailout page? Return home
        {
            [self gotoPageForState:1];
        }
        else //Just go back one state
        {
            [self gotoPageForState:state-1];
        }
    }
    else //Login /etc mode?
    {
        if (state == 6) // PW reset? back to login
        {
            [self gotoPageForState:5];
        }
    }
    if (bailit) [self dismissViewControllerAnimated : YES completion:nil];
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
        self->avatarImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
        self->avatarImage = [self->avatarImage imageByScalingAndCroppingForSize :
                       CGSizeMake(LOGIN_AVATAR_SIZE, LOGIN_AVATAR_SIZE)  ];
        self->_portraitImage.image = self->avatarImage;
        _LSTopButton.hidden  = FALSE; //User can now proceed...

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
-(void) emailVerifyAlert
{
    [self pixAlertDEBUG:self :@"Email Verification Required" :
        @"Check your email for a new message." :false];
}


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

//======<UITextFieldDelegate>==========================================
- (IBAction)textFieldChanged:(id)sender {
    BOOL gotTop    =  (_topTextField.text.length > 0);
    BOOL gotBottom =  (_bottomTextField.text.length > 0);

    //Handle Next button enable/disable based on filled text fields
    if (state == 2)
    {
        [_LSTopButton setEnabled:gotTop];
    }
    else if (state == 3) //email and password page?
    {
        [_LSTopButton setEnabled:(gotTop & gotBottom)];
    }
    else if (state == 6) //password reset? bottom text entered?
    {
        [_LSTopButton setEnabled:gotTop];
    }

} //end textFieldChanged


//======(PixUtils)==========================================
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

//==========loginTestVC=========================================================================
- (void)loginUser
{
#ifdef IGNOREUSEREVENTS
    [UIApplication.sharedApplication beginIgnoringInteractionEvents];
#endif
    [spv start:@"Logging in..."];
    [PFUser logInWithUsernameInBackground:_userName password:_password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        BOOL bailit = false;
        if (user != nil)
        {
            NSNumber *workn = user[@"emailVerified"];
            BOOL isVerified = [workn boolValue];
            if (!isVerified ) //Check for email verification first!
            {
                [PFUser logOut];
                [self emailVerifyAlert];
            }
            else
            {
                //NSLog(@"user logged in... id %@",PFUser.currentUser.objectId);
                bailit = true;
            }
        }
        else
        {
            [self pixAlertDEBUG:self :@"Error Logging In" : error.localizedDescription :false];
            self->failCount++;
            if (self->failCount > 2) //fail? Offer to reset password
            {
                NSLog(@" three failures!!");
            }
        }
        [self->spv stop];
#ifdef IGNOREUSEREVENTS
        [UIApplication.sharedApplication endIgnoringInteractionEvents];
#endif
        if (bailit)            //all done?
            [self dismissViewControllerAnimated : YES completion:nil];
    }];
}  //end loginUser

//==========loginTestVC=========================================================================
- (void)signupUser
{
    PFUser *user  = [[PFUser alloc] init];
    signupError   = FALSE;
    user.username = _userName;
    user.password = _password;
    user.email    = _emailString;
    NSData *avatarData = UIImagePNGRepresentation(avatarImage);
    PFFile *avatarImageFile = [PFFile fileWithName : @"avatar.png" data:avatarData];
    user[_PuserPortraitKey] = avatarImageFile;
    [spv start : @"Creating your profile"];
    DBBeingAccessed = TRUE;
#ifdef IGNOREUSEREVENTS
    [UIApplication.sharedApplication beginIgnoringInteractionEvents];
#endif
    [user signUpInBackgroundWithBlock:^(BOOL success, NSError * _Nullable error) {
        [self->spv stop];
        self->DBBeingAccessed = FALSE;
        if (error != nil)
        {
            [self pixAlertDEBUG:self :@"Error Signing Up" : error.localizedDescription :false];
            self->signupError = TRUE;
        }
        else
        {
            [self gotoPageForState:self->state+1];
        }

#ifdef IGNOREUSEREVENTS
        [UIApplication.sharedApplication endIgnoringInteractionEvents];
#endif
    }];
}  // end signupUser

//==========loginTestVC=========================================================================
- (BOOL)validateEmailWithString:(NSString*)emailIn
{
    //NSLog(@"validate email %@.....",emailIn);
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailIn];
}

//==========loginTestVC=========================================================================
- (BOOL)validateUsernameWithString:(NSString*)uname
{
    NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
    s = [s invertedSet];
    NSRange r = [uname rangeOfCharacterFromSet:s];
    if (r.location != NSNotFound) {
        return FALSE;
    }
    return TRUE;
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




//===Test Parse Crap



/*-----------------------------------------------------------*/
/*-----------------------------------------------------------*/
double drand(double lo_range,double hi_range )
{
    int rand_int;
    double tempd,outd;
    
    rand_int = rand();
    tempd = (double)rand_int/(double)RAND_MAX;  /* 0.0 <--> 1.0*/
    
    outd = (double)(lo_range + (hi_range-lo_range)*tempd);
    return(outd);
}   //end drand




@end
