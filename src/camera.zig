const Vec3 = @import("vector.zig").Vector3;
const Ray = @import("ray.zig").Ray;

pub const Camera = struct {
    aspect_ratio: f32,
    viewport_height: f32,
    viewport_width: f32,
    focal_length: f32,
    origin: Vec3,
    horizontal: Vec3,
    vertical: Vec3,
    lower_left_corner: Vec3,

    pub fn init() Camera {
        const aspect_ratio: f32 = 16.0 / 9.0;
        const viewport_height: f32 = 2.0;
        const viewport_width: f32 = aspect_ratio * viewport_height;
        const focal_length: f32 = 1.0;
        const origin: Vec3 = Vec3.init(0.0, 0.0, 0.0);
        const horizontal: Vec3 = Vec3.init(viewport_width, 0.0, 0.0);
        const vertical: Vec3 = Vec3.init(0.0, viewport_height, 0.0);
        const lower_left_corner: Vec3 = origin.sub(horizontal.divVal(2)).sub(vertical.divVal(2)).sub(Vec3.init(0.0, 0.0, focal_length));
        return Camera{ .aspect_ratio = aspect_ratio, .viewport_height = viewport_height, .viewport_width = viewport_width, .focal_length = focal_length, .origin = origin, .horizontal = horizontal, .vertical = vertical, .lower_left_corner = lower_left_corner };
    }

    pub fn get_ray(self: Camera, u: f32, v: f32) Ray {
        return Ray.init(self.origin, self.lower_left_corner.add(self.horizontal.mulVal(u)).add(self.vertical.mulVal(v)).sub(self.origin));
    }
};
