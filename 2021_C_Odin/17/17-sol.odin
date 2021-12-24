// My solution in Odin to Day 17 2021 'Advent of Code' challenge.
//
// Author:   Benjamin Thompson (github: bg-thompson)
// Email:    bgt37@cornell.edu
// Created:  2021.12.24
//
// The question is available at:
//
// https://adventofcode.com/2021/day/16
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

FILENAME :: "17.txt"

// Practice data
EXAMPLE_DATA :: `target area: x=20..30, y=-10..-5`

// Calling "odin run 17-sol.odin -define:file=0" returned
	// Max y: 9 max height:  45
	// Number ways:  112
// These matched the examples on the website.

b_x_lower : int
b_x_upper : int
b_y_lower : int
b_y_upper : int

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
	xdata_messy := s.split(lines[2][2:], ".")
	ydata_messy := s.split(lines[3][2:], ".")
	// f.println(xdata_messy, ydata_messy) // debug

	b_x_lower, _  = v.parse_int(xdata_messy[0])
	b_x_upper, _ = v.parse_int(xdata_messy[2][:len(xdata_messy[2]) - 1]) // Because ','
	b_y_lower, _  = v.parse_int(ydata_messy[0])
	b_y_upper, _  = v.parse_int(ydata_messy[2])

	// Determine upper and lower bounds for probe velocities v_x and v_y.
	// Bounds are inclusive.
	sum_to_n :: proc ( n : int ) -> int { return n * (n + 1) / 2 }
	i := 0
	for sum_to_n(i) < b_x_lower { i += 1 }
	v_x_lower := i
	v_x_upper := b_x_upper
	v_y_lower := b_y_lower
	v_y_upper := -b_y_lower
	
	// For a given v_x, v_y, determine whether or not the probe goes through the region,
	// assuming the probe goes in an arch.
	goes_through_arch :: proc ( v_x_i , v_y_i : int ) -> bool {
		// Begin simulation from point where probe has coords (X, 0) and X > 0.
		// Assumes v_y is strictly positive!
		after_arch_x, after_arch_y, v_x, v_y : int
		switch v_x_i > 2*v_y_i + 1 {
			case true:
				// Probe still has horizontal velocity.
				after_arch_x = sum_to_n(v_x_i) - sum_to_n(v_x_i - (2 * v_y_i + 1))
				v_x = v_x_i - 2*v_y_i - 1
			case false:
				// Probe has no horizontal velocity.
				after_arch_x = sum_to_n(v_x_i)
				v_x = 0
		}
		v_y = -(v_y_i + 1)
		after_arch_y = 0
		// Simulate, and determine if it's within the area.
		curr_x := after_arch_x
		curr_y := after_arch_y
		for curr_y >= b_y_lower {
			// Test if in box, if not simulate.
			if b_x_lower <= curr_x && curr_x <= b_x_upper && curr_y <= b_y_upper { return true }
			else {
				curr_x = curr_x + v_x
				v_x = max(v_x - 1, 0)
				curr_y += v_y
				v_y -= 1
			}

		}
		return false
	}

	// Determine if the probe goes through the region, assuming the probe can start going down.
	// (A more generalized function, but slower... although not as slow as our Day 15 solution.)
	goes_through_down :: proc ( v_x_i, v_y_i : int) -> bool {
		curr_x := 0
		curr_y := 0
		v_x := v_x_i
		v_y := v_y_i
		for curr_y >= b_y_lower {
			// Test if in box, if not simulate.
			if b_x_lower <= curr_x && curr_x <= b_x_upper && curr_y <= b_y_upper { return true }
			else {
				curr_x = curr_x + v_x
				v_x = max(v_x - 1, 0)
				curr_y += v_y
				v_y -= 1
			}
		}
		return false
	}

	// Pt 1: Calculate highest y value that goes in square.
	max_y := 0
	for i in v_x_lower..v_x_upper {
		for j in 1..v_y_upper {
			if goes_through_arch(i,j) {
				if j > max_y { max_y = j }
			}
		}
	}
	f.println("Max y:", max_y, "max height: ", sum_to_n(max_y))
	// After "odin run 17-sol.odin -define:file=1" was run cmder printed
		// Max y: 140 max height:  9870
		// Time:  4.1316ms
	// This was correct.
	// Pt 2: Calculate number of velocities which work.
	number_ways := 0
	for i in v_x_lower..v_x_upper {
		for j in v_y_lower..v_y_upper {
			if goes_through_arch(i,j) {
				number_ways += 1
			}
		}
	}
	f.println("Number ways: ", number_ways)
	// Cmder printed
		// Number ways:  5523
		// Time:  6.4217ms
	// This was correct.
}

