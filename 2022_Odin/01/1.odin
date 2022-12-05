package aoc

import f "core:fmt"
import s "core:strings"
import v "core:strconv"

main :: proc() {
    // Load file as string.
    when ODIN_DEBUG {
        filename :: `test.txt`
    } else {
        filename :: `data.txt`
    }
    file_string :: string(#load(filename))

    // Split file into int strings.
    file_lines  := s.split_lines(file_string)

    // Calc max!
    max_s       := 0
    max_a       := 0
    max_b       := 0
    max_c       := 0
    temp_sum    := 0
    for l in file_lines {
        pi, ok := v.parse_int(l)
        if ok {
            temp_sum += pi
        } else {
            // Pt 1.
            max_s = max(temp_sum, max_s)
            // Pt 2.
            switch {
            case temp_sum >= max_a:
                max_c = max_b
                max_b = max_a
                max_a = temp_sum
            case max_a > temp_sum && temp_sum >= max_b:
                max_c = max_b
                max_b = temp_sum
            case max_b > temp_sum && temp_sum >= max_c:
                max_c = temp_sum
            }
            temp_sum = 0
        }
    }
    // Print result Pt. 1
    f.println("max_s:", max_s)
    // Obtained 70296, answer was correct.
    
    // Print results Pt. 2
    f.println("max_a, max_b, max_c", max_a,max_b,max_c)
    f.println("top 3 sum:", max_a + max_b + max_c)
    // Obtained 205381, answer was correct.
}
