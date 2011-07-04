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

@interface PlayViewController : UIViewController <GamePlayDelegate> {
    PhotoGameViewController *theParent;
    SessionManager *sessionManager;
    int playPhotoCounter;
    
    IBOutlet UILabel *scrollViewLabel;
    IBOutlet UILabel *peerLabel;
    IBOutlet UIImageView *seedPhoto;
    IBOutlet UIImageView *unveilPhotoBig;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *previewPhoto;
    IBOutlet UILabel *gamePlayLabel;
    IBOutlet UIButton *newRoundBtn;
    IBOutlet UIButton *playPhotoBtn;
    IBOutlet UIButton *nextPhotoBtn;

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
}

-(IBAction)nextPhotoBtnClicked;
-(IBAction)newRoundBtnClicked;
-(IBAction)playPhotoBtnClicked;
-(void)playPhotoClicked:(id)sender;
-(void)submittedPhotoClicked:(id)sender;
-(void)iVoteForPhoto:(id)sender;

-(void)pickLocalSeedPhoto;
-(void)setupPlayPhotosView;
-(void)setupSubmittedPhotosView;
-(void)setupGame;
- (void)sendPlayPhotoToPeer:(NSString*)peerID image:(UIImage*)img;

@property int unveilResponseCount;
@property int unveiledPhotoCounter;
@property int gameStep;
@property int gameRound;
@property (nonatomic, retain) IBOutlet UIButton *newRoundBtn;
@property (nonatomic, retain) IBOutlet UIButton *playPhotoBtn;
@property (nonatomic, retain) IBOutlet UIImageView *previewPhoto;
@property (nonatomic, retain) IBOutlet UIImageView *unveilPhotoBig;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel *peerLabel;
@property (nonatomic, retain) IBOutlet UILabel *gamePlayLabel;
@property (nonatomic, retain) IBOutlet UIImageView *seedPhoto;
@property (nonatomic, retain) IBOutlet UIButton *nextPhotoBtn;
@property (nonatomic, retain) IBOutlet UILabel *scrollViewLabel;

@property (nonatomic, retain) PhotoGameViewController *theParent;
@property (nonatomic, retain) SessionManager *sessionManager;
@property (nonatomic, retain) NSURL *mySeedPhotoURL;
@property (nonatomic, retain) NSString *iVoteForPeerID;
@property (nonatomic, retain) NSMutableArray *playPhotos;

@property (nonatomic, retain) NSMutableDictionary *players;

@end
