// Unions allow one value to be stored of many different typed fields.
const expect = @import("std").testing.expect;

const Payload = union {
    int: i64,
    float: f64,
    bool: bool,
};

// Fails because we can't assign another type in the inion since the union is already holding an int.
// test "simple union" {
// var payload = Payload{ .int = 1234 };
// payload.float = 12.34;
// }

// So this is a very common pattern. We can switch on which field is active in
// a union by supplying it with an enum. E.g. an enum  that has 3 variants and
// we pass it a union and assign field types.
//
// We can now switch on each of the enum variants.
//
// We can't switch on a union alone.
//
// This is known as a: "Tagged Union"
const Tag = enum { a, b, c };
const Tagged = union(Tag) { a: u8, b: f32, c: bool };

test "switch on tagged union" {
    var value = Tagged{ .b = 1.5 };

    switch (value) {
        .a => |*byte| byte.* += 1,
        .b => |*float| float.* *= 2,
        .c => |*boolean| boolean.* = !boolean.*,
    }

    try expect(value.b == 3);
}

// We can reduce the boilerplate since the tag type of a tagged union can be inferred.
const Tagged2 = union(enum) { a: u8, b: f32, c: bool };

// void types can have their type ommited from the syntax using any non-keyword (expect void).
const Tagged3 = union(enum) { a: u8, b: f32, c: bool, none };
