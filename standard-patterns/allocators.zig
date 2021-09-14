const std = @import("std");
const expect = std.testing.expect;

// The most basic allocator is the std.heap.page_allocator. It will make a syscall
// to the OS for pages of memory.
test "allocation" {
    const allocator = std.heap.page_allocator;

    const memory = try allocator.alloc(u8, 100);
    defer allocator.free(memory);

    try expect(memory.len == 100);
    try expect(@TypeOf(memory) == []u8);
}

// An allocator that allocated memory into a fixed buffer.
test "fixed buffer allocator" {
    var buffer: [1000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    var allocator = &fba.allocator;

    const memory = try allocator.alloc(u8, 100);
    defer allocator.free(memory);

    try expect(memory.len == 100);
    try expect(@TypeOf(memory) == []u8);
}

// An arena allocator takes a child allocator and allows you to allocate many
// times and free once using `defer arena.deinit()`.
test "arena allocator" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = &arena.allocator;

    const m1 = try allocator.alloc(u8, 1);
    const m2 = try allocator.alloc(u8, 10);
    const m3 = try allocator.alloc(u8, 100);

    try expect(m1.len == 1);
    try expect(m2.len == 10);
    try expect(m3.len == 100);
}

// alloc and free are usually used with slices. For single items, use create
// and destory.
test "allocator create/destroy" {
    const byte = try std.heap.page_allocator.create(u8);
    defer std.heap.page_allocator.destroy(byte);

    byte.* = 128;
    try expect(byte.* == 128);
}

// Zig has a general purpose allocator. This is a safe allocator which can prevent
// double free, use-after-free and can detect leaks. The GPA is designed for saftey
// over performance. It apparently may still be faster than the page allocator.
test "GPA" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        if (leaked) expect(false) catch @panic("TEST FAIL");
    }

    const bytes = try gpa.allocator.alloc(u8, 100);
    defer gpa.allocator.free(bytes);
}
