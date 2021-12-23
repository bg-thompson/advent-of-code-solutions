// My solution in Odin to Day 16 2021 'Advent of Code' challenge.
//
// Author:   Benjamin Thompson (github: bg-thompson)
// Email:    bgt37@cornell.edu
// Created:  2021.12.23
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

// Practice data
// Calling "odin run 16-sol.odin -define:file=0" returned
	// 
// This matched the example on the website.


//EXAMPLE_DATA :: `38006F45291200`
//EXAMPLE_DATA :: `D2FE28` // Literal value 2021, parsed correctly.

//EXAMPLE_DATA :: `38006F45291200` 
// This corresponds to [1, 6, 27, [5, 4, 10], [2, 4, 20]], parsed correctly.

//EXAMPLE_DATA :: `EE00D40C823060`
// This corresponds to [7,3,3,[2,4,1],[4,4,2],[1,4,3]], parsed correctly.

EXAMPLE_DATA :: `620080001611562C8802118E34`
// This corresponds to [3,0,2,[0,0,22,[0,4,10],[5,4,11]],[1,0,2,[0,4,12],[3,4,13]]], parsed correctly.

//EXAMPLE_DATA :: `A0016C880162017C3686B18A3D4780`
// This has a version sum of 31, this agreed with the value on the website.

BYTE_ARR_UPPER_BOUND :: 8000


Packet :: union { Num_pack, Op_n_pack, Op_l_pack }

Num_pack :: struct {
	version : u8,
	type    : u8, // Always 4.
	number  : u32,
}

Op_n_pack  :: struct {
	version : u8,
	type    : u8, 
	n_packs : u16, // The number of packets (11 bit)
	packets : [] Packet,
}

Op_l_pack  :: struct {
	version : u8,
	type    : u8, 
	l_packs : u16,  // The length of the packets (15 bit)
	packets : [] Packet,
}

parse_version :: proc ( bytes : [] u8 ) -> ( number : u8) {
	return 4*bytes[0] + 2*bytes[1] + bytes[2]
}

// Parse a packet representing a literal value.
parsepack_n :: proc ( bytes : [] u8 )  -> ( pack : Num_pack, length : u16 ) {
	v := bytes[0:3]	
	t := bytes[3:6]	
	pack.version = parse_version(v)
	pack.type = parse_version(t)
	assert(pack.type == 4) // Number packets are always 4.
	temp_i := 6
	n_grps := 1
	// Find number of 3-digit groups.
	for bytes[temp_i] == 1 {
		// f.println("num grps: ", bytes[temp_i:temp_i+5]) // debug
		n_grps += 1
		temp_i += 5
	}
	// f.println("num grps: ", bytes[temp_i:temp_i+5]) // debug
	// Calculate number.
	temp_n := u32(0)
	mult := u32(1)
	for g in 0..n_grps - 1 {
		temp_n += mult*8*u32(bytes[6 + (n_grps - 1 - g)*5 + 1] )
		temp_n += mult*4*u32(bytes[6 + (n_grps - 1 - g)*5 + 2] )
		temp_n += mult*2*u32(bytes[6 + (n_grps - 1 - g)*5 + 3] )
		temp_n += mult*1*u32(bytes[6 + (n_grps - 1 - g)*5 + 4] )
		mult *= 16
	}
	pack.number = temp_n
	length = u16(6 + 5 * n_grps)
	//f.println("Parsed literal packet: ", pack) // debug
	return pack, length
}

