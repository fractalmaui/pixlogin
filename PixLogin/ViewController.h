//
//  ViewController.h
//  PixLogin
//
//  Created by Dave Scruton on 5/21/18.
//  Copyright © 2018 huedoku. All rights reserved.
//
//  Parse URL http://ec2-52-42-95-208.us-west-2.compute.amazonaws.com
//  Login to server Shell...
//  ssh -i "InstashamiOSKeyPair.pem" ubuntu@ec2-52-42-95-208.us-west-2.compute.amazonaws.com
//    ....pem file must be wherever you launch from!
//   NOTE: Changes EVERY TIME you restart!
//    davesky/dogdog12!
// Test Login (NOT FOR PARSE CONSOLE BUT FOR APP)
//     dave@dog.com / dogdog12!
// DHS 6/12 Ran npm install for mailgun, must run from this folder:
//    /home/bitnami/apps/parse/conf
//    npm install --save parse-server-mailgun
//
// mailgun test:
//   https://www.npmjs.com/package/parse-server-mailgun
//  I set up json folder here:
//      /home/bitnami/node_modules/parse-server-mailgun
// {
//     "apiKey" : "47317c98-35c12b4c",
//     "fromAddress" :"info@huedoku.com",
//     "domain" : "huedoku.com",
//     "recipient" : "fraktalmaui@gmail.com",
//     "username" : "info@huedoku.com",
//     "appName" : "Huedoku Pix"
// }

//    here's the test:
//      node ./src/mailgun-tester
//  it runs but returns an error:
//{ Error: Forbidden
//    at IncomingMessage.res.on (/home/bitnami/node_modules/mailgun-js/lib/request.js:311:17)
//    at emitNone (events.js:111:20)
//   ...etc
//  I assume this is a configuration error since we aren't fully set up in  mailgun
//  domain verify?
//    https://app.mailgun.com/app/domains/www.huedoku.com/verify
// Another example, can't figure out how to change parse config though...
//  https://androidexamples4u.wordpress.com/projects/mailgun-integration-parseserver/
// WHERE is the index.js file that I need to change??

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "LoginViewController.h"
@interface ViewController : UIViewController
{
    BOOL signedUp;
}
@property (weak, nonatomic) IBOutlet UILabel *instrsLabel;
- (IBAction)loginSelect:(id)sender;
- (IBAction)signupSelect:(id)sender;
- (IBAction)avatarSelect:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;


@end

