package aoc22

import f "core:fmt"
import s "core:strings"

when ODIN_DEBUG {
    FILENAME :: `test.txt`
} else {
    FILENAME :: `data.txt`
}

filestring :: string(#load(FILENAME))


main :: proc() {
    pt1_sol := pt1()
    f.println("Pt1 sol:", pt1_sol)
    // Returned 1598, answer was correct.
    pt2_sol := pt2()
    f.println("Pt2 sol:", pt2_sol)
    // Returned 2414, answer was correct.
}

pt1 :: proc() -> int {
    istr  := s.trim_space(filestring)
    l := len(istr)
    when ODIN_DEBUG { f.println(istr, l) } // @debug
    start_packet := 0
p1: for i in 0..=l-4 {
        if !(istr[i]   == istr[i+1] ||
             istr[i]   == istr[i+2] ||
             istr[i]   == istr[i+3] ||
             istr[i+1] == istr[i+2] ||
             istr[i+1] == istr[i+3] ||
             istr[i+2] == istr[i+3] ) {
            break p1
        } else {
            start_packet += 1
        }
}
    return start_packet + 4
}

pt2 :: proc() -> int {
    istr  := s.trim_space(filestring)
    l := len(istr)

    packet_start := 0
    when ODIN_DEBUG { f.println(istr, l) } // @debug
    
    p2: for i in 0..=l-14 {
        n:  for j in 0..=12 {
            for k in j+1..=13 {
//              f.println(j,k) // @debug
                if istr[i+j] == istr[i+k] {
                    packet_start += 1
                    continue p2
                }
            }
        }
        f.println("break p2, i=",i)
        break p2
    }
    return packet_start + 14
}
