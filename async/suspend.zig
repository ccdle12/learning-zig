//! async = keyword to invoke a function in an async context
//! async func() = returns the functions stack frame
//! resume = a keyword used on the frame
//! suspend = is used from the called function
const expect = @import("std").testing.expect;

var foo: i32 = 1;

fn func() void {
    foo += 1; // step 2.
    suspend {} // step 3.
    foo += 1; // never reached, since we suspend and never resume

}
test "suspend with no resume" {
    var frame = async func(); // step 1.
    _ = frame;
    try expect(foo == 2); // step. 4
}
