package aoc22

import f "core:fmt"
import s "core:strings"
import v "core:strconv"
import   "core:time"

when ODIN_DEBUG { FILENAME :: `test.txt` } else { FILENAME :: `data.txt`}

FILE :: string(#load(FILENAME))

main :: proc() {
    // Parse data
    lines        := s.split_lines(FILE)
    number_moves := len(lines)
    moves := make([dynamic] [2]i8, number_moves)
    x, y : i8
    for l, li in lines {
        if l == "" { continue }
        fields := s.fields(l)
        nt, _   := v.parse_int(fields[1])
        assert(nt < 128)
        n := i8(nt)
        switch fields[0] {
        case "U": x, y =  0,  n
        case "D": x, y =  0, -n
        case "L": x, y = -n,  0
        case "R": x, y =  n,  0
        }
        moves[li] = {x, y}
    }
    when ODIN_DEBUG { f.println("Moves:", moves) }
    t1   := time.now()
    sol1 := pt1(&moves)
    t2   := time.now()
    f.println("Pt1 Sol:",  sol1)
    // Returned 6018, answer was correct.
    f.println("Pt1 Time:", time.diff(t1,t2))

    t3   := time.now()
    sol2 := pt2(&moves)
    t4   := time.now()
    f.println("Pt2 Sol:",  sol2)
    f.println("Pt2 Time:", time.diff(t3,t4))
    // Returned 2619, answer was correct.
}

pt1 :: proc( moves : ^[dynamic] [2] i8 ) -> int {
    // Determine bounds of grid.
    x_min, x_max := 0, 0
    y_min, y_max := 0, 0
    cpos    : [2]int = {0,0}
    for m in moves {
        cpos.x += int(m.x)
        cpos.y += int(m.y)
        x_min   = min(x_min, cpos.x)
        x_max   = max(x_max, cpos.x)
        y_min   = min(y_min, cpos.y)
        y_max   = max(y_max, cpos.y)
    }
    when ODIN_DEBUG { f.println("Bounding Box:",x_min,x_max,y_min,y_max) }
    // Create box to keep track of where the tail has visited.
    box_h_width := max(-x_min, x_max)
    box_h_hidth := max(-y_min, y_max)
    cpos  = { box_h_width, box_h_hidth }
    box_w       := 2 * box_h_width + 1
    box_h       := 2 * box_h_hidth + 1
    box  := make([dynamic] i8, box_w * box_h)

    // Apply simulation!
    hpos := cpos
    tpos := cpos
    box[box_w * tpos.y + tpos.x] = 1
    for m in moves {
        when ODIN_DEBUG { f.println("Move:", m) }
        mx, my := m.x, m.y
        for mx < 0 {
            hpos.x -= 1
            mx     += 1
            tpos = update_knot(hpos, tpos)
            box[box_w * tpos.y + tpos.x] = 1
        }
        for mx > 0 {
            hpos.x += 1
            mx     -= 1
            tpos = update_knot(hpos, tpos)
            box[box_w * tpos.y + tpos.x] = 1
        }
        for my < 0 {
            hpos.y -= 1
            my     += 1
            tpos = update_knot(hpos, tpos)
            box[box_w * tpos.y + tpos.x] = 1
        }
        for my > 0 {
            hpos.y += 1
            my     -= 1
            tpos = update_knot(hpos, tpos)
            box[box_w * tpos.y + tpos.x] = 1
        }
    }

    // Calculate number of squares tail has visited.
    total := 0
    for sq in box { total += int(sq) }
    return total
}

update_knot :: proc( hpos : [2] int, told : [2] int) -> ( tnew : [2] int) {
    tnew = told
    if ODIN_DEBUG { f.println("hpos, told", hpos, told) }
    dx  := hpos.x - told.x
    adx := abs(dx)
    dy  := hpos.y - told.y
    ady := abs(dy)
    
    if adx <= 1 && ady <= 1 { return told }
    assert( (adx == 2 || ady == 2) )
    if adx == 1 { tnew.x += dx }
    if ady == 1 { tnew.y += dy }
    if adx == 2 { tnew.x += dx / 2 }
    if ady == 2 { tnew.y += dy / 2 }
    return
}

pt2 :: proc( moves : ^[dynamic] [2] i8 ) -> int {
    // Determine bounds of grid.
    x_min, x_max := 0, 0
    y_min, y_max := 0, 0
    cpos    : [2]int = {0,0}
    for m in moves {
        cpos.x += int(m.x)
        cpos.y += int(m.y)
        x_min   = min(x_min, cpos.x)
        x_max   = max(x_max, cpos.x)
        y_min   = min(y_min, cpos.y)
        y_max   = max(y_max, cpos.y)
    }
    when ODIN_DEBUG { f.println("Bounding Box:",x_min,x_max,y_min,y_max) }
    // Create box to keep track of where the tail has visited.
    box_h_width := max(-x_min, x_max)
    box_h_hidth := max(-y_min, y_max)
    cpos  = { box_h_width, box_h_hidth }
    box_w       := 2 * box_h_width + 1
    box_h       := 2 * box_h_hidth + 1
    box  := make([dynamic] i8, box_w * box_h)

    // Apply simulation!
    rope : [10] [2] int
    rope = cpos
    box[box_w * cpos.y + cpos.x] = 1
    for m in moves {
        when ODIN_DEBUG { f.println("Move:", m) }
        mx, my := m.x, m.y
        for mx < 0 {
            rope[0].x -= 1
            mx     += 1
            for k in 1..=9 { rope[k] = update_knot(rope[k-1],rope[k]) }
            box[box_w * rope[9].y + rope[9].x] = 1
        }
        for mx > 0 {
            rope[0].x += 1
            mx     -= 1
            for k in 1..=9 { rope[k] = update_knot(rope[k-1],rope[k]) }
            box[box_w * rope[9].y + rope[9].x] = 1
        }
        for my < 0 {
            rope[0].y -= 1
            my     += 1
            for k in 1..=9 { rope[k] = update_knot(rope[k-1],rope[k]) }
            box[box_w * rope[9].y + rope[9].x] = 1          
        }
        for my > 0 {
            rope[0].y += 1
            my     -= 1
            for k in 1..=9 { rope[k] = update_knot(rope[k-1],rope[k]) }
            box[box_w * rope[9].y + rope[9].x] = 1 
        }
    }

    // Calculate number of squares tail has visited.
    total := 0
    for sq in box { total += int(sq) }
    return total
}
