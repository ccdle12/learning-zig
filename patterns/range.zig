const std = @import("std");

// A way to implement range that returns an array and we the caller can iterate
// over the array within a for loop.
//
// Probably should just be called fn range() when used outside of this example.
pub fn range_with_arr(comptime times: usize) [times]void {
    const arr: [times]void = undefined;
    return arr;
}

test "range with arr" {
    for (range_with_arr(10)) |_, i|
        try std.testing.expect(i < 10);
}

// Implementing range using an iterator and calling next().
//
// Probably should just be called fn range() when used outside of this example.
pub fn range_iter(times: usize) RangeIterator {
    return .{
        .cursor = 0,
        .stop = times,
    };
}

const RangeIterator = struct {
    cursor: usize,
    stop: usize,

    pub fn next(self: *RangeIterator) ?usize {
        if (self.cursor < self.stop) {
            defer self.cursor += 1;
            return self.cursor;
        }

        return null;
    }
};

test "range with iterator" {
    var it = range_iter(10);
    while (it.next()) |i|
        try std.testing.expect(i < 10);
}
