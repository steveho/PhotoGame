//
//  Player.m
//  PhotoGame
//
//  Created by Steve Ho on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Player.h"


@implementation Player

@synthesize name, roundPhoto, roundVotes;
@synthesize roundVotedFor;


- (id) init {
    if ((self = [super init])) {
        name = nil;
        roundPhoto = nil;
        roundVotes = 0;
        roundVotedFor = nil;
    }
    return self;
}

- (void)dealloc {
    name = nil;
    roundPhoto = nil;
    roundVotedFor = nil;
    [super dealloc];
}

@end
