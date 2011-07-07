//
//  PhotosViewController.h
//  PhotoGame
//
//  Created by Steve Ho on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotoGameViewController.h"
#import "PhotoGameAppDelegate.h"

@interface PhotosViewController : UIViewController {
    IBOutlet UIButton *imgBtn0;
    IBOutlet UIButton *imgBtn1;
    IBOutlet UIButton *imgBtn2;
    IBOutlet UIButton *imgBtn3;
    IBOutlet UIButton *imgBtn4;
    IBOutlet UIButton *imgBtn5;
    IBOutlet UIButton *imgBtn6;
    IBOutlet UIButton *imgBtn7;
    IBOutlet UIButton *imgBtn8;
    IBOutlet UIButton *imgBtn9;
    IBOutlet UIButton *imgBtn10;
    IBOutlet UIButton *imgBtn11;
    IBOutlet UIButton *imgBtn12;
    IBOutlet UIButton *imgBtn13;
    IBOutlet UIButton *imgBtn14;
    IBOutlet UIButton *imgBtn15;

    PhotoGameViewController *theParent;    
}

@property (nonatomic, retain) IBOutlet UIButton *imgBtn0;
@property (nonatomic, retain) IBOutlet UIButton *imgBtn1;
@property (nonatomic, retain) IBOutlet UIButton *imgBtn2;
@property (nonatomic, retain) IBOutlet UIButton *imgBtn3;
@property (nonatomic, retain) IBOutlet UIButton *imgBtn4;
@property (nonatomic, retain) IBOutlet UIButton *imgBtn5;
@property (nonatomic, retain) IBOutlet UIButton *imgBtn6;
@property (nonatomic, retain) IBOutlet UIButton *imgBtn7;
@property (nonatomic, retain) IBOutlet UIButton *imgBtn8;
@property (nonatomic, retain) IBOutlet UIButton *imgBtn9;
@property (nonatomic, retain) IBOutlet UIButton *imgBtn10;
@property (nonatomic, retain) IBOutlet UIButton *imgBtn11;
@property (nonatomic, retain) IBOutlet UIButton *imgBtn12;
@property (nonatomic, retain) IBOutlet UIButton *imgBtn13;
@property (nonatomic, retain) IBOutlet UIButton *imgBtn14;
@property (nonatomic, retain) IBOutlet UIButton *imgBtn15;

@property (nonatomic, retain) PhotoGameViewController *theParent;

-(BOOL)addImageToGrid:(UIImage*)img;
-(IBAction)showHomeView:(id)sender;
-(void)populatePlayPhotoGrid;
-(void)recreatedRandomPhotos;
-(void)setupGrid;

@end
