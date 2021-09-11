const expect = @import("std").testing.expect;

const Direction = enum { north, south, east, west };

// Enums can have specified (int) tags. In this case a u2, so if we try to add
// fourth variant, this would not compile since the u2 would not be able to hold
// the next int value.
const Value = enum(u2) { zero, one, two, three };

// @enumToInt converts the enum into the int type.
test "enum ordinal value" {
    try expect(@enumToInt(Value.zero) == 0);
    try expect(@enumToInt(Direction.north) == 0);
}

// Enum values can be overriden, so we can start from any value. Next will
// increment the int by 1.
const Value2 = enum(u32) {
    hundred = 100,
    thousand = 1000,
    million = 1000000,
    next,
};

test "set enum ordinal value" {
    try expect(@enumToInt(Value2.hundred) == 100);
    try expect(@enumToInt(Value2.thousand) == 1000);
    try expect(@enumToInt(Value2.million) == 1000000);
    try expect(@enumToInt(Value2.next) == 1000001);
}

// Methods in enums.
// Interesting.. isClubs can be accessed via each variant and also just using
// the enum passing in a variant.
const Suit = enum {
    clubs,
    spades,
    diamonds,
    hearts,
    pub fn isClubs(self: Suit) bool {
        return self == Suit.clubs;
    }
};

test "enum method" {
    try expect(Suit.spades.isClubs() == Suit.isClubs(.spades));
}

// Enum const and var.
const Mode = enum {
    var count: u32 = 0;
    on,
    off,
};

// We can mutate the inner variant since its a var, but we wouldn't able to mutate
// the rest of variants because its a cosnt.
test "var const enum" {
    Mode.count += 1;
    try expect(Mode.count == 1);
}
