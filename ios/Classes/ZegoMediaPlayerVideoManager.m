//
//  ZegoMediaPlayerVideoManager.m
//  Pods-Runner
//
//  Created by 27 on 2023/2/2.
//

#import "ZegoMediaPlayerVideoManager.h"
#import "ZegoTextureRendererController.h"
#import "ZegoExpressEngineMethodHandler.h"
#import "ZegoLog.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZegoMediaPlayerVideoManager()<ZegoMediaPlayerVideoHandler>

@property (nonatomic, weak) id<ZegoFlutterMediaPlayerVideoHandler> handler;

@end

@implementation ZegoMediaPlayerVideoManager

+ (instancetype)sharedInstance {
    static ZegoMediaPlayerVideoManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZegoMediaPlayerVideoManager alloc] init];
    });
    return instance;
}

-(void)setVideoHandler:(id<ZegoFlutterMediaPlayerVideoHandler>)handler {
    
    self.handler = handler;
}

-(id<ZegoFlutterMediaPlayerVideoHandler>_Nullable)getMediaPlayerVideoHandler {
    return self.handler;
}

- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer
    videoFramePixelBuffer:(CVPixelBufferRef)buffer
              param:(ZegoVideoFrameParam *)param {
    if([self.handler respondsToSelector:@selector(mediaPlayer:videoFramePixelBuffer:param:)]) {
        VideoFrameParam *videoFrameParam = [[VideoFrameParam alloc] init];
        videoFrameParam.size = param.size;
        videoFrameParam.format = (VideoFrameFormat)param.format;
        videoFrameParam.rotation = param.rotation;
        videoFrameParam.strides = malloc(sizeof(int)*4);
        for (int i = 0; i < 4; i++) {
            videoFrameParam.strides[i] = param.strides[i];
        }
        
        [self.handler mediaPlayer:[mediaPlayer.index intValue] videoFramePixelBuffer:buffer param:videoFrameParam];
    }
}

- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer
    videoFramePixelBuffer:(CVPixelBufferRef)buffer
                    param:(ZegoVideoFrameParam *)param
          extraInfo:(NSDictionary *)extraInfo {
    if([self.handler respondsToSelector:@selector(mediaPlayer:videoFramePixelBuffer:param:extraInfo:)]) {
        VideoFrameParam *videoFrameParam = [[VideoFrameParam alloc] init];
        videoFrameParam.size = param.size;
        videoFrameParam.format = (VideoFrameFormat)param.format;
        videoFrameParam.rotation = param.rotation;
        videoFrameParam.strides = malloc(sizeof(int)*4);
        for (int i = 0; i < 4; i++) {
            videoFrameParam.strides[i] = param.strides[i];
        }
        
        [self.handler mediaPlayer:[mediaPlayer.index intValue] videoFramePixelBuffer:buffer param:videoFrameParam extraInfo:extraInfo];
    }
}

@end
