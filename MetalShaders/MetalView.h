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


@property (strong,nonatomic) NSDate *timer;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)stopRender;
- (void)configurePipelineWithFragmentShader:(NSString *)fragmentShaderName;

@end
