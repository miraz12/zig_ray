const std = @import("std");
const vec3 = @import("vector.zig").Vector3;
const ray = @import("ray.zig").Ray;

const hit_record = struct {
    p: vec3,
    normal: vec3,
    t: f32,
    front_face: bool,

    fn set_face_normal(self: *hit_record, r: ray, outward_normal: *vec3) void {
        self.front_face = r.dir.dot(outward_normal) < 0;
        if (self.front_face) {
            self.normal = outward_normal;
        } else {
            self.normal = -outward_normal;
        }
    }
};

const Sphere = struct {
    center: vec3,
    radius: f32,

    fn init(center: vec3, radius: f32) Sphere {

    }

    fn hit(self: *Sphere, r: ray, t_min: f32, t_max: f32, rec: *hit_record) bool {
        const oc: vec3 = r.orig.sub(self.center);
        const a: f32 = r.dir.len2();
        const half_b: f32 = oc.dot(r.dir);
        const c = oc.len2() - self.radius * self.radius;
        const discriminant = half_b * half_b - a * c;
        if (discriminant < 0.0) {
            return false;
        } else {
            const sqrtd = std.math.sqrt(discriminant);
            var root: f32 = (-half_b - std.math.sqrt(discriminant)) / a;
            if ((root < t_min) || (root < t_max)) {
                root = (-half_b + sqrtd) / a;
                if ((root < t_min) || (root < t_max)) {
                    return false;
                }
            }
            rec.t = root;
            const outward_normal: vec3 = (rec.p - self.center) / self.radius;
            rec.set_face_normal(r, outward_normal);
            return true;
        }
    }
};
