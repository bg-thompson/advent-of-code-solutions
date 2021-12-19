// My incomplete solution in Odin the Day 14 2021 'Advent of Code' challenge.
// I have no idea why it is incorrect, it computes the test case correctly.
//
// Author:   Benjamin Thompson (github: bg-thompson)
// Email:    bgt37@cornell.edu
// Created:  2021.12.19
//
// The question is available at:
//
// https://adventofcode.com/2021/day/14
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


// TODO: Use core:time

package main

import "core:os"
import s "core:strings"
import f "core:fmt"
import v "core:strconv"

// Practice data
// Calling "odin run 14-sol.odin -define:filetype=0 -define:n_steps=10" returned
	// Largest count:  1749 Smallest count:  161
	// Difference:  1588
// This matched the example on the website.

transitionF : [26*26][2] int // These are automatically initialized with 0.
startingV   : [26*26] u32

// Functions to convert "XY" to an index.
crying :: proc ( str : string ) -> ( tears : int ) {
	tears = 0	
	assert(len(str) == 2)
	for c, i in str {
		switch i {
			case 0:
				tears += 26*(int(c) - int('A'))
			case 1:
				tears += int(c) - int('A')
			case:
				f.println("Impossible tears")
		}
	}
	return tears
}

// Functions to convert "X", "Y" to an index.
crying_too :: proc ( str1, str2 : string ) -> (more_tears : int) {
	more_tears = 0
	assert(len(str1) == len(str2))
	assert(len(str1) == 1)
	for c in str1 {
		more_tears += 26*(int(c) - int('A'))
	}
	for c in str2 {
		more_tears += int(c) - int('A')
	}
	return more_tears
}

// Main stepping function, given a vector, it computes the transition
// using transitionF.
step :: proc( input : [26*26] u32 ) -> ( ret : [26*26] u32 ) {
	for val, i in input {
		ret[transitionF[i][0]] += val
		ret[transitionF[i][1]] += val
	}
	return ret
}

// Compute most common and least common elements.
// The number of times A appears is the sum of the number of times AX
// appears for all X + (final_letter == A ? 1 : 0)

final_letter_index : int = #config(final_letter, 1)

letterCounts :: proc ( double_counts : [26*26] u32 ) -> (counts : [26] u32) {
	for i in 0..25 {
		for j in 0..25 {
			counts[i] += double_counts[26*i + j]
		}
	}
	counts[final_letter_index] += 1	
	return counts
}

main :: proc() {
	filename : string = ---
	switch #config(filetype, 0) {
		case 0:
			filename = "test14.txt"
		case 1:
			filename = "14.txt"
		case:
			f.println("0 = testing, 1 = actual computation")
	}
	// Parse file.
	data, succ := os.read_entire_file(filename)
	if !succ {
		f.println("File containing data not found!")
		os.exit(1)
	}
	defer delete(data)
	lines := s.split(string(data), "\n")
	defer delete(lines)

	// Set initial vector.
	firstline := lines[0]
	for i in 0..len(firstline) - 3 {
		startingV[crying(firstline[i:i+2])] += 1
	}

	// Create transition function.
	for l,i in lines[2:] {
		if len(l) < 2 {
			continue
		}
		first_i, second_i : int
		parts := s.fields(l) ; defer delete(parts)
		xy := parts[0]
		add := parts[2]
		trans_i := crying(xy)
		first_i = crying_too(xy[:1],add)
		second_i = crying_too(add,xy[1:])
		transitionF[trans_i][0] = first_i
		transitionF[trans_i][1] = second_i
	}
	// Apply transition function to computation!
	transVec := startingV
	n_steps : int = #config(n_steps, 2)
	for i in 1..n_steps {
		transVec = step(transVec)	
	}
		

	// Final letter in both the example and our data is B.
	// If it is different, it can be adjusted from the command line.
	// E.g.
	// odin run 14-sol.odin -define:filetype=1 -define:final_letter=2
	
	final_counts := letterCounts(transVec)

	// Calculate difference between largest letter count and smallest.
	smallest := final_counts[final_letter_index]
	largest  := smallest
	for i in 0..25 {
		if final_counts[i] != 0 {
			if final_counts[i] > largest  { largest = final_counts[i] }
			if final_counts[i] < smallest { smallest = final_counts[i] }
		}
	}
	f.println("Largest count: ", largest, "Smallest count: ", smallest)
	f.println("Difference: ", largest - smallest)
	// When filename=1 flag was called, the following was printed:
		// Largest count:  4030 Smallest count:  974
		// Difference:  3056
	// THIS WAS INCORRECT!!!
	// We have no idea why, it was correct for the test case.
}

