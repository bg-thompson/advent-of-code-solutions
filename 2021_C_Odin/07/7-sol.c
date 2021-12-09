// My solution in C to the Day 7 2021 'Advent of Code' challenge.
//
// The question is available at:
//
// https://adventofcode.com/2021/day/7
//
// Author:   Benjamin Thompson (github: bg-thompson)
// Email:    bgt37@cornell.edu
// Created:  2021.12.07
//
// This code is for educational uses only, and as such no portion of it 
// should ever be used in production code.
//
#include <stdio.h>
#include <string.h>

//#define FILENAME "7.txt"
#define FILENAME "test7.txt" // Returned 37 (Pt 1), 169 (Pt 2), these were correct.
#define UPPER_SUB_COUNT 2000
#define UPPER_FUEL_COUNT 0xffffffff

int main() {
	short int subs[UPPER_SUB_COUNT];
	char temp_char[UPPER_SUB_COUNT * 4];
	// Read file into data
	FILE * datafile = fopen(FILENAME, "r");
	fgets(temp_char, sizeof(temp_char), datafile);
	fclose(datafile);
	int n_sub = 0;
	short int temp;
	short int max_pos = 0;
	char * tk;
	for (tk = strtok(temp_char, ","); tk != NULL; tk = strtok(NULL, ",")) {
		temp = (short int) strtol(tk, NULL, 0);
		subs[n_sub] = temp;
		n_sub++;
		max_pos = (max_pos >= temp ? max_pos : temp);
	}
	// Now calculate total fuel cost for each possible position in between 0 and
	// max_pos.
	unsigned int min_fuel_cost = UPPER_FUEL_COUNT;
	short int min_pos;	
	short int temp_d;
	unsigned int temp_fuel_cost;
	for (short int i = 0; i <= max_pos; i++) {
		temp_fuel_cost = 0;
		for (int j = 0; j < n_sub; j++) {
			// Pt 1 fuel cost
			// temp_fuel_cost += (subs[j] >= i ? subs[j] - i : i - subs[j]);
			// Pt 2 fuel cost
			temp_d = (subs[j] >= i ? subs[j] - i : i - subs[j]);
			temp_fuel_cost += (temp_d * (temp_d + 1) / 2);
		}
		if (min_fuel_cost > temp_fuel_cost) {
			min_fuel_cost = temp_fuel_cost;
			min_pos = i;
		}
	}
	printf("n_sub: %d, min pos: %u, min fuel: %d\n", n_sub, min_pos, min_fuel_cost);
	// Pt 1
	// Returned n_sub: 1000, min pos: 376, min fuel: 352707, this was correct.
	// Pt 2
	// Returned n_sub: 1000, min pos: 490, min fuel: 95519693, this was correct.
	return 0;
}

