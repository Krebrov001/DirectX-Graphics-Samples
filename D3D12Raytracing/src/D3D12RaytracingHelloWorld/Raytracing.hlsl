//*********************************************************
//
// Copyright (c) Microsoft. All rights reserved.
// This code is licensed under the MIT License (MIT).
// THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
// ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
// IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
// PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
//
//*********************************************************

#ifndef RAYTRACING_HLSL
#define RAYTRACING_HLSL

#include "RaytracingHlslCompat.h"

RaytracingAccelerationStructure Scene : register(t0, space0);
RWTexture2D<float4> RenderTarget : register(u0);
ConstantBuffer<RayGenConstantBuffer> g_rayGenCB : register(b0);

typedef BuiltInTriangleIntersectionAttributes MyAttributes;
struct RayPayload
{
    float4 color;
};

bool IsInsideViewport(float2 p, Viewport viewport)
{
    return (p.x >= viewport.left && p.x <= viewport.right)
        && (p.y >= viewport.top && p.y <= viewport.bottom);
}

[shader("raygeneration")]
void MyRaygenShader()
{
    float2 lerpValues = (float2)DispatchRaysIndex() / (float2)DispatchRaysDimensions();

    // Orthographic projection since we're raytracing in screen space.
    float3 rayDir = float3(0, 0, 1);
    float3 origin = float3(
        lerp(g_rayGenCB.viewport.left, g_rayGenCB.viewport.right, lerpValues.x),
        lerp(g_rayGenCB.viewport.top, g_rayGenCB.viewport.bottom, lerpValues.y),
        0.0f);

    if (IsInsideViewport(origin.xy, g_rayGenCB.stencil))
    {
        // Trace the ray.
        // Set the ray's extents.
        RayDesc ray;
        ray.Origin = origin;
        ray.Direction = rayDir;
        // Set TMin to a non-zero small value to avoid aliasing issues due to floating - point errors.
        // TMin should be kept small to prevent missing geometry at close contact areas.
        ray.TMin = 0.001;
        ray.TMax = 10000.0;
        RayPayload payload = { float4(0, 0, 0, 0) };
        TraceRay(Scene, RAY_FLAG_CULL_BACK_FACING_TRIANGLES, ~0, 0, 1, 0, ray, payload);

        // Write the raytraced color to the output texture.
        RenderTarget[DispatchRaysIndex().xy] = payload.color;
    }
    else
    {
        // Render interpolated DispatchRaysIndex outside the stencil window
        RenderTarget[DispatchRaysIndex().xy] = float4(lerpValues, 0, 1);
    }
}


float draw_triangle5(in MyAttributes attr, in float3 range, in float increment) {

    float blue = 0.0;

    // Get the color of the center triangle.
    if (attr.barycentrics.x < range.x &&
        attr.barycentrics.y < range.y &&
        (1 - attr.barycentrics.x - attr.barycentrics.y) < range.z)
        blue += 1.0;

    const float offset1 = 0.5;
    const float offset2 = 1.5;

    // Get the color of the top triangle.
    //blue += draw_triangle6(attr, float3(range.x - increment, range.y - increment, range.z + increment), increment / 2);
    // Get the color of the left triangle.
    //blue += draw_triangle6(attr, float3(range.x + increment, range.y - increment, range.z - increment), increment / 2);
    // Get the color of the right triangle.
    //blue += draw_triangle6(attr, float3(range.x - increment, range.y + increment, range.z - increment), increment / 2);

    return blue;
}



float draw_triangle4(in MyAttributes attr, in float3 range, in float increment) {

    float blue = 0.0;

    // Get the color of the center triangle.
    if (attr.barycentrics.x < range.x &&
        attr.barycentrics.y < range.y &&
        (1 - attr.barycentrics.x - attr.barycentrics.y) < range.z)
        blue += 1.0;

    const float offset1 = 0.5;
    const float offset2 = 1.5;

    // Get the color of the top triangle.
    blue += draw_triangle5(attr, float3(range.x - increment, range.y - increment, range.z + increment), increment / 2);
    // Get the color of the left triangle.
    blue += draw_triangle5(attr, float3(range.x + increment, range.y - increment, range.z - increment), increment / 2);
    // Get the color of the right triangle.
    blue += draw_triangle5(attr, float3(range.x - increment, range.y + increment, range.z - increment), increment / 2);

    return blue;
}


