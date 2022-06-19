const vecInc = @import("vector.zig");
const vec3 = vecInc.Vector3;

pub const Ray = struct {
    orig: vec3,
    dir: vec3,

    pub fn init(orig: vec3, dir: vec3) Ray {
        return Ray{ .orig = orig, .dir = dir };
    }

    pub fn at(self: Ray, t: f32) vec3 {
        return self.orig.add(self.dir.mulVal(t));
    }
};
