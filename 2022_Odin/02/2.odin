package aoc22

import f "core:fmt"
import s "core:strings"

when ODIN_DEBUG {
    filename :: `test.txt`
} else {
    filename :: `data.txt`
}

rps :: enum u8 {
    R,
    P,
    S,
}

TLENGTH :: 3000

Match :: struct {
    opp : rps,
    mov : rps,
}

guide : [TLENGTH] Match

main :: proc() {
    using rps
    // Parse file.
    file_string :: string(#load(filename))
    file_lines  := s.split_lines(file_string)
    do_calc := true
    for l, i in file_lines {
	if l == "" { continue }
	if len(l) != 3 {
	    f.println("ERROR! Line does not have 3 runes!")
	    f.println("Line number:", i)
	    do_calc = false
	    return
	}
	if i > TLENGTH {
	    f.println("ERROR! TLENGTH exceeded!")
	    do_calc = false
	    return
	}
    }
    if !do_calc {
	return
    }

    // Load data into guide.
    guide_length := 0
    
    for l, i in file_lines {
	if l == "" { continue }
	switch l[0] {
	case 'A':
	    guide[i].opp = .R
	case 'B':
	    guide[i].opp = .P
	case 'C':
	    guide[i].opp = .S
	    case:
	    f.println("Parsing Error!")
	}
	switch l[2] {
	case 'X':
	    guide[i].mov = .R
	case 'Y':
	    guide[i].mov = .P
	case 'Z':
	    guide[i].mov = .S
	    case:
	    f.println("Parsing Error!")
	}
	guide_length += 1
    }
    when ODIN_DEBUG {
	f.println(guide[0:guide_length])
    }

    // Calculate score (Pt1)
    total_score := calc_score(guide_length)
    
    f.println("Total score:", total_score)
    // Returned 13005, answer was correct.

    // Calculate modified score (Pt2)
    modified_score := calc_score2(guide_length)
    f.println("Modified score:", modified_score)
    // Returned 11373, answer was correct.
}

calc_score :: proc(guide_length : int) -> int {
    t_s := 0
    for match, i in guide {
	if i >= guide_length { break }
	m_s : int
	switch match {
	case {.R, .R}: m_s = 1 + 3
	case {.R, .P}: m_s = 2 + 6
	case {.R, .S}: m_s = 3 + 0
	case {.P, .R}: m_s = 1 + 0
	case {.P, .P}: m_s = 2 + 3
	case {.P, .S}: m_s = 3 + 6
	case {.S, .R}: m_s = 1 + 6
	case {.S, .P}: m_s = 2 + 0
	case {.S, .S}: m_s = 3 + 3
	}
	t_s += m_s
    }
    return t_s
}

calc_score2 :: proc(guide_length : int) -> int {
    t_s := 0
    for match, i in guide {
	if i >= guide_length { break }
	m_s : int
	switch match {
	case {.R, .R}: m_s = 0 + 3
	case {.R, .P}: m_s = 3 + 1
	case {.R, .S}: m_s = 6 + 2
	case {.P, .R}: m_s = 0 + 1
	case {.P, .P}: m_s = 3 + 2
	case {.P, .S}: m_s = 6 + 3
	case {.S, .R}: m_s = 0 + 2
	case {.S, .P}: m_s = 3 + 3
	case {.S, .S}: m_s = 6 + 1
	}
	t_s += m_s
    }
    return t_s
}
