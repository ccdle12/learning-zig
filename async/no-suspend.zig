const std = @import("std");

fn doTicksDuration(ticker: *u32) i64 {
    const start = std.time.milliTimestamp();

    while (ticker.* > 0) {
        suspend {}
        ticker.* -= 1;
    }

    return std.time.milliTimestamp() - start;
}

//! nosuspend is a keyword asserting that no suspends will be called on an async
//! function. In this case, we don't want to use async or the caller to be async.
//!
//! By using nosuspend, we are saying that the suspend statements will not be reached.
//! If we change ticker to above 0, the compiler will notice that the suspend
//! statement will be reached and will result in a compiler error.
pub fn main() !void {
    var ticker: u32 = 0;
    const duration = nosuspend doTicksDuration(&ticker);
    _ = duration;
}
