/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBMjpegServer.h"

#import <mach/mach_time.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "GCDAsyncSocket.h"

static const NSUInteger MAX_FPS = 60;
static const NSTimeInterval FRAME_TIMEOUT = 1.;

static NSString *const SERVER_NAME = @"WDA MJPEG Server";
static const char *QUEUE_NAME = "JPEG Screenshots Provider Queue";


@interface FBMjpegServer()

@property (nonatomic, readonly) dispatch_queue_t backgroundQueue;
@property (nonatomic, readonly) NSMutableArray<GCDAsyncSocket *> *listeningClients;
@property (nonatomic, readonly) mach_timebase_info_data_t timebaseInfo;
@property (nonatomic, readonly) long long mainScreenID;
@property (nonatomic) const NSData * screenshotData;
@property (nonatomic) const NSNumber * orientation;

@end


@implementation FBMjpegServer

- (instancetype)init
{
    if ((self = [super init])) {
        _screenshotData = [[NSData alloc] init];
        _listeningClients = [NSMutableArray array];
        dispatch_queue_attr_t queueAttributes = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0);
        _backgroundQueue = dispatch_queue_create(QUEUE_NAME, queueAttributes);
        mach_timebase_info(&_timebaseInfo);
        dispatch_async(_backgroundQueue, ^{
            [self streamScreenshot];
        });
        
    }
    return self;
}

- (void)scheduleNextScreenshotWithInterval:(uint64_t)timerInterval timeStarted:(uint64_t)timeStarted
{
    uint64_t timeElapsed = mach_absolute_time() - timeStarted;
    int64_t nextTickDelta = timerInterval - timeElapsed * self.timebaseInfo.numer / self.timebaseInfo.denom;
    if (nextTickDelta > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, nextTickDelta), self.backgroundQueue, ^{
            [self streamScreenshot];
        });
    } else {
        // Try to do our best to keep the FPS at a decent level
        dispatch_async(self.backgroundQueue, ^{
            [self streamScreenshot];
        });
    }
}

- (void)streamScreenshot
{
    if (![self.class canStreamScreenshots]) {
        return;
    }
    
    NSUInteger framerate = 24;//FBConfiguration.mjpegServerFramerate;
    uint64_t timerInterval = (uint64_t)(1.0 / ((0 == framerate || framerate > MAX_FPS) ? MAX_FPS : framerate) * NSEC_PER_SEC);
    
    uint64_t timeStarted = mach_absolute_time();
    @synchronized (self.listeningClients) {
        if (0 == self.listeningClients.count) {
            [self scheduleNextScreenshotWithInterval:timerInterval timeStarted:timeStarted];
            return;
        }
    }
    
    @synchronized (self) {
        if (nil == _screenshotData || _screenshotData.length == 0 || _orientation == nil) {
            
            [self scheduleNextScreenshotWithInterval:timerInterval timeStarted:timeStarted];
            return;
        }
        
        [self sendScreenshot: _screenshotData and: _orientation];
        
        
        [self scheduleNextScreenshotWithInterval:timerInterval timeStarted:timeStarted];
    }
}


- (void)sendScreenshot:(NSData *)screenshotData and: (NSNumber * ) orientation {
    
   
    @synchronized (self.listeningClients) {
        for (GCDAsyncSocket *client in self.listeningClients) {
            NSString *chunkHeader = nil;
            
            if(client.isHeadRequest)
            {
                chunkHeader = [NSString stringWithFormat:@"--BoundaryString\r\nContent-type: image/jpg\r\nX-Orientation: %@\r\n\r\n", orientation];
                
                NSMutableData *chunk = [[chunkHeader dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                [chunk appendData:(id)[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [client writeData:chunk withTimeout:-1 tag:0];
                
            } else {
                chunkHeader = [NSString stringWithFormat:@"--BoundaryString\r\nContent-type: image/jpg\r\nContent-Length: %@\r\n\r\n", @(screenshotData.length)];
                NSMutableData *chunk = [[chunkHeader dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                [chunk appendData:screenshotData];
                [chunk appendData:(id)[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [client writeData:chunk withTimeout:-1 tag:0];
            }
            
        }
    }
}

+ (BOOL)canStreamScreenshots
{
    return true;
}

- (void)didClientConnect:(GCDAsyncSocket *)newClient
{
    
    // Start broadcast only after there is any data from the client
    [newClient readDataWithTimeout:-1 tag:0];
}

- (void)did:(GCDAsyncSocket *)client Send:(NSData *)data {
   
    @synchronized (self.listeningClients) {
        if ([self.listeningClients containsObject:client]) {
            return;
        }
    }
    
    NSString *request = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    
    NSString *streamHeader = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nServer: %@\r\nConnection: close\r\nMax-Age: 0\r\nExpires: 0\r\nCache-Control: no-cache, private\r\nPragma: no-cache\r\nAccess-Control-Allow-Origin: *\r\nContent-Type: multipart/x-mixed-replace; boundary=--BoundaryString\r\n\r\n", SERVER_NAME];
    [client writeData:(id)[streamHeader dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    @synchronized (self.listeningClients) {
        
        [client setIsHeadRequest: [request containsString: @"/info"]];
        
        [self.listeningClients addObject:client];
    }
}


- (void)didClientDisconnect:(GCDAsyncSocket *)client
{
    @synchronized (self.listeningClients) {
        [self.listeningClients removeObject:client];
    }
}

- (void)set:(NSData *)data and: (NSNumber *) orientation {
    @synchronized (self) {
        self.screenshotData  = data;
        self.orientation = orientation;
    }
}

@end
