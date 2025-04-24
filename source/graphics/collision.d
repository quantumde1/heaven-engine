module graphics.collision;

import raylib;
import raylib.raymath;
import std.math;

struct OBB
{
    Quaternion rotation;
    Vector3 center;
    Vector3 halfExtents;
}

void getAxes(ref const OBB obb, out Vector3 right, out Vector3 up, out Vector3 forward)
{
    Matrix rot = QuaternionToMatrix(obb.rotation);

    right = Vector3(rot.m0, rot.m1, rot.m2);
    up = Vector3(rot.m4, rot.m5, rot.m6);
    forward = Vector3(rot.m8, rot.m9, rot.m10);
}

void getCorners(ref const OBB obb, out Vector3[8] corners)
{
    Vector3 right, up, forward;
    getAxes(obb, right, up, forward);

    right = Vector3Scale(right, obb.halfExtents.x);
    up = Vector3Scale(up, obb.halfExtents.y);
    forward = Vector3Scale(forward, obb.halfExtents.z);

    corners[0] = Vector3Add(Vector3Add(Vector3Add(obb.center, right), up), forward);
    corners[1] = Vector3Add(Vector3Add(Vector3Subtract(obb.center, right), up), forward);
    corners[2] = Vector3Add(Vector3Add(Vector3Subtract(obb.center, right), up), Vector3Negate(forward));
    corners[3] = Vector3Add(Vector3Add(Vector3Add(obb.center, right), up), Vector3Negate(forward));

    corners[4] = Vector3Add(Vector3Add(Vector3Add(obb.center, right), Vector3Negate(up)), forward);
    corners[5] = Vector3Add(Vector3Add(Vector3Subtract(obb.center, right), Vector3Negate(up)), forward);
    corners[6] = Vector3Add(Vector3Add(Vector3Subtract(obb.center, right), Vector3Negate(up)), Vector3Negate(forward));
    corners[7] = Vector3Add(Vector3Add(Vector3Add(obb.center, right), Vector3Negate(up)), Vector3Negate(forward));
}

void drawWireframe(ref const OBB obb, Color color)
{
    Vector3[8] c;
    getCorners(obb, c);

    DrawLine3D(c[0], c[1], color);
    DrawLine3D(c[1], c[2], color);
    DrawLine3D(c[2], c[3], color);
    DrawLine3D(c[3], c[0], color);

    DrawLine3D(c[4], c[5], color);
    DrawLine3D(c[5], c[6], color);
    DrawLine3D(c[6], c[7], color);
    DrawLine3D(c[7], c[4], color);

    DrawLine3D(c[0], c[4], color);
    DrawLine3D(c[1], c[5], color);
    DrawLine3D(c[2], c[6], color);
    DrawLine3D(c[3], c[7], color);
}

bool containsPoint(ref const OBB obb, Vector3 point)
{
    Vector3 local = Vector3Subtract(point, obb.center);

    Quaternion inverseRot = QuaternionInvert(obb.rotation);
    local = Vector3RotateByQuaternion(local, inverseRot);

    return fabs(local.x) <= obb.halfExtents.x &&
           fabs(local.y) <= obb.halfExtents.y &&
           fabs(local.z) <= obb.halfExtents.z;
}

void projectBoundingBoxOntoAxis(ref const BoundingBox box, Vector3 axis, out float outMin, out float outMax)
{
    Vector3[8] corners = [
        Vector3(box.min.x, box.min.y, box.min.z),
        Vector3(box.max.x, box.min.y, box.min.z),
        Vector3(box.max.x, box.max.y, box.min.z),
        Vector3(box.min.x, box.max.y, box.min.z),
        Vector3(box.min.x, box.min.y, box.max.z),
        Vector3(box.max.x, box.min.y, box.max.z),
        Vector3(box.max.x, box.max.y, box.max.z),
        Vector3(box.min.x, box.max.y, box.max.z)
    ];

    float min = Vector3DotProduct(corners[0], axis);
    float max = min;

    for (int i = 1; i < 8; ++i)
    {
        float projection = Vector3DotProduct(corners[i], axis);
        if (projection < min)
            min = projection;
        if (projection > max)
            max = projection;
    }

    outMin = min;
    outMax = max;
}

void projectOBBOntoAxis(ref const OBB obb, Vector3 axis, out float outMin, out float outMax)
{
    Vector3 right, up, forward;
    getAxes(obb, right, up, forward);

    float r =
        fabs(Vector3DotProduct(right, axis)) * obb.halfExtents.x +
        fabs(Vector3DotProduct(up, axis)) * obb.halfExtents.y +
        fabs(Vector3DotProduct(forward, axis)) * obb.halfExtents.z;

    float centerProj = Vector3DotProduct(obb.center, axis);
    outMin = centerProj - r;
    outMax = centerProj + r;
}

bool checkCollisionBoundingBoxVsOBB(ref const BoundingBox box, ref const OBB obb)
{
    Vector3[3] aabbAxes = [
        Vector3(1, 0, 0),
        Vector3(0, 1, 0),
        Vector3(0, 0, 1)
    ];

    Vector3[3] obbAxes;
    getAxes(obb, obbAxes[0], obbAxes[1], obbAxes[2]);

    Vector3[15] testAxes;
    int axisCount = 0;

    for (int i = 0; i < 3; i++)
        testAxes[axisCount++] = aabbAxes[i];

    for (int i = 0; i < 3; i++)
        testAxes[axisCount++] = obbAxes[i];

    for (int i = 0; i < 3; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            Vector3 cross = Vector3CrossProduct(aabbAxes[i], obbAxes[j]);
            if (Vector3LengthSqr(cross) > 0.000001f)
            {
                testAxes[axisCount++] = Vector3Normalize(cross);
            }
        }
    }

    for (int i = 0; i < axisCount; ++i)
    {
        Vector3 axis = testAxes[i];
        float minA, maxA, minB, maxB;

        projectBoundingBoxOntoAxis(box, axis, minA, maxA);
        projectOBBOntoAxis(obb, axis, minB, maxB);

        if (maxA < minB || maxB < minA)
        {
            return false;
        }
    }

    return true;
}

