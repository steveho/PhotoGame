//
//  GameData.m
//  PhotoGame
//
//  Created by Steve Ho on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameData.h"


@implementation GameData


@synthesize images;

- (id)init {
    self = [super init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];        
    NSString *path = [[NSString alloc] initWithFormat:@"%@/%@", directory, DATA_FILE_NAME];        
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [self release];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:path]];
        
        self = [[GameData alloc] initWithCoder:unarchiver];
        
        [unarchiver finishDecoding];
        [unarchiver release]; 
    }
    [path release];
    
    if(images == nil) {
        images = [[NSMutableArray alloc] initWithCapacity:16];
    }
    
    return self;
}

- (void)saveToFile {    
    NSMutableData *fileData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:fileData];
    [self encodeWithCoder:archiver];
    [archiver finishEncoding];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];    
    NSString *path = [[NSString alloc] initWithFormat:@"%@/%@", directory, DATA_FILE_NAME];
    
    [fileData writeToFile:path atomically:YES];
    
    [archiver release];
    [path release];
}

- (void)deleteFile {
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];    
    NSString *path = [[NSString alloc] initWithFormat:@"%@/%@", directory, DATA_FILE_NAME];
    
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if (!success) {
        NSLog(@"Error removing document path: %@", error.localizedDescription);
    }    
    
    [path release];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    images = [aDecoder decodeObjectForKey:@"images"];
    userName = [aDecoder decodeObjectForKey:@"userName"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:images forKey:@"images"];
    [aCoder encodeObject:userName forKey:@"userName"];
}

- (void)setUserName:(NSMutableString *)name {
    userName = name;
}
- (NSMutableString*)getUserName {
    return userName;
}

@end

