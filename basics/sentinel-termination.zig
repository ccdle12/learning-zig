const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;

// So we can add a child type of an array to be used as the termination value.
// In this case,  we are using 0 as the termination value. So I think we would
// use stuff like... iterate until 'termination character'
test "sentinel termination" {
    const terminated = [3:0]u8{ 3, 2, 1 };
    print("terminated: {d}\n", .{terminated});
    try expect(terminated.len == 3);

    const x = @bitCast([4]u8, terminated);
    print("x after bitcast with terminated: {d}\n", .{terminated});
    try expect(x.len == 4);
    try expect(x[3] == 0);
}

test "string literal" {
    try expect(@TypeOf("hello") == *const [5:0]u8);
}

// Sentinel termination works well with C strings. We have a c string terminated
// with 0, indicated by [*:0].
test "C string" {
    const c_string: [*:0]const u8 = "hello";
    var array: [5]u8 = undefined;

    var i: usize = 0;
    while (c_string[i] != 0) : (i += 1) {
        array[i] = c_string[i];
    }
}

// test "coercion" {
// var a: [*:0]u8 = undefined;
// const b: [*]u8 = a;

// var c: [5:0]u8 = undefined;
// const d: [5]u8 = c;

// var e: [:10]f32 = undefined;
// const f = e;
// }

// test "sentinel terminated slicing" {
// var x = [_:0]u8{255} ** 3;
// print("x: {d}\n", x);

// const y = x[0..3 :0];
// print("y: {d}\n", y);
// }
