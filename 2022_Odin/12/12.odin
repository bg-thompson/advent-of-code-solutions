package aoc22

import f "core:fmt"
import s "core:strings"
import   "core:time"

when ODIN_DEBUG { FILENAME :: `test.txt` } else { FILENAME :: `data.txt` }

FILE :: string(#load(FILENAME))

grid  : [dynamic] i8
gridh : int
gridw : int
end   : int

main :: proc() {
    ls    := s.split_lines(FILE)
    gridw = len(ls[0]) + 2 // +2 for the buffer.
    gridh = len(ls)    + 1 // ditto.
    grid  = make([dynamic] i8) //, gridw * gridh)

    start : int
    // Load in data, add filler boundary, height -1,
    // to make problem easier.
    for i in 1..=gridw { append(&grid, -1) }
    for l, li in ls {
	if l == "" { continue }
	append(&grid, -1)
	for c, ci in l {
	    switch c {
	    case 'S':
		start = gridw*(li + 1) + ci + 1
		append(&grid, 1)
	    case 'E':
		end   = gridw*(li + 1) + ci + 1
		append(&grid, 26)
		case:
		append(&grid, i8(c - 'a' + 1))
	    }
	}
	append(&grid, -1)
    }
    for i in 1..=gridw { append(&grid, -1) }
    when ODIN_DEBUG {
	f.println("w, h, Start:", gridw, gridh, start)
	f.println("Grid:")
	for i in 0..=gridh-1 {
	    for j in grid[i*gridw:(i+1)*gridw] {
		f.printf("%02d ", j)
	    }
	    f.println("")
	}
    }
    
    t1 := time.now()
    sol1 := length_min_path(start)
    t2 := time.now()
    f.println("Pt1 Sol:", sol1)
    // Returned 468, answer was correct.
    f.println("Pt1 Time:", time.diff(t1,t2))

    t3 := time.now()
    min_path_from_a := gridh * gridw
    for val, i in grid {
	if val == 1 {
	    min_path_from_a = min(min_path_from_a, length_min_path(i))
	}
    }
    t4 := time.now()
    f.println("Pt2 Sol:", min_path_from_a)
    f.println("Pt2 Time:", time.diff(t3,t4))
}

length_min_path :: proc(starting_pos : int) -> int {
    // With node, keeping track of backtracking: pt1 sol, 300us
    // With only array:                                   168us
    gridb := make([] bool, gridw * gridh)

    // Find and calculate shortest distance, just use b-first search.
    fronto := make([dynamic] int)
    frontn := make([dynamic] int)
    temp   : [dynamic] int
    append(&fronto, starting_pos)
    curr_len := 0
    iteration_number := 0
    f1: for {
	iteration_number += 1
	for ni in fronto {
	    currh := grid[ni]
	    north := ni - gridw
	    south := ni + gridw
	    east  := ni + 1
	    west  := ni - 1
	    directions : [4] int = { north, south, east, west }
	    for d in directions {
		diff := grid[d] - currh
		if diff <= 1 && grid[d] > -1 && gridb[d] == false {
		    gridb[d] = true
		    if d == end {
			when ODIN_DEBUG { f.println("E found!") }
			return iteration_number
		    }
		    append(&frontn, d)
		}
	    }
	}
	clear(&fronto)
	temp = fronto
	fronto = frontn
	frontn = temp
	
	if len(fronto) == 0 {
	    when ODIN_DEBUG { f.println("fronto empty! iter:", iteration_number) }
	    break f1
	}
    }
    
    return 1_000_000
}
