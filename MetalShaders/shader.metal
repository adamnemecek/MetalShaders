//
//  shader.metal
//  MetalShaders
//
//  Created by Lixuan Zhu on 5/29/15.
//  Copyright (c) 2015 Lixuan Zhu. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct ColoredVertex {
    float4 position [[position]];
    float4 color;
};

struct FragmentUniforms
{
    float2 resolution;
    float time;
};


// Vertex Shader
vertex ColoredVertex vertex_main(constant float4 *position [[buffer(0)]],
                                 constant float4 *color [[buffer(1)]],
                                 uint vertexID [[vertex_id]]) {
    ColoredVertex coloredVertex;
    coloredVertex.position = position[vertexID];
    coloredVertex.color = color[vertexID];
    return coloredVertex;
}

// Fragment Shader
fragment float4 fragment_main(ColoredVertex coloredVertex [[stage_in]]) {
    return coloredVertex.color;
}

// First Shader
fragment float4 fragment_main_1(ColoredVertex coloredVertex [[stage_in]],
                                constant FragmentUniforms *uniforms [[buffer(0)]]) {

    float2 resolution = uniforms->resolution;
    float t = uniforms->time;

    float4 color = float4(coloredVertex.position.x/resolution.x, coloredVertex.position.y/resolution.y,cos(3.1415*t),1.0);
    return color;
}

// Second Shader
fragment float4 fragment_main_2(ColoredVertex coloredVertex [[stage_in]],
                                 constant FragmentUniforms *uniforms [[buffer(0)]]) {
    float4 coordinates = coloredVertex.position;
    float4 color = float4(0.0,coordinates.xy-floor(coordinates.xy),1.0);

    return color;
}


