package aoc22

import f "core:fmt"
import s "core:strings"
import v "core:strconv"
import   "core:testing"

when ODIN_DEBUG {
    FILENAME :: `test.txt`
} else {
    FILENAME :: `data.txt`
}

FILE :: string(#load(FILENAME))

main :: proc() {
    sol1, sol2 := pt12()
    f.println("Pt 1 solution:", sol1)
    // Output was 576, answer was correct.
    f.println("Pt 2 solution:", sol2)
    // Output was 905, answer was correct.
}

RangePair :: [4] int

pt12 :: proc() -> (int, int) {
    lines := s.split_lines(FILE)
    pair_data : [1100] RangePair
    range_pair_n    := 0

    for l in lines {
	if l == "" { continue }
	s_pairs := s.split_n(l, ",", 2)
	//	f.println("s_pairs", s_pairs) // @debug
	r1_nums := s.split_n(s_pairs[0], "-", 2)
	r2_nums := s.split_n(s_pairs[1], "-", 2)
	//	f.println(r1_nums, r2_nums) // @debug
	x, _ := v.parse_int(r1_nums[0])
	y, _ := v.parse_int(r1_nums[1])
	z, _ := v.parse_int(r2_nums[0])
	w, _ := v.parse_int(r2_nums[1])
	
	pair_data[range_pair_n].x = x
	pair_data[range_pair_n].y = y
	pair_data[range_pair_n].z = z
	pair_data[range_pair_n].w = w
	range_pair_n += 1
    }
    f.println(pair_data[0:10]) // @debug

    // Determine how many pairs are in the other. (Pt1)
    pt1_count := 0
    i := 0
    for i < range_pair_n {
	if ( (pair_data[i].x <= pair_data[i].z) && (pair_data[i].w <= pair_data[i].y) ) || ( (pair_data[i].x >= pair_data[i].z) && (pair_data[i].w >= pair_data[i].y) ) { pt1_count += 1 }
	i += 1
    }

    // Determine how many pairs overlap (Pt2)
    i = 0
    pt2_count := 0
    for i < range_pair_n {
	p := pair_data[i]
	if (p.x <= p.z && p.z <= p.y) || (p.x <= p.w && p.w <= p.y) ||
	    (p.z <= p.x && p.x <= p.w) || (p.z <= p.y && p.y <= p.w)
	{ pt2_count += 1 }
	i += 1
    }
    return pt1_count, pt2_count
}
