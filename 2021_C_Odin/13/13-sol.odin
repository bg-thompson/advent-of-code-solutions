// My solution in Odin the Day 13 2021 'Advent of Code' challenge.
//
// Author:   Benjamin Thompson (github: bg-thompson)
// Email:    bgt37@cornell.edu
// Created:  2021.12.18
//
// The question is available at:
//
// https://adventofcode.com/2021/day/13
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
import s "core:strings"
import f "core:fmt"
import v "core:strconv"

// Our data
FILENAME     :: "13.txt"
MAX_ROWS_COLS :: 1400

// Practice data
//FILENAME     :: "test13.txt" // Returned 
//MAX_ROWS_COLS:: 20 // ASSUMING each fold of the paper aligns edges up,



dotPaper : [MAX_ROWS_COLS][MAX_ROWS_COLS] u8 // Fill with default (0).

instruction :: struct {
	value : int,
	axis  : string,
}

UPPER_LIMIT_FOLD_INTS :: 1000

instructionList : [UPPER_LIMIT_FOLD_INTS] instruction

// Print out a dot configuration to the console
print_dots :: proc (dim : int) -> () {
	for row  in 0..dim - 1 {
		defer f.printf("\n")
		for col in 0..dim - 1 {
			if dotPaper[row][col] == 0 {
				f.printf(".")
			} else {
				f.printf("#")
			}
		}
	}
}

// Fold along an axis x = n.
fold_x     :: proc (n : int) -> () {
	for col in 0..n - 1 {
		for row in 0..len(dotPaper) - 1 {
			dotPaper[row][col] |= dotPaper[row][2*n - col]
		}
	}
}

// Fold along an axis y = n.
fold_y     :: proc (n : int) -> () {
	for col in 0..len(dotPaper) - 1 {
		for row in 0..n - 1 {
			dotPaper[row][col] |= dotPaper[2*n - row][col]
		}
	}
}

main :: proc() {
	// Parse file.
	data, succ := os.read_entire_file(FILENAME)
	if !succ {
		f.println("File containing data not found!")
		os.exit(1)
	}
	defer delete(data)
	lines := s.split(string(data), "\n")
	defer delete(lines)
	
	// First, fill up the dot paper with the coordinates.
	x_coord, y_coord : int
	instruction_start: int = ---
	for l, index in lines {
		if (len(l) <= 2) { 
			instruction_start = index + 1
			break
		}
		nums := s.split(l, ",")
		defer delete(nums)
		x_coord, _ = v.parse_int(nums[0])
		y_coord, _ = v.parse_int(nums[1])
		dotPaper[y_coord][x_coord] = 1
	}
	// Second, put the folding instructions into instructionList.

	instr_i := 0
	//for l in lines[instruction_start:] {
	for l in lines[instruction_start:] {
		if len(l) < 3 { break }
		bits := s.split(l, " ")
		juicy := bits[2]
		defer delete(bits)
		actualparts := s.split(juicy,"=")
		defer delete(actualparts)
		instructionList[instr_i].axis = actualparts[0]
		instructionList[instr_i].value, _ = v.parse_int(actualparts[1])
		instr_i += 1
	}
	count_dots :: proc ( n_col, n_row : int) -> ( total : int) {
		total = 0
		for row in 0..n_row-1 {
			for col in 0..n_col-1 {
				if dotPaper[row][col] != 0 {
					total += 1
				}
			}
		}
		return total
	}
	// Apply instructions to dotPaper
	for i in 0..instr_i - 1 {
		if i == 1 {
			// Pt 1
			// Manually look at value in first instruction.
			// For test13.txt:
			f.println("No. dots after first fold: ", count_dots(n_col=655, n_row=len(dotPaper)))
			// Cmder returned:
				// No. dots after first fold:  708
			// This was correct.
		}
		switch instructionList[i].axis {
			case "x":
				fold_x(instructionList[i].value)
			case "y":
				fold_y(instructionList[i].value)
			case:
				f.println("error! axis should be x or y")
		}
	}
	// Pt 2
	print_dots(80) 
	// Cmder returned (partial):
		//	####.###..#....#..#.###..###..####.#..#...#..#..#.#..###..#......#....#...##.#.#
		//	#....#..#.#....#..#.#..#.#..#.#....#..#......#....#......#....#..#....#.#.......
		//	###..###..#....#..#.###..#..#.###..####...#.##..#.#.#.......#.........#..###..##
		//	#....#..#.#....#..#.#..#.###..#....#..#......#.......#.#.#..#.........#.#..#....
		//	#....#..#.#....#..#.#..#.#.#..#....#..#...#..#....#....#.#..#....#....#.........
		//	####.###..####..##..###..#..#.#....#..#...#.......#.........#..##..#.##..###.###
		//	................................................................................
	// EBLUBRFH was entered and correct.
}

