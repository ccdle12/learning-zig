const expect = @import("std").testing.expect;

const FileOpenError = error{ AccessDenied, OutOfMemory, FileNotFound };
const AllocationError = error{OutOfMemory};

test "coerce error from a subset to a superset" {
    const err: FileOpenError = AllocationError.OutOfMemory;
    try expect(err == FileOpenError.OutOfMemory);
}

test "error union" {
    // Union between two types: { type ! type } = { one of the values }
    //
    // catch will return the right hand operand if the union is not holding
    // the type of the left hand operand.
    //
    var maybe_error: AllocationError!u16 = 10;
    var no_error = maybe_error catch 0;

    try expect(@TypeOf(no_error) == u16);
    try expect(no_error == 10);

    var maybe_error_1: AllocationError!u16 = AllocationError.OutOfMemory;
    var no_error_1 = maybe_error_1 catch 0;
    try expect(no_error_1 == 0);
}
