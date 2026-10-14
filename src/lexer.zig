const std = @import("std");
const Token = @import("token.zig");
const utils = @import("utils.zig");

input: []const u8,
ch: u8 = 0,
position: usize = 0,
read_position: usize = 0,

const Self = @This();

pub fn init(input: []const u8) Self {
    var l: Self = .{ .input = input };
    l.takeChar();
    return l;
}

pub fn nextToken(self: *Self) !Token {
    self.skipWhiteSpace();

    var token: Token = undefined;

    switch (self.ch) {
        0 => {
            token = Token.new(Token.TokenKind.eof, "");
        },
        '[' => {
            token = self.prepareCurrentToken(Token.TokenKind.open_bracket);
        },
        ']' => {
            token = self.prepareCurrentToken(Token.TokenKind.close_bracket);
        },
        '(' => {
            token = self.prepareCurrentToken(Token.TokenKind.open_paren);
        },
        ')' => {
            token = self.prepareCurrentToken(Token.TokenKind.close_paren);
        },
        '{' => {
            token = self.prepareCurrentToken(Token.TokenKind.open_brace);
        },
        '}' => {
            token = self.prepareCurrentToken(Token.TokenKind.close_brace);
        },
        '.' => {
            if (self.peekChar() == '.') {
                self.takeChar();
                if (self.peekChar() == '.') {
                    self.takeChar();
                    token = Token.new(Token.TokenKind.ellipsis, self.input[self.position - 2 .. self.read_position]);
                } else {
                    self.takeChar();
                    return error.InvalidToken;
                }
            } else {
                token = self.prepareCurrentToken(Token.TokenKind.dot);
            }
        },
        '-' => {
            if (self.peekChar() == '>') {
                self.takeChar();
                token = Token.new(Token.TokenKind.arrow, self.input[self.position - 1 .. self.read_position]);
            } else if (self.peekChar() == '-') {
                self.takeChar();
                token = Token.new(Token.TokenKind.decrement, self.input[self.position - 1 .. self.read_position]);
            } else if (self.peekChar() == '=') {
                self.takeChar();
                token = Token.new(Token.TokenKind.compound_subtraction, self.input[self.position - 1 .. self.read_position]);
            } else if (self.peekChar() == '0') {
                const start: usize = self.position;
                self.takeChar();
                if (self.peekChar() == 'x' or self.peekChar() == 'X') {
                    self.takeChar();
                    self.takeHexadecimal();
                    token = Token.new(Token.TokenKind.negative_hex_number, self.input[start..self.read_position]);
                } else {
                    self.takeOctal();
                    token = Token.new(Token.TokenKind.negative_octal_number, self.input[start..self.read_position]);
                }
            } else if (utils.isDigit(self.peekChar())) {
                const start: usize = self.position;
                self.takeChar();
                try self.takeNumber();
                const kind: Token.TokenKind = try switch (self.input[self.position]) {
                    'l', 'L' => switch (self.input[self.position - 1]) {
                        'l', 'L' => switch (self.input[self.position - 2]) {
                            'u', 'U' => error.NegativeUnsignedNumber,
                            else => Token.TokenKind.negative_long_long_decimal_number,
                        },
                        'u', 'U' => error.NegativeUnsignedNumber,
                        else => Token.TokenKind.negative_long_decimal_number,
                    },
                    'u', 'U' => error.NegativeUnsignedNumber,
                    else => Token.TokenKind.negative_decimal_number,
                };
                token = Token.new(kind, self.input[start..self.read_position]);
            } else {
                token = self.prepareCurrentToken(Token.TokenKind.minus);
            }
        },
        '+' => {
            if (self.peekChar() == '+') {
                self.takeChar();
                token = Token.new(Token.TokenKind.increment, self.input[self.position - 1 .. self.read_position]);
            } else if (self.peekChar() == '=') {
                self.takeChar();
                token = Token.new(Token.TokenKind.compound_addition, self.input[self.position - 1 .. self.read_position]);
            } else {
                token = self.prepareCurrentToken(Token.TokenKind.plus);
            }
        },
        '&' => {
            if (self.peekChar() == '&') {
                self.takeChar();
                token = Token.new(Token.TokenKind.and_operator, self.input[self.position - 1 .. self.read_position]);
            } else if (self.peekChar() == '=') {
                self.takeChar();
                token = Token.new(Token.TokenKind.compound_bitwise_and, self.input[self.position - 1 .. self.read_position]);
            } else {
                token = self.prepareCurrentToken(Token.TokenKind.ampersand);
            }
        },
        '*' => {
            if (self.peekChar() == '/') {
                self.takeChar();
                token = Token.new(Token.TokenKind.comment_block_end, self.input[self.position - 1 .. self.read_position]);
            } else if (self.peekChar() == '=') {
                self.takeChar();
                token = Token.new(Token.TokenKind.compound_multiplication, self.input[self.position - 1 .. self.read_position]);
            } else {
                token = self.prepareCurrentToken(Token.TokenKind.asterisk);
            }
        },
        '~' => {
            token = self.prepareCurrentToken(Token.TokenKind.flip_operator);
        },
        '!' => {
            if (self.peekChar() == '=') {
                self.takeChar();
                token = Token.new(Token.TokenKind.not_equal, self.input[self.position - 1 .. self.read_position]);
            } else {
                token = self.prepareCurrentToken(Token.TokenKind.bang);
            }
        },
        '/' => {
            if (self.peekChar() == '/') {
                self.takeChar();
                token = Token.new(Token.TokenKind.comment, self.input[self.position - 1 .. self.read_position]);
            } else if (self.peekChar() == '*') {
                self.takeChar();
                token = Token.new(Token.TokenKind.comment_block_start, self.input[self.position - 1 .. self.read_position]);
            } else if (self.peekChar() == '=') {
                self.takeChar();
                token = Token.new(Token.TokenKind.compound_division, self.input[self.position - 1 .. self.read_position]);
            } else {
                token = self.prepareCurrentToken(Token.TokenKind.back_slash);
            }
        },
        '%' => {
            if (self.peekChar() == '=') {
                self.takeChar();
                token = Token.new(Token.TokenKind.compound_modulo, self.input[self.position - 1 .. self.read_position]);
            } else if (self.peekChar() == '>') {
                self.takeChar();
                token = Token.new(Token.TokenKind.close_brace, self.input[self.position - 1 .. self.read_position]);
            } else {
                token = self.prepareCurrentToken(Token.TokenKind.percent);
            }
        },
        '<' => {
            if (self.peekChar() == '<') {
                self.takeChar();
                if (self.peekChar() == '=') {
                    self.takeChar();
                    token = Token.new(Token.TokenKind.compound_left_shift, self.input[self.position - 2 .. self.read_position]);
                } else {
                    token = Token.new(Token.TokenKind.left_shift, self.input[self.position - 1 .. self.read_position]);
                }
            } else if (self.peekChar() == '=') {
                self.takeChar();
                token = Token.new(Token.TokenKind.lt_eq, self.input[self.position - 1 .. self.read_position]);
            } else if (self.peekChar() == ':') {
                self.takeChar();
                token = Token.new(Token.TokenKind.open_bracket, self.input[self.position - 1 .. self.read_position]);
            } else if (self.peekChar() == '%') {
                self.takeChar();
                token = Token.new(Token.TokenKind.open_brace, self.input[self.position - 1 .. self.read_position]);
            } else {
                token = self.prepareCurrentToken(Token.TokenKind.lt);
            }
        },
        '>' => {
            if (self.peekChar() == '>') {
                self.takeChar();
                if (self.peekChar() == '=') {
                    self.takeChar();
                    token = Token.new(Token.TokenKind.compound_right_shift, self.input[self.position - 2 .. self.read_position]);
                } else {
                    token = Token.new(Token.TokenKind.right_shift, self.input[self.position - 1 .. self.read_position]);
                }
            } else if (self.peekChar() == '=') {
                self.takeChar();
                token = Token.new(Token.TokenKind.gt_eq, self.input[self.position - 1 .. self.read_position]);
            } else {
                token = self.prepareCurrentToken(Token.TokenKind.gt);
            }
        },
        '=' => {
            if (self.peekChar() == '=') {
                self.takeChar();
                token = Token.new(Token.TokenKind.equal, self.input[self.position - 1 .. self.read_position]);
            } else {
                token = self.prepareCurrentToken(Token.TokenKind.assign);
            }
        },
        '^' => {
            if (self.peekChar() == '=') {
                self.takeChar();
                token = Token.new(Token.TokenKind.compound_bitwise_xor, self.input[self.position - 1 .. self.read_position]);
            } else {
                token = self.prepareCurrentToken(Token.TokenKind.caret);
            }
        },
        '|' => {
            if (self.peekChar() == '|') {
                self.takeChar();
                token = Token.new(Token.TokenKind.or_operator, self.input[self.position - 1 .. self.read_position]);
            } else if (self.peekChar() == '=') {
                self.takeChar();
                token = Token.new(Token.TokenKind.compound_bitwise_or, self.input[self.position - 1 .. self.read_position]);
            } else {
                token = self.prepareCurrentToken(Token.TokenKind.pipe);
            }
        },
        '?' => {
            token = self.prepareCurrentToken(Token.TokenKind.question_mark);
        },
        ':' => {
            if (self.peekChar() == '>') {
                self.takeChar();
                token = Token.new(Token.TokenKind.close_bracket, self.input[self.position - 1 .. self.read_position]);
            } else {
                token = self.prepareCurrentToken(Token.TokenKind.colon);
            }
        },
        ';' => {
            token = self.prepareCurrentToken(Token.TokenKind.semicolon);
        },
        '0' => {
            const start: usize = self.position;
            if (self.peekChar() == 'x' or self.peekChar() == 'X') {
                self.takeChar();
                self.takeHexadecimal();
                token = Token.new(Token.TokenKind.hex_number, self.input[start..self.read_position]);
            } else {
                self.takeOctal();
                token = Token.new(Token.TokenKind.octal_number, self.input[start..self.read_position]);
            }
        },
        else => {
            if (utils.isLetter(self.ch) or self.ch == '_') {
                const start: usize = self.position;
                self.takeWord();
                if (std.mem.eql(u8, "__func__", self.input[start..self.read_position])) {
                    token = Token.new(Token.TokenKind.func, self.input[start..self.read_position]);
                } else {
                    const kind = Token.keywordToTokenKind(self.input[start..self.read_position]) orelse Token.TokenKind.ident;
                    token = Token.new(kind, self.input[start..self.read_position]);
                }
            } else if (utils.isNonZeroDigit(self.ch)) {
                const start: usize = self.position;
                try self.takeNumber();
                const kind: Token.TokenKind = switch (self.input[self.position]) {
                    'l', 'L' => switch (self.input[self.position - 1]) {
                        'l', 'L' => switch (self.input[self.position - 2]) {
                            'u', 'U' => Token.TokenKind.unsigned_long_long_decimal_number,
                            else => Token.TokenKind.long_long_decimal_number,
                        },
                        'u', 'U' => Token.TokenKind.unsigned_long_decimal_number,
                        else => Token.TokenKind.long_decimal_number,
                    },
                    'u', 'U' => Token.TokenKind.unsigned_decimanl_number,
                    else => Token.TokenKind.decimal_number,
                };
                token = Token.new(kind, self.input[start..self.read_position]);
            } else {
                std.debug.print("char: {any}\n", .{self.ch});
                self.takeChar();
                return error.InvalidToken;
            }
        },
    }

    self.takeChar();
    return token;
}

