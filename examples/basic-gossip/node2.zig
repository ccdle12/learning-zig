//! TODO:
//! A small gossip implementation that showcases using zig async.
//!
//! Requirements:
//!
//! - A Node has a list of peers that it will gossip messages to.
//! - A Node can receive a message from the peers and broadcast it to the rest
//! of the peers
//! - A Node needs to be able to connect to each peer of TCP
//! - A Node has an event loop, where it adds jobs to a Queue e.g.:
//!   - SendMessage {..}
//!   - ReceiveMessage {..}
//! - Allow for convenience sake, pass in a command line arg to start the different
//! nodes {node1, node2, node3} and hardcode the ports for each node.
//!
//! Tasks:
//!
//! - [x] Create a Node
//! - [x] Create a list of peers (Node)
//! - [x] Look up how to send a TCP message
//! - [] Create the Queue for the tasks
//! - [] Handle user args to create each node
//! - [] Maybe create another thread to listen for incoming connections?
//!   - [] Check how that works
//!
//! Stage 1:
//!
//! - [] OnStart:
//!   - [] Listen on the P2P Port (9000, 9001, 9002)
//!   - [x] Create a cache of peers
//!   - [] One node sends out a message to all the nodes in their cache
//!   - [] The nodes receive the message on their listening port, caches the
//!   received message and rebroadcasts
//!
//! Stage 2:
//! - [] Make Async
//! - [] Create an http or JSON server?
//!   - [] Send a message on that port and it rebroadcasts to the peers
//! - [] Loop event loop server?
//! - [] Pick up on user input to switch between the listening ports
//! - [] Don't send messages to ourselves
const std = @import("std");
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;
const os = std.os;
const net = std.net;

// TODO: Maybe instead create a std.Connection and we can add the Steam later?
const Node = struct {
    addr: net.Address,
    socket: ?os.socket_t = null,
};

// TODO: Might need to update this, right now it's just gonna hold a frame.
const LoopFrame = struct { frame: anyframe };

// TODO: Maybe just easier to create 3 files, {node1, node2, node3};
pub fn main() !void {
    const this_port = 9001;

    // TODO: Event Loop
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // var allocator = &gpa.allocator;
    // var queue = std.TailQueue();

    // TODO: extract
    var peer_list: [3]Node = undefined;
    var i: u16 = 0;
    while (i < 3) : (i += 1) {
        const port = 9000 + i;
        if (this_port == port) continue;

        std.debug.print("Adding peer: {d}\n", .{port});

        // TODO: Compare this node to node1, node2, node3 (expected port) and skip
        // adding the node if it matches the port.
        // try peer_list.append(Node{ .addr = try net.Address.parseIp("127.0.0.1", port) });
        peer_list[i] = Node{ .addr = try net.Address.parseIp("127.0.0.1", port) };
    }

    // TODO: At the moment gross, but just want to see how we can mutate the peer_list
    // with an fd.
    //
    // TODO: This should be in an async retry, so that we can keep trying to connect.
    for (peer_list) |_, index| {
        var fd = os.socket(os.AF.INET, os.SOCK.STREAM, os.IPPROTO.TCP) catch unreachable;

        var peer = &peer_list[index];
        os.connect(fd, &peer.addr.any, @sizeOf(os.sockaddr)) catch continue;
        peer.socket = fd;
    }

    // NOTE: Non-blocking
    // TODO: extract
    var server = net.StreamServer.init(.{});
    defer server.deinit();

    try server.listen(net.Address.parseIp("127.0.0.1", this_port) catch unreachable);
    std.debug.warn("listening at {}\n", .{server.listen_address});

    // NOTE: Blocking
    while (true) {
        std.debug.print("main loop in node2\n", .{});
        var conn = try server.accept();
        var buf: [1024]u8 = undefined;
        _ = try conn.stream.read(&buf);
        std.debug.print("Received msg: {d}\n", .{buf});
        // _ = try conn.stream.write("Welcome to the server");
    }
}
