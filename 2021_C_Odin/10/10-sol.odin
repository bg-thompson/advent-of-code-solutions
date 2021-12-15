// My solution in Odin to the Day 10 2021 'Advent of Code' challenge.
//
// Author:   Benjamin Thompson (github: bg-thompson)
// Email:    bgt37@cornell.edu
// Created:  2021.12.14
//
// The question is available at:
//
// https://adventofcode.com/2021/day/10
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
import f "core:fmt"
import s "core:strings"
import sl "core:slice"

// Our data
FILENAME :: "10.txt"
LINELENUPPER :: 200

// Practice data
//FILENAME     :: "test10.txt" // Returned (Pt 1, Pt 2) = (26397, 288957) (correct).
//LINELENUPPER :: 30

Brackets :: enum u8 { CURVE, SQUARE, FANCY, CORNER }

main :: proc() {
	// Parse file
	data, succ := os.read_entire_file(FILENAME)
	if !succ {
		f.println("File containing data not found!")
		os.exit(1)
	}
	defer delete(data)
	lines := s.split(string(data), "\n")
	defer delete(lines)

	// Pt 1: Find first illegal characters in corrupted lines and score.
	// Pt 2: count completions needed according to rule.
	comp_score  := u64(0)
	temp_score   : u64
	tempchecker : [LINELENUPPER] Brackets
	corrupted : bool
	i : int
	num_corrupted, corrupted_score := 0, 0
	non_corrupted_number : = 0
	non_corrupted : [LINELENUPPER] u64
	using Brackets
	for l in lines {
		corrupted = false
		i = 0
loop:	for symb in l {
			switch symb {
				case '(':
					i += 1
					tempchecker[i] = CURVE
				case '[':
					i += 1
					tempchecker[i] = SQUARE
				case '{':
					i += 1
					tempchecker[i] = FANCY
				case '<':
					i += 1
					tempchecker[i] = CORNER
				case ')':
					if (tempchecker[i] == CURVE) {
						i -= 1
					} else {
						corrupted = true	
						corrupted_score += 3
						num_corrupted += 1
						break loop
					}
				case ']':
					if (tempchecker[i] == SQUARE) {
						i -= 1
					} else {
						corrupted = true
						corrupted_score += 57
						num_corrupted += 1
						break loop
					}
				case '}':
					if (tempchecker[i] == FANCY) {
						i -= 1
					} else {
						corrupted = true
						num_corrupted += 1
						corrupted_score += 1197
						break loop
					}
				case '>':
					if (tempchecker[i] == CORNER) {
						i -= 1
					} else {
						corrupted = true
						num_corrupted += 1
						corrupted_score += 25137
						break loop
					}
				case:
			}
		}
		if !corrupted { 
			// Compute temp_score
			temp_score = 0
			for i != 0 {
				switch tempchecker[i] {
					case CURVE:
						temp_score = 5*temp_score + 1
					case SQUARE:
						temp_score = 5*temp_score + 2
					case FANCY:
						temp_score = 5*temp_score + 3
					case CORNER:
						temp_score = 5*temp_score + 4
					case:
						f.println("error! there shouldn't be any other types of things needed!")
				}
				i -= 1
			}
			non_corrupted[non_corrupted_number] = temp_score
			non_corrupted_number += 1
		}
	}
	f.println("Total number corrupted lines: ", num_corrupted)
	f.println("Corrupted score: ", corrupted_score)
	f.println("Completed score: ", comp_score)
	// Pt 1 solution: Cmder printed 
		// Corrupted score:  374061	
	// This was correct.
	sl.sort(non_corrupted[0:non_corrupted_number]) 
	middle := non_corrupted_number / 2 
	f.println("Middle score: ", non_corrupted[middle])
	// Pt 2 solution: Cmder printed
}

