const std = @import("std");

const dprint  = std.debug.print;
const dassert = std.debug.assert;

const question_data = @embedFile("question_3_data.txt");
const test1         = @embedFile("test1.txt");
const test2         = @embedFile("test2.txt");

// Zig-mode has weird formatting for a multi-line string ending in //,
// so we've sent it to test_data instead.

// test1 data:
//123..
//4*5.6
//...78

const data = question_data;

// Evaluated at comptime since in container-level scope.
const line_length : u32 = for (data, 0..) |char, index| {
    if (char == '\n') break index + 1;
} else 0;

pub fn main() void {
    std.debug.assert(line_length != 0); // Lookup how to do comptime asserts.
    dprint("Data line length:{}\n", .{line_length}); //@debug

    // TODO:
    // Find string numerals, determine if they have an ajacent symbol other than
    // 0..9 and .

    var pt1_total : u32 = 0;
    
    var prev_char_digit = false;
    var num_start_index : usize = undefined;

    for (data, 0..) |char, index| {
        const isdigit = std.ascii.isDigit(char);
        defer prev_char_digit = isdigit;

        // Previous character cannot be a digit at the start of a new line.
        prev_char_digit = prev_char_digit and index % line_length != 0;
        
        if (isdigit and ! prev_char_digit) num_start_index = index;
        if (! isdigit and prev_char_digit) {
            // End of numeral, process.


            // Determine if the rectangle around the number contains any symbols.
            var tl_index = num_start_index;
            var rectw = index - num_start_index + 1;
            rectw += @intFromBool(num_start_index % line_length != 0);
            tl_index -= @intFromBool(num_start_index % line_length != 0);
            
            var recth : usize = 1;
            recth += @intFromBool(index / line_length != 0);
            tl_index -= if(num_start_index / line_length != 0) line_length else 0;
            recth += @intFromBool(index + line_length < data.len);
//            dprint("rectw, recth: {} {}\n", .{rectw, recth}); // @debug

            var adjacent = false;
            // Recall that 0..N in Zig is the same as 0..<N in Odin.
            lx: for (0..rectw) |x| { 
                for (0..recth) |y| {
                    adjacent = is_symbol(data[tl_index + x + line_length * y]);
                    if (adjacent) break :lx;
                }
            }

            if (adjacent) {
                const num_str = data[num_start_index..index];
                //            dprint("Num found: {s}\n", .{num_str}); // @debug
                const number = std.fmt.parseInt(u32, num_str, 10) catch 0;
                if (number == 0) dprint("Error: parseInt error, tried to parse {s}.", .{num_str});
//                dprint("Num found: {} adjacent: {}\n", .{number, adjacent}); // @debug
                pt1_total += number;
            }
        }
    }
    
    dprint("Pt1 sol: {}\n", .{pt1_total});
    // Output: 553079 (correct).
}

fn is_symbol(char : u8) bool {
    return ! (std.ascii.isWhitespace(char) or std.ascii.isDigit(char) or char == '.');
//    dprint("{c} is {}\n", .{char, is_char});
}
