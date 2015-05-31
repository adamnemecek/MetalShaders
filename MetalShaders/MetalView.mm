//
//  MetalView.m
//  
//
//  Created by Lixuan Zhu on 5/27/15.
//
//

#import "MetalView.h"
#import <simd/simd.h>

struct FragmentUniform {
    simd::float2 resolution;
    float time;
};

@implementation MetalView

+ (id)layerClass {
    return [CAMetalLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        //po[self setUp];
    }
    return self;
}

- (void)awakeFromNib {

}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setUp];
}

- (void)setUp {
    self.timer = [NSDate date];
    [self setUpMetalLayer];
    [self buildVertexBuffers];
    [self configurePipelineWithFragmentShader:@"fragment_main"];
}

- (void)stopRender {
    [self invalideDisplayLink];
}

- (void)configurePipelineWithFragmentShader:(NSString *)fragmentShaderName {
    [self buildPipeLineWithVertexShader:@"vertex_main" fragmentShader:fragmentShaderName];
}

- (void)setUpMetalLayer {
    // Get GPU
    self.device = MTLCreateSystemDefaultDevice();
    // Configure MetalLayer
    self.metalLayer.device = self.device;
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    self.metalLayer = (CAMetalLayer *)self.layer;
}

- (void)setUpDisplayLink {
    if (self.displayLink == nil) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLinkCalled:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)invalideDisplayLink {
    if (self.displayLink != nil) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)buildVertexBuffers {
    static const float positions[] = {-1.0, 1.0, 0, 1,
                                      -1.0,-1.0, 0, 1,
                                       1.0, 1.0, 0, 1,
                                       1.0, 1.0, 0, 1,
                                      -1.0,-1.0, 0, 1,
                                       1.0,-1.0, 0, 1,};

    static const float colors[] = {1.0, 0.0, 0.0, 1,
                                   0.5, 1.0, 0.0, 1,
                                   0.0, 0.0, 1.0, 1,
                                   0.0, 0.0, 1.0, 1,
                                   0.0, 1.0, 0.0, 1,
                                   0.5, 0.5, 0.5, 1};

    FragmentUniform *u = new FragmentUniform();
    u->resolution = {static_cast<float>(self.bounds.size.width),static_cast<float>(self.bounds.size.height)};
    u->time = [self.timer timeIntervalSinceNow];


    self.positionBuffer = [self.device newBufferWithBytes:positions
                                                   length:sizeof(positions)
                                                  options:MTLResourceOptionCPUCacheModeDefault];

    self.colorBuffer = [self.device newBufferWithBytes:colors
                                                length:sizeof(colors)
                                               options:MTLResourceOptionCPUCacheModeDefault];

    self.resolutionBuffer = [self.device newBufferWithBytes:u
                                                     length:sizeof(FragmentUniform)
                                                    options:MTLResourceOptionCPUCacheModeDefault];
}

- (void)buildPipeLineWithVertexShader:(NSString *)vertexShader
                       fragmentShader:(NSString *)fragmentShader {
    // Get library which contains all metal functions
    id<MTLLibrary> library = [self.device newDefaultLibrary];
    id<MTLFunction> vertexFunction = [library newFunctionWithName:vertexShader];
    id<MTLFunction> fragmentFunction = [library newFunctionWithName:fragmentShader];

    // Create Pipeline Descriptor
    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.vertexFunction = vertexFunction;
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    pipelineDescriptor.colorAttachments[0].pixelFormat = self.metalLayer.pixelFormat;

    // Create Pipeline
    self.pipleline = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                                                                 error:NULL];
}

// Display Link
- (void)didMoveToWindow {
    [super didMoveToSuperview];
    if (self.superview) {
        [self setUpDisplayLink];
    }
    else {
        [self invalideDisplayLink];
    }
}

// Call back for each display link signal
- (void)onDisplayLinkCalled:(CADisplayLink *)displayLink {
    [self buildVertexBuffers];
    [self redraw];
}

// Metal Rendering Pass
- (void)redraw {
    // Acquire Drawable
    id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
    id<MTLTexture> texture = drawable.texture;

    // Configure render pass
    MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    passDescriptor.colorAttachments[0].texture = texture;
    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 0.5, 0.5,1.0);

    // Metal Commands
    // encoder -> buffer -> queue
    id<MTLCommandQueue> commandQueue = [self.device newCommandQueue];
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
    // Configure encoder
    [encoder setRenderPipelineState:self.pipleline];
    [encoder setVertexBuffer:self.positionBuffer offset:0 atIndex:0];
    [encoder setVertexBuffer:self.colorBuffer offset:0 atIndex:1];
    [encoder setFragmentBuffer:self.resolutionBuffer offset:0 atIndex:0];

    // start issue commands
    [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6 instanceCount:1];
    [encoder endEncoding];

    // upload to GPU and render the pass
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

@end
