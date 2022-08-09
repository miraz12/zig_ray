const Vec3 = @import("vector.zig").Vector3;

pub const Ray = struct {
    orig: Vec3,
    dir: Vec3,

    pub fn init(orig: Vec3, dir: Vec3) Ray {
        return Ray{ .orig = orig, .dir = dir };
    }

    pub fn at(self: Ray, t: f32) Vec3 {
        return self.orig.add(self.dir.mulVal(t));
    }
};
