package aoc22

import f "core:fmt"
import s "core:strings"
import v "core:strconv"
import   "core:time"
import   "core:mem"

when ODIN_DEBUG { FILENAME :: `test.txt` } else { FILENAME :: `data.txt`}

DATA :: string(#load(FILENAME))

TOTALDISKSPACE       :: 70_000_000
UPDATESPACENEEDED    :: 30_000_000
MAXIMUMCAPACITY      :: TOTALDISKSPACE - UPDATESPACENEEDED

NodeType :: enum u8 {
    DIR,
    FILE,
}

Item :: struct {
    type   : NodeType,
    index  : int,
    parent : int,
    lsd    : bool,
    name   : string,
    size   : int,
    children : [dynamic] int,
}

gitems   : [dynamic] Item
gitems_i : int
cdi      : int // Current directory index.
lines    : [] string

main :: proc() {
    
    t1   := time.now()
    sol1, sol2 := pt1()
    // Returned 1391690, 5469168, answers were correct.
    t2   := time.now()
    f.println("Pt1 Sol:",  sol1)
    f.println("Pt1 Time:", time.diff(t1,t2))

    f.println("Pt2 Sol:",  sol2)

}

pt1 :: proc() -> (int, int) {
    using NodeType

    // Setup gitems
    gitems	= make([dynamic] Item)
    gitems_i	= 0
    
    root : Item
    root.type	  = .DIR
    root.index	  = 0
    root.parent	  = -1
    root.lsd	  = false
    root.name     = "root"
    root.size     = -1
    root.children = make([dynamic] int)
    
    append(&gitems, root)
    gitems_i = 1

    cdi = 0
    
    // Start parsing file.
    lines = s.split_lines(DATA)
    for l, li in lines {
	if l == "" { continue }
	when ODIN_DEBUG { f.println("Line:", l) }
	if l[0] == '$' {
	    fields := s.fields(l)
	    if fields[1] == "cd" {
		change_dir(fields[2])
	    } else {
		assert(fields[1] == "ls")
		do_ls(li + 1)
	    }
	} else {
	    continue
	}
    }
    // Now calculate sizes of all DIR items.

    calculate_size :: proc ( iti : int) -> int {
	using NodeType
	dirsize := 0
	for ci in gitems[iti].children {
	    switch gitems[ci].type {
	    case .DIR:
		if gitems[ci].size == -1 {
		    gitems[ci].size = calculate_size(ci)
		}
		dirsize += gitems[ci].size
	    case .FILE:
		dirsize += gitems[ci].size
	    }
	}
	when ODIN_DEBUG { f.println("dirsize:", dirsize) }
	return dirsize
    }
    // Set sizes of all directories.
    gitems[0].size = calculate_size(0)

    // Count the number of dirs with size < 100_000
    sum_pt1 := 0
    for item in gitems {
	if item.type == .DIR && item.size < 100_000 {
	    when ODIN_DEBUG {
		f.println("Found dir", item.name, "size:", item.size)
	    }
	    sum_pt1 += item.size
	}
    }

    // Pt2
    f.println("")
    pt2_sol := TOTALDISKSPACE
    total_size := gitems[0].size
    f.println("Total size:", total_size)
    f.println("MAXIMUMCAPACITY:", MAXIMUMCAPACITY)
    assert(total_size <= TOTALDISKSPACE)

    for item in gitems {
	if item.type == .DIR && total_size - item.size <= MAXIMUMCAPACITY {
	    pt2_sol = min(pt2_sol, item.size)
	}
    }
    
    return sum_pt1, pt2_sol
}

change_dir :: proc( str : string ) {
    using NodeType
    switch str {
    case `/`:
	cdi = 0
    case "..":
	cdi = gitems[cdi].parent
	case:
	when ODIN_DEBUG {
	f.println("Attempting to change dir")
	    f.println("gitems[cdi].children:")
	}
	for c in gitems[cdi].children {
	    if gitems[c].type == .DIR && gitems[c].name == str {
		cdi = c
		break
	    }
	}
	if gitems[cdi].name != str {
	    f.println("change dir error (gitems[cdi].name, str):", gitems[cdi].name, str)
	    assert(gitems[cdi].name == str)
	}
    }
    when ODIN_DEBUG { f.println("Directory now:", gitems[cdi].name, "\n") }
    return
}

do_ls :: proc( line_index : int) {
    if gitems[cdi].lsd { return }
    using NodeType
    // Go through lines until "" or a line not starting with a $
    // is discovered.
    li := line_index
    for lines[li] != "" {
	if lines[li][0] == '$' { break }
	fields := s.fields(lines[li])
	if fields[0] == "dir" { // Add new dir
	    append(&gitems, Item{
		type		= .DIR,
		index		= gitems_i,
		parent		= cdi,
		lsd		= false,
		name		= s.clone(fields[1]),
		size            = -1,
		children        = make([dynamic] int),
	    })
	} else { // Add new file.
		size, ok := v.parse_int(fields[0])
		assert(ok)
		append(&gitems, Item{
		    type	= .FILE,
		    index	= gitems_i,
		    parent	= cdi,
		    lsd		= false,
		    name	= s.clone(fields[1]),
		    size        = size,
		    children	= nil,
		})
	}
	append(&gitems[cdi].children, gitems_i)
	gitems_i += 1
	li       += 1
    }

    when ODIN_DEBUG {
	f.println("Contents of:", gitems[cdi].name, ":")
	for i in gitems[cdi].children {
	    f.println(gitems[i].name)
	}
	f.println("")
    }
    gitems[cdi].lsd = true

    return
}


pt2 :: proc() -> int {
    return 0
}
