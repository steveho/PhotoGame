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
    int playPhotoCounter;
    
    IBOutlet UILabel *peerLabel;
    IBOutlet UIImageView *seedPhoto;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *previewPhoto;
    IBOutlet UILabel *gamePlayLabel;
    IBOutlet UIActivityIndicatorView *seedPhotoLoading;
    IBOutlet UIButton *newRoundBtn;
    IBOutlet UIButton *playPhotoBtn;

    //step 1: get seed photo
    //step 2: select a matching photo and submit
    NSMutableDictionary *players;
    int gameStep;
    int gameRound;
    NSString *currentSeeder; //peerID of the round's seeder
    NSURL *mySeedPhotoURL;
}

-(IBAction)newRoundBtnClicked;
-(IBAction)playPhotoBtnClicked;
-(void)playPhotoClicked:(id)sender;
-(void)submittedPhotoClicked:(id)sender;

-(void)pickLocalSeedPhoto;
-(void)setupPlayPhotosView;
-(void)setupSubmittedPhotosView;
-(void)setupGame;
- (void)sendPlayPhotoToPeer:(NSString*)peerID image:(UIImage*)img;



@property int gameStep;
@property int gameRound;
@property (nonatomic, retain) IBOutlet UIButton *newRoundBtn;
@property (nonatomic, retain) IBOutlet UIButton *playPhotoBtn;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *seedPhotoLoading;
@property (nonatomic, retain) IBOutlet UIImageView *previewPhoto;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel *peerLabel;
@property (nonatomic, retain) IBOutlet UILabel *gamePlayLabel;
@property (nonatomic, retain) PhotoGameViewController *theParent;
@property (nonatomic, retain) SessionManager *sessionManager;
@property (nonatomic, retain) IBOutlet UIImageView *seedPhoto;
@property (nonatomic, retain) NSURL *mySeedPhotoURL;

@property (nonatomic, retain) NSMutableDictionary *players;

@end
