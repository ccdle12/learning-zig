// Simple Linkedlist
//
// A Node with { value, *next, *previous };
//
// Want to know:
// - head
// - tail
const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const testing = std.testing;

// To do generics in zig, we need to return a struct from a function. Usually
// with an internal type (Node). We can think of this function as a sort of
// factory.
fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            value: T,
            next: ?*Node = null,
            prev: ?*Node = null,
        };

        head: ?*Node = null,
        tail: ?*Node = null,
        len: usize = 0,
        allocator: *Allocator,

        // NOTE: Seems to be the idiomatic way to pass construct a struct and
        // pass in an allocator.
        pub fn init(allocator: *Allocator) Self {
            return Self{
                .allocator = allocator,
            };
        }

        pub fn insert(self: *Self, value: T) !void {
            defer self.len += 1;

            const node = try self.allocator.create(Node);
            errdefer self.allocator.destroy(node);
            node.*.value = value;

            if (self.head == null) {
                self.head = node;
                return;
            }

            if (self.tail == null) {
                self.head.?.next = node;
                self.tail = node;
                return;
            }

            self.tail.?.next = node;
            self.tail = node;

            return;
        }

        pub fn value_at_index(self: *Self, index: usize) ?*T {
            var i: usize = 0;
            var cur: *Node = self.head.?;

            // TODO: Return an error instead or maybe option is ok?
            // TODO: Improve iteration
            while (i <= index) : (i += 1) {
                if (i == index) {
                    return &cur.value;
                }

                cur = cur.next.?;
            }

            return null;
        }

        pub fn remove(self: *Self, index: usize) !void {
            // TODO: What if we try to decrement this below 0?
            if (self.len > 0) {
                defer self.len -= 1;
            }

            if (index >= self.len) {
                return;
            }

            if (index == 0) {
                var old_head = self.head.?;
                var new_head = self.head.?.next;

                self.head = new_head;
                self.allocator.destroy(old_head);

                return;
            }

            // TODO: Swap the positions of prev, cur, next while iterating.
            // 1. Look up index and remove.
            var i: usize = 0;
            var prev: *Node = self.head.?;
            var cur: *Node = prev.next.?;
            var next: *Node = cur.next.?;

            // TODO: This is gross.
            while (i <= index) : (i += 1) {
                var cur_index = i + 1;

                // TODO: Need to handle, what if we are at tail?
                if (cur_index == index) {
                    prev.next = next;
                    self.allocator.destroy(cur);
                    return;
                }

                prev = cur;
                cur = next;
                next = cur.next.?;
            }

            return;
        }
    };
}

test "Init Node" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const List = LinkedList(u8);
    var list = List.init(&arena.allocator);

    try list.insert(1); // {1}
    try expect(list.head.?.value == 1);
    try expect(list.len == 1);

    try list.insert(2); // {1, 2}
    try expect(list.head.?.value == 1);
    try expect(list.value_at_index(1).?.* == 2);
    try expect(list.len == 2);

    try list.insert(3); // {1, 2, 3}
    try expect(list.head.?.value == 1);
    try expect(list.head.?.next.?.value == 2);
    try expect(list.tail.?.value == 3);
    try expect(list.len == 3);

    try expect(list.value_at_index(0).?.* == 1);
    try expect(list.value_at_index(1).?.* == 2);
    try expect(list.value_at_index(2).?.* == 3);

    try list.remove(1); // {1, 3}
    try expect(list.head.?.value == 1);
    try expect(list.head.?.next.?.value == 3);
    try expect(list.tail.?.value == 3);
    try expect(list.len == 2);

    try list.insert(4); // {1, 3, 4}
    try list.remove(0); // {3, 4}
    try expect(list.value_at_index(0).?.* == 3);
    try expect(list.value_at_index(1).?.* == 4);

    try list.insert(5); // {3, 4, 5}
    try expect(list.value_at_index(1).?.* == 4);
    try expect(list.value_at_index(2).?.* == 5);
    try list.remove(2); // {3, 4}
    try expect(list.value_at_index(0).?.* == 3);
    try expect(list.value_at_index(1).?.* == 4);

    // TODO: Move to another test.
    // Attemp to remove index greater than list length.
    try list.remove(2);
    try list.remove(3);
}

test "remove() edge cases" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const List = LinkedList(u8);
    var list = List.init(&arena.allocator);

    try list.insert(1); // {1}
    try expect(list.head.?.value == 1);
    try expect(list.len == 1);

    try list.remove(0);
    try expect(list.len == 0);
    try list.remove(0);
}
