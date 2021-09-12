const std = @import("std");
const meta = std.meta;
const expect = std.testing.expect;
const Vector = meta.Vector;

test "test vector" {
    const x: Vector(4, f32) = .{ 1, -10, 20, -1 };
    const y: Vector(4, f32) = .{ 2, 10, 0, 1 };
    const z = x + y;

    try expect(meta.eql(z, Vector(4, f32){ 3, 0, 20, 0 }));
}

test "vector indexing" {
    const x: Vector(4, u8) = .{ 255, 0, 255, 0 };
    try expect(x[0] == 255);
}

test "vector * scalar" {
    const x: Vector(3, f32) = .{ 12.5, 37.5, 2.5 };

    // Splat produces a vector of length of type.
    // We can multiple all internal values of vector and the @splat to return
    // a new vector with all the values multiplied.
    //
    // Both vectors need to be of the same length.
    const y = x * @splat(3, @as(f32, 2));

    try expect(meta.eql(y, Vector(3, f32){ 25, 75, 5 }));
}

// Vectors don't have a len field like arrays, but we can find the length using
// std.men.len.
const len = std.mem.len;

test "vector looping" {
    const x = Vector(4, u8){ 255, 0, 255, 0 };
    var sum = blk: {
        var tmp: u10 = 0;
        var i: u8 = 0;

        while (i < len(x)) : (i += 1) tmp += x[i];
        break :blk tmp;
    };

    try expect(sum == 510);
}
