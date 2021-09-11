const expect = @import("std").testing.expect;

// Optionals use the syntax ?T - it stores null or T.
test "optional" {
    var found_index: ?usize = null;
    const data = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 12 };

    for (data) |v, i| {
        if (v == 10) found_index = i;
    }

    try expect(found_index == null);
}

// orelse unwraps the optional or returns somethingelse
test "orelse" {
    var a: ?f32 = null;
    var b = a orelse 0;

    try expect(b == 0);
    try expect(@TypeOf(b) == f32);
}

// .? is shorthand for orelse unreachable, when we know its impossible for an
// optional value to be null.
test "orelse unreachable" {
    const a: ?f32 = 5;
    const b = a orelse unreachable;
    const c = a.?;
    try expect(b == c);
}

// if (b) |value| {} will capture the value if theres some and will copy it into
// value and go to the scoped {}.
test "if optional payload capture" {
    const a: ?i32 = 5;
    if (a != null) {
        const value = a.?;
        try expect(value == 5);
    }

    const b: ?i32 = 5;
    if (b) |value| {
        try expect(value == 5);
    }
}

var numbers_left: u32 = 4;

fn eventuallyNullSequence() ?u32 {
    if (numbers_left == 0) return null;
    numbers_left -= 1;

    return numbers_left;
}

test "while null capture" {
    var sum: u32 = 0;
    while (eventuallyNullSequence()) |value| {
        sum += value;
    }

    try expect(sum == 6);
}
