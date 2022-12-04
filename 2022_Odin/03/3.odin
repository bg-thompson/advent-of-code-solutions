package aoc22

import f "core:fmt"
import s "core:strings"
import   "core:testing"

when ODIN_DEBUG {
    FILENAME :: `test.txt`
} else {
    FILENAME :: `data.txt`
}

FILE :: string(#load(FILENAME))

main :: proc() {
    sol1 := pt1()
    sol2 := pt2()
    f.println("Pt 1 solution:", sol1)
    // Returned 8233, answer was correct.
    f.println("Pt 2 solution:", sol2)
    // Returned 2821, answer was correct.
}

pt1 :: proc() -> int {
    lines := s.split_lines(FILE)
    defer delete(lines)
    for l in lines { assert(len(l) & 1 != 1) } // len should be even.

    total := 0
    for l in lines {
	if l == "" { continue }
	hl := len(l) >> 1
next:	for a in l[0:hl] {
	    for b in l[hl:] {
		if a == b {
		    raw_score := int(b) - 'A' + 1
		    if raw_score < 27 {
			total += raw_score + 26
		    } else {
			total += raw_score - 0x20
		    }
		    break next
		}
	    }
}
    }
    return total
}

pt2 :: proc() -> int {
    lines := s.split_lines(FILE)
    defer delete(lines)

    total := 0
    for l, i in lines {
	if i % 3 != 0 { continue }
	if l == "" { continue }
next:	for a in l {
	    for b in lines[i+1] {
		if a == b {
		    for c in lines[i+2] {
			if a == c {
			    //	    f.println(a) // @debug
			    raw_score := int(b) - 'A' + 1
			    if raw_score < 27 {
				total += raw_score + 26
			    } else {
				total += raw_score - 0x20
			    }
			    break next
			}
		    }
		}
	    }
	}
    }
    return total
}

@(test)
test_pt1 :: proc( t : ^testing.T) {
    testing.expect_value(t, pt1(), 157)
}

test_pt2 :: proc( t: ^testing.T) {
    testing.expect_value(t, pt2(), 70)
}
