//
//  HowToPlay.h
//  PhotoGame
//
//  Created by Steve Ho on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoGameAppDelegate.h"
#import "PhotoGameViewController.h"

@interface HowToPlay : UIViewController {
    PhotoGameViewController *theParent;    
    IBOutlet UIButton *dontShowCBBtn;
    BOOL showRules;
}

@property (nonatomic, retain) PhotoGameViewController *theParent;
@property (nonatomic, retain) IBOutlet UIButton *dontShowCBBtn;
@property BOOL showRules;

-(IBAction)letsGoBtn;
-(IBAction)dontShowRuleAgainClicked;
- (void)updateShowRules;

@end
