//! In this example, we use the async await convention. async can be used event
//! on functions that have no suspend, like in func3.
const expect = @import("std").testing.expect;

fn func3() u32 {
    return 5;
}

test "async/await" {
    var frame = async func3();
    try expect(await frame == 5);
}
