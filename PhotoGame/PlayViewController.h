//
//  PlayViewController.h
//  PhotoGame
//
//  Created by Steve Ho on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PhotoGameAppDelegate.h"
#import "PhotoGameViewController.h"
#import "SessionManager.h"
#import "Player.h"

#define NEXT_PIC @"Next Pic"
#define PLAY_PIC @"Play Pic"
#define GO_VOTE @"Go Vote"
#define WAITINGX @"Waiting"
#define IMAGE_PREVIEW_SIZE CGSizeMake(320.0f,310.0f)

@interface PlayViewController : UIViewController <GamePlayDelegate, UIAlertViewDelegate> {
    PhotoGameViewController *theParent;
    SessionManager *sessionManager;
    int playPhotoCounter;
    UITextField *photoCaptionTextField;
    UIButton *customeBtn1;
    
    IBOutlet UILabel *scrollViewLabel;
    IBOutlet UILabel *peerLabel;
    IBOutlet UIImageView *seedPhoto;
    IBOutlet UIImageView *unveilPhotoBig;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *previewPhoto;
    IBOutlet UILabel *gamePlayLabel;
    IBOutlet UIButton *startGameBtn;
    IBOutlet UINavigationBar *navBar;
    IBOutlet UIView *imageContainer;
    UINavigationItem *navBarItem;
    UIBarButtonItem *navBarBtnItem;
    UIButton *playPhotoCheckMarkBtn;
    
    //step 1: get seed photo
    //step 2: select a matching photo and submit
    //step 3: viewing play photos - when all have submitted, photos are shown one at a time, controlled by the current seeder
    //step 4: vote
    NSMutableArray *playPhotos; //for seeder to use only
    NSMutableDictionary *players;
    int gameStep;
    int gameRound;
    int unveiledPhotoCounter;
    int unveilResponseCount; //for currentSeeder to keep track of responses
    NSString *currentSeeder; //peerID of the round's seeder
    NSURL *mySeedPhotoURL;
    NSString *iVoteForPeerID;
    NSMutableArray *alreadySeededPhotos;
    UIButton *curSelectedPlayPhoto;
}

-(IBAction)newRoundBtnClicked;
-(void)playPhotoClicked:(id)sender;
-(void)submittedPhotoClicked:(id)sender;
-(void)iVoteForPhoto:(id)sender;

-(void)pickLocalSeedPhoto;
-(void)setupPlayPhotosView;
-(void)setupSubmittedPhotosView;
-(void)setupGame;
-(void)prepareNewRound;
-(void)navBarBtnItemClicked:(id)sender;

@property int unveilResponseCount;
@property int unveiledPhotoCounter;
@property int gameStep;
@property int gameRound;

@property (nonatomic, retain) IBOutlet UIView *imageContainer;
@property (nonatomic, retain) UIButton *playPhotoCheckMarkBtn;
@property (nonatomic, retain) UIButton *customeBtn1;
@property (nonatomic, retain) UIBarButtonItem *navBarBtnItem;
@property (nonatomic, retain) UINavigationItem *navBarItem;
@property (nonatomic, retain) UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UIButton *startGameBtn;
@property (nonatomic, retain) IBOutlet UIImageView *previewPhoto;
@property (nonatomic, retain) IBOutlet UIImageView *unveilPhotoBig;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel *peerLabel;
@property (nonatomic, retain) IBOutlet UILabel *gamePlayLabel;
@property (nonatomic, retain) IBOutlet UIImageView *seedPhoto;
@property (nonatomic, retain) IBOutlet UILabel *scrollViewLabel;
@property (nonatomic, retain) UITextField *photoCaptionTextField;

@property (nonatomic, retain) PhotoGameViewController *theParent;
@property (nonatomic, retain) SessionManager *sessionManager;
@property (nonatomic, retain) NSURL *mySeedPhotoURL;
@property (nonatomic, retain) NSString *iVoteForPeerID;
@property (nonatomic, retain) NSMutableArray *playPhotos;
@property (nonatomic, retain) NSMutableArray *alreadySeededPhotos;
@property (nonatomic, retain) NSMutableDictionary *players;

@property (nonatomic, retain) UIButton *curSelectedPlayPhoto;

@end
