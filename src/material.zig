const std = @import("std");
const math = std.math;

const Vec3 = @import("vector.zig").Vector3;
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hittables.zig").HitRecord;
const Random = std.rand.Random;

pub const Material = struct {
    albedo: Vec3 = Vec3.init(0.0, 0.0, 0.0),
    fuzz: f32 = 0.0,
    ir: f32 = 0.0,
};

pub const Lambertian = struct {
    pub fn scatter(mat: Material, r_in: Ray, rec: HitRecord, rnd: Random, attenuation: *Vec3, scattered: *Ray) bool {
        _ = r_in;
        var scatterDirection = rec.normal.add(Vec3.randomUnitVec(rnd));

        if (scatterDirection.nearZero()) {
            scatterDirection = rec.normal;
        }

        scattered.* = Ray.init(rec.p, scatterDirection);
        attenuation.* = mat.albedo;
        return true;
    }
};

pub const Metal = struct {
    pub fn scatter(mat: Material, r_in: Ray, rec: HitRecord, rnd: Random, attenuation: *Vec3, scattered: *Ray) bool {
        const reflected: Vec3 = Vec3.reflect(Vec3.unitVec(r_in.dir), rec.normal);
        scattered.* = Ray.init(rec.p, reflected.add(Vec3.randomUnitVec(rnd).mulVal(mat.fuzz)));
        attenuation.* = mat.albedo;
        return (Vec3.dot(scattered.dir, rec.normal) > 0);
    }
};

pub const Dialectric = struct {
    pub fn scatter(mat: Material, r_in: Ray, rec: HitRecord, rnd: Random, attenuation: *Vec3, scattered: *Ray) bool {
        attenuation.* = Vec3.init(1.0, 1.0, 1.0);
        var refraction_ratio: f32 = mat.ir;
        if (rec.front_face) {
            refraction_ratio = 1.0 / mat.ir;
        }

        const unit_direction: Vec3 = Vec3.unitVec(r_in.dir);
        const cos_theta = math.min(-unit_direction.dot(rec.normal), 1.0);
        const sin_theta = math.sqrt(1.0 - cos_theta * cos_theta);
        const cannot_refract: bool = (refraction_ratio * sin_theta) > 1.0;
        var direction: Vec3 = undefined;
        if (cannot_refract or (reflectance(cos_theta, refraction_ratio) > rnd.float(f32))) {
            direction = Vec3.reflect(unit_direction, rec.normal);
        } else {
            direction = Vec3.refract(unit_direction, rec.normal, refraction_ratio);
        }

        const refracted: Vec3 = Vec3.refract(unit_direction, rec.normal, refraction_ratio);
        scattered.* = Ray.init(rec.p, refracted);
        return true;
    }

    fn reflectance(cosine: f32, ref_idx: f32) f32 {
        var r0: f32 = (1.0 - ref_idx) / (1.0 + ref_idx);
        r0 = r0 * r0;
        return r0 + (1.0 - r0) * math.pow(f32, (1.0 - cosine), 5);
    }
};
