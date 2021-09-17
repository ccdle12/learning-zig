const std = @import("std");
const expect = std.testing.expect;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;
const eql = std.mem.eql;

test "io writer usage" {
    var list = ArrayList(u8).init(test_allocater);
    defer list.deinit();

    const bytes_written = try list.writer().write("Hello World!",);

    try expect(bytes_written == 12);
    try expect(eql(u8, list.items, "Hello World!"));
}

// Use a file reader to alloc space according to the size of the input and
// copy it's contents into a newly returned buffer that is owned by the caller.
test "io reader usage" {
    const message = "Hello File!";

    const file = try std.fs.cwd().createFile(
        "junk_file2.txt",
        .{ .read = true },
    );
    defer file.close();

    try file.writeAll(message);
    try file.seekTo(0);
    
    const contents = try file.reader().readAllAlloc(
        test_allocator,
        message.len
    );
    defer test_allocator.free(contents);

    try expect(eql(u8, contents, message));
}

// Common pattern for reading user input.
fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    var line = (try reader.readUntilDelimiterOrEof(
            buffer,
            '\n',
    )) orelse return null;

    if (std.builtin.os.tag == .windows) {
        line = std.mem.trimRight(u8, line, '\r');
    }

    return line;

}

test "read until next line" {
    const stdout = std.io.getStdOut();
    const stdin = std.io.getStdIn();

    try stdout.writeAll("ccdle12");

    var buffer: [100]u8 = undefined;
    const input = (try nextLine(stdin.reader(), &buffer)).?;
    try stdout.writer().print("Your name is: \"{s}\"\n", .{input});
}
