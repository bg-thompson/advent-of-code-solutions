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
    // Returned 7713, answer was correct.
    f.println("Pt1 Time:", time.diff(t1,t2))
    // 5.60 ms

    t3 := time.now()
    sol2 := pt2()
    t4 := time.now()
    f.println("Pt2 Sol:", sol2)
    // Returned 1664569352803, answer was correct.
    f.println("Pt2 Time:", time.diff(t3,t4))
    // 135.00 ms
}

pt1 :: proc() -> int {
    lines := s.split_lines(FILE)
    llen := len(lines) - 1
    f.println("llen:", llen)
    // Add a unique index to each number, since
    // they are not all unique.
    // LOW BLOW advent of code not specifying this.
    // Low blow.
    data := make([dynamic] [2] i16, llen)
    
    for l, i in lines {
	if l == "" { continue }
	n, ok := v.parse_int(l) ; assert(ok)
	data[i] = {i16(n), i16(i)}
    }
    when ODIN_DEBUG { f.println("Original data:", data) }
    
    // Apply elf decryption!
    for i in 0..=llen-1 { linear_search_and_move(&data, i16(i)) }
    when ODIN_DEBUG { f.println("Mixed data:", data) }
    
    // Find index of 0.
    id0 := -1
    for e, i in data {
	if e.x == 0 {
	    id0 = i
	    break
	}
    }
    assert(id0 != -1)
    // Take Pt1 sum.
    pt1sum := 0
    when ODIN_DEBUG{ f.println("id0:", id0) }
    for i in 1..=3 {
	n := data[(id0 + 1000*i) % llen].x
	when ODIN_DEBUG { f.println("n:", n) }
	pt1sum += int(n)
    }
    return pt1sum
}

// Basically a copy of pt1 above.
pt2 :: proc() -> int {
    lines := s.split_lines(FILE)
    llen := len(lines) - 1
    f.println("llen:", llen)
    // Add a unique index to each number, since
    // they are not all unique.
    // LOW BLOW advent of code not specifying this.
    // Low blow.
    data := make([dynamic] [2] int, llen)
    DKEY := 811589153

    for l, i in lines {
	if l == "" { continue }
	n, ok := v.parse_int(l) ; assert(ok)
	data[i] = {DKEY * n, i}
    }
    when ODIN_DEBUG { f.println("Original data:", data) }
    
    // Apply elf decryption!
    for j in 1..=10 {
	for i in 0..=llen-1 { linear_search_and_move(&data, i) }
    }
    when ODIN_DEBUG { f.println("Mixed data:", data) }
    
    // Find index of 0.
    id0 := -1
    for e, i in data {
	if e.x == 0 {
	    id0 = i
	    break
	}
    }
    assert(id0 != -1)
    // Take Pt2 sum.
    pt2sum := 0
    when ODIN_DEBUG{ f.println("id0:", id0) }
    for i in 1..=3 {
	n := data[(id0 + 1000*i) % llen].x
	when ODIN_DEBUG { f.println("n:", n) }
	pt2sum += n
    }
    return pt2sum
}

linear_search_and_move :: proc(a : ^[dynamic] [2] $T, index : T ) {
    la := len(a)
    pair : [2] T
    idp := -1
    for e, i in a {
	if e.y == index {
	    pair = e
	    idp = i
	    break
	}
    }
    assert(idp != -1)
    ordered_remove(a, idp)
    idy := ((idp + int(pair.x)) % (la - 1))
    if idy < 0 { idy += la - 1 }
    inject_at(a, idy, pair)
}
