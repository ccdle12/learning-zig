const std = @import("std");
const math = std.math;

const expect = std.testing.expect;
const floor = math.floor;

fn PriorityQueue(comptime T: type, size: usize) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            value: T,
            priority: u32,
        };

        heap: [size]Node,

        pub fn init() Self {
            var pq_nodes: [size]Self.Node = undefined;
            for (pq_nodes) |*node| node.* = .{ .value = 0, .priority = 0 };
            return Self{ .heap = pq_nodes };
        }

        pub fn peek(self: *Self) T {
            return self.heap[0].value;
        }

        pub fn pop(self: *Self) T {
            const value = self.peek();

            self.heap[0] = self.heap[size - 1];
            self.heapify_down(0);

            return value;
        }

        // Time Complexity: O(log n)
        fn heapify_down(self: *Self, index: usize) void {
            var current = index;
            var largest = current;
            var left = self.left_child(largest);
            var right = self.right_child(largest);

            while (largest < size - 1) {
                if (left < size and self.heap[index].priority < self.heap[left].priority) {
                    largest = left;
                }

                if (right < size and self.heap[largest].priority < self.heap[right].priority) {
                    largest = right;
                }

                if (largest == current) return;

                self.swap(largest, current);
                current = largest;
                largest = current;
                left = self.left_child(largest);
                right = self.right_child(largest);
            }
        }

        pub fn push(self: *Self, value: T, priority: u32) void {
            const node = Self.Node{ .value = value, .priority = priority };
            self.heap[size - 1] = node;

            self.heapify_up(size - 1);
        }

        // Time Complexity: O(log n)
        fn heapify_up(self: *Self, index: usize) void {
            var current = index;
            while (current > 0) {
                const parent = self.parent_index(current);
                if (self.heap[parent].priority > self.heap[current].priority)
                    return;

                self.swap(parent, current);
                current = parent;
            }
        }

        inline fn left_child(self: *Self, index: usize) usize {
            _ = self;
            return (2 * index) + 1;
        }

        inline fn right_child(self: *Self, index: usize) usize {
            _ = self;
            return (2 * index) + 2;
        }

        inline fn parent_index(self: *Self, index: usize) usize {
            _ = self;
            return (index - 1) / 2;
        }

        inline fn swap(self: *Self, a: usize, b: usize) void {
            var tmp = self.heap[a];
            self.heap[a] = self.heap[b];
            self.heap[b] = tmp;
        }
    };
}

test "Priority Queue" {
    const priorityQueue = PriorityQueue(u8, 6);

    var pq = priorityQueue.init();
    pq.push(6, 6);

    try expect(pq.peek() == 6);
    try expect(pq.pop() == 6);

    pq.push(6, 6);
    pq.push(2, 5);
    pq.push(8, 2);
    pq.push(123, 1);
    pq.push(100, 9);
    pq.push(159, 7);

    try expect(pq.peek() == 100);
    try expect(pq.pop() == 100);
    try expect(pq.peek() == 159);

    pq.push(1, 200);
    try expect(pq.peek() == 1);
}
