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
    // Returned 708us.
}

DL  :: 22
DLB :: DL + 2

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
    cube := make([] i8, DLB*DLB*DLB)
    for d in data {

	cube[d.x + 1 + (d.y + 1)*DLB + (d.z + 1)*DLB*DLB] = 1
    }
    total_hidden_faces := 0
    adjacents :: [6] int { -1, 1, -DLB, DLB, DLB*DLB, -DLB*DLB }
    for d in data {
	pos := d.x + 1 + (d.y + 1)*DLB + (d.z + 1)*DLB*DLB
	for adj in adjacents {
	    total_hidden_faces += int(cube[pos + adj])
	}
    }
    
    return 6 * nlines - total_hidden_faces
}

pt2 :: proc() -> int {
    // Process data.
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

    // Create bool cube with i8 and buffer, and fill with data.
    cube := make([] i8, DLB*DLB*DLB)
    for d in data { cube[d.x + 1 + (d.y + 1)*DLB + (d.z + 1)*DLB*DLB] = 1 }

    // Do breath-first search on the exterior,
    // the only entries left with 0 will be air pockets.
    boundaryo := make([dynamic] [3] int)
    boundaryn := make([dynamic] [3] int)
    temp      : [dynamic] [3] int
    append(&boundaryo, [3]int{0,0,0})
    cube[0] = 1
    
    adjacents :: [6] int { -1, 1, -DLB, DLB, DLB*DLB, -DLB*DLB }
    
    for len(boundaryo) != 0 {
	for p in boundaryo {
	    for i in 0..=2 {
		if p[i] - 1 >= 0 {
		    offset := i == 2 ? -DLB*DLB : -i*DLB + (i-1)
		    if cube[p.x + p.y*DLB + p.z*DLB*DLB + offset] == 0 {
			cube[p.x + p.y*DLB + p.z*DLB*DLB + offset] = 1
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
		    offset := i == 2 ? DLB*DLB : i*DLB + (1-i)
		    if cube[p.x + p.y*DLB + p.z*DLB*DLB + offset] == 0 {
			cube[p.x + p.y*DLB + p.z*DLB*DLB + offset] = 1
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
    

