const std = @import("std");
const ArrayList = std.ArrayList;
const net = std.net;
const p2p = @import("p2p.zig");

pub fn main() !void {
    // TODO: Change peer array into ArrayList and place mutex over it.
    var peer_list = [2]p2p.Peer{
        p2p.Peer{ .addr = try net.Address.parseIp("127.0.0.1", 9001) },
        p2p.Peer{ .addr = try net.Address.parseIp("127.0.0.1", 9002) },
    };

    var connect_peers_fn = async p2p.connectPeers(&peer_list);
    nosuspend await connect_peers_fn;

    // TODO: This is just for demo purposes, to force the network to gossip.
    var broadcast_fn = async p2p.broadcast(&peer_list);
    nosuspend await broadcast_fn;

    var p2p_server = net.StreamServer.init(.{});
    try p2p_server.listen(net.Address.parseIp("127.0.0.1", 9000) catch unreachable);
    defer p2p_server.deinit();

    var p2p_server_thread = try std.Thread.spawn(.{}, p2p.listen, .{&p2p_server});
    defer p2p_server_thread.detach();

    while (true) {
        std.debug.print("Length of event_queue: {d}\n", .{p2p.event_queue.len});

        if (p2p.event_queue.popFirst()) |item| resume item.data.frame;
        std.time.sleep(1000 * std.time.ns_per_ms);
    }
}
