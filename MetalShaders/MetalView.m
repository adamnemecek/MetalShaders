//
//  MetalView.m
//  
//
//  Created by Lixuan Zhu on 5/27/15.
//
//

#import "MetalView.h"

@interface MetalView()

@property (strong, nonatomic) id<MTLDevice> device;
@property (strong, nonatomic) CAMetalLayer *metalLayer;
@property (strong, nonatomic) id<MTLRenderPipelineState> pipleline;
@property (strong, nonatomic) id<MTLCommandQueue> commandQueue;
@property (strong, nonatomic) id<MTLBuffer> positionBuffer;
@property (strong, nonatomic) id<MTLBuffer> colorBuffer;
@property (strong, nonatomic) CADisplayLink *displayLink;

@end

@implementation MetalView

+ (id)layerClass {
    return [CAMetalLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    [self setUpMetalLayer];
    [self buildVertexBuffers];
    [self buildPipeLine];
}

- (void)setUpMetalLayer {

    // Get GPU
    self.device = MTLCreateSystemDefaultDevice();

    // Configure MetalLayer
    self.metalLayer = (CAMetalLayer *)self.layer;
    self.metalLayer.device = self.device;
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;

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

    self.positionBuffer = [self.device newBufferWithBytes:positions
                                                   length:sizeof(positions)
                                                  options:MTLResourceOptionCPUCacheModeDefault];

    self.colorBuffer = [self.device newBufferWithBytes:colors
                                                length:sizeof(colors)
                                               options:MTLResourceOptionCPUCacheModeDefault];
}

- (void)buildPipeLine {
    // Get library which contains all metal functions
    id<MTLLibrary> library = [self.device newDefaultLibrary];
    id<MTLFunction> vertexFunction = [library newFunctionWithName:@"vertex_main"];
    id<MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragment_main_1"];

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
        self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                       selector:@selector(displayLinkTick:)];

        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    else {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

// Call back for each display link tick
- (void)displayLinkTick:(CADisplayLink *)displayLink {
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

    // start issue commands
    [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6 instanceCount:1];
    [encoder endEncoding];

    // upload to GPU and render the pass
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

@end
