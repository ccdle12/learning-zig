const std = @import("std");
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;
const os = std.os;
const net = std.net;

const Node = struct {
    addr: net.Address,
    socket: ?os.socket_t = null,
};

const LoopFrame = struct { frame: anyframe };

pub fn main() !void {
    const this_port = 9001;

    var peer_list: [3]Node = undefined;
    var i: u16 = 0;
    while (i < 3) : (i += 1) {
        const port = 9000 + i;
        if (this_port == port) continue;

        std.debug.print("Adding peer: {d}\n", .{port});

        peer_list[i] = Node{ .addr = try net.Address.parseIp("127.0.0.1", port) };
    }

    for (peer_list) |_, index| {
        var fd = os.socket(os.AF.INET, os.SOCK.STREAM, os.IPPROTO.TCP) catch unreachable;

        var peer = &peer_list[index];
        os.connect(fd, &peer.addr.any, @sizeOf(os.sockaddr)) catch continue;
        peer.socket = fd;
    }

    var server = net.StreamServer.init(.{});
    defer server.deinit();

    try server.listen(net.Address.parseIp("127.0.0.1", this_port) catch unreachable);
    std.debug.warn("listening at {}\n", .{server.listen_address});

    while (true) {
        std.debug.print("main loop in node2\n", .{});
        var conn = try server.accept();
        var buf: [1024]u8 = undefined;
        _ = try conn.stream.read(&buf);
        std.debug.print("Received msg: {d}\n", .{buf});
    }
}
