const std = @import("std");

pub const TokenKind = enum(u8) {
    // punctuators
    eof,
    open_bracket,
    close_bracket,
    open_paren,
    close_paren,
    open_brace,
    close_brace,
    dot,
    arrow,
    increment,
    decrement,
    ampersand,
    asterisk,
    plus,
    minus,
    flip_operator,
    bang,
    back_slash,
    percent,
    left_shift,
    right_shift,
    lt,
    gt,
    lt_eq,
    gt_eq,
    equal,
    not_equal,
    caret,
    pipe,
    and_operator,
    or_operator,
    question_mark,
    colon,
    semicolon,
    ellipsis,
    assign,
    compound_multiplication,
    compound_division,
    compound_modulo,
    compound_addition,
    compound_subtraction,
    compound_left_shift,
    compound_right_shift,
    compound_bitwise_and,
    compound_bitwise_xor,
    compound_bitwise_or,

    comment,
    comment_block_start,
    comment_block_end,

    // keywords
    auto,
    break_kw,
    case,
    char,
    const_kw,
    continue_kw,
    default,
    do,
    double,
    else_kw,
    enum_kw,
    extern_kw,
};

kind: TokenKind,
literal: []const u8,

const Self = @This();

pub fn new(kind: TokenKind, literal: []const u8) Self {
    return .{ .kind = kind, .literal = literal };
}

pub fn format(self: *const Self, writer: *std.Io.Writer) !void {
    try writer.print("Token: {{ kind: {any}, literal: {s} }}", .{ self.kind, self.literal });
}

pub fn keywordToTokenKind(keyword: []const u8) !TokenKind {
    if (std.mem.eql(u8, "break", keyword)) {
        return TokenKind.break_kw;
    } else if (std.mem.eql(u8, "const", keyword)) {
        return TokenKind.const_kw;
    } else if (std.mem.eql(u8, "continue", keyword)) {
        return TokenKind.continue_kw;
    } else if (std.mem.eql(u8, "else", keyword)) {
        return TokenKind.else_kw;
    } else if (std.mem.eql(u8, "enum", keyword)) {
        return TokenKind.enum_kw;
    } else if (std.mem.eql(u8, "extern", keyword)) {
        return TokenKind.extern_kw;
    } else {
        return std.meta.stringToEnum(TokenKind, keyword) orelse return error.InvalidToken;
    }
}