fn takeChar(self: *Self) void {
    if (self.read_position >= self.input.len) {
        self.ch = 0;
        self.position = self.read_position;
    } else {
        self.ch = self.input[self.read_position];
    }
    self.position = self.read_position;
    self.read_position += 1;
}

fn skipWhiteSpace(self: *Self) void {
    while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
        self.takeChar();
    }
}

fn prepareCurrentToken(self: Self, kind: Token.TokenKind) Token {
    return Token.new(kind, self.input[self.position..self.read_position]);
}

fn peekChar(self: *Self) u8 {
    if (self.read_position >= self.input.len) {
        return 0;
    } else {
        return self.input[self.read_position];
    }
}

fn takeWord(self: *Self) void {
    while (utils.isLetter(self.peekChar()) or utils.isDigit(self.peekChar()) or self.peekChar() == '_') {
        self.takeChar();
    }
}

fn takeNumber(self: *Self) !void {
    while (utils.isDigit(self.peekChar())) {
        self.takeChar();
    }
    if (self.peekChar() != ' ' and self.peekChar() != '\t' and self.peekChar() != '\n' and self.peekChar() != '\r') {
        if (self.peekChar() == 'u' or self.peekChar() == 'U') {
            self.takeChar();
            if (self.peekChar() == 'l' or self.peekChar() == 'L') {
                self.takeChar();
            }
            if (self.peekChar() == 'l' or self.peekChar() == 'L') {
                self.takeChar();
            }
        } else if (self.peekChar() == 'l' or self.peekChar() == 'L') {
            self.takeChar();
            if (self.peekChar() == 'l' or self.peekChar() == 'L') {
                self.takeChar();
            }
            if (self.peekChar() == 'u' or self.peekChar() == 'U') {
                self.takeChar();
            }
        } else {
            return error.InvalidNumberToken;
        }
    }
}

