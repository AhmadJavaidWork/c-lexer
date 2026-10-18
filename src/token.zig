const std = @import("std");

pub const TokenKind = enum(u16) {
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
    float,
    for_kw,
    goto,
    if_kw,
    inline_kw,
    int,
    long,
    register,
    restrict,
    return_kw,
    short,
    signed,
    sizeof,
    static,
    struct_kw,
    switch_kw,
    typedef,
    union_kw,
    unsigned,
    void_kw,
    volatile_kw,
    while_kw,
    _Bool,
    _Complex,
    _Imaginary,

    // identifier
    ident,
    func,

    // integer constants
    decimal_number,
    decimal_long_number,
    decimal_long_long_number,
    decimal_unsigned_number,
    decimal_unsigned_long_number,
    decimal_unsigned_long_long_number,

    decimal_negative_number,
    decimal_negative_long_number,
    decimal_negative_long_long_number,
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

pub fn keywordToTokenKind(keyword: []const u8) ?TokenKind {
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
    } else if (std.mem.eql(u8, "for", keyword)) {
        return TokenKind.for_kw;
    } else if (std.mem.eql(u8, "if", keyword)) {
        return TokenKind.if_kw;
    } else if (std.mem.eql(u8, "inline", keyword)) {
        return TokenKind.inline_kw;
    } else if (std.mem.eql(u8, "return", keyword)) {
        return TokenKind.return_kw;
    } else if (std.mem.eql(u8, "struct", keyword)) {
        return TokenKind.struct_kw;
    } else if (std.mem.eql(u8, "switch", keyword)) {
        return TokenKind.switch_kw;
    } else if (std.mem.eql(u8, "union", keyword)) {
        return TokenKind.union_kw;
    } else if (std.mem.eql(u8, "void", keyword)) {
        return TokenKind.void_kw;
    } else if (std.mem.eql(u8, "volatile", keyword)) {
        return TokenKind.volatile_kw;
    } else if (std.mem.eql(u8, "while", keyword)) {
        return TokenKind.while_kw;
    } else {
        return std.meta.stringToEnum(TokenKind, keyword);
    }
}
