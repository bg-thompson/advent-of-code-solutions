package aoc22

import f "core:fmt"
import s "core:strings"
import v "core:strconv"
import   "core:time"
import   "core:slice"

when ODIN_DEBUG { FILENAME :: `test.txt` } else { FILENAME :: `data.txt`}
FILE :: string(#load(FILENAME))

main :: proc() {
    t1 := time.now()
    sol1 := pt1()
    t2 := time.now()
    f.println("Pt1 Sol:", sol1)
    // Returned 158731561459602, answer was correct.
    f.println("Pt1 Time:", time.diff(t1,t2))
    // 2.649 ms

    t3 := time.now()
    sol2 := pt2()
    t4 := time.now()
    
    f.println("Pt2 Sol:", sol2)
    // Returned 3769668716709, answer was correct.
    f.println("Pt2 Time:", time.diff(t3,t4))
    // 57.54 ms
}

nl : int

pt1 :: proc() -> int {
    lines := s.split_lines(FILE)
    nl = len(lines) - 1
    mp := make(map[string] int)
    data := make([]([]string), nl)
    for l, li in lines {
	if l == "" { continue }
	data[li] = s.fields(l)
    }
    when ODIN_DEBUG { f.println(data) }
    for len(mp) != nl {
	for strs in data {
	    key := strs[0][0:4]
	    val, computed := mp[key]
	    if !computed {
		switch len(strs[1:]) {
		case 1:
		    // The monkey screams a single number.
		    n, ok := v.parse_int(strs[1])
		    assert(ok)
		    mp[key] = n
		case 3:
		    // Monkey screams an op.
		    key2, key3 := strs[1], strs[3]
		    val2, computed2 := mp[key2]
		    val3, computed3 := mp[key3]
		    if computed2 && computed3 {
			switch strs[2] {
			case "+": mp[key] = val2 + val3
			case "-": mp[key] = val2 - val3
			case "*": mp[key] = val2 * val3
			case "/":
			    // ASSUMPTION: no problems with division.
			    mp[key] = val2 / val3
			    case:
			    assert(false)
			}
			if key == "root" { return mp[key] }
		    }
		    case:
		    assert(false)
		}
	    }
	}
	when ODIN_DEBUG { f.println(mp) }
    }
    return -1
}

PT2LIMIT :: 1_000_000
pt2 :: proc() -> int {
    // Try brute force to begin...
        lines := s.split_lines(FILE)
    nl = len(lines) - 1
    mp := make(map[string] int)
    data := make([]([]string), nl)
    for l, li in lines {
	if l == "" { continue }
	data[li] = s.fields(l)
    }
    when ODIN_DEBUG { f.println(data) }

    // When the input was varied, the right hand side
    // of root was constant.
    // Hence find the intersection of the linear left-hand
    // side y = mx + b with the constant.
    STEP :: 1_000_000_000_000
    l0, r0, _ := go_ape(0,&data)
    l1, r1, _ := go_ape(STEP, &data)
    assert(r0 == r1)
    gradient := f64(l1 - l0)/f64(STEP)
    seed     := int(f64(r0 - l0)/gradient)
    when ODIN_DEBUG { f.println("Seed:", seed) }
    // Do brute force around the seed to discover the solution.
    for n in 0..=100 {
	l, r, valid :=  go_ape(seed + n - 50, &data)
	if valid && l == r {
	    f.println("Solution found!")
	    return seed + n - 50
	}
    }
    return -1
}

go_ape :: proc( initn : int, data : ^[]([]string) ) -> (l,r : int, valid : bool) {
    valid = true
    mp := make(map[string] int)
    defer delete(mp)
    for len(mp) != nl {
	for strs in data {
	    key := strs[0][0:4]
	    val, computed := mp[key]
	    if !computed {
		switch len(strs[1:]) {
		case 1:
		    if key != "humn" {
			// The monkey screams a single number.
			n, ok := v.parse_int(strs[1])
			assert(ok)
			mp[key] = n
		    } else {
			// The human screams a single number.
			mp[key] = initn
		    }
		case 3:
		    // Monkey screams an op.
		    key2, key3 := strs[1], strs[3]
		    val2, computed2 := mp[key2]
		    val3, computed3 := mp[key3]
		    if computed2 && computed3 {
			if key == "root" {
			    return val2, val3, valid
			}
			switch strs[2] {
			case "+": mp[key] = val2 + val3
			case "-": mp[key] = val2 - val3
			case "*": mp[key] = val2 * val3
			case "/":
			    // ASSUMPTION: a valid solution will have
			    // no remainder with any division.
			    valid &= (val2 % val3) == 0
			    mp[key] = val2 / val3
			    case:
			    assert(false)
			}
		    }
		    case:
		    assert(false)
		}
	    }
	}
	when ODIN_DEBUG { f.println(mp) }
    }
    assert(false)
    return -1, -1, false
}
