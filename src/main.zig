const std = @import("std");
const expect = std.testing.expect;
const rndGen = std.rand.DefaultPrng;
const math = std.math;
const material = @import("material.zig");

const Random = std.rand.Random;
const Vec3 = @import("vector.zig").Vector3;
const Ray = @import("ray.zig").Ray;
const Sphere = @import("hittables.zig").Sphere;
const HitRecord = @import("hittables.zig").HitRecord;
const Camera = @import("camera.zig").Camera;
const ArrayList = std.ArrayList;
const Material = material.Material;

pub fn main() anyerror!void {
    // Image
    const aspect_ratio: f32 = 3.0 / 2.0;
    const image_width: i32 = 500;
    const image_height: i32 = @floatToInt(i32, @intToFloat(f32, image_width) / aspect_ratio);
    const num_samples: i32 = 50;

    const seed = @truncate(u64, @bitCast(u128, std.time.nanoTimestamp()));
    var prng = rndGen.init(seed);
    const rnd = prng.random();

    // // World
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var world = ArrayList(Sphere).init(allocator);
    try world.append(Sphere.init(Vec3.init(0.0, -1000.0, -1.0), 1000.0, Material{ .albedo = Vec3.init(0.5, 0.5, 0.5) }, material.Lambertian.scatter));

    var a: i32 = -11;
    while (a < 11) : (a += 1) {
        var b: i32 = -11;
        while (b < 11) : (b += 1) {
            const choose_mat = rnd.float(f32);
            const center = Vec3.init(@intToFloat(f32, a) + 0.9 * rnd.float(f32), 0.2, @intToFloat(f32, b) + 0.9 * rnd.float(f32));
            if ((center.sub(Vec3.init(4.0, 0.2, 0.0))).len() > 0.9) {
                if (choose_mat < 0.8) {
                    // diffuse
                    try world.append(Sphere.init(center, 0.2, Material{ .albedo = Vec3.init(rnd.float(f32), rnd.float(f32), rnd.float(f32)) }, material.Lambertian.scatter));
                } else if (choose_mat < 0.95) {
                    // metal
                    const albedo = Vec3.init(rnd.float(f32) * (1.0 - 0.5) + 0.5, rnd.float(f32) * (1.0 - 0.5) + 0.5, rnd.float(f32) * (1.0 - 0.5) + 0.5);
                    const fuzz = rnd.float(f32) * (1.0 - 0.5) + 0.5;
                    try world.append(Sphere.init(center, 0.2, Material{ .albedo = albedo, .fuzz = fuzz }, material.Metal.scatter));
                } else {
                    // glass
                    try world.append(Sphere.init(center, 0.2, Material{ .ir = 1.5 }, material.Dialectric.scatter));
                }
            }
        }
    }

    try world.append(Sphere.init(Vec3.init(0.0, 1.0, 0.0), 1.0, Material{ .albedo = Vec3.init(0.4, 0.2, 0.1) }, material.Lambertian.scatter));
    try world.append(Sphere.init(Vec3.init(-4.0, 1.0, 0.0), 1.0, Material{ .ir = 1.5 }, material.Dialectric.scatter));
    try world.append(Sphere.init(Vec3.init(4.0, 1.0, 0.0), 1.0, Material{ .albedo = Vec3.init(0.7, 0.6, 0.5), .fuzz = 0.0 }, material.Metal.scatter));

    // Camera
    const look_from = Vec3.init(13.0, 2.0, 3.0);
    const look_at = Vec3.init(0.0, 0.0, 0.0);
    const vup = Vec3.init(0.0, 1.0, 0.0);
    const dist_to_focus = 10.0;
    const aperture = 0.1;
    const cam: Camera = Camera.init(look_from, look_at, vup, 20.0, aspect_ratio, aperture, dist_to_focus);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("P3\n{} {}\n255\n", .{ image_width, image_height });

    var j: i32 = image_height - 1;
    while (j >= 0) : (j -= 1) {
        std.log.err("\rScanlines remaining: {}", .{j});
        var i: i32 = 0;
        while (i < image_width) : (i += 1) {
            var k: i32 = 0;
            var pixel_color: Vec3 = Vec3.init(0.0, 0.0, 0.0);
            while (k <= num_samples) : (k += 1) {
                const u: f32 = (@intToFloat(f32, i) + rnd.float(f32)) / @intToFloat(f32, image_width - 1);
                const v: f32 = (@intToFloat(f32, j) + rnd.float(f32)) / @intToFloat(f32, image_height - 1);
                pixel_color = pixel_color.add(ray_color(cam.get_ray(u, v, rnd), world, 50, rnd));
            }
            try write_color(stdout, pixel_color, num_samples);
        }
    }

    std.log.err("\rDone.", .{});
}

fn write_color(out: std.fs.File.Writer, vec: Vec3, numSamples: i32) !void {
    const scale = 1.0 / @intToFloat(f32, numSamples);
    const r: f32 = math.clamp(math.sqrt(vec.x * scale), 0.0, 0.999);
    const g: f32 = math.clamp(math.sqrt(vec.y * scale), 0.0, 0.999);
    const b: f32 = math.clamp(math.sqrt(vec.z * scale), 0.0, 0.999);
    try out.print("{} {} {}\n", .{ @floatToInt(i32, r * 256), @floatToInt(i32, g * 256), @floatToInt(i32, b * 256) });
}

fn ray_color(r: Ray, world: ArrayList(Sphere), depth: u32, rnd: Random) Vec3 {
    if (depth == 0) {
        return Vec3.init(0.0, 0.0, 0.0);
    }
    var i: usize = 0;
    var rec: HitRecord = undefined;
    var tempRec: HitRecord = undefined;
    var closest: f32 = 100000.0;
    var hitAnything: bool = false;

    while (i < world.items.len) : (i += 1) {
        var elem = world.items[i];
        if (elem.hit(r, 0.001, closest, &tempRec)) {
            closest = tempRec.t;
            rec = tempRec;
            hitAnything = true;
        }
    }
    if (hitAnything) {
        var scattered: Ray = undefined;
        var attenuation: Vec3 = undefined;
        if (rec.materialScatterFn(rec.mat, r, rec, rnd, &attenuation, &scattered)) {
            return attenuation.mul(ray_color(scattered, world, depth - 1, rnd));
        }
        return Vec3.init(0.0, 0.0, 0.0);
    }

    const unit_direction: Vec3 = r.dir.unitVec();
    const t = 0.5 * (unit_direction.y + 1.0);
    return Vec3.init(1.0, 1.0, 1.0).mulVal(1.0 - t).add(Vec3.init(0.5, 0.7, 1.0).mulVal(t));
}

fn hit_sphere(center: Vec3, radius: f32, r: Ray) f32 {
    const oc: Vec3 = r.orig.sub(center);
    const a: f32 = r.dir.len2();
    const half_b: f32 = oc.dot(r.dir);
    const c = oc.len2() - radius * radius;
    const discriminant = half_b * half_b - a * c;
    if (discriminant < 0.0) {
        return -1.0;
    } else {
        return (-half_b - std.math.sqrt(discriminant)) / a;
    }
}
