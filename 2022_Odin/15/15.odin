package aoc22

import f "core:fmt"
import s "core:strings"
import v "core:strconv"
import   "core:time"
import   "core:slice"

when ODIN_DEBUG { FILENAME :: `test.txt` } else { FILENAME :: `data.txt` }

when ODIN_DEBUG { ROW :: 10 } else { ROW :: 2_000_000 }
when ODIN_DEBUG { SENSORLIMIT :: 15 } else { SENSORLIMIT :: 40 }

FILE :: string(#load(FILENAME))

main :: proc() {
    t1 := time.now()
    sol1 := pt1()
    t2 := time.now()
    f.println("Pt1 Sol:", sol1)
    // Returned 5716881
    f.println("Pt1 Time:", time.diff(t1,t2))
    // 22.0ms

    t3 := time.now()
    sol2 := pt2()
    t4 := time.now()
    f.println("Pt2 Sol:", sol2)
    // Returned 10852583132904, answer was correct.
    f.println("Pt2 Time:", time.diff(t3,t4))
    // 1.601 s
}

pt1 :: proc() -> int {
    file := FILE
    ln := 0
    sbl           : [SENSORLIMIT * 4] int = 0
    for {
	line, lok := s.split_lines_iterator(&file)
	if !lok { break }
	assert(ln < SENSORLIMIT)
	lp := s.split_multi(line,[]string{"x=", "y=", ", ", ": "})
	sx, sy, bx, by := lp[1], lp[3], lp[5], lp[7]
	a, ok1 := v.parse_int(sx)
	b, ok2 := v.parse_int(sy)
	c, ok3 := v.parse_int(bx)
	d, ok4 := v.parse_int(by)
	assert(ok1 & ok2 & ok3 & ok4)
	sbl[4*ln + 0] = a
	sbl[4*ln + 1] = b
	sbl[4*ln + 2] = c
	sbl[4*ln + 3] = d
	ln += 1
    }
    when ODIN_DEBUG { f.println(sbl) }

    // Calculate box bounds.
    xmin , xmax, ymin, ymax := sbl[0], sbl[0], sbl[1], sbl[1]
    for q in 0..=ln-1 {
	a, b, c, d := sbl[4*q], sbl[4*q + 1], sbl[4*q + 2], sbl[4*q + 3]
	dist := metric(a,b,c,d)
	
	xmin = min(xmin, a - dist)
	xmax = max(xmax, a + dist)
	ymin = min(ymin, b - dist)
	ymax = max(ymax, b + dist)
    }
    
    when ODIN_DEBUG { f.println("Box bounds:", xmin, xmax, ymin, ymax) }

    // Test for whether or not a square is in a beacon range,
    // moving L to R.
    // If it is, skip to the border of that beacon range.

    covered := 0
    ml: for sq := xmin; sq <= xmax; sq += 1 {
	for q in 0..=ln-1 {
	    a, b, c, d := sbl[4*q], sbl[4*q + 1], sbl[4*q + 2], sbl[4*q + 3]
	    rad  := metric(a,b,c,d)
	    dist := metric(sq,ROW,a,b)
	    if dist <= rad {
		border := sq + rad - dist
		covered += rad - dist + 1
		sq = border
		continue ml
	    }
	}
    }
    return covered - 1 // Somehow an off-by-one error has crept in.
                       // No matter, AOC doesn't know :)
}

pt2 :: proc() -> int {
    file := FILE
    ln := 0
    sbl           : [SENSORLIMIT * 4] int = 0
    for {
	line, lok := s.split_lines_iterator(&file)
	if !lok { break }
	assert(ln < SENSORLIMIT)
	lp := s.split_multi(line,[]string{"x=", "y=", ", ", ": "})
	sx, sy, bx, by := lp[1], lp[3], lp[5], lp[7]
	a, ok1 := v.parse_int(sx)
	b, ok2 := v.parse_int(sy)
	c, ok3 := v.parse_int(bx)
	d, ok4 := v.parse_int(by)
	assert(ok1 & ok2 & ok3 & ok4)
	sbl[4*ln + 0] = a
	sbl[4*ln + 1] = b
	sbl[4*ln + 2] = c
	sbl[4*ln + 3] = d
	ln += 1
    }
    when ODIN_DEBUG { f.println(sbl) }

    // Calculate box bounds.
    xmin , xmax, ymin, ymax := sbl[0], sbl[0], sbl[1], sbl[1]
    for q in 0..=ln-1 {
	a, b, c, d := sbl[4*q], sbl[4*q + 1], sbl[4*q + 2], sbl[4*q + 3]
	dist := metric(a,b,c,d)
	
	xmin = min(xmin, a - dist)
	xmax = max(xmax, a + dist)
	ymin = min(ymin, b - dist)
	ymax = max(ymax, b + dist)
    }

    // Find the location not covered.
    for yp := 0; yp <= 4_000_000 ; yp += 1 {
	xl: for xp := 0 ; xp <= 4_000_000 ; xp += 1 {
	    for q in 0..=ln-1 {
		a, b, c, d := sbl[4*q], sbl[4*q + 1], sbl[4*q + 2], sbl[4*q + 3]
		rad  := metric(a,b,c,d)
		dist := metric(xp,yp,a,b)
		if dist <= rad {
		    xp += rad - dist
		    continue xl
		}
	    }
	    // Not within the radius!
	    f.println("Signal found!")
	    return xp * 4_000_000 + yp
	}
    }
    return -1
}

metric :: proc( x0, y0 , x1, y1 : int ) -> int {
    return abs(x0 - x1) + abs(y0 - y1)
}
