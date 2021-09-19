const std = @import("std");
const os = std.os;
const net = std.net;

// TODO: Read Beejs tutorial and make sure I understand each flag
pub fn main() !void {
    const fd = try os.socket(os.AF.INET, os.SOCK.STREAM, os.IPPROTO.TCP);
    var server = try net.Address.parseIp("127.0.0.1", 9000);

    try os.connect(fd, &server.any, @sizeOf(os.sockaddr));

    var buf: [1024]u8 = undefined;
    while (true) {
        const bytes = try os.read(fd, &buf);
        std.debug.print("Received bytes num: {d}", .{bytes});
        std.debug.print("Received in msg buf: {d}", .{buf});
    }
}
