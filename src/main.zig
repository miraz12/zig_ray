const std = @import("std");
const vec3 = @import("vector.zig").Vector3;
const ray = @import("ray.zig").Ray;
const hittable = @import("hittables.zig").Ray;
const expect = std.testing.expect;

pub fn main() anyerror!void {
    // Image
    const aspect_ratio: f32 = 16.0 / 9.0;
    const image_width: i32 = 1080;
    const image_height: i32 = @floatToInt(i32, @intToFloat(f32, image_width) / aspect_ratio);

    // Camera
    const viewport_height: f32 = 2.0;
    const viewport_width: f32 = aspect_ratio * viewport_height;
    const focal_length: f32 = 1.0;

    const origin: vec3 = vec3.init(0.0, 0.0, 0.0);
    const horizontal: vec3 = vec3.init(viewport_width, 0.0, 0.0);
    const vertical: vec3 = vec3.init(0.0, viewport_height, 0.0);
    const lower_left_corner: vec3 = origin.sub(horizontal.divVal(2)).sub(vertical.divVal(2)).sub(vec3.init(0.0, 0.0, focal_length));

    const stdout = std.io.getStdOut().writer();
    try stdout.print("P3\n{} {}\n255\n", .{ image_width, image_height });

    var j: i32 = image_height - 1;
    while (j >= 0) : (j -= 1) {
        std.log.err("\rScanlines remaining: {}", .{j});
        var i: i32 = 0;
        while (i < image_width) : (i += 1) {
            const u: f32 = @intToFloat(f32, i) / @intToFloat(f32, image_width - 1);
            const v: f32 = @intToFloat(f32, j) / @intToFloat(f32, image_height - 1);
            const r: ray = ray.init(origin, lower_left_corner.add(horizontal.mulVal(u)).add(vertical.mulVal(v)).sub(origin));
            const pixel_color: vec3 = ray_color(r);
            try write_color(stdout, pixel_color);
        }
    }

    std.log.err("\rDone.", .{});
}

fn write_color(out: std.fs.File.Writer, vec: vec3) !void {
    try out.print("{} {} {}\n", .{ @floatToInt(i32, vec.x * 255.999), @floatToInt(i32, vec.y * 255.999), @floatToInt(i32, vec.z * 255.999) });
}

fn ray_color(r: ray) vec3 {
    var t: f32 = hit_sphere(vec3.init(0.0, 0.0, -1.0), 0.5, r);
    if (t > 0.0) {
        const N: vec3 = (r.at(t).sub(vec3.init(0.0, 0.0, -1.0))).unitVec();
        return vec3.init(N.x + 1.0, N.y + 1.0, N.z + 1.0).mulVal(0.5);
    }
    const unit_direction: vec3 = r.dir.unitVec();
    t = 0.5 * (unit_direction.y + 1.0);
    return vec3.init(1.0, 1.0, 1.0).mulVal(1.0 - t).add(vec3.init(0.5, 0.7, 1.0).mulVal(t));
}

fn hit_sphere(center: vec3, radius: f32, r: ray) f32 {
    const oc: vec3 = r.orig.sub(center);
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
