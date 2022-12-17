package aoc22

import f "core:fmt"
import s "core:strings"
import v "core:strconv"
import   "core:time"
import   "core:slice"


when ODIN_DEBUG { FILENAME :: `test.txt` } else { FILENAME :: `data.txt` }
// For use in Pt1
//when ODIN_DEBUG { CHAMBERHEIGHT :: 30 } else { CHAMBERHEIGHT :: 8000 }
when ODIN_DEBUG { CHAMBERHEIGHT :: 30 } else { CHAMBERHEIGHT :: 2_000_000}

SIMLIMIT :: 10_000

FILE :: string(#load(FILENAME))

BRUTAL :: 1_000_000_000_000

Rock :: struct{
    w : int,
    h : int,
    stones : []i8,
}

R1 :: Rock{4,1,{1,1,1,1}}

R2 :: Rock{3,3,{0,1,0,
		1,1,1,
		0,1,0}}

// Arrays go L to R, bottom to up.
R3 :: Rock{3,3,{1,1,1,
		0,0,1,
		0,0,1}}

R4 :: Rock{1,4,{1,
		1,
		1,
		1}}

R5 :: Rock{2,2,{1,1,
		1,1}}

Rocks :: [5]Rock{R1,R2,R3,R4,R5}

main :: proc() {
    rocks := Rocks
    WIDTH :: 9
    chamber := make([] i8, WIDTH * CHAMBERHEIGHT )
    // Array goes L to R, bottom to top.
    // Add a floor to the chamber
    for i in 0..=WIDTH-1 { chamber[i] = 1 }
    // Add in walls to either side of the chamber.
    for i in 0..=CHAMBERHEIGHT-1 {
	chamber[WIDTH*i] = 1
	chamber[WIDTH*i + WIDTH - 1] = 1
    } 
    
    lines   := s.split_lines(FILE)
    jets    := lines[0]
    jetlength := len(jets)
    
    jn          := 0
    // Pt1
    // when ODIN_DEBUG { SIMLIMIT :: 10 } else { SIMLIMIT :: 2022 }
    
    // When theight was printed in the final iteration, 3067
    // was obtained, this was correct.
    
    rn          := 0
    theight	:= 0
    ru1, ru2, ru3 := 0,0,0
    th2, th3 := 0,0
    sl: for i := 0; i < SIMLIMIT; i += 1 {
	spawn_point := WIDTH*(theight + 4) + 3
	// Attempt to apply wind.
	rock := rocks[rn]
	rw := rock.w
	rh := rock.h
	stones := rock.stones
	
	for {
	    when ODIN_DEBUG {
		f.println("Spawn point:", spawn_point % WIDTH, spawn_point / WIDTH)
		f.printf("Jet: %c (%d)\n", jets[jn], jn)
	    }
	    switch jets[jn] {
	    case '>':
		moving := true
		w1: for y in 0..=rh-1 {
		    for x in 0..=rw-1 {
			if stones[y*rw + x] == 1 && chamber[spawn_point + y*WIDTH + x + 1] == 1 {
			    // Then there is a blockage, so don't move.
			    moving = false
			    break w1
			}
		    }
		}
		if moving {
		    spawn_point += 1
		    when ODIN_DEBUG { f.println("--->") }
		}
	    case '<':
		moving := true
		w2: for y in 0..=rh-1 {
		    for x in 0..=rw-1 {
			if stones[y*rw + x] == 1 && chamber[spawn_point + y*WIDTH + x - 1] == 1 {
			    moving = false
			    break w2
			}
		    }
		}
		if moving {
		    when ODIN_DEBUG { f.println("<---") }
		    spawn_point -= 1
		}
		case:
		assert(false)
	    }
	    jn = (jn + 1) % jetlength
	    // Attempt to move down.
	    write_rock := false
	    wl: for y in 0..=rh-1 {
		for x in 0..=rw-1 {
		    if stones[y*rw + x] == 1 && chamber[spawn_point - WIDTH + y*WIDTH + x] == 1 {
			// There is a blockage, so the stone comes to rest.
			// Add it to the chamber!
			write_rock = true
			break wl
		    }
		}
	    }
	    if !write_rock {
		spawn_point -= WIDTH
	    } else {
		for y in 0..=rh-1 {
		    for x in 0..=rw-1 {
			if stones[y*rw + x] == 1 {
			    chamber[spawn_point + y*WIDTH + x] = 1
			}
		    }
		}
		break
	    }
	}
	
	// Calculate towerheight
	theight = 0
	tl: for y in 0..=CHAMBERHEIGHT-1 {
	    for x in 1..=WIDTH-2 {
		if chamber[y*WIDTH + x] == 1 { continue tl }
	    }
	    // Empty row!
	    theight = y - 1
	    break
	}
	// Manually found that jn == 6 repeats.
	res_found := false
	if jn == 6 && i > 10 {
	    //	if i ==1585 {
	    // Led to Pt2 solution: 1514369501484, answer was correct.
	    if ru1 == 0 { ru1 = i }
	    else {
		if ru2 == 0 { ru2 = i ; th2 = theight }
		else { ru3 = i ; th3 = theight }
		if (ru2 - ru1) == (ru3 - ru2) {
		    res := ru2 - ru1
		    f.println("")
		    f.println("Rock number res found!:", res)
		    f.println("Difference in tower height:", th3 - th2)
		    f.println("Calculate the height of the tower at:", BRUTAL % res)
		    f.println("Then add to", (BRUTAL / res) * (th3 - th2), "and - 1 to obtain the solution to Pt2.")
		    f.println("")
		    res_found = true
		}
	    }
	    f.println("Tower height:", theight, "tile number:", i, jn )
	    f.println("Previous 5 rows")
	    for z in 0..=5 {
		for x in 0..=WIDTH-1 {
		    f.printf("%s", chamber[theight*WIDTH -z*WIDTH + x] == 1 ? "#" : ".")
		}
		f.println("")
	    }
	}
	rn = (rn + 1) % 5
	if res_found { break sl }
    }
}


print_chamber :: proc( ch : ^[]i8, w, h : int) {
    for y in 0..=h-1 {
	if (h - 1 - y) % 5 == 0 { f.printf("%d ", (h - 1 - y) % 10) }
	else { f.printf("  ") }
	for x in 0..=w-1 {
	    f.printf("%s", ch[(h - 1 - y)*w + x] == 1 ? "#" : ".")
	}
	f.println("")
    }
    f.println("")
}
