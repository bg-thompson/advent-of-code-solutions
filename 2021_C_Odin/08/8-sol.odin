package main

import "core:os"
import "core:fmt"
import "core:strings"


DigitLine :: struct {
	unique_patterns:	[10] string,
	four_digits:		[4]  string,
}

digitdata : [200] DigitLine

main :: proc() {
	// Parse file
//	data, succ := os.read_entire_file("test8.txt") // Returned 26 (correct)

	data, succ := os.read_entire_file("8.txt")
	if !succ {
		fmt.println("File containing data not found!")
		os.exit(1)
	}
	defer delete(data)

	lines := strings.split(string(data), "\n")
	defer delete(lines)

	n_lines := len(lines) - 1
	fmt.println("n_lines", n_lines)
	for i in 0..<n_lines {
		words := strings.split(lines[i], " ")
		defer delete(words)
		for j in 0..<10 {
			digitdata[i].unique_patterns[j] = words[j]
		}
		for j in 0..<4 {
			digitdata[i].four_digits[j] = strings.trim_space(words[11 + j])
		}
	}
	// fmt.println(digitdata[0]) // debug
	// Pt 1
	// Sum up number of words with lengths 2, 3, 7, 8. 

	unique_seg_digits := 0
	tl : int
	okay := [4] int { 2, 3, 4, 7}
	for i in 0..<n_lines {
		for j in 0..<4 {
			tl = len(digitdata[i].four_digits[j])
//			fmt.println(tl) // debug

			for k in okay {
				if (tl == k) {
				unique_seg_digits += 1
				}
			}
		}
//		fmt.printf("\n") // debug
	}
	fmt.println("total: ", unique_seg_digits)
	// Returned 387, this was correct.
}
