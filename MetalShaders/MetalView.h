//
//  MetalView.h
//  
//
//  Created by Lixuan Zhu on 5/27/15.
//
//
#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>

@interface MetalView : UIView

@property (strong,nonatomic) id<MTLDevice> device;
@property (strong,nonatomic) CAMetalLayer *metalLayer;
@property (strong,nonatomic) id<MTLBuffer> positionBuffer;
@property (strong,nonatomic) id<MTLBuffer> colorBuffer;
@property (strong,nonatomic) id<MTLBuffer> resolutionBuffer;

@property (strong,nonatomic) id<MTLRenderPipelineState> pipleline;
@property (strong,nonatomic) CADisplayLink *displayLink;

@property (strong,nonatomic) NSDate *timer;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)stopRender;
- (void)configurePipelineWithFragmentShader:(NSString *)fragmentShaderName;

@end
