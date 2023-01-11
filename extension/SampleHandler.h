//
//  SampleHandler.h
//  extension
//
//  Created by farhanahmed on 24/08/2022.
//
@import VideoToolbox;

#import <ReplayKit/ReplayKit.h>
#import "GCDAsyncSocket.h" // for TCP
#import <VideoToolbox/VTCompressionSession.h>
#include "GCDAsyncSocket.h"
#include "FBTCPSocket.h"
#include "FBMjpegServer.h"

@interface SampleHandler : RPBroadcastSampleHandler
@property (nonatomic) FBTCPSocket *tcpServer;
@property (nonatomic) uint16_t port;
@property (nonatomic) VTCompressionSessionRef session;
@property (nonatomic) NSNumber *orientation;

@end
