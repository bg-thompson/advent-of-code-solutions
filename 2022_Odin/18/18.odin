package aoc22

import f "core:fmt"
import s "core:strings"
import v "core:strconv"
import   "core:time"

when ODIN_DEBUG { FILENAME :: `test.txt` } else { FILENAME :: `data.txt`}
FILE :: string(#load(FILENAME))

main :: proc() {
    t1 := time.now()
    sol1 := pt1()
    t2 := time.now()
    f.println("Pt1 Sol:", sol1)
    // Returned 4512, answer was correct.
    f.println("Pt1 Time:", time.diff(t1,t2))
    // Returned 550us.

    t3 := time.now()
    sol2 := pt2()
    t4 := time.now()
    f.println("Interior faces:", sol2)
    f.println("Pt2 Sol:", sol1 - sol2)
    // Returned 2554, answer was correct.
    f.println("Pt2 Time:", time.diff(t3,t4))
    // Returned 993us.
}

DL :: 30

pt1 :: proc() -> int {
    // Process data
    lines := s.split_lines(FILE)
    nlines := len(lines) - 1
    data := make([] [3] int, nlines)
    for i in 0..=nlines-1 {
	ints := s.split(lines[i],",")
	for str, j in ints {
	    n, ok := v.parse_int(str)
	    assert(ok && n < DL)
	    data[i][j] = n
	}
    }
    when ODIN_DEBUG { f.println("Data:")
		      f.println(data) }
    
    // Create bool cube with i8 and buffer, and fill with data.
    cube := make([] i8, (DL + 2)*(DL + 2)*(DL + 2))
    for d in data {

	cube[d.x + 1 + (d.y + 1)*(DL + 2) + (d.z + 1)*(DL + 2)*(DL + 2)] = 1
    }
    total_hidden_faces := 0
    adjacents :: [6] int { -1, 1, -(DL + 2), (DL + 2), (DL + 2)*(DL + 2), -(DL + 2)*(DL + 2) }
    for d in data {
	pos := d.x + 1 + (d.y + 1)*(DL + 2) + (d.z + 1)*(DL + 2)*(DL + 2)
	for adj in adjacents {
	    total_hidden_faces += int(cube[pos + adj])
	}
    }
    
    return 6 * nlines - total_hidden_faces
}

pt2 :: proc() -> int {
    // Process data, and calculate bounds of droplet.
    maxx, maxy, maxz := 0,0,0
    minx, miny, minz := DL, DL, DL
    
    lines := s.split_lines(FILE)
    nlines := len(lines) - 1
    data := make([] [3] int, nlines)
    for i in 0..=nlines-1 {
	ints := s.split(lines[i],",")
	for str, j in ints {
	    n, ok := v.parse_int(str)
	    assert(ok && n < DL)
	    data[i][j] = n
	    switch j {
		case 0:
		minx = n < minx ? n : minx
		maxx = n > maxx ? n : maxx
	    case 1:
		miny = n < miny ? n : miny
		maxy = n > maxy ? n : maxy
	    case 2:
		minz = n < minz ? n : minz
		maxz = n > maxz ? n : maxz
		case:
		assert(false)
	    }
	}
    }
    if ODIN_DEBUG { f.println("min/max x, y z:", minx, maxx, miny, maxy, minz, maxz) }

    // Create bool cube with i8 and buffer, and fill with data.
    cube := make([] i8, (DL + 2)*(DL + 2)*(DL + 2))
    for d in data { cube[d.x + 1 + (d.y + 1)*(DL + 2) + (d.z + 1)*(DL + 2)*(DL + 2)] = 1 }

    // Do breath-first search on the exterior,
    // the only entries left with 0 will be air pockets.
    boundaryo := make([dynamic] [3] int)
    boundaryn := make([dynamic] [3] int)
    temp      : [dynamic] [3] int
    append(&boundaryo, [3]int{0,0,0})
    cube[0] = 1
    
    adjacents :: [6] int { -1, 1, -(DL + 2), (DL + 2), (DL + 2)*(DL + 2), -(DL + 2)*(DL + 2) }
    
    for len(boundaryo) != 0 {
	for p in boundaryo {
	    for i in 0..=2 {
		if p[i] - 1 >= 0 {
		    offset := i == 2 ? -(DL + 2)*(DL + 2) : -i*(DL + 2) + (i-1)
		    if cube[p.x + p.y*(DL + 2) + p.z*(DL + 2)*(DL + 2) + offset] == 0 {
			cube[p.x + p.y*(DL + 2) + p.z*(DL + 2)*(DL + 2) + offset] = 1
			switch i {
			case 0:
			    append(&boundaryn, [3]int{p.x - 1, p.y, p.z})
			case 1:
			    append(&boundaryn, [3]int{p.x, p.y-1, p.z})
			case 2:
			    append(&boundaryn, [3]int{p.x, p.y, p.z - 1})
			}
		    }
		}
		if p[i] + 1 < DL + 2 {
		    offset := i == 2 ? (DL + 2)*(DL + 2) : i*(DL + 2) + (1-i)
		    if cube[p.x + p.y*(DL + 2) + p.z*(DL + 2)*(DL + 2) + offset] == 0 {
			cube[p.x + p.y*(DL + 2) + p.z*(DL + 2)*(DL + 2) + offset] = 1
			switch i {
			case 0:
			    append(&boundaryn, [3]int{p.x + 1, p.y, p.z})
			case 1:
			    append(&boundaryn, [3]int{p.x, p.y + 1, p.z})
			case 2:
			    append(&boundaryn, [3]int{p.x, p.y, p.z + 1})
			}
		    }
		}
	    }
	}
	clear(&boundaryo)
	temp = boundaryo
	boundaryo = boundaryn
	boundaryn = temp
    }
    // Find non-zero entries.
    gaps := new([dynamic] int)
    for val, i in cube {
	if val == 0 { append(gaps, i) }
    }
    when ODIN_DEBUG { f.println("Number of interior cubes:", len(gaps)) }
    // Now compute hidden faces for the interior cubes.
    total_air_faces := 0
    for g in gaps {
	for adj in adjacents {
	    total_air_faces += int(1 - cube[g + adj])
	}
    }
    total_interior_faces := 6 * len(gaps) - total_air_faces
    return total_interior_faces
}
    

