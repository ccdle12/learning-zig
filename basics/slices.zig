const expect = @import("std").testing.expect;
const print = @import("std").debug.print;

fn total(values: []const u8) usize {
    var count: usize = 0;
    for (values) |v| count += v;

    return count;
}

test "slices" {
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    try expect(total(slice) == 6);
}

// If the range n and m are known at compile time, then slicing will actually
// produce a pointer to an array.
test "slices 2" {
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    try expect(@TypeOf(slice) == *const [3]u8);
}

// x[n..] will slice to the end
test "slices 3" {
    var array = [_]u8{ 1, 2, 3, 4, 5 };
    var slice = array[0..];

    // So this is no longer a pointer?
    try expect(@TypeOf(slice) == *[5]u8);
}
