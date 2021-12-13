// My solution in Odin to the Day 8 2021 'Advent of Code' challenge.
//
// Author:   Benjamin Thompson (github: bg-thompson)
// Email:    bgt37@cornell.edu
// Created:  2021.12.12
//
// The question is available at:
//
// https://adventofcode.com/2021/day/8
//
// Odin is an open source language by gingerBill et al. available at:
// https://github.com/odin-lang/Odin
//
// The Odin compiler is currently in active development.
// The language (as of December 2021) does not really have any in-depth tutorials
// and there is not much documentation, but (as always) the basics can
// be picked up by reading through the demo, skimming the
// core function libraries, reading other people's Odin code,
// asking questions on Odin's Discord, and (most importantly!)
// by writing code in Odin.
//
// This code is for educational uses only, and as such no portion of it 
// should ever be used in production code.
//
// The code has not been checked for memory leaks,... there is a good chance they exist!

package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:unicode/utf8"


DigitLine :: struct {
	unique_patterns:	[10] string,
	four_digits:		[4]  string,
}

tempunique  : [10] string
solver      : [10] string
tempunknown : [4]  string
digitdata   : [200] DigitLine

// A function which will order the letters in the words. Since each
// has a very simple structure, there is no need to invoke an advanced
// sorting algorithm. (... we also are not yet familiar with how to do
// this in Odin.

alphaorder :: proc(src: string) -> string {
	d : [7] rune
	i := 0
	for l in "abcdefg" {
		if strings.contains_rune(src, l) >= 0 {
			d[i] = l
			i += 1
		}
	}
	return utf8.runes_to_string(d[:i])
}

// The majority of the digit determination can be done by seeing how
// many of the words have digits in common.
intersection :: proc(s1: string, s2: string, ) -> int {
	intnum := 0
	for l in s1 {
		if (strings.contains_rune(s2,l) >= 0) {
			intnum += 1
		}
	}
	return intnum
}

main :: proc() {
	// Parse file
	// data, succ := os.read_entire_file("test8.txt") // Returned (Pt 1, Pt 2) = (26, 61229) (correct)

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

	// Store sorted words into the struct. Words representing the
	// same digit contain the same types of letters, but the ordering
	// of the digits can differ. As such, sorting the words by 
	// alphabetical order before we store them eliminates the need
	// means we can check digits by a simple string comparision.
	for i in 0..<n_lines {
		words := strings.split(lines[i], " ")
		defer delete(words)
		for j in 0..<10 {
			digitdata[i].unique_patterns[j] = alphaorder(words[j])
		}
		for j in 0..<4 {
			// There is a "|" delimiter between the 10th and 11th words.
			digitdata[i].four_digits[j] = alphaorder(words[11 + j])
		}
	}
	// Pt 1
	// Sum up number of words with lengths 2, 3, 7, 8. 

	unique_seg_digits := 0
	tl : int
	okay := [4] int { 2, 3, 4, 7}
	for i in 0..<n_lines {
		for j in 0..<4 {
			tl = len(digitdata[i].four_digits[j])
			for k in okay {
				if (tl == k) {
				unique_seg_digits += 1
				}
			}
		}
	}
	fmt.println("Pt 1 total: ", unique_seg_digits)
	// Returned 387, this was correct.
	// Pt 2
	// Figure out what the four digits at the end of every row are.
	sum_of_outputs := 0
	for i in 0..<n_lines {
		tempunique = digitdata[i].unique_patterns
		tempunknown = digitdata[i].four_digits
		// Figure out the digits which can be determined based on
		// length alone

		for w in tempunique {
			switch len(w) {
				case 2: solver[1] = w
				case 3: solver[7] = w
				case 4: solver[4] = w
				case 7: solver[8] = w
			}
		}
		// The following sections can probably be far more efficient
		// in terms of computation time and code size. We are only beginning
		// to learn Odin though, so don't yet know the best Odin standard
		// functions to use.
		//
		// Determine 9 (only len = 6 word which contains all letters
		// in 4.

		for w in tempunique {
			if len(w) == 6 {
				if intersection(w,solver[4]) == 4 {
					solver[9] = w
				}
			}
		}
		// Determine 6 (only len = 6 word which doesn't have all
		// the letters in 1.
		for w in tempunique {
			if len(w) == 6 {
				if intersection(w,solver[1]) != 2 {
					solver[6] = w
				}
			}
		}

		// Determine 0 (remaining len = 6 word).
		for w in tempunique {
			if len(w) == 6 {
				if w != solver[9] && w != solver[6] {
					solver[0] = w
				}
			}
		}
		// Determine 3 (only len = 5 word with all the letters in 1).
		for w in tempunique {
			if len(w) == 5 {
				if intersection(w,solver[1]) == 2 {
					solver[3] = w
				}
			}
		}

		// Determine 2 and 5 (take intersection with 6, 5 has intersection
		// number 5 while 2 has intersection number 4.
		for w in tempunique {
			if len(w) == 5 {
				switch intersection(w,solver[6]) {
					case 4: 
						if w != solver[3] {
							solver[2] = w
						}
					case 5: solver[5] = w
				}
			}
		}

		// Compute the four_digit score
		mult := 1
		rowsum := 0
		tempdigit := 0
		for j in 0..3 {
			for k in 0..9 {
				if tempunknown[3 - j] == solver[k] {
					rowsum += k * mult
					mult *= 10
					continue
				}
			}
		}
	sum_of_outputs += rowsum
	}
	fmt.println("Pt 2 total: ", sum_of_outputs) 
	// Cmder printed the following:
		//
		// Pt 2 total:  986034
		//
	// this was correct.
}
