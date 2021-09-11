const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;
const print = std.debug.print;

// comptime_int are integer literals. They have no size and they can't be used
// at runtime. The values of comptime_int are coerced into any integer type
// that can hold them.
//
// Same with comptime_float, internally a f128, cannot be coerced into integers.
fn Matrix(
    comptime T: type,
    comptime width: comptime_int,
    comptime height: comptime_int,
) type {
    return [height][width]T;
}

test "returning a type" {
    try expect(Matrix(f32, 4, 4) == [4][4]f32);
    try expect(Matrix(u8, 3, 2) == [2][3]u8);
}

test "branching on types" {
    const a = 5;
    const b: if (a < 10) f32 else i32 = 5;

    try expect(@TypeOf(b) == f32);
}

// We can also switch on the type at comptime using @typeInfo.
fn addSmallInts(comptime T: type, a: T, b: T) T {
    // Switch on the type of T:
    //  - if the type is a .ComptimeInt is a builtin variant of the TypeId:
    //    - https://ziglang.org/documentation/0.5.0/#typeId
    //
    //  - Same with .Int, but I'm not sure what the difference is between the two
    //  at this stage
    //
    // If the type is not a .ComptimeInt, we'll check if it's bits is less than
    // 16 and if not, we'll panic with a compile time error.
    return switch (@typeInfo(T)) {
        .ComptimeInt => a + b,
        .Int => |info| if (info.bits <= 16)
            a + b
        else
            @compileError("ints too large"),
        else => @compileError("only ints accepted"),
    };
}

test "typeinfo switch" {
    const x = addSmallInts(u16, 20, 30);

    try expect(@TypeOf(x) == u16);
    try expect(x == 50);
}

// So this creates a new Int type that increments the bits size by 1 and just
// uses the same signedness. Very interesting.
fn GetBiggerInt(comptime T: type) type {
    return @Type(.{
        .Int = .{
            .bits = @typeInfo(T).Int.bits + 1,
            .signedness = @typeInfo(T).Int.signedness,
        },
    });
}

test "@Type" {
    try expect(GetBiggerInt(u8) == u9);
    try expect(GetBiggerInt(i31) == i32);
}

// Generic structs can made by returning a struct type.
// @This is used to get the inner most struct and is used as Self
// std.mem.eql is used to compare the two slices.
fn Vec(
    comptime count: comptime_int,
    comptime T: type,
) type {
    return struct {
        data: [count]T,
        const Self = @This();

        // It doesn't actually mutate the current struct data. It makes a copy
        // and returns the copy with absolute numbers.
        fn abs(self: Self) Self {
            var tmp = Self{ .data = undefined };
            for (self.data) |elem, i| {
                tmp.data[i] = if (elem < 0)
                    // Flips an integer to positive if it's negative.
                    -elem
                else
                    elem;
            }
            return tmp;
        }

        fn init(data: [count]T) Self {
            return Self{ .data = data };
        }
    };
}

test "generic vector" {
    const x = Vec(3, f32).init([_]f32{ 10, -10, 5 });

    // Return an a vector with absolute values (flip all negatives).
    const y = x.abs();
    try expect(eql(f32, &y.data, &[_]f32{ 10, 10, 5 }));
}

// Types of function parameters can be inferred by using anytype. @TypeOf can
// be used on the paramter inside of the function that was declared using anytype.
fn plusOne(x: anytype) @TypeOf(x) {
    return x + 1;
}

test "inferred function paramter" {
    try expect(plusOne(@as(u32, 1)) == 2);
}

// Comptime concatenation of arrays and slices.
test "++" {
    const x: [4]u8 = undefined;
    const y = x[0..];

    const a: [6]u8 = undefined;
    const b = a[0..];

    const new = y ++ b;
    try expect(new.len == 10);
}

// Concatenates the same values x amount times.
test "**" {
    const pattern = [_]u8{ 0xCC, 0xAA };
    const memory = pattern ** 3;

    try expect(eql(u8, &memory, &[_]u8{ 0xCC, 0xAA, 0xCC, 0xAA, 0xCC, 0xAA }));
}