fn takeOctal(self: *Self) void {
    while (utils.isOctalDigit(self.peekChar())) {
        self.takeChar();
    }
}

fn takeHexadecimal(self: *Self) void {
    while (utils.isHexadecimalDigit(self.peekChar())) {
        self.takeChar();
    }
}

test "tokenize c" {
    var l: Self = Self.init(
        \\ auto break case char const continue
        \\ default do double else enum extern
        \\ float for goto if inline int long
        \\ register restrict return short signed
        \\ sizeof static struct switch typedef
        \\ union unsigned void volatile while
        \\ _Bool _Complex _Imaginary a a0 _a0 a_0
        \\ __func__ 1234 01234 0x1234 0X1234 -1234
        \\ -0x1234 -0X1234 -01234 -1234l -1234L
        \\ -1234ll -1234LL -1234Ll -1234lL 1234ull
        \\ 1234Ull 1234uLl 1234ULl 1234ulL 1234UlL
        \\ 1234uLL 1234ULL
        \\ [](){}.->++--&*+-~!/%<<>><><=>===!=^|&&||?:;...=*=/=%=+=-=<<=>>=&=^=|=<::><%%>///**/
    );

    const expected_tokens = [_]Token{
        .{ .kind = Token.TokenKind.auto, .literal = "auto" },
        .{ .kind = Token.TokenKind.break_kw, .literal = "break" },
        .{ .kind = Token.TokenKind.case, .literal = "case" },
        .{ .kind = Token.TokenKind.char, .literal = "char" },
        .{ .kind = Token.TokenKind.const_kw, .literal = "const" },
        .{ .kind = Token.TokenKind.continue_kw, .literal = "continue" },
        .{ .kind = Token.TokenKind.default, .literal = "default" },
        .{ .kind = Token.TokenKind.do, .literal = "do" },
        .{ .kind = Token.TokenKind.double, .literal = "double" },
        .{ .kind = Token.TokenKind.else_kw, .literal = "else" },
        .{ .kind = Token.TokenKind.enum_kw, .literal = "enum" },
        .{ .kind = Token.TokenKind.extern_kw, .literal = "extern" },
        .{ .kind = Token.TokenKind.float, .literal = "float" },
        .{ .kind = Token.TokenKind.for_kw, .literal = "for" },
        .{ .kind = Token.TokenKind.goto, .literal = "goto" },
        .{ .kind = Token.TokenKind.if_kw, .literal = "if" },
        .{ .kind = Token.TokenKind.inline_kw, .literal = "inline" },
        .{ .kind = Token.TokenKind.int, .literal = "int" },
        .{ .kind = Token.TokenKind.long, .literal = "long" },
        .{ .kind = Token.TokenKind.register, .literal = "register" },
        .{ .kind = Token.TokenKind.restrict, .literal = "restrict" },
        .{ .kind = Token.TokenKind.return_kw, .literal = "return" },
        .{ .kind = Token.TokenKind.short, .literal = "short" },
        .{ .kind = Token.TokenKind.signed, .literal = "signed" },
        .{ .kind = Token.TokenKind.sizeof, .literal = "sizeof" },
        .{ .kind = Token.TokenKind.static, .literal = "static" },
        .{ .kind = Token.TokenKind.struct_kw, .literal = "struct" },
        .{ .kind = Token.TokenKind.switch_kw, .literal = "switch" },
        .{ .kind = Token.TokenKind.typedef, .literal = "typedef" },
        .{ .kind = Token.TokenKind.union_kw, .literal = "union" },
        .{ .kind = Token.TokenKind.unsigned, .literal = "unsigned" },
        .{ .kind = Token.TokenKind.void_kw, .literal = "void" },
        .{ .kind = Token.TokenKind.volatile_kw, .literal = "volatile" },
        .{ .kind = Token.TokenKind.while_kw, .literal = "while" },
        .{ .kind = Token.TokenKind._Bool, .literal = "_Bool" },
        .{ .kind = Token.TokenKind._Complex, .literal = "_Complex" },
        .{ .kind = Token.TokenKind._Imaginary, .literal = "_Imaginary" },
        .{ .kind = Token.TokenKind.ident, .literal = "a" },
        .{ .kind = Token.TokenKind.ident, .literal = "a0" },
        .{ .kind = Token.TokenKind.ident, .literal = "_a0" },
        .{ .kind = Token.TokenKind.ident, .literal = "a_0" },
        .{ .kind = Token.TokenKind.func, .literal = "__func__" },
        .{ .kind = Token.TokenKind.decimal_number, .literal = "1234" },
        .{ .kind = Token.TokenKind.octal_number, .literal = "01234" },
        .{ .kind = Token.TokenKind.hex_number, .literal = "0x1234" },
        .{ .kind = Token.TokenKind.hex_number, .literal = "0X1234" },
        .{ .kind = Token.TokenKind.negative_decimal_number, .literal = "-1234" },
        .{ .kind = Token.TokenKind.negative_hex_number, .literal = "-0x1234" },
        .{ .kind = Token.TokenKind.negative_hex_number, .literal = "-0X1234" },
        .{ .kind = Token.TokenKind.negative_octal_number, .literal = "-01234" },
        .{ .kind = Token.TokenKind.negative_long_decimal_number, .literal = "-1234l" },
        .{ .kind = Token.TokenKind.negative_long_decimal_number, .literal = "-1234L" },
        .{ .kind = Token.TokenKind.negative_long_long_decimal_number, .literal = "-1234ll" },
        .{ .kind = Token.TokenKind.negative_long_long_decimal_number, .literal = "-1234LL" },
        .{ .kind = Token.TokenKind.negative_long_long_decimal_number, .literal = "-1234Ll" },
        .{ .kind = Token.TokenKind.negative_long_long_decimal_number, .literal = "-1234lL" },
        .{ .kind = Token.TokenKind.unsigned_long_long_decimal_number, .literal = "1234ull" },
        .{ .kind = Token.TokenKind.unsigned_long_long_decimal_number, .literal = "1234Ull" },
        .{ .kind = Token.TokenKind.unsigned_long_long_decimal_number, .literal = "1234uLl" },
        .{ .kind = Token.TokenKind.unsigned_long_long_decimal_number, .literal = "1234ULl" },
        .{ .kind = Token.TokenKind.unsigned_long_long_decimal_number, .literal = "1234ulL" },
        .{ .kind = Token.TokenKind.unsigned_long_long_decimal_number, .literal = "1234UlL" },
        .{ .kind = Token.TokenKind.unsigned_long_long_decimal_number, .literal = "1234uLL" },
        .{ .kind = Token.TokenKind.unsigned_long_long_decimal_number, .literal = "1234ULL" },
        .{ .kind = Token.TokenKind.open_bracket, .literal = "[" },
        .{ .kind = Token.TokenKind.close_bracket, .literal = "]" },
        .{ .kind = Token.TokenKind.open_paren, .literal = "(" },
        .{ .kind = Token.TokenKind.close_paren, .literal = ")" },
        .{ .kind = Token.TokenKind.open_brace, .literal = "{" },
        .{ .kind = Token.TokenKind.close_brace, .literal = "}" },
        .{ .kind = Token.TokenKind.dot, .literal = "." },
        .{ .kind = Token.TokenKind.arrow, .literal = "->" },
        .{ .kind = Token.TokenKind.increment, .literal = "++" },
        .{ .kind = Token.TokenKind.decrement, .literal = "--" },
        .{ .kind = Token.TokenKind.ampersand, .literal = "&" },
        .{ .kind = Token.TokenKind.asterisk, .literal = "*" },
        .{ .kind = Token.TokenKind.plus, .literal = "+" },
        .{ .kind = Token.TokenKind.minus, .literal = "-" },
        .{ .kind = Token.TokenKind.flip_operator, .literal = "~" },
        .{ .kind = Token.TokenKind.bang, .literal = "!" },
        .{ .kind = Token.TokenKind.back_slash, .literal = "/" },
        .{ .kind = Token.TokenKind.percent, .literal = "%" },
        .{ .kind = Token.TokenKind.left_shift, .literal = "<<" },
        .{ .kind = Token.TokenKind.right_shift, .literal = ">>" },
        .{ .kind = Token.TokenKind.lt, .literal = "<" },
        .{ .kind = Token.TokenKind.gt, .literal = ">" },
        .{ .kind = Token.TokenKind.lt_eq, .literal = "<=" },
        .{ .kind = Token.TokenKind.gt_eq, .literal = ">=" },
        .{ .kind = Token.TokenKind.equal, .literal = "==" },
        .{ .kind = Token.TokenKind.not_equal, .literal = "!=" },
        .{ .kind = Token.TokenKind.caret, .literal = "^" },
        .{ .kind = Token.TokenKind.pipe, .literal = "|" },
        .{ .kind = Token.TokenKind.and_operator, .literal = "&&" },
        .{ .kind = Token.TokenKind.or_operator, .literal = "||" },
        .{ .kind = Token.TokenKind.question_mark, .literal = "?" },
        .{ .kind = Token.TokenKind.colon, .literal = ":" },
        .{ .kind = Token.TokenKind.semicolon, .literal = ";" },
        .{ .kind = Token.TokenKind.ellipsis, .literal = "..." },
        .{ .kind = Token.TokenKind.assign, .literal = "=" },
        .{ .kind = Token.TokenKind.compound_multiplication, .literal = "*=" },
        .{ .kind = Token.TokenKind.compound_division, .literal = "/=" },
        .{ .kind = Token.TokenKind.compound_modulo, .literal = "%=" },
        .{ .kind = Token.TokenKind.compound_addition, .literal = "+=" },
        .{ .kind = Token.TokenKind.compound_subtraction, .literal = "-=" },
        .{ .kind = Token.TokenKind.compound_left_shift, .literal = "<<=" },
        .{ .kind = Token.TokenKind.compound_right_shift, .literal = ">>=" },
        .{ .kind = Token.TokenKind.compound_bitwise_and, .literal = "&=" },
        .{ .kind = Token.TokenKind.compound_bitwise_xor, .literal = "^=" },
        .{ .kind = Token.TokenKind.compound_bitwise_or, .literal = "|=" },
        .{ .kind = Token.TokenKind.open_bracket, .literal = "<:" },
        .{ .kind = Token.TokenKind.close_bracket, .literal = ":>" },
        .{ .kind = Token.TokenKind.open_brace, .literal = "<%" },
        .{ .kind = Token.TokenKind.close_brace, .literal = "%>" },

        .{ .kind = Token.TokenKind.comment, .literal = "//" },
        .{ .kind = Token.TokenKind.comment_block_start, .literal = "/*" },
        .{ .kind = Token.TokenKind.comment_block_end, .literal = "*/" },
        .{ .kind = Token.TokenKind.eof, .literal = "" },
    };

    var actual_token: Token = undefined;

    try std.testing.expectEqual(0, l.position);
    try std.testing.expectEqual(1, l.read_position);

    for (expected_tokens) |et| {
        actual_token = try l.nextToken();

        try std.testing.expectEqual(et.kind, actual_token.kind);
        try std.testing.expectEqualStrings(et.literal, actual_token.literal);
    }

    try std.testing.expect(l.position > l.input.len);
    try std.testing.expect(l.read_position > l.input.len);
    try std.testing.expectEqual(0, l.ch);
}
