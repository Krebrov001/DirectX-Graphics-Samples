/**
 * @file    Raytracing.hlsl
 * @author  Konstantin Rebrov
 *
 * @section DESCRIPTION
 *
 * This file
 */

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

/**
 * @param p      the coordinate has a x and a y value
 * @return bool  true if the given coordinate is in the viewport, false if it is not
 */
bool IsInsideViewport(float2 p, Viewport viewport)
{
    return (p.x >= viewport.left && p.x <= viewport.right)
        && (p.y >= viewport.top && p.y <= viewport.bottom);
}

/**
 * This shader generates the rays by calling the TraceRay() intrinsic.
 */
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
    
    // Get the color of the top triangle.
    blue += draw_triangle2(attr, float3(range.x - increment, range.y - increment, range.z + increment), increment / 2);
    // Get the color of the left triangle.
    blue += draw_triangle2(attr, float3(range.x + increment, range.y - increment, range.z - increment), increment / 2);
    // Get the color of the right triangle.
    blue += draw_triangle2(attr, float3(range.x - increment, range.y + increment, range.z - increment), increment / 2);

    return blue;
}


/**
 * The closest hit shader gets called whenever a ray hits the big triangle,
 * and it just passes those coordinates to the first stack frame of the draw_triangle() function,
 * which determines if the given pixel is in the pattern.
 */
[shader("closesthit")]
void MyClosestHitShader(inout RayPayload payload, in MyAttributes attr)
{
    float red = 0.0;
    float green = 0.0;
    float blue = 0.0;

    blue += draw_triangle1(attr, float3(0.5, 0.5, 0.5), 0.25); // center triangle
    
    payload.color = float4(red, green, blue, 1);
}


/**
 * The miss shader draws the background around the triangle as blue.
 */
[shader("miss")]
void MyMissShader(inout RayPayload payload)
{
    payload.color = float4(0.0, 0.0, 1.0, 1.0);
}

#endif // RAYTRACING_HLSL