// My solution in Odin to Pt 2 of the Day 12 2021 'Advent of Code' challenge.
// The majority of this code has been copied from my Pt 1 solution, this is 
// a slight modification of it.
//
// Author:   Benjamin Thompson (github: bg-thompson)
// Email:    bgt37@cornell.edu
// Created:  2021.12.18
//
// The question is available at:
//
// https://adventofcode.com/2021/day/12
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

// Our data
FILENAME     :: "12.txt"

// Practice data
//FILENAME     :: "test12-small.txt" // Returned 36 (correct)
//FILENAME     :: "test12.txt" // Returned 3509 (correct)

// Instead of letting paths be (slower) dynamic arrays, we'll make all
// paths vectors of the same length, and seperately record the length of
// the path.
PATH_LEN_UPPER_BOUND :: 400
UPPER_VERTEX_BOUND   :: 20

// A type alias
Path     :: struct {
	visited : [PATH_LEN_UPPER_BOUND] u8,
	doubleb : bool,
	length  : int,
}

VType    :: enum u8 { SMALL, LARGE, START, END, ERROR }

Vertex   :: struct {
	index : u8,
	type  : VType,
	ident : string,
}

vList : [UPPER_VERTEX_BOUND] Vertex
n_vertex : u8
gMat  : [UPPER_VERTEX_BOUND][UPPER_VERTEX_BOUND] u8

// A function for debugging 

print_path :: proc ( path : Path ) -> () {
	for i in 0..<path.length {
		f.printf("%s-",vList[path.visited[i]].ident)
	}
	f.printf("\n")
}

// The main function which returns the number of possible paths to the
// end cave given an initial path.
// Warning: this function is recursive!
calc_paths :: proc( ipath : Path ) -> ( n_paths : u32 ) {
	// print_path(ipath) // debug
	current_node := ipath.visited[ipath.length - 1]
	vtype : VType
	temp_total := u32(0)
	for i in 0..<n_vertex {
		if gMat[current_node][i] != 0 {
			// f.println("Trying node: ", i) // debug
			vtype = vList[i].type 
			switch vtype {
				case .END:
					temp_total += 1
				case .SMALL:
					// Check to see if the cave has already been visited more than once.
					// If it has been visited twice, ignore.
					// If it has been visited once, and doubleb is false, set
					// doubleb to true.
					num_visits := 0
					for j in 0..<ipath.length {
						if ipath.visited[j] == i { num_visits += 1}
					}
					if num_visits == 0 || (num_visits == 1 && !ipath.doubleb ) {
						ndoubleb := ipath.doubleb
						if num_visits == 1 && !ipath.doubleb {
							ndoubleb = true
						}
						// Add cave to path, and calculate total with this path.
						npath := ipath
						npath.doubleb = ndoubleb
						npath.visited[npath.length] = i
						npath.length += 1
						temp_total += calc_paths(npath)
					}
				case .LARGE :
						// Add cave to path, and calculate total with this path.
						npath := ipath
						npath.visited[npath.length] = i
						npath.length += 1
						temp_total += calc_paths(npath)
				case .START:
					fallthrough
				case .ERROR:
					// Error!
					f.println("There is vertex which is not END, SMALL or LARGE!")
			}
		}
	}
	return temp_total
}

// Determine type of cave given its string.
caveType :: proc ( ident : string ) -> (t : VType) {
	switch ident {
		case "start":
			t = .START
		case "end":
			t = .END
		case:
			switch ident[0] {
				case 'a'..'z': 
					t = .SMALL
				case 'A'..'Z':
					t = .LARGE
				case:
					// Error!
					f.println("caveType determination error")
					t = .ERROR
			}
	}
	return t
}

main :: proc() {
	// Parse file. Create adjacency matrix for the graph, and create a vertex
	// list describing the type of vertex.
	// Set the starting vertex as small, and remember its index.
	data, succ := os.read_entire_file(FILENAME)
	if !succ {
		f.println("File containing data not found!")
		os.exit(1)
	}
	defer delete(data)
	lines := s.split(string(data), "\n")
	defer delete(lines)
	
	n_vertex = 0
	v1_in, v2_in : bool
	v1_id, v2_id : u8
	n_edges := len(lines) - 1
	for l in 0..<n_edges {
		parts := s.split(lines[l],"-")
		v1_str := s.trim_space(parts[0])
		v2_str := s.trim_space(parts[1])
		v1_in, v2_in = false, false
		for i in 0..<n_vertex {
			if vList[i].ident == v1_str {
				v1_in = true
				v1_id = i
			} else if vList[i].ident == v2_str {
				v2_in = true
				v2_id = i
			}
		}
		switch v1_in {
		case true:
			switch v2_in {
				case true:
					// v1 and v2 are in vList.
					// So jump to adding edge in adj matrix.
				case false:
					// v1 in vList, v2 not.
					// Create entry for v2 in vList.
					vList[n_vertex].index = n_vertex
					v2_id = n_vertex
					vList[n_vertex].type = caveType(v2_str)
					vList[n_vertex].ident = v2_str
					n_vertex += 1
			}
		case false:
			switch v2_in {
				case true:
					// v1 not in vList, v1 is.
					// Create entry for v1 in vList.
					vList[n_vertex].index = n_vertex
					v1_id = n_vertex
					vList[n_vertex].type = caveType(v1_str)
					vList[n_vertex].ident = v1_str
					n_vertex += 1
				case false:
					// v1 and v2 not in vList.
					// Create entry for v1 and in vList.
					vList[n_vertex].index = n_vertex
					v1_id = n_vertex
					vList[n_vertex].type = caveType(v1_str)
					vList[n_vertex].ident = v1_str
					n_vertex += 1
					vList[n_vertex].index = n_vertex
					v2_id = n_vertex
					vList[n_vertex].type = caveType(v2_str)
					vList[n_vertex].ident = v2_str
					n_vertex += 1
			}
		}
		// Add edge to adjacency matrix.	
		gMat[v1_id][v2_id] = 1
		gMat[v2_id][v1_id] = 1
	}
	// debug for adj. matrix:
	// Print:
	// -Vertex List
	// -Matrix
	/*
	for i in 0..<n_vertex {
		f.println("vertex: ", vList[i])
	}
	for i in 0..<n_vertex {
		f.println(gMat[i])
	}
	*/
	// Pt 2: Compute total number of paths from start to exit which
	// go through any small cave at most twice.
	// Create path S-S (S = START), and replace START with small
	start_index : u8
si:	for i in 0..<n_vertex {
		if vList[i].type == .START {
			start_index = i
			vList[i].type = .SMALL
			break si
		}
	}
	sPath : Path
	sPath.visited[0] = start_index
	sPath.visited[1] = start_index
	sPath.length = 2
	sPath.doubleb = false
	// Compute path lengths.
	n_path_lengths := calc_paths(sPath)
	f.println("Number of paths: ", n_path_lengths)
	// Cmder returned:
		// Number of paths:  130094
 	// This was correct.
}

