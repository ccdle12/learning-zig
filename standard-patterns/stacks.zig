const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;
const print = std.debug.print;

test "stack" {
    const string = "(()())";
    var stack = std.ArrayList(usize).init(test_allocator);
    defer stack.deinit();

    const Pair = struct { open: usize, close: usize };
    var pairs = std.ArrayList(Pair).init(test_allocator);
    defer pairs.deinit();

    for (string) |char, i| {
        if (char == '(') try stack.append(i);
        if (char == ')')
            try pairs.append(.{ .open = stack.pop(), .close = i });
    }

    for (pairs.items) |pair, i| {
        try expect(std.meta.eql(pair, switch (i) {
            0 => Pair{ .open = 1, .close = 2 },
            1 => Pair{ .open = 3, .close = 4 },
            2 => Pair{ .open = 0, .close = 5 },
            else => unreachable,
        }));
    }
}
