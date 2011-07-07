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
}

@property (nonatomic, retain) PhotoGameViewController *theParent;

-(IBAction)letsGoBtn;

@end
