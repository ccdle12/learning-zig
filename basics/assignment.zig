const std = @import("std");

pub fn main() void {
    const constant: i32 = 5;
    var variable: u32 = 5000;

    const inferred_constant = @as(i32, 5); // as does explicit type conversion.
    var inferred_variable = @as(u32, 5000);

    // undefined can be used as no value, that can be coerced to any type
    // but needs to have a type annotation in order to be used.
    const a: i32 = undefined;
    var b: i32 = undefined;
}
