const expect = @import("std").testing.expect;
const print = @import("std").debug.print;

// Normal pointers aren't allowed to have 0 or null as a value.
//
// Referencing: &variable
// Pointer: *variable
// Deferencing: variable.*
fn increment(num: *u8) void {
    num.* += 1;
}

test "pointers" {
    var x: u8 = 1;
    increment(&x);
    try expect(x == 2);
}

// Cannot have a pointer to a value of 0.
test "naughty pointer" {
    var x: u16 = 0;
    var y: *u8 = @intToPtr(*u8, x);

    print("y: {d}", .{y});
}

// Similar to c++, we can have immutable pointers, using the const declartion of
// the variable.
//
// *T will coerce to a *const T
test "const pointers" {
    const x: u8 = 1;
    var y = &x;
    y.* += 1;
}

// Pointer size integers???
test "usize" {
    try expect(@sizeOf(usize) == @sizeOf(*u8));
    try expect(@sizeOf(isize) == @sizeOf(*u8));
}
