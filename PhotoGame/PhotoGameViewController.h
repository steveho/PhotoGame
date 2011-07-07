//
//  PhotoGameViewController.h
//  PhotoGame
//
//  Created by Steve Ho on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "GameData.h"
#import "PhotosViewController.h"
#import "PlayViewController.h"
#import "PhotoGameAppDelegate.h"
#import "HowToPlay.h"

@interface PhotoGameViewController : UIViewController <UIAlertViewDelegate> {
    UITextField *nameField;
    GameData *gameData;
    NSMutableArray *allImages;
    NSMutableString *myUserName;
    NSMutableArray *playImages;
    
    NSMutableDictionary *views;
}

-(IBAction)startGame;
-(IBAction)showEditPhotoView:(id)sender;
-(IBAction)showPlayView:(id)sender;
-(IBAction)showHowToPlay:(id)sender;
-(void)loadData;
-(void)findAllImages;
-(NSURL*)getDeviceRandomPhoto;
-(UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)size;
-(void)getRandomPlayPhotos;

@property (nonatomic, retain) NSMutableDictionary *views;
@property (nonatomic, retain) NSMutableArray *allImages;
@property (nonatomic, retain) NSMutableString *myUserName;
@property (nonatomic, retain) NSMutableArray *playImages;
@property (nonatomic, retain) GameData *gameData;

@end
