const std = @import("std");
const Token = @import("token.zig");

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
            token = self.prepareCurrentToken(Token.TokenKind.colon);
        },
        ';' => {
            token = self.prepareCurrentToken(Token.TokenKind.semicolon);
        },
        else => {
            return error.InvalidToken;
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

test "tokenize c" {
    var l: Self = Self.init(
        \\ [](){}.->++--&*+-~!/%<<>><><=>===!=^|&&||?:;...=*=/=%=+=-=<<=>>=&=^=|=<:///**/
    );

    const expected_tokens = [_]Token{
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
