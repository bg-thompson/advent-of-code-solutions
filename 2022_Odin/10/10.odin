package aoc22

import f "core:fmt"
import s "core:strings"
import v "core:strconv"
import   "core:time"
import   "core:slice"

when ODIN_DEBUG {
    FILENAME :: `test.txt`
} else {
    FILENAME :: `data.txt`
}

FILE :: string(#load(FILENAME))

CRT_W :: 40
CRT_H :: 6

main :: proc() {
    t1   := time.now()
    sol1 := pt1()
    t2   := time.now()
    f.println("Pt1 Sol:",  sol1)
    // Returned 17940, answer was correct.
    f.println("Pt1 TIme:", time.diff(t1,t2))

    t3   := time.now()
    pt2()
    // Returned:
    //    ####..##..###...##....##.####...##.####.
    //    ...#.#..#.#..#.#..#....#.#.......#....#.
    //    ..#..#....###..#..#....#.###.....#...#..
    //    .#...#....#..#.####....#.#.......#..#...
    //    #....#..#.#..#.#..#.#..#.#....#..#.#....
    //    ####..##..###..#..#..##..#.....##..####.
    //
    // ZCBAJFJZ was correct.
    t4   := time.now()
    f.println("Pt2 Time:", time.diff(t3,t4))
}

pt1 :: proc() -> int {
    lines  := s.split_lines(FILE)
    cycle_n := 1
    reg_val := 1
    ss_sum := 0
    important_cycles : [6]int = {20,60,100,140,180,220}
    for l in lines {
	if l == "" { continue }
	fs := s.fields(l)
	// Check if cycle in list.
	if slice.contains(important_cycles[:],cycle_n) {
	    when  ODIN_DEBUG {
		f.println("Important cycle:", cycle_n)
		f.println("Strength:", cycle_n * reg_val)
	    }
	    signal_strength := cycle_n * reg_val
	    ss_sum += signal_strength
	}
	// Check if cycle will be in the middle of an addx
	if fs[0] == "addx" && slice.contains(important_cycles[:],cycle_n + 1) {
	    when  ODIN_DEBUG {
		f.println("Important cycle:", cycle_n + 1)
		f.println("Strength:", (cycle_n + 1) * reg_val)
	    }
	    signal_strength := (cycle_n + 1) * reg_val
	    ss_sum += signal_strength
	}
	// Update cycle number, and reg val.
	switch fs[0] {
	case "addx":
	    k, _ := v.parse_int(fs[1])
	    reg_val += k
	    cycle_n += 2
	case "noop":
	    cycle_n += 1
	}
    }
    return ss_sum
}

pt2 :: proc() {
    lines  := s.split_lines(FILE)
    cn := 1
    regv   := 1
    screen := make([dynamic] rune)
    for l in lines {
	if l == "" { continue }
	when ODIN_DEBUG {
	    f.println("Current cycle/regv:", cn, regv)
	}
	// Print out # / . , then to op.
	append_pixel(cn, regv, &screen)
	// Op.
	fs := s.fields(l)
	if fs[0] == "noop" {
	    cn += 1
	} else {
	    cn += 1
	    append_pixel(cn, regv, &screen)
	    val, _ := v.parse_int(fs[1])
	    regv += val
	    cn += 1
	}
    }
    // Print solution.
    for y in 0..=CRT_H-1 {
	for x in 0..=CRT_W-1 {
	    f.printf("%c", screen[y*CRT_W + x])
	}
	f.printf("\n")
    }
}

append_pixel :: proc( cnt, regv : int, arr :  ^[dynamic] rune) {
    cn := cnt % CRT_W
    if cn == regv || cn == regv+1 || cn == regv+2 {
	append(arr, '#')
    } else {
	append(arr, '.')
    }
}