bool checkCollisionOBBvsOBB(ref const OBB a, ref const OBB b)
{
    Vector3[3] axesA, axesB;
    getAxes(a, axesA[0], axesA[1], axesA[2]);
    getAxes(b, axesB[0], axesB[1], axesB[2]);

    Vector3[15] testAxes;
    int axisCount = 0;

    for (int i = 0; i < 3; ++i)
        testAxes[axisCount++] = axesA[i];

    for (int i = 0; i < 3; ++i)
        testAxes[axisCount++] = axesB[i];

    for (int i = 0; i < 3; ++i)
    {
        for (int j = 0; j < 3; ++j)
        {
            Vector3 cross = Vector3CrossProduct(axesA[i], axesB[j]);
            float len = Vector3Length(cross);
            if (len > 0.0001f)
            {
                testAxes[axisCount++] = Vector3Scale(cross, 1.0f / len);
            }
        }
    }

    for (int i = 0; i < axisCount; ++i)
    {
        Vector3 axis = testAxes[i];

        float minA, maxA, minB, maxB;
        projectOBBOntoAxis(a, axis, minA, maxA);
        projectOBBOntoAxis(b, axis, minB, maxB);

        if (maxA < minB || maxB < minA)
        {
            return false;
        }
    }

    return true;
}

RayCollision getRayCollisionOBB(Ray ray, ref const OBB obb)
{
    RayCollision result;
    result.hit = false;
    result.distance = 0;
    result.normal = Vector3(0.0f, 0.0f, 0.0f);
    result.point = Vector3(0.0f, 0.0f, 0.0f);

    // Move ray into OBB's local space
    Vector3 localOrigin = Vector3Subtract(ray.position, obb.center);
    Quaternion inverseRot = QuaternionInvert(obb.rotation);
    Vector3 localRayOrigin = Vector3RotateByQuaternion(localOrigin, inverseRot);
    Vector3 localRayDir = Vector3RotateByQuaternion(ray.direction, inverseRot);

    Vector3 boxMin = Vector3Negate(obb.halfExtents);
    Vector3 boxMax = obb.halfExtents;

    // Ray vs AABB in OBB-local space
    float tmin = -float.infinity;
    float tmax = float.infinity;
    Vector3 normal = Vector3(0);

    for (int i = 0; i < 3; ++i)
    {
        float origin;
        float dir;
        float min;
        float max;
        
        switch (i)
        {
            case 0:
                origin = localRayOrigin.x;
                dir = localRayDir.x;
                min = boxMin.x;
                max = boxMax.x;
                break;
            case 1:
                origin = localRayOrigin.y;
                dir = localRayDir.y;
                min = boxMin.y;
                max = boxMax.y;
                break;
            case 2:
                origin = localRayOrigin.z;
                dir = localRayDir.z;
                min = boxMin.z;
                max = boxMax.z;
                break;
            default:
                assert(false);
        }

        if (fabs(dir) < 0.0001f)
        {
            if (origin < min || origin > max)
                return result;
        }
        else
        {
            float ood = 1.0f / dir;
            float t1 = (min - origin) * ood;
            float t2 = (max - origin) * ood;
            int axis = i;

            if (t1 > t2)
            {
                float temp = t1;
                t1 = t2;
                t2 = temp;
                axis = -axis;
            }

            if (t1 > tmin)
            {
                tmin = t1;
                normal = Vector3(0);
                switch (abs(axis))
                {
                    case 0:
                        normal.x = axis >= 0 ? -1.0f : 1.0f;
                        break;
                    case 1:
                        normal.y = axis >= 0 ? -1.0f : 1.0f;
                        break;
                    case 2:
                        normal.z = axis >= 0 ? -1.0f : 1.0f;
                        break;
                    default:
                        break;
                }
            }

            if (t2 < tmax)
            {
                tmax = t2;
            }

            if (tmin > tmax)
                return result;
        }
    }

    // Convert result to world space
    result.hit = true;
    result.distance = tmin;
    result.point = Vector3Add(ray.position, Vector3Scale(ray.direction, tmin));
    result.normal = Vector3RotateByQuaternion(normal, obb.rotation);

    return result;
}

bool checkCollisionSphereVsOBB(Vector3 sphereCenter, float radius, ref const OBB obb)
{
    Vector3 localCenter = Vector3Subtract(sphereCenter, obb.center);
    Quaternion invRot = QuaternionInvert(obb.rotation);
    localCenter = Vector3RotateByQuaternion(localCenter, invRot);

    Vector3 Clamped = Vector3(
        Clamp(localCenter.x, -obb.halfExtents.x, obb.halfExtents.x),
        Clamp(localCenter.y, -obb.halfExtents.y, obb.halfExtents.y),
        Clamp(localCenter.z, -obb.halfExtents.z, obb.halfExtents.z)
    );

    Vector3 worldClamped = Vector3RotateByQuaternion(Clamped, obb.rotation);
    worldClamped = Vector3Add(worldClamped, obb.center);

    float distSq = Vector3DistanceSqr(sphereCenter, worldClamped);
    return distSq <= radius * radius;
}