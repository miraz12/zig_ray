const std = @import("std");

pub fn main() anyerror!void {
    const image_width: i32 = 256;
    const image_height: i32 = 256;

    const stdout = std.io.getStdOut().writer();
    try stdout.print("P3\n{} {}\n255\n", .{ image_width, image_height });

    var j: i32 = image_height - 1;
    while (j >= 0) : (j -= 1) {
        var i: i32 = 0;
        while (i < image_width) : (i += 1) {
            const r: f32 = @intToFloat(f32, i) / @intToFloat(f32, image_width - 1);
            const g: f32 = @intToFloat(f32, j) / @intToFloat(f32, image_height - 1);
            const b: f32 = 0.25;

            const ir = @floatToInt(i32, 255.999 * r);
            const ig = @floatToInt(i32, 255.999 * g);
            const ib = @floatToInt(i32, 255.999 * b);

            try stdout.print("{} {} {}\n", .{ ir, ig, ib });
        }
    }
}