float draw_triangle3(in MyAttributes attr, in float3 range, in float increment) {

    float blue = 0.0;

    // Get the color of the center triangle.
    if (attr.barycentrics.x < range.x &&
        attr.barycentrics.y < range.y &&
        (1 - attr.barycentrics.x - attr.barycentrics.y) < range.z)
        blue += 1.0;

    const float offset1 = 0.5;
    const float offset2 = 1.5;

    // Get the color of the top triangle.
    blue += draw_triangle4(attr, float3(range.x - increment, range.y - increment, range.z + increment), increment / 2);
    // Get the color of the left triangle.
    blue += draw_triangle4(attr, float3(range.x + increment, range.y - increment, range.z - increment), increment / 2);
    // Get the color of the right triangle.
    blue += draw_triangle4(attr, float3(range.x - increment, range.y + increment, range.z - increment), increment / 2);

    return blue;
}




float draw_triangle2(in MyAttributes attr, in float3 range, in float increment) {

    float blue = 0.0;

    // Get the color of the center triangle.
    if (attr.barycentrics.x < range.x &&
        attr.barycentrics.y < range.y &&
        (1 - attr.barycentrics.x - attr.barycentrics.y) < range.z)
        blue += 1.0;

    const float offset1 = 0.5;
    const float offset2 = 1.5;

    // Get the color of the top triangle.
    blue += draw_triangle3(attr, float3(range.x - increment, range.y - increment, range.z + increment), increment / 2);
    // Get the color of the left triangle.
    blue += draw_triangle3(attr, float3(range.x + increment, range.y - increment, range.z - increment), increment / 2);
    // Get the color of the right triangle.
    blue += draw_triangle3(attr, float3(range.x - increment, range.y + increment, range.z - increment), increment / 2);

    return blue;
}


float draw_triangle1(in MyAttributes attr, in float3 range, in float increment) {

    float blue = 0.0;

    // Get the color of the center triangle.
    if (attr.barycentrics.x < range.x &&
        attr.barycentrics.y < range.y &&
        (1 - attr.barycentrics.x - attr.barycentrics.y) < range.z)
        blue += 1.0;

    const float offset1 = 0.5;
    const float offset2 = 1.5;
    
    // Get the color of the top triangle.
    blue += draw_triangle2(attr, float3(range.x - increment, range.y - increment, range.z + increment), increment / 2);
    // Get the color of the left triangle.
    blue += draw_triangle2(attr, float3(range.x + increment, range.y - increment, range.z - increment), increment / 2);
    // Get the color of the right triangle.
    blue += draw_triangle2(attr, float3(range.x - increment, range.y + increment, range.z - increment), increment / 2);

    return blue;
}

[shader("closesthit")]
void MyClosestHitShader(inout RayPayload payload, in MyAttributes attr)
{
    //float3 barycentrics = float3(1 - attr.barycentrics.x - attr.barycentrics.y, attr.barycentrics.x, attr.barycentrics.y);
    float red = 0.0;
    float green = 0.0;
    float blue = 0.0;

    /*
    if (attr.barycentrics.x > 0.5)
        red += 0.7;

    if (attr.barycentrics.y > 0.5)
        red += 0.7;

    if ((1 - attr.barycentrics.x - attr.barycentrics.y) > 0.5)
        red += 0.7;
    */

    /*
    if (attr.barycentrics.x < 0.5 &&
        attr.barycentrics.y < 0.5 &&
        (1 - attr.barycentrics.x - attr.barycentrics.y) < 0.5)
        blue += 1.0;
    */

    blue += draw_triangle1(attr, float3(0.5, 0.5, 0.5), 0.25);     // center triangle
    //blue += draw_triangle(attr, float3(0.25, 0.25, 0.75));  // top triangle
    //blue += draw_triangle(attr, float3(0.75, 0.25, 0.25));  // left triangle
    //blue += draw_triangle(attr, float3(0.25, 0.75, 0.25));  // right triangle

    payload.color = float4(red, green, blue, 1);
}

[shader("miss")]
void MyMissShader(inout RayPayload payload)
{
    payload.color = float4(0.0, 0.0, 1.0, 1.0);
}

#endif // RAYTRACING_HLSL