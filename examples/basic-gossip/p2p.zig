const std = @import("std");
const ArrayList = std.ArrayList;
const ArrayListAligned = std.ArrayListAligned;
const net = std.net;
const os = std.os;

pub const EventFrame = struct { frame: anyframe };

pub const tailQueue = std.TailQueue(EventFrame);
pub var event_queue = tailQueue{};

// TODO: Maybe create a list of inbound and outbound???
pub const Peer = struct {
    // For outbound peers.
    addr: net.Address,
    socket: ?os.socket_t = null,

    // For inbound peers.
    conn: ?net.StreamServer.Connection = null,
};

// Only for demo purposes to force a gossip on an interval.
pub fn tryBroadcast(peer_list: *[2]Peer) void {
    while (true) {
        for (peer_list) |peer| {
            std.debug.print("Each peer in broadcast: {d}\n", .{peer.addr});
            if (peer.socket != null) {
                _ = os.write(peer.socket.?, "msg") catch |err| {
                    std.debug.print("Error broadcasting: {u}\n", .{err});
                };
            }
        }

        suspend event_queue.append(&tailQueue.Node{ .data = EventFrame{ .frame = @frame() } });
    }

    std.debug.print("Exiting tryBroadcast \n", .{});
    return;
}

pub fn broadcast(peer_list: *[2]Peer) void {
    var tasks = [_]@Frame(tryBroadcast){
        async tryBroadcast(peer_list),
    };

    for (tasks) |*t| await t;
}

// TODO: Pass a list to be mutated and should have a lock. Acquire the lock
// and add the peer using the conn.
//
// Caller should call this function in a dedicated thread.
pub fn listen(server: *net.StreamServer) void {
    while (true) {
        std.debug.print("in p2p listen loop\n", .{});
        var conn = server.accept() catch unreachable;
        _ = conn;
    }
}

pub fn tryConnect(peer: *Peer) void {
    var fd = os.socket(os.AF.INET, os.SOCK.STREAM, os.IPPROTO.TCP) catch unreachable;

    while (peer.socket == null) {
        std.debug.print("Peer addr: {d}\n", .{peer.addr.in});

        os.connect(fd, &peer.addr.any, @sizeOf(os.sockaddr)) catch |err| {
            std.debug.print("Error connecting: {u}\n", .{err});
            peer.socket = null;
            suspend event_queue.append(&tailQueue.Node{ .data = EventFrame{ .frame = @frame() } });
            continue;
        };

        peer.socket = fd;
    }

    std.debug.print("Peer connected: {d}\n", .{peer.addr.in});
}

pub fn connectPeers(peer_list: *[2]Peer) void {
    var tasks = [_]@Frame(tryConnect){
        async tryConnect(&peer_list[0]),
        async tryConnect(&peer_list[1]),
    };

    for (tasks) |*t| await t;
}
