const expect = @import("std").testing.expect;

// Loops can be used as expressions.
// break true - break the loop and return true
// else statement can be used after while
fn rangeHasNumber(begin: usize, end: usize, number: usize) bool {
    var i = begin;

    return while (i < end) : (i += 1) {
        if (i == number) {
            break true;
        }
    } else false;
}

test "while loop expression" {
    try expect(rangeHasNumber(0, 10, 3));
}
