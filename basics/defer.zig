const expect = @import("std").testing.expect;

test "defer" {
    var x: i16 = 5;

    {
        defer x += 2;
        try expect(x == 5);
    }

    try expect(x == 7);
}

// multiple defers are exectued in reverse order.
test "multi defer" {
    var x: u8 = 6;

    {
        defer x += 2;
        defer x /= 2;
    }

    try expect(x == 5);
}
