// My solution in C to the Day 1 2021 'Advent of Code' challenge.
//
// The question is available at:
// https://adventofcode.com/2021/day/1
//
// Author:   Benjamin Thompson
// Email:    bgt37@cornell.edu
// Created:  2021.12.01
//
// This code is for educational uses only, and as such no portion of it 
// should ever be used in production code.
//
#include <stdio.h>
#include <string.h>

#define DATAFILE_NAME "1.txt"
// #define DATAFILE_NAME "test1.txt" // For testing, returned 7, 5 (correct).
#define DATAFILE_LENGTH 2001

void main() {
	// Read data into int array
	FILE * datafile = fopen(DATAFILE_NAME,"r");
	char temp_depth_str[8];
	unsigned int depths[DATAFILE_LENGTH];
	unsigned int i = 0;
	while(fgets(temp_depth_str,sizeof(temp_depth_str),datafile) != NULL) {
		if (strlen(temp_depth_str) - 1) {
			depths[i++] = (unsigned int) strtol(temp_depth_str,NULL,0);
		}
	}
	fclose(datafile);
	// Now calculate number of times the depth increases
	unsigned int total_increases = 0;
	for (unsigned int j = 0; j < i - 1; j++) {
		total_increases += (depths[j + 1] > depths[j]);
	}
	printf("Total increases: %d\n", total_increases);
	// 1616 was printed to powershell, this was correct.
	// Calculate the number of increases using sliding windows
	unsigned int total_w_increases = 0;
	for (unsigned int j = 0; j < i - 3; j++) {
		total_w_increases += depths[j+3] > depths[j];
	}
	printf("Total w increases: %d\n", total_w_increases);
	// 1645 was printed to powershell, this was correct.
}
