const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;

fn ticker(step: u8) void {
    while (tick < 3) {
        std.time.sleep(1 * std.time.ns_per_s);
        tick += @as(isize, step);
        print("\nTicking... {d}", .{tick});
    }
}

var tick: isize = 0;

test "threading" {
    var thread = try std.Thread.spawn(.{}, ticker, .{@as(u8, 1)});
    _ = thread;

    try expect(tick == 0);
    std.time.sleep(3 * std.time.ns_per_s / 2);
    try expect(tick == 1);

    thread.join();
}
