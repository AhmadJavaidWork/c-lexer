pub fn isLetter(c: u8) bool {
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z');
}

pub fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

pub fn isNonZeroDigit(c: u8) bool {
    return c >= '1' and c <= '9';
}

pub fn isOctalDigit(c: u8) bool {
    return c >= '0' and c <= '7';
}
