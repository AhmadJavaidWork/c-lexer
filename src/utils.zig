pub fn isLetter(ch: u8) bool {
    return (ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z');
}

pub fn isDigit(ch: u8) bool {
    return ch >= '0' and ch <= '9';
}

pub fn isNonZeroDigit(ch: u8) bool {
    return ch >= '1' and ch <= '9';
}

pub fn isOctalDigit(ch: u8) bool {
    return ch >= '0' and ch <= '7';
}

pub fn isHexadecimalDigit(ch: u8) bool {
    return isDigit(ch) or (ch >= 'a' and ch <= 'f') or (ch >= 'A' and ch <= 'F');
}

pub fn isInSourceCharacterSet(ch: u8) bool {
    return (ch >= ' ' and ch <= '&') or (ch >= '(' and ch <= '[') or (ch >= ']' and ch <= '~');
}

pub fn isSimpleEscapeSeq(ch: u8) bool {
    return switch (ch) {
        '\'', '\"', '?', '\\', 'a', 'b', 'f', 'n', 'r', 't', 'v' => true,
        else => false,
    };
}
