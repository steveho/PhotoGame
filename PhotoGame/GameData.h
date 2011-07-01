//
//  GameData.h
//  PhotoGame
//
//  Created by Steve Ho on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATA_FILE_NAME @"GameData"

@interface GameData : NSObject <NSCoding> {
    NSMutableArray *images;
    NSMutableString *userName;
}

@property (nonatomic, retain) NSMutableArray *images;

- (id)init;
- (void)saveToFile;
- (void)deleteFile;
- (void)setUserName:(NSMutableString*)name;
- (NSMutableString*)getUserName;

@end

