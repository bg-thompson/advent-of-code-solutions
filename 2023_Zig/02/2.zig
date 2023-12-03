// Disclaimer: At the time of writing, my experience with Zig is basically 0.
// The aim of solving these problems is to provide myself with an introduction to Zig.
const std  = @import("std");
const data = @embedFile("question2_data.txt");

const test_data =
    \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
;

const dprint  = std.debug.print;
const dassert = std.debug.assert;

pub fn main() void {
    // Pt1, Pt2
    var pt1_solution : u32 = 0;
    var pt2_solution : u32 = 0;
    var line_iter = std.mem.tokenizeAny(u8, data, "\n");
    var line_index : u32 = 0;
    while (line_iter.next()) |line| : (line_index += 1) {
        var game_possible = true;
        var max_red   : u32 = 0;
        var max_green : u32 = 0;
        var max_blue  : u32 = 0;
        var pair_iter = std.mem.tokenizeAny(u8, line, ";:,");
        var pair_index : u32 = 0;
        while (pair_iter.next()) |seg| : (pair_index += 1) {
            if (pair_index == 0) {
                continue;
            }
            const pair : [] const u8 = std.mem.trim(u8, seg, " ");
            var token_iter = std.mem.tokenizeAny(u8, pair, " ");
            var token_index : u32 = 0;
            var ball_number : u32    = undefined;
            while (token_iter.next()) |token| : (token_index += 1) {
                if (token_index == 0) {
                    //@cleanup practice actually handling the error here.
                    ball_number = std.fmt.parseInt(u32, token, 10) catch 0;
                } else {
                    // Add in switch.
                    switch (token[0]) {
                        'r' => {
                            game_possible = game_possible and ball_number <= 12;
                            max_red = @max(max_red, ball_number);
                        },
                        'g' => {
                            game_possible = game_possible and ball_number <= 13;
                            max_green = @max(max_green, ball_number);
                        },
                        'b' => {
                            game_possible = game_possible and ball_number <= 14;
                            max_blue = @max(max_blue, ball_number);
                        },
                        else => unreachable,
                    }
                }
                dassert(token_index <= 1);
            }
//            dprint("{s}\n", .{pair}); //@debug
        }
        if (game_possible) {
            pt1_solution += line_index + 1;
        }
        const game_product = max_red * max_green * max_blue;
        pt2_solution += game_product;
        dprint("Game outcome possible:{}\n",  .{game_possible});
        dprint("Game prod:{}\n", .{game_product});
    }
    dprint("Pt1 sol:{}\n", .{pt1_solution});
    // Output: 2156 (correct).
    dprint("Pt2 sol:{}\n", .{pt2_solution});
    // Output: 66909 (correct).
}
