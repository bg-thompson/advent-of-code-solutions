// My solution in Odin to the Day 9 2021 'Advent of Code' challenge.
//
// Author:   Benjamin Thompson (github: bg-thompson)
// Email:    bgt37@cornell.edu
// Created:  2021.12.13
//
// The question is available at:
//
// https://adventofcode.com/2021/day/9
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
import v "core:strconv"

// Our data
FILENAME :: "9.txt"
MAT_ROWS :: 100
MAT_COLS :: 100

// Practice data
// FILENAME :: "test9.txt" // Returned (Pt 1, Pt 2) = (15, 1134), this was correct.
// MAT_ROWS :: 5
// MAT_COLS :: 10

// Check that a position is actually in the matrix.
// This is a bit inefficient, but it allows us to write a check for a
// low point regardless of if the location is a corner, on an edge, etc.
valid_location :: proc(row_index, column_index: int) -> (isVaild : bool) {
	isValid := true
	switch row_index {
		case 0..<MAT_ROWS: isVaild = true
		case:              isVaild = false
		}
	switch column_index {
		case 0..<MAT_COLS: isValid &= true
		case:              isVaild = false
	}
	return isVaild
}

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

	floor : [MAT_COLS][MAT_ROWS] u8
	i_row, i_col, temp_n : int
	for i_row in 0..<MAT_ROWS {
		for i_col in 0..<MAT_COLS {
			temp_n, _ = v.parse_int(lines[i_row][i_col:i_col + 1])
			floor[i_col][i_row] = u8(temp_n) // Cast int to u8
		}
	}

	// Pt 1: Find all the low points.
	rl_sum : u32

	// Determine if a point is a basin.
	isBasin :: proc(i_col, i_row : int, mat : [MAT_COLS][MAT_ROWS] u8 ) -> (isB : bool) {
			isB = true
			temp := mat[i_col][i_row]
			if valid_location(i_row + 0, i_col + 1) {
				isB &= (mat[i_col + 1][i_row + 0] > temp)	
			}
			if valid_location(i_row + 0, i_col - 1) {
				isB &= (mat[i_col - 1][i_row + 0] > temp)	
			}
			if valid_location(i_row + 1, i_col + 0) {
				isB &= (mat[i_col + 0][i_row + 1] > temp)	
			}
			if valid_location(i_row - 1, i_col + 0) {
				isB &= (mat[i_col + 0][i_row - 1] > temp)	
			}
			return isB
		}

	for i_row in 0..<MAT_ROWS {
		for i_col in 0..<MAT_COLS {
			if isBasin(i_col, i_row, floor) {
				bval := floor[i_col][i_row]
				rl_sum += u32(bval) + 1
			}
		}
	}	
	f.println("Risk level sum: ", rl_sum)
	// Pt 1 solution: Cmder printed 
		//	Risk level sum:  564
	// This was correct.

	// Pt 2: Calculate the largest basins
	// We'll create a int matrix which holds u32s instead of u8s.
	// We'll then calculate the size of the basins by following each non-9 values
	// downstream until we end up in a basin, and which point we increase the
	// value of the corresponding point in the int matrix.
	// We then search this int matrix for the three largest numbers and multiply
	// them together.
	
	// Given the coordinate of a non-9 and non-basin, find the next down-stream
	// point.
	downstream :: proc(c_o, r_o: int, mat: [MAT_COLS][MAT_ROWS] u8) -> (c_n, r_n: int) {
		temp := mat[c_o][r_o]
		if valid_location(r_o - 1, c_o) {
			if (mat[c_o][r_o - 1] < temp) {
				return c_o, r_o - 1
			}
		}
		if valid_location(r_o + 1, c_o) {
			if (mat[c_o][r_o + 1] < temp) {
				return c_o, r_o + 1
			}
		}
		if valid_location(r_o, c_o - 1) {
			if (mat[c_o - 1][r_o] < temp) {
				return c_o - 1, r_o
			}
		}
		if valid_location(r_o, c_o + 1) {
			if (mat[c_o + 1][r_o] < temp) {
				return c_o + 1, r_o
			}
		}
		return -1, -1 // An error if we get here.
	}
	basindata : [MAT_COLS][MAT_ROWS] u32
	r_t, c_t : int
	for i_row in 0..<MAT_ROWS {
		for i_col in 0..<MAT_COLS {
			r_t, c_t = i_row, i_col 
			if floor[c_t][r_t] == 9 {
				continue
			} else {
				for !isBasin(c_t,r_t, floor) {
					c_t, r_t = downstream(c_t, r_t, floor)
				}
				basindata[c_t][r_t] += 1
			}
		}
	}
	// Find three largest basins
	b1, b2, b3, btemp := u32(0), u32(0), u32(0), u32(0)
	for i_row in 0..<MAT_ROWS {
		for i_col in 0..<MAT_COLS {
			if basindata[i_col][i_row] != 0 {
				btemp = basindata[i_col][i_row]	
				switch {
					case btemp > b1:
								b3 = b2
								b2 = b1
								b1 = btemp
					case btemp > b2:
								b3 = b2
								b2 = btemp
					case btemp > b3:
								b3 = btemp
					case:
				}
			}
		}
	}
	f.println("largest basins: ", b1, b2, b3, "product: ", b1*b2*b3)
	// Pt 1 solution: Cmder printed 
		//	largest basins:  105 103 96 product:  1038240
	// This was correct.
}
