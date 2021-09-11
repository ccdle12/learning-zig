const expect = @import("std").testing.expect;
const print = @import("std").debug.print;

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

fn failingFunction() error{Oops}!void {
    return error.Oops;
}

test "returning an error" {
    // Because the union could be error or void, we use a closure? to catch
    // the error. If it's void it would never enter the closure. You can still
    // return void and assign it into a result.
    failingFunction() catch |err| {
        try expect(err == error.Oops);
        return;
    };

    const result = failingFunction();
    print("result: {u}\n", .{result});
}

fn failFn() error{Oops}!i32 {
    try failingFunction();
    return 12;
}

// Used more commonly than the above "x catch |err| return err", this is not the
// same as the try catch in other languages.
test "try x" {
    var v = failFn() catch |err| {
        try expect(err == error.Oops);
        return;
    };

    try expect(v == 12);
}

var problems: u32 = 99;

// errdefer is a keyword that is executed at the end of a function if there is
// an error AND before the error is returned.
fn failFnCounter() error{Oops}!void {
    errdefer problems += 1;
    try failingFunction();
}

test "errdefer" {
    failFnCounter() catch |err| {
        try expect(err == error.Oops);
        try expect(problems == 100);
        return;
    };
}

// Error sets can be inferred in a union, from within the function call.
fn createFile() !void {
    return error.AccessDenied;
}

test "inferred error set" {
    const x: error{AccessDenied}!void = createFile();

    // try will return an error if there is one.
    var y = x catch |err| {
        try expect(err == FileOpenError.AccessDenied);
        return;
    };

    // that's why, we normal wouldn't do a check like this, but it demonstrates
    // the void was returned from the closure because there were no errors.
    try expect(@TypeOf(y) == void);
}

test "merging error sets" {
    const A = error{ NotDir, PathNotFound };
    const B = error{ OutOfMemory, PathNotFound };
    const C = A || B;

    try expect(C.NotDir == A.NotDir);
    try expect(C.OutOfMemory == B.OutOfMemory);
}
