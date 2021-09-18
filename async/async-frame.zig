const std = @import("std");
const expect = std.testing.expect;

fn add(a: i32, b: i32) i64 {
    return a + b;
}

// @Frame returns the frame type of the function, in the case a frame of add().
// @Frame(add)
test "@Frame" {
    var frame: @Frame(add) = async add(1, 2);
    try expect(await frame == 3);
}

// @frame() returns a pointer to the frame of the current function.
// All @frame() pointers coerce to `anyframe` type, which can use the `resume`
// keyword.
fn double(value: u8) u9 {
    suspend {
        resume @frame();
    }

    return value * 2;
}

test "@frame 1" {
    var f = async double(1);
    try expect(nosuspend await f == 2);
}

// We can use suspend, resumse and @frame to ask other functions to resume us.
fn callLater(comptime laterFn: fn () void, ms: u64) void {
    suspend {
        std.debug.print("Entered the suspend block!\n", .{});
        wakeupLater(@frame(), ms);
    }

    laterFn();
}

fn wakeupLater(frame: anyframe, ms: u64) void {
    std.time.sleep(ms * std.time.ns_per_ms);
    resume frame;
}

fn alarm() void {
    std.debug.print("Time's Up!\n", .{});
}

test "@frame 2" {
    var f = async callLater(alarm, 1000);
    nosuspend await f;
}

// anyframe is a kind of type erasure, but if we want to to know the return type
// then we can use `anyframe->T`
fn zero(comptime x: anytype) x {
    return 0;
}

fn awaiter(x: anyframe->f32) f32 {
    return nosuspend await x;
}

test "anyframe->T" {
    var frame = async zero(f32);
    try expect(awaiter(&frame) == 0);
}
