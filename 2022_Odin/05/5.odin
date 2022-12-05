package aoc22

import f "core:fmt"
import s "core:strings"
import v "core:strconv"
import   "core:testing"

when ODIN_DEBUG {
    FILENAME1 :: `test-strings.txt`
} else {
    FILENAME1 :: `data-strings.txt`
}

when ODIN_DEBUG {
    FILENAME2 :: `test-moves.txt`
} else {
    FILENAME2 :: `data-moves.txt`
}

BasicBuffer :: struct {
    b : [100] rune,
    l : int,    
}

Move :: [3] int

STRINGFILE :: string(#load(FILENAME1))
MOVEFILE   :: string(#load(FILENAME2))

cratebuffer : [100] BasicBuffer

transfer_crate :: proc( bb1, bb2 : ^BasicBuffer) {
    bb2.b[bb2.l] = bb1.b[bb1.l - 1]
    bb1.l -= 1
    bb2.l += 1
    return
}

perform_move :: proc( a, b, c : int) {
    i := 0
    for i < a {
        transfer_crate(&cratebuffer[b-1], &cratebuffer[c-1])
        i += 1
    }
    return
}

main :: proc() {
    // f.println("Pt 1 solution:")
    // pt1()
    f.println("Pt 2 solution:")
    pt2()
}

pt1 :: proc() {
    // Load strings, move into buffers
    cratestrings := s.split_lines(STRINGFILE)
    for l,i in cratestrings {
        if l == "" { continue }
        for r, j in l {
            cratebuffer[i].b[j] = r
            cratebuffer[i].l += 1
        }
    }
    //    f.println(cratebuffer[0:5]) // @debug

    // Load move file into moves
    move_data   : [1000] Move
    move_number := 0
    movestrings := s.split_lines(MOVEFILE)
    for l, i in movestrings {
        if l == "" { continue }
        move_number += 1
        fields := s.fields(l)
        n1, _ := v.parse_int(fields[1])
        n2, _ := v.parse_int(fields[3])
        n3, _ := v.parse_int(fields[5])
        move_data[i][0] = n1
        move_data[i][1] = n2
        move_data[i][2] = n3
    }
    //    f.println(move_data[0:10]) // @debug

    // Perform moves!
    i := 0
    for i < move_number {
        m := move_data[i]
        perform_move(m[0],m[1],m[2])
        i += 1
    }
    //    f.println(cratebuffer[0:5]) // @debug

    // Print out runes on top of stack. (Pt1)
    for c in cratebuffer {
        if c.l != 0 {
            f.printf("%c", c.b[c.l - 1])
        }
    }
    // Returned: PSNRGBTFT, answer was correct.
}

pt2 :: proc() {
    // Load strings, move into buffers
    cratestrings := s.split_lines(STRINGFILE)
    for l,i in cratestrings {
        if l == "" { continue }
        for r, j in l {
            cratebuffer[i].b[j] = r
            cratebuffer[i].l += 1
        }
    }
    //    f.println(cratebuffer[0:5]) // @debug

    // Load move file into moves
    move_data   : [1000] Move
    move_number := 0
    movestrings := s.split_lines(MOVEFILE)
    for l, i in movestrings {
        if l == "" { continue }
        move_number += 1
        fields := s.fields(l)
        n1, _ := v.parse_int(fields[1])
        n2, _ := v.parse_int(fields[3])
        n3, _ := v.parse_int(fields[5])
        move_data[i][0] = n1
        move_data[i][1] = n2
        move_data[i][2] = n3
    }
    //    new_move(2,1,3) // @debug
    //    f.println(cratebuffer[0:5]) // @debug

    // Perform moves!
    i := 0
    for i < move_number {
        m := move_data[i]
        new_move(m[0],m[1],m[2])
        i += 1
    }

    // Print out runes on top of stack. (Pt1)
    for c in cratebuffer {
        if c.l != 0 {
            f.printf("%c", c.b[c.l - 1])
        }
    }
    // Returned: BNTZFPMMW, answer was correct.
}

new_move :: proc( a, b, c : int) {
    bb1 := &cratebuffer[b-1]
    bb2 := &cratebuffer[c-1]
    bb1l := bb1.l
    for i in 0..=a-1 {
        bb2.b[bb2.l + i] = bb1.b[bb1.l - a + i]
    }
    bb1.l -= a
    bb2.l += a
    return
}
