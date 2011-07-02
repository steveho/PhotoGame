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
    PacketTypeDataSeedPhoto = 1,
    PacketTypeDataPlayPhoto = 2,
    PacketTypeDataPlayerName = 3,
    PacketTypeDataPlayerStarted = 4
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

- (void)peerListDidChange:(SessionManager *)session peer:(NSString*)peerID;
- (void)sendDataToPeer:(NSString*)peerID type:(PacketType)type data:(NSData*)data;
- (void)sendSeedPhotoToPeer:(NSString*)peerID;
- (void)sendBasicInfoToPeer:(NSString*)peerID;
- (void)setLocalSeedPhoto:(UIImage*)img;
- (UIImage*)getLocalSeedPhoto;

- (void)updatePlayerInfo:(NSString*)peerID started:(NSString*)date;
- (void)updatePlayerInfo:(NSString*)peerID name:(NSString*)name;
- (void)updatePlayerInfo:(NSString*)peerID currentPlayPhoto:(UIImage*)value;
- (void)updatePlayerInfo:(NSString*)peerID currentPlayVotes:(int)value;

- (void)updateGameHost;
- (void)startNewGameRound;

@end