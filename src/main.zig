const std = @import("std");
const vecInc = @import("vector.zig");
const vec3 = vecInc.Vector3;
const expect = std.testing.expect;

pub fn main() anyerror!void {
    const image_width: i32 = 256;
    const image_height: i32 = 256;

    const stdout = std.io.getStdOut().writer();
    try stdout.print("P3\n{} {}\n255\n", .{ image_width, image_height });
    const vec: vec3 = vec3.init(0.0, 0.0, 0.0);
    std.log.err("hello: {}", .{vec.x});

    var j: i32 = image_height - 1;
    while (j >= 0) : (j -= 1) {
        std.log.err("\rScanlines remaining: {}", .{j});
        var i: i32 = 0;
        while (i < image_width) : (i += 1) {
            const pixel_color: vec3 = vec3.init(@intToFloat(f32, i) / @intToFloat(f32, image_width - 1), @intToFloat(f32, j) / @intToFloat(f32, image_height - 1), 0.25);
            try write_color(stdout, pixel_color);
        }
    }

    std.log.err("\rDone.", .{});
}

fn write_color(out: std.fs.File.Writer, vec: vec3) !void {
    try out.print("{} {} {}\n", .{@floatToInt(i32, vec.x * 255.999),
                                  @floatToInt(i32, vec.y * 255.999),
                                  @floatToInt(i32, vec.z * 255.999)});
}