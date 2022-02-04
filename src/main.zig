const std = @import("std");
const vector = std.meta.Vector;

pub fn main() anyerror!void {
    const image_width: i32 = 256;
    const image_height: i32 = 256;

    const stdout = std.io.getStdOut().writer();
    try stdout.print("P3\n{} {}\n255\n", .{ image_width, image_height });
    const vec: std.meta.Vector(3, f32) = [_]f32{0.0, 0.0, 0.0};
    std.log.err("hello: {}", .{vec[0]});

    var j: i32 = image_height - 1;
    while (j >= 0) : (j -= 1) {
        std.log.err("\rScanlines remaining: {}", .{j});
        var i: i32 = 0;
        while (i < image_width) : (i += 1) {
            const pixel_color: vector(3, f32) = [_]f32 {@intToFloat(f32, i) / @intToFloat(f32, image_width - 1), @intToFloat(f32, j) / @intToFloat(f32, image_height - 1), 0.25};
            try write_color(stdout, pixel_color);
        }
    }
    
    std.log.err("\rDone.", .{});
}

fn write_color(out: std.fs.File.Writer, vec: vector(3, f32)) !void {
    try out.print("{} {} {}\n", .{@floatToInt(i32, vec[0] * 255.999), 
                                  @floatToInt(i32, vec[1] * 255.999), 
                                  @floatToInt(i32, vec[2] * 255.999)});
}
