const expect = @import("std").testing.expect;

const Vec3 = struct { x: f32, y: f32, z: f32 };

// Assigning a vector, we need to use .field???
test "struct usage" {
    const my_vec = Vec3{ .x = 3.15, .y = 4.34, .z = 5.34 };
    try expect(my_vec.x == 3.15);
}

// All fields must be assigned
// test "missing struct field" {
// const my_vec = Vec3{
//     .x = 3.15,
//     .y = 4.34,
// };
// try expect(my_vec.x == 3.15);
// }

// Field defaults.
const Vec4 = struct {
    x: f32,
    y: f32,
    z: f32 = 0,
    w: f32 = undefined,
};

test "struct defaults" {
    const my_vec = Vec4{
        .x = 25,
        .y = -50,
    };

    try expect(my_vec.z == 0);
}

// Structs when given a pointer to a strinct does one level of dereferencing so the fields are auto accessable.
const Stuff = struct {
    x: i32,
    y: i32,
    fn swap(self: *Stuff) void {
        const tmp = self.x;
        self.x = self.y;
        self.y = tmp;
    }
};

test "automatic deference" {
    var thing = Stuff{ .x = 10, .y = 20 };
    thing.swap();
    try expect(thing.x == 20);
    try expect(thing.y == 10);
}
