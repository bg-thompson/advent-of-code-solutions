package aoc22

import f "core:fmt"
import s "core:strings"
import v "core:strconv"
import   "core:time"

when ODIN_DEBUG { FILENAME :: `test.txt` } else { FILENAME :: `data.txt` }

FILE :: string(#load(FILENAME))

main :: proc() {
    t1 := time.now()
    sol1 := pt1()
    t2 := time.now()
    f.println("Pt1 Sol:",  sol1)
    // Returned 131052, answer was correct.
    f.println("Pt1 Time:", time.diff(t1,t2))
    // Returned 333us.

    // Pt2
    // TODO...
}

when ODIN_DEBUG { SQ   :: 4 } else { SQ :: 50 }
when ODIN_DEBUG { HIDTH :: 3 * SQ } else { HIDTH :: 4 * SQ }
when ODIN_DEBUG { WIDTH :: 4 * SQ } else { WIDTH :: 3 * SQ }

Meta :: struct { offset, length : u8 }
Direction :: enum u8 { left, right }
Instruction :: union { int, Direction }

pt1 :: proc() -> int {
    using Direction
    lines := s.split_lines(FILE)
    
    // Process commands.
    rawcommands := lines[HIDTH + 1]
    lraw := len(rawcommands)
    commands    := make([] Instruction, lraw)
    ncommands   := 0
    digit_start := 0
    index       := 0
    for index < lraw {
	if rawcommands[index] == 'L' || rawcommands[index] == 'R' {
	    n, ok := v.parse_int(rawcommands[digit_start:index])
	    assert(ok && n < 256)
	    digit_start = index + 1
	    commands[ncommands    ] = n
	    commands[ncommands + 1] = rawcommands[index] == 'L' ? .left : right
	    ncommands += 2
	}
	index += 1
    }
    n, ok := v.parse_int(rawcommands[digit_start:index])
    assert(ok && n < 256)
    commands[ncommands] = n
    when ODIN_DEBUG { f.println("Commands:", commands) }

    // Determine rowmeta and colmeta manually, then
    // use this to define the horizontal and vertical grids.
    // Waaaay easier than trying to parse a general file.
    rowmeta : [HIDTH] Meta
    colmeta : [WIDTH] Meta

    when ODIN_DEBUG {
	rowmeta = { 0..=3  = {8,4 },
		    4..=7  = {0,12},
		    8..=11 = {8,8 },
		  }
    } else {
	rowmeta = { 0..=49    = {50,100},
		    50..=99   = {50,50},
		    100..=149 = {0,100},
		    150..=199 = {0,50},
		  }
    }
    when ODIN_DEBUG {
	colmeta = { 0..=7   = {4,4},
		    8..=11  = {0,12},
		    12..=15 = {8,4},
		  }
    } else {
	colmeta = { 0..=49  = {100,100},
		    50..=99 = {0,150},
		    100..=149 = {0,50},
		  }
    }

    // Load in row data.
    rdata := make([] []u8, HIDTH)
    for i in 0..=HIDTH-1 {
	of := rowmeta[i].offset
	ln := rowmeta[i].length
	rdata[i] = transmute([]u8) lines[i][of:of+ln]
    }
    // Load in col data.
    cdata := make([] []u8, WIDTH)
    for i in 0..=WIDTH-1 {
	of := colmeta[i].offset
	ln := colmeta[i].length
	col := make([]u8, ln)
	for j in 0..=ln-1 { col[j] = lines[of+j][i] }
	cdata[i] = col
    }

    when ODIN_DEBUG {
	f.println("H meta:", transmute([HIDTH][2]u8) rowmeta)
	f.println("V meta:", transmute([WIDTH][2]u8) colmeta)
	f.println("H Grid:"); f.println(rdata)
	f.println("V Grid:"); f.println(cdata)
    }

    // Finally, do move simulation.
    direction := 0 // 0123 = ESWN
    pos       : [2] int = { int(rowmeta[0].offset), 0}
    for ci in 0..=ncommands {
	when ODIN_DEBUG { f.println("Curr pos:", pos) }
	com := commands[ci]
	if ci & 1 == 1 {
	    // Turn
	    assert(com == .left || com == .right)
	    if com == .left {
		direction = (direction + 3) & 0x03
	    } else {
		direction = (direction + 1) & 0x03
	    }
	} else {
	    // Try walking in direction for n squares.
	    n := com.(int)
	    switch direction {
	    case 0:
		offset  := int(rowmeta[pos.y].offset)
		oldapos := pos.x - offset
		newapos := walk(rdata[pos.y], n, true, oldapos)
		pos.x    = newapos + offset
	    case 1:
		offset  := int(colmeta[pos.x].offset)
		oldapos := pos.y - offset
		newapos := walk(cdata[pos.x], n, true, oldapos)
		pos.y    = newapos + offset
	    case 2:
		offset  := int(rowmeta[pos.y].offset)
		oldapos := pos.x - offset
		newapos := walk(rdata[pos.y], n, false, oldapos)
		pos.x    = newapos + offset
	    case 3:
		offset  := int(colmeta[pos.x].offset)
		oldapos := pos.y - offset
		newapos := walk(cdata[pos.x], n, false, oldapos)
		pos.y    = newapos + offset
	    }
	}
    }
    when ODIN_DEBUG { f.println("Final pos:", pos) }
    return 1000 * (pos.y + 1) + 4 * (pos.x + 1) + direction
}

walk :: proc( ptr : []u8, steps : int, forwards : bool, apos : int) -> int {
    when ODIN_DEBUG {
	f.println("Walking along:", ptr)
	f.println(steps, forwards, apos)
    }
    curri := apos
    l := len(ptr)
    adv := forwards ? 1 : -1
    for i in 0..=steps-1 {
	if ptr[(curri + adv + l) % l] != '#' {
	    curri = (curri + adv + l) % l
	} else {
	    break
	}
    }
    return curri
}