// Parse a general packet.
parsepacket :: proc( bytes : [] u8 ) -> ( pack : Packet, length : u16) {
	// Determine if the packet is of type Op_n_pack or Op_l_pack or Num_pack
	type := bytes[3:6]
	type_n := parse_version(type)
	if (type_n == 4) {
		// Packet represents a literal value.
		pack, length = parsepack_n(bytes)
		return pack, length
	} else {
		// Packet is an operator packet.
		subpackets := make([dynamic] Packet)
		// TODO: determine if Op_n_pack, Op_l_pack, create array and 
		// fill with packets.
		length_id := bytes[6] // 0 / 1 : length in bits / subpackets
		switch length_id {
			case 0: // Subpacket length in bits.
				// Fill up packet metadata
				ret : Op_l_pack
				ret.version = parse_version(bytes[0:3])
				ret.type = parse_version(bytes[3:6])
				bit_length := u16(0)
				multf := u16(1)
				for i in 0..14 {
					bit_length += u16(bytes[7+14 - i])*multf
					multf *= 2
				}
				assert(bit_length != 0)
				ret.l_packs = bit_length
				// Parse content of packet
				//f.println("Found Op_l packet: ", ret) // debug
				//f.println("Parsing content...") // debug
				subbits := bytes[6 + 1 + 15:]
				curr_subbit := u16(0)
				for curr_subbit < bit_length {
					next_pack, next_length := parsepacket(subbits[curr_subbit:])
					append(&subpackets, next_pack)
					curr_subbit += next_length
				}
				// Subpackets have been parsed.
				ret.packets = subpackets[:]
				pack = ret
				length = 7 + 15 + bit_length // Don't forget the type ID (I) bit!
			case 1: // Subpacket length in terms of number of subpackets.
				// Fill up packet metadata
				ret : Op_n_pack
				ret.version = parse_version(bytes[0:3])
				ret.type = parse_version(bytes[3:6])
				bit_number := u16(0)
				multf := u16(1)
				for i in 0..10 {
					bit_number += u16(bytes[7+10 - i])*multf
					multf *= 2
				}
				assert(bit_number != 0)
				ret.n_packs = bit_number
				// Parse content of packet.
				//f.println("Found Op_n packet: ", ret) // debug
				//f.println("Parsing content...") // debug
				subbits := bytes[6 + 1 + 11:]
				curr_subpacket := u16(0)
				curr_subbit    := u16(0)
				for curr_subpacket < bit_number {
					next_pack, next_length := parsepacket(subbits[curr_subbit:])
					append(&subpackets, next_pack)
					curr_subbit += next_length
					curr_subpacket += 1
				}
				// Parsing is complete.
				ret.packets = subpackets[:]
				pack = ret
				length = 7 + 11 + curr_subbit
		}
		return pack, length
	}
}
/*
Op_n_pack  :: struct {
	version : u8,
	type    : u8, 
	n_packs : u16, // The number of packets (11 bit)
	packets : [] Packet,
}
*/

// We represent the packet info as follows:
// [Version, Type, Length, CONTENTS]
//
// CONTENTS is either an integer or an array of packets.
//
// Packets of type 4 don't have a length value.

// Convert one HEX ASCII characters (as a string) into a byte.
parsehexletter :: proc ( r : rune ) -> ( arr : [4] u8 ) {
	num : u8
	switch r {
		case 'A'..'F': num = u8(r - 'A' + 10)
		case '0'..'9': num = u8(r - '0')
	}
	arr[0] = num & 8 >> 3
	arr[1] = num & 4 >> 2
	arr[2] = num & 2 >> 1
	arr[3] = num & 1
	return arr
}

main :: proc() {
	time_begin := t.now() ; defer f.println("Time: ", t.diff(time_begin, t.now()))
	// Parse file.
	lines : [] string ; defer delete(lines)
	switch #config(file, 0) {
		case 0:
			lines = s.fields(EXAMPLE_DATA)
		case 1:
			filename := "16.txt"
			data, succ := os.read_entire_file(filename)
			if !succ {
				f.println("File containing data not found!")
				os.exit(1)
			}
			lines = s.fields(string(data))
		case:
			f.println("0 = testing, 1 = actual computation")
	}
	hex_str := lines[0]

	// Store Hex data into a list of 0s and 1s (each a u8).
	// This data rep. will make processing SOOOO much easier
	// than storing it in binary.

	binData : [BYTE_ARR_UPPER_BOUND] u8
	for r, i in hex_str {
		bits := parsehexletter(r)
		for j in 0..3 {
			binData[4*i + j] = bits[j]
		}
	}
	//f.println(hex_str) // debug
	prop_packet, prop_length := parsepacket(binData[:])
	// Pt 1: Sum up version numbers in packet.
	version_sum :: proc ( p : Packet ) -> (sum : int) {
		// Determine type of packet
		switch in p {
		case Num_pack:
			sum = int(p.(Num_pack).version)
		case Op_n_pack:
			pack := p.(Op_n_pack)
			sum += int(pack.version)
			for sub in pack.packets {	sum += int(version_sum(sub)) }
		case Op_l_pack:
			pack := p.(Op_l_pack)
			sum += int(pack.version)
			for sub in pack.packets {	sum += int(version_sum(sub)) }
		}
		return sum
	}
	f.println("Version sum: ", version_sum(prop_packet))
	// After running "odin run 16-sol.odin -define:file=1", cmder printed
		// Version sum:  901
		// Time:  6.0462ms
	// This was correct!
}


