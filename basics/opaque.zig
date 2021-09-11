// opaque has no known size and alignment. These data types cannot be stored
// directly. It's used to maintain type safety with pointers to types we don't
// have information about.
//
// Opaques typcial use case is to maintain type safety when interoperating with
// C code that does not expose complete type information.
const Window = opaque {};
const Button = opaque {};

extern fn show_window(*Window) callconv(.C) void;

test "opaque" {
    var main_window: *Window = undefined;
    show_window(main_window);
}
