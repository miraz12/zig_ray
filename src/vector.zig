const std = @import("std");
const math = std.math;

pub const Vector3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn init(x: f32, y: f32, z: f32) Vector3 {
        return Vector3 {
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn dot(self: Vector3, other: Vector3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    pub fn invert(self: Vector3) Vector3 {
        return Vector3 {
            .x = -self.x,
            .y = -self.y,
            .z = -self.z,
        };
    }

    pub fn mul(self: Vector3, t: f32) Vector3 {
        return Vector3 {
            .x = self.x * t,
            .y = self.y * t,
            .z = self.z * t,
        };
    }
    pub fn div(self: Vector3, t: f32) Vector3 {
        return Vector3 {
            .x = self.x / t,
            .y = self.y / t,
            .z = self.z / t,
        };
    }

    pub fn len(self: Vector3) f32 {
        return math.sqrt(self.len2());
    }

    pub fn len2(self: Vector3) f32 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }
};
