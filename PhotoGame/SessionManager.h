//
//  SessionManager.h
//  PhotoGame
//
//  Created by Steve Ho on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h> 

typedef enum {
    PacketTypeQueryNeedSeedPhoto = 0,
    PacketTypeDataSeedPhoto = 1
} PacketType;

@interface SessionManager : NSObject <GKSessionDelegate> {
	GKSession *mySession;
    NSMutableArray *playerList;
    id delegate;
}

@property (nonatomic, retain) GKSession *mySession;
@property (nonatomic, retain) NSMutableArray *playerList;
@property (nonatomic, assign) id delegate;


- (void)setupSession;
- (void)sendData:(NSData*)data ofType:(PacketType)type to:(NSArray*)peers;

@end



@protocol GamePlayDelegate

- (void)peerListDidChange:(SessionManager *)session;
- (void)sendSeedPhotoToPeer:(NSString*)peerID;
- (void)setLocalSeedPhoto:(UIImage*)img;
- (UIImage*)getLocalSeedPhoto;

@end