// Disclaimer: At the time of writing, my experience with Zig is basically 0.
// The aim of solving these problems is to provide myself with an introduction to Zig.
const std = @import("std");
const data = @embedFile("problem1_data.txt");

const example_data =
    \\1abc2
    \\pqr3stu8vwx
    \\a1b2c3d4e5f
    \\treb7uchet
;

// @cleanup There is surely some standard library that does this, track it down.
// Obviously KMP is better. But this is AoC so O(n^2) is fine.
fn crude_first_substring_search(substr: [] const u8, str: [] const u8) i32 {
    const strlen = str.len;
    const sublen  = substr.len;
    var i : usize = 0;
    var j : usize = 0;
    while (i < strlen) : (i += 1) {
        j = 0;
        while (j < sublen and i + j < strlen) : (j += 1) {
            if (substr[j] != str[i + j]) {
                break;
            }
        }
        if (j == sublen) {
            // Match found!
            return @intCast(i);
        }
    }
    return -1;
}

// @copypasta from above.
fn crude_last_substring_search(substr: [] const u8, str: [] const u8) i32 {
    const strlen = str.len;
    const sublen  = substr.len;
    var i : usize = 0;
    var j : usize = 0;
    while (i < strlen) : (i += 1) {
        j = 0;
        while (j < sublen and strlen - 1 - i + j < strlen) : (j += 1) {
            if (substr[j] != str[strlen - 1 - i + j]) {
                break;
            }
        }
        if (j == sublen) {
            // Match found!
            return @intCast(strlen - 1 - i);
        }
    }
    return -1;
}

pub fn main() !void {
    // Part 1.
    //    var iter = std.mem.split(u8, example_data, "\n");
    var iter = std.mem.split(u8, data, "\n");    
    var code_total : u32 = 0;
    while (iter.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var first_numeral : u8 = undefined;
        var last_numeral  : u8 = undefined;
        const line_length = line.len;
        var i : u32 = 0;
        while (i < line_length) : (i += 1) {
            const tnum = line[i] - '0';
            if (0 <= tnum and tnum <= 9) {
                first_numeral = tnum;
                break;
            }
        }
        i = 0;
        while (i < line_length) : (i += 1) {
            const tnum = line[line_length - 1 - i] - '0';
            if (0 <= tnum and tnum <= 9) {
                last_numeral = tnum;
                break;
            }
        }
        code_total += 10 * first_numeral + last_numeral;
        //        std.debug.print("{}{}\n", .{first_numeral, last_numeral});
    }
    std.debug.print("(Pt1) Total: {}\n", .{code_total});
    // Output: 54450 (correct).
    
    // Part 2.
    var pt2_total : u32 = 0;
    // Just search each line for the first occurance (if any) of the strings
    // "0", "1", ... , "9", "one", "two", ... , "nine".

    var iter2 = std.mem.split(u8, data, "\n");    
//    const code_total2 : u32 = 0;
    while (iter2.next()) |line| {
        if (line.len == 0) { continue; }

        var first_word_locations = [20] i32 {0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0};
        var last_word_locations  = [20] i32 {0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0};
        const word_array = [_] [] const u8 {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"};

        for (word_array, 0..) |word, index| {
            first_word_locations[index] = crude_first_substring_search(word, line);
            last_word_locations[index]  = crude_last_substring_search(word, line);
        }
        
        var min_index : usize = 1_000_000;
        var min_value : i32 = 1_000_000;

        var max_index : usize = 1_000_000;
        var max_value : i32 = -1;
        
        for (first_word_locations, 0..) |value, index| {
            if (value != -1 and value < min_value) {
                min_value = value;
                min_index = index;
            }
        }
        for (last_word_locations, 0..) |value, index| {
            if (value != -1 and value > max_value) {
                max_value = value;
                max_index = index;
            }
        }
        // @cleanup nasty casting, this can surely be done in two less lines.
        const first_digit_u32 : u32 = @intCast(min_index);
        const first_digit = first_digit_u32 % 10;
        const last_digit_u32  : u32 = @intCast(max_index);
        const last_digit  = last_digit_u32 % 10;
//        std.debug.print("{any}\n", .{first_word_locations});
//        std.debug.print("{any}\n", .{last_word_locations});
//        std.debug.print("{}, {}\n", .{first_digit, last_digit});
        pt2_total += 10 * first_digit + last_digit;
    }
    std.debug.print("(Pt2) Total: {}\n", .{pt2_total});
    // Output: 54265 (correct).
}
