const std = @import("std");

var timer: ?std.time.Timer = null;
fn nanotime() u64 {
    if (timer == null) {
        timer = std.time.Timer.start() catch unreachable;
    }

    return timer.?.read();
}

// holds the frame and the nanotime of when the frame should be resumed.
const Delay = struct { frame: anyframe, expires: u64 };

// suspend the caller, to be resumed later by the event loop.
fn waitForTime(time_ms: u64) void {
    suspend timer_queue.add(Delay{
        .frame = @frame(),
        .expires = nanotime() + (time_ms * std.time.ns_per_ms),
    }) catch unreachable;
}

fn waitUntilAndPrint(
    time1: u64,
    time2: u64,
    name: []const u8,
) void {
    const start = nanotime();

    // suspend self, to be woken up when time1 has passed.
    std.debug.print("before first waitForTime\n", .{});
    waitForTime(time1);
    std.debug.print(
        "[{s}] it is now {} ms since start!\n",
        .{ name, (nanotime() - start) / std.time.ns_per_ms },
    );
    std.debug.print("after first waitForTime\n", .{});

    // suspend self, to be woken up when time2 has passed.
    waitForTime(time2);
    std.debug.print(
        "[{s}] it is now {} ms since start!\n",
        .{ name, (nanotime() - start) / std.time.ns_per_ms },
    );
}

fn asyncMain() void {
    // stores the async frames of our task
    var tasks = [_]@Frame(waitUntilAndPrint){
        async waitUntilAndPrint(1000, 1200, "task-pair a"),
        async waitUntilAndPrint(500, 1300, "task-pair b"),
    };

    for (tasks) |*t| await t;
}

// priority queue of tasks
// lower .expires => higher priortiy => to be executed before
var timer_queue: std.PriorityQueue(Delay) = undefined;
fn cmp(a: Delay, b: Delay) std.math.Order {
    return std.math.order(a.expires, b.expires);
}

pub fn main() !void {
    timer_queue = std.PriorityQueue(Delay).init(std.heap.page_allocator, cmp);
    defer timer_queue.deinit();

    std.debug.print("1. after init the PriorityQueue\n", .{});
    var main_task = async asyncMain();
    std.debug.print("2. after calling asyncMain()\n", .{});

    // the body of the event loop
    // pops the task which is to be next executed
    while (timer_queue.removeOrNull()) |delay| {
        std.debug.print("popping from queue: {d} ms\n", .{delay.expires / std.time.ns_per_ms});
        // wait until it is time to execute the next task
        const now = nanotime();
        if (now < delay.expires) {
            std.time.sleep(delay.expires - now);
        }

        // execute the next task
        resume delay.frame;
    }
    std.debug.print("3. after event loop\n", .{});

    nosuspend await main_task;
    std.debug.print("4. end\n", .{});
}
