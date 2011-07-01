//
//  PlayViewController.h
//  PhotoGame
//
//  Created by Steve Ho on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoGameAppDelegate.h"
#import "PhotoGameViewController.h"
#import "SessionManager.h"

@interface PlayViewController : UIViewController <GamePlayDelegate> {
    PhotoGameViewController *theParent;
    SessionManager *sessionManager;
    IBOutlet UILabel *peerLabel;
    IBOutlet UIImageView *seedPhoto;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *previewPhoto;
    int playPhotoCounter;
}

-(IBAction)newSeedPhoto;
-(void)setupPlayPhotos;

@property (nonatomic, retain) IBOutlet UIImageView *previewPhoto;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel *peerLabel;
@property (nonatomic, retain) PhotoGameViewController *theParent;
@property (nonatomic, retain) SessionManager *sessionManager;
@property (nonatomic, retain) IBOutlet UIImageView *seedPhoto;

@end
