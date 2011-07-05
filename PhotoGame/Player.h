//
//  Player.h
//  PhotoGame
//
//  Created by Steve Ho on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Player : NSObject {
    NSString *name;
    UIImage *roundPhoto;
    int roundVotes;
    NSString *roundVotedFor;
    NSString *roundPhotoCaption;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) UIImage *roundPhoto;
@property int roundVotes;
@property (nonatomic, retain) NSString *roundVotedFor;
@property (nonatomic, retain) NSString *roundPhotoCaption;

@end