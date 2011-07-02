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
    UIImage *currentPlayPhoto;
    int currentPlayVotes;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) UIImage *currentPlayPhoto;
@property int currentPlayVotes;

@end
