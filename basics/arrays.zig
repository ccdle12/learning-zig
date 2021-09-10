const std = @import("std");

pub fn main() void {
    const a = [5]u8{ 'h', 'e', 'l', 'l', 'o' };
    const b = [_]u8{ 'w', 'o', 'r', 'l', 'd' };

    const length = a.len;
    std.debug.print("Length: {x}\n", .{length});
}
