//
//  PhotoGameAppDelegate.h
//  PhotoGame
//
//  Created by Steve Ho on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoGameViewController;

@interface PhotoGameAppDelegate : NSObject <UIApplicationDelegate> {    
    PhotoGameViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet PhotoGameViewController *viewController;

- (void)switchView:(UIView*)fromView to:(UIView*)toView;

@end
