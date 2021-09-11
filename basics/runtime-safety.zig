const print = @import("std").debug.print;

// This would not compile because of the runtimesafety being on and trying
// to access an index that is out of bounds.
// test "out of bounds" {
// const a = [3]u8{ 1, 2, 3 };
// var index: u8 = 5;
// const b = a[index];
// print("B: {d}\n", .{b});
// }

// By disabling runtime safety, this would cause unexpected behaviour but still
// passes.
test "out of bounds" {
    @setRuntimeSafety(false);
    const a = [3]u8{ 1, 2, 3 };
    var index: u8 = 5;
    const b = a[index];
    print("B: {x}\n", .{b});
}
