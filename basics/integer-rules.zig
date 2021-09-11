const expect = @import("std").testing.expect;

const decimal_int: i32 = 9822;
const hex_int: u8 = 0xff;
const another_hex_int: u8 = 0xFF;
const octal_int: u16 = 0o755;
const binary_int: u8 = 0b11110000;

const one_billion: u64 = 1_000_000_000;

// Integers can be coerced into another integer type if the other integer type
// is larger.
test "integer widening" {
    const a: u8 = 250;
    const b: u16 = a;
    const c: u32 = b;
    try expect(c == a);
}

// @intCast will be used to explicity convert from one type to another.
// This will only work if if the value can fit into the other type.
test "@intCast" {
    const x: u64 = 200;
    const y = @intCast(u8, x);

    try (expect(@TypeOf(y) == u8));
}

// Overflows are detectable illegal behaviour.
// Overflows can be forced using wrapping operators.
//
// Wrapping Operators:
// +%
// -%
// *%
// +%=
// -%=
// *%=
test "well defined overflow" {
    var a: u8 = 255;
    a +%= 1;
    try expect(a == 0);
}
