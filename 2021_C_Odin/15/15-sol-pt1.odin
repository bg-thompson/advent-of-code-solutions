// My solution in Odin to Pt 1 of Day 15 2021 'Advent of Code' challenge.
//
// Author:   Benjamin Thompson (github: bg-thompson)
// Email:    bgt37@cornell.edu
// Created:  2021.12.21
//
// The question is available at:
//
// https://adventofcode.com/2021/day/15
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

// Practice data
// Calling "odin run 15-sol.odin -define:file=0 -define:dim=10" returned
	// Smallest path:  40
// This matched the example on the website.

MATDIM :: #config(dim, 10)

Node :: struct {
	risk : u8,
	visited : bool,
	length : u32,
}


DataMatrix : [MATDIM + 2][MATDIM + 2] Node = ---

// The lowest path from the top-left to the bottom-right
// this should be 40 (NOT including the initial 1)
EXAMPLE_DATA :: \
`1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581`

main :: proc() {
	DirectionsX := [4] int {-1, 1, 0, 0}
DirectionsY := [4] int { 0, 0, 1, -1}
	time_begin := t.now(); defer f.println("Time: ", t.diff(time_begin, t.now()))
	// Parse file.
	lines : [] string ; defer delete(lines)
	switch #config(file, 0) {
		case 0:
			lines = s.fields(EXAMPLE_DATA)
		case 1:
			filename := "15.txt"
			data, succ := os.read_entire_file(filename)
			if !succ {
				f.println("File containing data not found!")
				os.exit(1)
			}
			lines = s.fields(string(data))
		case:
			f.println("0 = testing, 1 = actual computation")
	}

	// Initialize DataMatrix with default values.
	for i in 0..MATDIM + 1 {
		for j in 0..MATDIM + 1 {
			DataMatrix[i][j].risk = 9
			DataMatrix[i][j].visited = false
			DataMatrix[i][j].length = max(u32)
		}
	}
	// Mark border nodes as visited.
	for j in 0..MATDIM + 1 {
		DataMatrix[0][j].visited = true
		DataMatrix[MATDIM + 1][j].visited = true
	}
	for i in 1..MATDIM {
		DataMatrix[i][0].visited = true
		DataMatrix[0][i].visited = true
	}
	// Fill up DataMatrix with input.
	for i in 1..MATDIM {
		for j in 1..MATDIM {
			intvalue, _ := v.parse_int(lines[i-1][j-1:j])
			DataMatrix[i][j].risk = u8(intvalue)
		}
	}
	// debug
	/*
	for i in 0..MATDIM + 1 {
		defer f.println("")
		for j in 0..MATDIM + 1 {
			f.printf("%d", DataMatrix[i][j].risk)
		}
	}
	*/
	// Compute lowest total risk of path using Dijiktra's algorithm.
	// Step 1: Update lengths to un-visited adjacent nodes
	curr_x, curr_y := 1, 1
	end_x,  end_y  := MATDIM, MATDIM
	currnode : Node = ---
	DataMatrix[curr_x][curr_y].length = 0
	tempnode : Node = ---
    //for q in 0..10 { // debug

    for curr_x != end_x || curr_y != end_y {
//	f.println("curr_x, curr_y", curr_x, curr_y) // debug
		currnode = DataMatrix[curr_x][curr_y]
//		f.println("current length: ", currnode.length) // debug
		for a, i in DirectionsX {
			b := DirectionsY[i]
			tempnode = DataMatrix[curr_x + a][curr_y + b]
			if !tempnode.visited {
				if currnode.length + u32(tempnode.risk) < tempnode.length {
					DataMatrix[curr_x + a][curr_y + b].length = currnode.length + u32(tempnode.risk)
				}
			}
		}
		// Remember to set node as visited!
		DataMatrix[curr_x][curr_y].visited = true
		// Otherwise choose next node to be unvisited and smallest.
		smallest := max(u32)
		for i in 1..MATDIM {
			for j in 1..MATDIM {
				if !DataMatrix[i][j].visited {
					if DataMatrix[i][j].length < smallest {
						smallest = DataMatrix[i][j].length
						curr_x = i
						curr_y = j
					}
				}
			}
		}
	}
	// Pt 1
	// Print out smallest path length.
	f.println("Smallest path: ", DataMatrix[end_x][end_y].length)
	// Running the command
		// odin run 15-sol.odin -define:file=1 -define:dim=100
	// Cmder printed:
		// Smallest path:  652
	// This was correct.
}

