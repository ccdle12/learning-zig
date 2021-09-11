const expect = @import("std").testing.expect;

// while loop works as well, but this will inline in compile time, taking each
// type and adding the size of it to sum. So after compiletime and before
// becoming an IR or asm, it would look like this:
//
// ...
// sum += sizeOf(i32)
// sum += sizeOf(f32)
// sum += sizeOf(u8)
// sum += sizeOf(bool)
// ...
//
// It's suggested that inline should be used sparingly, the compiler will do
// a better job at optimizing.
test "inline for" {
    const types = [_]type{ i32, f32, u8, bool };

    var sum: usize = 0;
    inline for (types) |T| sum += @sizeOf(T);

    try expect(sum == 10);
}
