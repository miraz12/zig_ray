const std = @import("std");
const material = @import("material.zig");
const Material = material.Material;
const Vec3 = @import("vector.zig").Vector3;
const Ray = @import("ray.zig").Ray;
const Random = std.rand.Random;

pub const HitRecord = struct {
    p: Vec3,
    normal: Vec3,
    t: f32,
    front_face: bool,
    mat: Material,
    materialScatterFn: *const fn (mat: Material, r_in: Ray, rec: HitRecord, rnd: Random, attenuation: *Vec3, scattered: *Ray) bool,

    fn set_face_normal(self: *HitRecord, r: Ray, outward_normal: Vec3) void {
        self.front_face = r.dir.dot(outward_normal) < 0;
        if (self.front_face) {
            self.normal = outward_normal;
        } else {
            self.normal = Vec3.init(-outward_normal.x, -outward_normal.y, -outward_normal.z);
        }
    }
};

pub const Sphere = struct {
    center: Vec3,
    radius: f32,
    mat: Material,
    materialScatterFn: *const fn (mat: Material, r_in: Ray, rec: HitRecord, rnd: Random, attenuation: *Vec3, scattered: *Ray) bool,

    pub fn init(
        center: Vec3,
        radius: f32,
        mat: Material,
        scatterFn: *const fn (mat: Material, r_in: Ray, rec: HitRecord, rnd: Random, attenuation: *Vec3, scattered: *Ray) bool,
    ) Sphere {
        return Sphere{ .center = center, .radius = radius, .materialScatterFn = scatterFn, .mat = mat };
    }

    pub fn hit(self: *Sphere, r: Ray, t_min: f32, t_max: f32, rec: *HitRecord) bool {
        const oc: Vec3 = r.orig.sub(self.center);
        const a: f32 = r.dir.len2();
        const half_b: f32 = oc.dot(r.dir);
        const c = oc.len2() - self.radius * self.radius;
        const discriminant = half_b * half_b - a * c;
        if (discriminant < 0.0) {
            return false;
        } else {
            const sqrtd = std.math.sqrt(discriminant);
            var root: f32 = (-half_b - sqrtd) / a;
            if ((root < t_min) or (root > t_max)) {
                root = (-half_b + sqrtd) / a;
                if ((root < t_min) or (root > t_max)) {
                    return false;
                }
            }
            rec.t = root;
            rec.p = r.at(rec.t);
            var outward_normal: Vec3 = (rec.p.sub(self.center)).divVal(self.radius);
            rec.set_face_normal(r, outward_normal);
            rec.materialScatterFn = self.materialScatterFn;
            rec.mat = self.mat;
            return true;
        }
    }
};
