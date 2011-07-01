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
#import "PhotoGameAppDelegate.h"
#import "PlayViewController.h"

@interface PhotoGameViewController : UIViewController <UIAlertViewDelegate> {
    UITextField *nameField;
    GameData *gameData;
    NSMutableArray *allImages;
    NSString *myUserName;
    
}

-(IBAction)startGame;
-(IBAction)showEditPhotoView:(id)sender;
-(IBAction)showPlayView:(id)sender;
-(void)loadData;
-(void)findAllImages;
-(NSURL*)getDeviceRandomPhoto;
-(UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)size;

@property (nonatomic, retain) NSMutableArray *allImages;
@property (nonatomic, retain) NSString *myUserName;



@end
