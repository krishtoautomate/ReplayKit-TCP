//
//  SampleHandler.m
//  extension
//
//  Created by farhanahmed on 24/08/2022.
//


#import "SampleHandler.h"
#import <sys/utsname.h>
@interface SampleHandler (GCDAsyncSocketDelegate)
@end

@implementation SampleHandler

VTCompressionOutputHandler outputHandler;
bool isWriting = false;

-(NSString*) deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    
//    int port = [[[NSProcessInfo processInfo] environment] objectForKey: @"PORT"].intValue;
//    if(port <= 0) {
//        port = self.port;
//    }else {
//        self.port = port;
//    }
    
    self.port = 8000;
    
    NSString *model = [self deviceName];
    
    bool flipOrientation = false;
    if ([model  isEqual: @"iPad14,1"] || [model  isEqual: @"iPad14,2"] ) {
        flipOrientation = true;
    }
    
    self.tcpServer = [[FBTCPSocket alloc] initWithPort:self.port];
    self.tcpServer.delegate = [[FBMjpegServer alloc] init];
    [self.tcpServer startWithError:nil];
    CGSize size = [[UIScreen mainScreen]bounds].size;
    VTCompressionSessionRef session;
    OSStatus error = VTCompressionSessionCreate(kCFAllocatorDefault,
                                                (flipOrientation ? size.height: size.width) - 1,
                                                (flipOrientation ? size.width : size.height) - 1,
                                                kCMVideoCodecType_JPEG,
                                                nil,
                                                nil,
                                                nil,
                                                nil,
                                                nil,
                                                &session);
    
    self.session = session;
    
    if (error != 0) {
        NSLog(@"Unable to create a VTCompressionSessionCreate");
    }
    
    CGFloat qty = [[[NSProcessInfo processInfo] environment] objectForKey: @"QTY"].floatValue;
    if (!qty) {
        qty = 0.70;
    }
    
    if (VTSessionSetProperty(self.session, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue) != 0) {
        NSLog(@"Unable to set a VTSessionSetProperty: kVTCompressionPropertyKey_RealTime");
        return;
    }
    
    if (VTSessionSetProperty(self.session, kVTCompressionPropertyKey_Quality, CFNumberCreate(kCFAllocatorDefault, kCFNumberCGFloatType, &qty)) != 0) {
        NSLog(@"Unable to set a VTSessionSetProperty: kVTCompressionPropertyKey_Quality");
        return;
    }
    
    outputHandler = ^(OSStatus status, VTEncodeInfoFlags infoFlags, CMSampleBufferRef  _Nullable sampleBuffer) {
        
        
        if(status != noErr) {
            NSLog(@"JPEG: VTCompressionSessionEncodeFrame failed with %d", status);
            return;
        }
        
        if (sampleBuffer == nil) {
            NSLog(@"VTCompressionSessionEncodeFrameWithOutputHandler sampleBuffer nil");
            return;
        }
        
        if (!CMSampleBufferDataIsReady(sampleBuffer))
        {
            NSLog(@"frame data is not ready ");
            return;
        }
        
        CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
        
        char *dataPointerOut;
        size_t lengthAtOffsetOut;
        size_t totalLengthOut;
        
        OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer, 0, &lengthAtOffsetOut, &totalLengthOut, &dataPointerOut);
        
        if(statusCodeRet != kCMBlockBufferNoErr)
        {
            NSLog(@"kCMBlockBufferErr");
            return;
        }
        
        NSData *screenshotData = [[NSData alloc] initWithBytes:dataPointerOut length: totalLengthOut];
        
        [[self.tcpServer delegate] set:screenshotData and: [self orientation]];
    };
}

- (void)broadcastPaused {
    
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    if(self.session) {
        VTCompressionSessionInvalidate(self.session);
        self.session = nil;
    }
    
    if(self.tcpServer) {
        [self.tcpServer stop];
    }
    
    isWriting = false;
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    
    @synchronized(self) {
        
        if (isWriting) {
            //NSLog(@"Skip Frame");
            return;
        }
    }
    if (sampleBufferType != RPSampleBufferTypeVideo) {
        return;
    }
    
    CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    if (imageBuffer == nil || self.session == nil) {
        return;
    }
    
    CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    
    CFStringRef RPVideoSampleOrientationKeyRef = (__bridge CFStringRef)RPVideoSampleOrientationKey;

    NSNumber *orientation = (NSNumber *) CMGetAttachment(sampleBuffer, RPVideoSampleOrientationKeyRef, nil);
    
    [self setOrientation: orientation];

    NSLog(@"info:%@", orientation);
    
    VTCompressionSessionEncodeFrameWithOutputHandler(self.session, imageBuffer, time, kCMTimeInvalid, nil, nil, outputHandler);
}


@end
