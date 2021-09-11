const expect = @import("std").testing.expect;

// Unreachable is an assertion to the compiler that a statement will never be reached.
// By telling the compiler that some path is not possible, the optimizer will use
// this information.

// In tests, unreachable will cause a panic
// test "unreachable" {
// const x: i32 = 1;
// const y: u32 = if (x == 2) 5 else unreachable;

// try expect(y == 5);
// }

fn asciiToUpper(x: u8) u8 {
    return switch (x) {
        'a'...'z' => x + 'A' - 'a',
        'A'...'Z' => x,
        else => unreachable,
    };
}

test "unreachable switch" {
    try expect(asciiToUpper('a') == 'A');
    try expect(asciiToUpper('A') == 'A');
}
