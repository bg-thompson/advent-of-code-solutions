package aoc22

import f "core:fmt"
import s "core:strings"
import   "core:time"

when ODIN_DEBUG { FILENAME :: `test.txt` } else { FILENAME :: `data.txt` }

FILE :: string(#load(FILENAME))

main :: proc() {
    t1 := time.now()
    sol1 := pt1()
    t2 := time.now()
    f.println("Pt1 Sol:", sol1)
    // Returned 5529, answer was correct
    f.println("Pt1 Time:", time.diff(t1,t2))
    // 220us

    t3 := time.now()
    sol2 := pt2()
    t4 := time.now()
    f.println("Pt2 Sol:", sol2)
    // Returned 27690, answer was correct
    f.println("Pt2 Time:", time.diff(t3,t4))
    // 13.2ms --- faster than expected, even with the
    // most naive sorting algo!
}

pt1 :: proc() -> int {
    l1 := make([dynamic] [2] i8)
    l2 := make([dynamic] [2] i8)
    index_sum_right_order := 0
    lines := s.split_lines(FILE)
    pair_number := 0
    loop1: for l, li in lines {
        if li % 3 != 0 { continue }
        pair_number += 1
        // Convert lines into lists of integers
        convert_string_into_pairs(&l1, l)
        convert_string_into_pairs(&l2, lines[li+1])
        when ODIN_DEBUG {
            f.println("1str:", l)
            f.println("2str:", lines[li+1])
            f.println("l1:", l1)
            f.println("l2:", l2)
        }
        // Compare!
        when ODIN_DEBUG {
            f.println("Order correct:", order_correct(&l1, &l2))
        }
        if order_correct(&l1,&l2) { index_sum_right_order += pair_number }
        clear(&l1)
        clear(&l2)
    }
    return index_sum_right_order
}

// Super crude, but our sorting algo takes less than a
// microsecond to do a pair, so it'll be fine.
pt2 :: proc() -> int {
    l1 := make([dynamic] [2] i8)
    l2 := make([dynamic] [2] i8)
    sorted_strings := make([dynamic] string)
    append(&sorted_strings, "[[2]]", "[[6]]")

    lines := s.split_lines(FILE)
    loop1: for l, li in lines {
        if li % 3 == 2 { continue loop1 }
        convert_string_into_pairs(&l1, l)
        for str, stri in sorted_strings {
            clear(&l2)
            convert_string_into_pairs(&l2, str)
            // Compare!
            if order_correct(&l1,&l2) {
                inject_at(&sorted_strings, stri, l)
                clear(&l1)
                continue loop1
            }
        }
        append(&sorted_strings, l)
        clear(&l1)
    }
    when ODIN_DEBUG { for st in sorted_strings { f.println(st) } }
    // Find index of [[2]] and [[6]] in storted strings
    i2, i6 := -1, -1
    for st, sti in sorted_strings {
        switch st {
        case "[[2]]":
            i2 = sti + 1
        case "[[6]]":
            i6 = sti + 1
        case:
            continue
        }
    }
    if i2 == -1 || i6 == -1 { f.println("[[2]] or [[6]] not found") }
    return i2 * i6
}

convert_string_into_pairs :: proc(ptr : ^[dynamic] [2] i8, str : string) {
    str_length := len(str)
    list_depth := i8(0)
    skip       := false
    for c, ci in str {
        if skip {
            skip = false
            continue
        }
        switch c {
        case '[':
            list_depth += 1
        case ']':
            append(ptr,[2]i8{-1,list_depth})
            list_depth -= 1
        case ',':
        case:
            if ci + 1 < str_length {
                if str[ci + 1] == '0' {
                    append(ptr,[2]i8{10,list_depth})
                    skip = true
                    continue
                }
            }
            append(ptr,[2]i8 {i8(c - '0'),list_depth})
        }
    }
    return 
}

order_correct :: proc(l1, l2 : ^[dynamic] [2] i8) -> bool {
    correct_order := true
    for i := 0; i < len(l1); i += 1 {
        if i >= len(l2) {
            // l2 shorter, so (l1,l2) in wrong order
            return false
        }
        // p1 = (a,b) p2 = (c,d)
        a, b, c, d := l1[i].x, l1[i].y, l2[i].x, l2[i].y
        if b == d {
            if a < c { return true  }
            if a > c { return false }
            continue
        }
        if a == c && a == -1 {
            // [[]] vs [] -like scenario.
            if b < d { return true  }
            if b > d { return false }
            continue
        }
        // Otherwise levels are different, so do the
        // 1 vs [3] -> [1] vs [3] rule.
        if b < d {
            // (a,b) -> (a,b+1), (-1,b+1)
            inject_at(l1, i+1, [2]i8{-1,b+1})
            inject_at(l1, i+1, [2]i8{a,b+1})
            inject_at(l2, i+1, l2[i])
            continue
        }
        if b > d {
            // (c,d) -> (c,d+1), (-1,d+1)
            inject_at(l2, i+1, [2]i8{-1,d+1})
            inject_at(l2, i+1, [2]i8{c,d+1})
            inject_at(l1, i+1, l1[i])
            continue
        }
        assert(false) // Should never get to here.
    }
    // Everything so has been equal.
    if len(l1) < len(l2) { return true  }
    if len(l1) > len(l2) { return false }
    assert(false) // Then l1 == l2, not meant to happen!
    return true
}
