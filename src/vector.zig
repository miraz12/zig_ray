const std = @import("std");
const math = std.math;

pub const Vector3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn init(x: f32, y: f32, z: f32) Vector3 {
        return Vector3{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn add(self: Vector3, other: Vector3) Vector3 {
        return Vector3{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn sub(self: Vector3, other: Vector3) Vector3 {
        return Vector3{
            .x = self.x - other.x,
            .y = self.y - other.y,
            .z = self.z - other.z,
        };
    }

    pub fn mul(self: Vector3, other: Vector3) Vector3 {
        return Vector3{
            .x = self.x * other.x,
            .y = self.y * other.y,
            .z = self.z * other.z,
        };
    }

    pub fn mulVal(self: Vector3, t: f32) Vector3 {
        return Vector3{
            .x = self.x * t,
            .y = self.y * t,
            .z = self.z * t,
        };
    }

    pub fn div(self: Vector3, other: Vector3) Vector3 {
        return Vector3{
            .x = self.x / other.x,
            .y = self.y / other.y,
            .z = self.z / other.z,
        };
    }

    pub fn divVal(self: Vector3, t: f32) Vector3 {
        return Vector3{
            .x = self.x / t,
            .y = self.y / t,
            .z = self.z / t,
        };
    }

    pub fn dot(self: Vector3, other: Vector3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    pub fn cross(self: Vector3, other: Vector3) Vector3 {
        return Vector3{
            .x = self.y * other.z - self.z * other.y,
            .y = self.z * other.x - self.x * other.z,
            .z = self.x * other.y - self.y * other.x,
        };
    }

    pub fn invert(self: Vector3) Vector3 {
        return Vector3{
            .x = -self.x,
            .y = -self.y,
            .z = -self.z,
        };
    }

    pub fn len(self: Vector3) f32 {
        return math.sqrt(self.len2());
    }

    pub fn len2(self: Vector3) f32 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub fn unitVec(self: Vector3) Vector3 {
        return self.divVal(self.len());
    }
};

const expect = @import("std").testing.expect;
test "Vector3.unitVec" {
    const epsilon: f32 = 0.00001;
    const v = Vector3.init(1.0, 2.0, 3.0);
    const uv = Vector3.unitVec(v);
    try expect(math.fabs(uv.len() - 1.0) < epsilon);
}

test "Vector3.dot" {
    const v1 = Vector3.init(1.0, 0.0, 0.0);
    const v2 = Vector3.init(0.0, 1.0, 0.0);
    try expect(v1.dot(v2) == 0.0);
}
