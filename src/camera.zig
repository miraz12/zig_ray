const math = @import("std").math;

const Random = @import("std").rand.Random;
const Vec3 = @import("vector.zig").Vector3;
const Ray = @import("ray.zig").Ray;

pub const Camera = struct {
    origin: Vec3,
    horizontal: Vec3,
    vertical: Vec3,
    lower_left_corner: Vec3,
    u: Vec3,
    v: Vec3,
    w: Vec3,
    lens_radius: f32,

    pub fn init(lookfrom: Vec3, lookat: Vec3, vup: Vec3, vfov: f32, aspect_ratio: f32, aperture: f32, focus_dist: f32) Camera {
        const theta: f32 = math.degreesToRadians(f32, vfov);
        const h: f32 = math.tan(theta / 2.0);
        const viewport_height: f32 = 2.0 * h;
        const viewport_width: f32 = aspect_ratio * viewport_height;

        const w = Vec3.unitVec(lookfrom.sub(lookat));
        const u = Vec3.unitVec(vup.cross(w));
        const v = w.cross(u);

        const origin: Vec3 = lookfrom;
        const horizontal: Vec3 = u.mulVal(viewport_width).mulVal(focus_dist);
        const vertical: Vec3 = v.mulVal(viewport_height).mulVal(focus_dist);
        const lower_left_corner: Vec3 = origin.sub(horizontal.divVal(2)).sub(vertical.divVal(2)).sub(w.mulVal(focus_dist));

        const lens_radius = aperture / 2.0;
        return Camera{ .origin = origin, .horizontal = horizontal, .vertical = vertical, .lower_left_corner = lower_left_corner, .w = w, .u = u, .v = v, .lens_radius = lens_radius };
    }

    pub fn get_ray(self: Camera, s: f32, t: f32, rnd: Random) Ray {
        const rd = Vec3.randomInUnitDisk(rnd).mulVal(self.lens_radius);
        const offset = self.u.mulVal(rd.x).add(self.v.mulVal(rd.y));
        return Ray.init(self.origin.add(offset), self.lower_left_corner.add(self.horizontal.mulVal(s)).add(self.vertical.mulVal(t)).sub(self.origin).sub(offset));
    }
};
