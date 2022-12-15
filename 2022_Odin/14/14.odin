package aoc22

import f "core:fmt"
import s "core:strings"
import v "core:strconv"
import   "core:time"

when ODIN_DEBUG { FILENAME :: `test.txt` } else { FILENAME :: `data.txt` }

FILE :: string(#load(FILENAME))

when ODIN_DEBUG {
    DEPTH    :: 20
    WIDTH    :: 30
} else {
    DEPTH    :: 200
    WIDTH    :: 1000
}

main :: proc() {
    t1 := time.now()
    sol1, sol2 := simulate()
    t2 := time.now()
    f.println("Pt1 Sol:", sol1)
    // Returned 979, answer was correct.
    f.println("Pt2 Sol:", sol2)
    // Returned 29044, answer was correct.
    f.println("Pt1/2 Time:", time.diff(t1,t2))
    // Returned 27.70 ms
}

simulate :: proc() -> (int, int) {
    file := FILE
    // Reverse xpos and depth in array for better cache results.
    cave := make([] i8, DEPTH * WIDTH)
    // Data minx, maxx, miny, maxy 479 548 13 174
    // Draw rocks!
    max_depth := 0 
    for {
	line, ok1 := s.split_lines_iterator(&file)
	if !ok1 { break }
	w0, d0 := -1, -1
	for pair in s.split_iterator(&line, " -> ") {
	    ps := s.split(pair, ",")
	    w1, ok3 := v.parse_int(ps[0])
	    d1, ok4 := v.parse_int(ps[1])
	    assert(ok3 && ok4)
	    draw_line(&cave, w0,d0,w1,d1)
	    max_depth = max(max_depth, d1)
	    w0 = w1
	    d0 = d1
	}
    }
    
    // Disable for Pt1.
    actual_depth      := max_depth + 2 // For Pt2.
    draw_line(&cave, 500 - WIDTH / 2, actual_depth, 500 + WIDTH / 2 - 1, actual_depth)
    
    when ODIN_DEBUG {
	f.println("Max depth:", max_depth)
	for y in 0..=WIDTH-1 { f.println(cave[y*DEPTH:(y+1)*DEPTH])}
	f.println("")
    }

    
    // Simulate sand!
    tick := 0
    when ODIN_DEBUG { TICKLIMIT :: 1000 } else { TICKLIMIT :: 1_000_000 }
    temp1, temp2 := coord(500,0)
    source   := temp2 * DEPTH + temp1
    sandbufo := make([dynamic] int)
    sandbufn := make([dynamic] int)
    tempbuf : [dynamic] int // Never stores data.
    stopped_sand      := - 1   // Pt1 solution.
    overflow_detected := false // For Pt1
    pt2_sand          := -1    // Pt2 solution.
    
    ml: for tick < TICKLIMIT {
	// Make sand gain every 4 ticks.
	if tick & 0x03 == 0 { append(&sandbufo, source) }
	sg: for sand in sandbufo {
	    // Overflow test.
	    if !overflow_detected {
		if sand % DEPTH > max_depth {
		    when ODIN_DEBUG { f.println("Overflow detected! Tick:", tick) }
		    overflow_detected = true
		    // Calculate number of sand grains which have stopped.
		    number_sand_created := tick / 4 + 1
		    grains_in_buffer    := len(sandbufo)
		    stopped_sand = number_sand_created - grains_in_buffer
		    // break ml // Pt1
		}
	    }
	    // Rules: Move R, if not RU, if not RD, otherwise write.
	    tries : [3] int = { sand + 1, sand - DEPTH + 1, sand + DEPTH + 1 }
	    for try in tries {
		if cave[try] == 0 {
		    append(&sandbufn, try)
		    continue sg
		}
	    }
	    // Otherwise, write in the sand!
	    // Or (Pt2) break if the writing is at the source!
	    if sand == source {
		when ODIN_DEBUG { f.println("Source stoppage detected!") }
		// Calculate number of sand grains which have stopped.
		pt2_sand = tick / 4 + 1
		break ml
	    }
	    cave[sand] = 1
	}
	clear(&sandbufo)
	tempbuf = sandbufo
	sandbufo = sandbufn
	sandbufn = tempbuf
	tick += 1
    }
    when ODIN_DEBUG {
	for y in 0..=WIDTH-1 { f.println(cave[y*DEPTH:(y+1)*DEPTH]) }
    }
    return stopped_sand, pt2_sand
}

// Convert between depth, width and array coordinates.
// In caves, depth goes L to R
coord :: #force_inline proc( w, d : int ) -> ( ax : int, ay : int) {
    return d, w - 500 + WIDTH / 2
}

draw_line :: proc( ptr: ^[] i8, w0,d0,w1,d1 : int) {
    // In cave, depth goes L to R
    // Convert inputs with coord.
    if w0 == -1 || d0 == -1 { return }
    when ODIN_DEBUG { f.printf("Drawing (%d, %d) -- (%d, %d)\n",w0,d0,w1,d1) }
    ax,ay := coord(w0,d0)
    bx,by := coord(w1,d1)
    if ax == bx {
	small := min(ay,by)
	large := max(ay,by)
	for t in small..=large {
	    ptr[t * DEPTH + ax] = 2
	}
    }
    if ay == by {
	small := min(ax,bx)
	large := max(ax,bx)
	for t in small..=large {
	    ptr[ay * DEPTH + t] = 2
	}
    }
    return
}
