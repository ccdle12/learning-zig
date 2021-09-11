const expect = @import("std").testing.expect;

// A block is an express that can be given a label and yields values.
test "labelled blocks" {
    const count = blk: {
        var sum: u32 = 0;
        var i: u32 = 0;

        while (i < 10) : (i += 1) sum += 1;
        break :blk sum;
    };

    try expect(count == 10);
    try expect(@TypeOf(count) == u32);
}
