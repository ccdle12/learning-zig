const print = @import("std").debug.print;
const expect = @import("std").testing.expect;

test "if statement" {
    const a = true;

    var x: u16 = 0;
    if (a) {
        x += 1;
    } else {
        x += 2;
    }

    try expect(x == 1);
}

test "if expression" {
    const a = true;
    var x: u16 = 0;

    x += if (a) 1 else 2;

    try expect(x == 1);
}

test "while" {
    var i: u8 = 2;
    while (i < 100) {
        i *= 2;
        print("While test: i iteration: {d}\n", .{i});
    }

    print("While test: i final: {d}\n", .{i});
    try expect(i == 128);
}

test "while with continue expression" {
    var sum: u8 = 0;
    var i: u8 = 0;

    while (i <= 3) : (i += 1) {
        if (i == 2) continue;
        sum += i;
    }

    try expect(sum == 4);
}

test "while with break" {
    var sum: u8 = 0;
    var i: u8 = 0;

    while (i <= 3) : (i += 1) {
        if (i == 2) break;
        sum += 1;
    }

    print("Result: {d}\n", .{sum});
    try expect(sum == 2);
}

test "for" {
    const string = [_]u8{ 'a', 'b', 'c' };

    for (string) |character, index| {
        print("Character and index: {u} | {d}\n", .{ character, index });
    }

    // Can omit the index iterator.
    for (string) |character| {}

    // Can omit the character
    for (string) |_, index| {}

    for (string) |_| {}
}
