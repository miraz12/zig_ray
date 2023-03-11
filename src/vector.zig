const std = @import("std");
const math = std.math;
const Random = std.rand.Random;

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

    pub fn reflect(v: Vector3, n: Vector3) Vector3 {
        return v.sub(n.mulVal(2.0 * v.dot(n)));
    }

    pub fn refract(uv: Vector3, n: Vector3, etai_over_etat: f32) Vector3 {
        var cos_theta = math.min(-uv.dot(n), 1.0);
        const r_out_prep: Vector3 = uv.add(n.mulVal(cos_theta)).mulVal(etai_over_etat);
        const r_out_paralell: Vector3 = n.mulVal(-math.sqrt(math.fabs(1.0 - r_out_prep.len2())));
        return r_out_prep.add(r_out_paralell);
    }

    pub fn unitVec(self: Vector3) Vector3 {
        return self.divVal(self.len());
    }

    pub fn randomUnitVec(rnd: Random) Vector3 {
        var vec = randomInUnitSphere(rnd);
        return vec.divVal(vec.len());
    }

    pub fn nearZero(self: Vector3) bool {
        const s = 1e-8;
        return (math.fabs(self.x) < s) and (math.fabs(self.y) < s) and (math.fabs(self.z) < s);
    }

    pub fn randomInUnitSphere(rnd: Random) Vector3 {
        return while (true) {
            const p = Vector3.init(rnd.float(f32) * 2.0 - 1.0, rnd.float(f32) * 2.0 - 1.0, rnd.float(f32) * 2.0 - 1.0);
            if (p.len2() < 1.0) {
                break p;
            }
        };
    }

    pub fn randomInUnitDisk(rnd: Random) Vector3 {
        return while (true) {
            const p = Vector3.init(rnd.float(f32) * 2.0 - 1.0, rnd.float(f32) * 2.0 - 1.0, 0.0);
            if (p.len2() < 1.0) {
                break p;
            }
        };
    }

    pub fn randomInHemisphere(norm: Vector3, rnd: Random) Vector3 {
        var vec: Vector3 = randomUnitVec(rnd);
        if (vec.dot(norm) > 0.0) {
            return vec;
        } else {
            return vec.mulVal(-1.0);
        }
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
