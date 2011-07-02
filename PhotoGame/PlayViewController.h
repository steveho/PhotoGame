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
#import "Player.h"

@interface PlayViewController : UIViewController <GamePlayDelegate> {
    PhotoGameViewController *theParent;
    SessionManager *sessionManager;
    IBOutlet UILabel *peerLabel;
    IBOutlet UIImageView *seedPhoto;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *previewPhoto;
    IBOutlet UILabel *gamePlayLabel;
    IBOutlet UIActivityIndicatorView *seedPhotoLoading;
    int playPhotoCounter;
    
    NSMutableDictionary *players;
    NSString *gameHostID;
}

-(IBAction)playPhotoBtnClicked;
-(IBAction)newSeedPhoto;
-(void)setupPlayPhotosView;
-(void)setupSubmittedPhotosView;
-(void)setupGame;

- (void)sendPlayPhotoToPeer:(NSString*)peerID image:(UIImage*)img;

@property (nonatomic, retain) NSString *gameHostID;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *seedPhotoLoading;
@property (nonatomic, retain) IBOutlet UIImageView *previewPhoto;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel *peerLabel;
@property (nonatomic, retain) IBOutlet UILabel *gamePlayLabel;
@property (nonatomic, retain) PhotoGameViewController *theParent;
@property (nonatomic, retain) SessionManager *sessionManager;
@property (nonatomic, retain) IBOutlet UIImageView *seedPhoto;

@property (nonatomic, retain) NSMutableDictionary *players;

@end
