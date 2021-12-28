// My solution in Odin to Pt 1 of the Day 25 2021 'Advent of Code' challenge.
//
// Author:   Benjamin Thompson (github: bg-thompson)
// Email:    bgt37@cornell.edu
// Created:  2021.12.28
//
// The question is available at:
//
// https://adventofcode.com/2021/day/25
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
import t "core:time"

FLOORDIMUPPERBOUND :: #config(upper_dim, 10)

State :: enum u8 { EMPTY, HSLUG, VSLUG }

// This will contain more space than necessary, but easier
// than thinking about dynamically allocated arrays whose
// dimensions are unknown at compilation.

Storage :: [FLOORDIMUPPERBOUND] [FLOORDIMUPPERBOUND] State
storage1, storage2 : Storage
floor, floor2, temp_ptr   : ^Storage
floor_w, floor_h : int

FILENAME :: "25.txt"

// Practice data
EXAMPLE_DATA :: `v...>>.vv>
.vv>>.vv..
>>.>v>...v
>>v>>.>.v.
v>v.vv.v..
>.>>..v...
.vv..>.>v.
v.v..>>v.v
....v..v.>`

// Calling "odin run 25-sol.odin -define:file=0" returned
	/* Steps until no movement:  58
	..>>v>vv..
	..v.>>vv..
	..>>v>>vv.
	..>>>>>vv.
	v......>vv
	v>v....>>v
	vvv.....>>
	>vv......>
	.>v.vv.v..

	Time:  31.2496ms
	*/
// These matched the example on the website.

// A debug function to print the seafloor.
print_floor :: proc ( ref : ^Storage ) {
	defer f.println("")
	for i in 0..floor_h - 1 {
		defer f.println("")
		for j in 0..floor_w - 1 {
			switch ref^[i][j] {
				case .EMPTY:  f.printf(".")
				case .HSLUG:  f.printf(">")
				case .VSLUG:  f.printf("v")
			}
		}
	}
}

main :: proc() {
	time_begin := t.now() ; defer f.println("Time: ", t.diff(time_begin, t.now()))
	// Parse file.
	lines : [] string ; defer delete(lines)
	switch #config(file, 0) {
		case 0:
			lines = s.fields(EXAMPLE_DATA)
		case 1:
			filename := FILENAME
			data, succ := os.read_entire_file(filename)
			if !succ {
				f.println("File containing data not found!")
				os.exit(1)
			}
			lines = s.fields(string(data))
		case:
			f.println("0 = testing, 1 = actual computation")
	}
	// Set up storage and store.
	floor  = &storage1
	floor2 = &storage2
	floor_w = len(lines[0])
	floor_h = len(lines)
	for i in 0..floor_h - 1 {
		for j in 0..floor_w - 1 {
			switch lines[i][j] {
				case '.': floor^[i][j] = .EMPTY
				case '>': floor^[i][j] = .HSLUG
				case 'v': floor^[i][j] = .VSLUG
				case: f.println("Parsing error! Not floor or slug")
			}
		}
	}
	// print_floor(floor) // debug
	//
	// Function which does the simulation. Temporarily store things in floor2.
	advance_time :: proc() -> ( has_moved : bool )   {
		has_moved = false
		// Reset floor2, coping VSLUGs.
		for i in 0..floor_h - 1 {
			for j in 0..floor_w - 1 {
				if floor^[i][j] == .VSLUG { floor2^[i][j] = .VSLUG }
				else { floor2^[i][j] = .EMPTY }
			}
		}
		// Try and move right-facing slugs.
		// The non-wrap around logic.
		for i in 0..floor_h - 1 {
			for j in 0..floor_w - 2 {
				if floor^[i][j] == .HSLUG {
					if floor^[i][j+1] == .EMPTY { has_moved = true; floor2^[i][j+1] = .HSLUG }
					else { floor2^[i][j] = .HSLUG }
				}
			}
			// Apply wrap-around logic.
			for j in floor_w-1..floor_w-1 {
				if floor^[i][j] == .HSLUG {
					if floor[i][0] == .EMPTY { has_moved = true; floor2^[i][0] = .HSLUG }
					else { floor2^[i][j] = .HSLUG }
				}
			}
		}
		// Swap floor and floor2
		temp_ptr = floor
		floor = floor2
		floor2 = temp_ptr
		// Reset floor2, coping HSLUGs.
		for i in 0..floor_h-1 {
			for j in 0..floor_w-1 {
				if floor^[i][j] == .HSLUG { floor2^[i][j] = .HSLUG }
				else { floor2^[i][j] = .EMPTY }
			}
		}
		// Try and move down-facing slugs. 
		// For best-cache usage move by rows instead of columns.
		// Non-wrap
		for i in 0..floor_h - 2 {
			for j in 0..floor_w-1 {
				if floor^[i][j] == .VSLUG {
					if floor^[i+1][j] == .EMPTY { has_moved = true; floor2^[i+1][j] = .VSLUG }
					else { floor2^[i][j] = .VSLUG }
				}
			}
		}
		// Wrap.
		for i in floor_h-1..floor_h-1 {
			for j in 0..floor_w-1 {
				if floor^[i][j] == .VSLUG {
					if floor^[0][j] == .EMPTY {	has_moved = true; floor2^[0][j] = .VSLUG }
					else { floor2^[i][j] = .VSLUG }
				}
			}
		}
		// Swap floor and floor2
		temp_ptr = floor
		floor = floor2
		floor2 = temp_ptr
		return has_moved
	}
	// Pt 1: calculate the first step in which no sea cucumbers move.

	moving := true
	counter := 0
	for moving {
		moving = advance_time()
		counter += 1
	}
	f.println("Steps until no movement: ", counter)
	// print_floor(floor) // debug

	// The command "odin run 25-sol.odin -define:file=1 -define:upper_dim=150" was run on
	// cmder outputting
	/*
		Steps until no movement:  386
		Time:  314.1853ms
	*/
	// This was correct.
}

