// My solution in Odin to the Day 11 2021 'Advent of Code' challenge.
//
// Author:   Benjamin Thompson (github: bg-thompson)
// Email:    bgt37@cornell.edu
// Created:  2021.12.15
//
// The question is available at:
//
// https://adventofcode.com/2021/day/11
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
FILENAME     :: "11.txt"

// Practice data
//FILENAME     :: "test11.txt" // Returned (Pt 1, Pt 2) = (204, 195) (correct)

DATADIM :: 10
STEPS   :: 1000

// A type alias
Mat     :: [DATADIM][DATADIM] u8
Bmat     :: [DATADIM + 2][DATADIM + 2] u8


// A function to make debugging easier.
print_grid :: proc( grid : Mat ) {
	for i in 0..<DATADIM {
		for j in 0..<DATADIM {
			f.printf("%d",grid[i][j])
		}
		f.printf("\n")
	}
	f.printf("\n")
}

// The main function which does the octapus energy transitition.
// It changes the matrix data.
step :: proc( mat : ^Mat ) -> ( flashes : u32 ) {
	// Add border to data to make transition logic easier, and add
	// 1 to the energy levels in the process.
	flashes = 0
	bmat : [DATADIM + 2][DATADIM + 2] u8
	for i in 0..<DATADIM {
		for j in 0..<DATADIM {
			bmat[i + 1][j + 1] = mat[i][j] + 1
		}
	}
	// Define function to see if transition is done.
	step_done :: proc ( temp : ^Bmat ) -> bool {
		for i in 1..DATADIM {
			for j in 1..DATADIM {
				if temp^[i][j] > 9 { return false }
			}
		}
		return true
	}
	// Test to see if transition is done. If not,...
	// play the squid game.
	for !step_done(&bmat) {
		for i in 1..DATADIM {
			for j in 1..DATADIM {
				if bmat[i][j] > 9 {
					// Set octopus energy level to 0, report flash, and increase
					// energy levels of neighboring squids IF they are
					// non-zero too. 
					bmat[i][j] = 0
					flashes += 1
					for r in 0..2 {
						for s in 0..2 {
							if bmat[i - 1 + r][j - 1 + s] != 0 {
								bmat[i - 1 + r][j - 1 + s] += 1
							}
						}
					}
				}
			}
		}
	}
	// Copy result from bmat back into mat.
	for i in 1..DATADIM {
		for j in 1..DATADIM {
			 mat^[i - 1][j - 1] = bmat[i][j]
		}
	}
	return flashes
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
	
	temp : int
	octs : [DATADIM][DATADIM] u8
	t_octs : [DATADIM][DATADIM] u8
	for i in 0..<DATADIM {
		for j in 0..<DATADIM {
			temp, _  = v.parse_int((lines[i])[j:j+1])
			octs[i][j] = u8(temp)
		}
	}
	// Pt 1: Count flashes after 100 steps.
	print_grid(octs) // debug
	t_flashes, s_flashes : u32
	t_flashes = 0
ll:	for i in 1..STEPS {
		s_flashes = step(&octs)
		// Pt 2: Determine if syncing has happened.
		if (s_flashes == DATADIM * DATADIM ) {
			f.println("Flash sync!")
			f.println("Sync at step: ", i)
			break ll
		}
		t_flashes += s_flashes
	}
	print_grid(octs) // debug
	// Pt 1
	f.printf("Total flashes in %d steps: %d\n", STEPS, t_flashes)
	// With STEPS = 100, Cmder returned
		// Total flashes in 100 steps: 1588
	// This was correct.
	// Pt 2
	// With STEPS = 200, Cmder returned
		// Flash sync!
		// Sync at step:  517
	// This was correct.
}

