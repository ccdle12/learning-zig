const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

test "split iterator" {
    const text = "robust, optimal, reusable, maintainable, ";
    var iter = std.mem.split(u8, text, ", ");

    try expect(eql(u8, iter.next().?, "robust"));
    try expect(eql(u8, iter.next().?, "optimal"));
    try expect(eql(u8, iter.next().?, "reusable"));
    try expect(eql(u8, iter.next().?, "maintainable"));
    try expect(eql(u8, iter.next().?, ""));
    try expect(iter.next() == null);
}

// Needle is used to return a string that contains the "needle" character.
// In the example, we are using the character 'e'.
const ContainsIterator = struct {
    strings: []const []const u8, // 2d array
    needle: []const u8,
    index: usize = 0,

    fn next(self: *ContainsIterator) ?[]const u8 {
        const index = self.index;
        for (self.strings[index..]) |string| {
            self.index += 1;
            if (std.mem.indexOf(u8, string, self.needle)) |_| {
                return string;
            }
        }

        return null;
    }
};

// "two" won't be returned by the iterator because we are using the needle 'e'.
test "custom iterator" {
    var iter = ContainsIterator{
        .strings = &[_][]const u8{ "one", "two", "three" },
        .needle = "e",
    };

    try expect(eql(u8, iter.next().?, "one"));
    try expect(eql(u8, iter.next().?, "two"));
    try expect(iter.next() == null);
}
