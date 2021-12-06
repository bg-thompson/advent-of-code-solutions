// My solution in C to the Day 5 2021 'Advent of Code' challenge.
//
// The question is available at:
//
// https://adventofcode.com/2021/day/5
//
// Author:   Benjamin Thompson (github: bg-thompson)
// Email:    bgt37@cornell.edu
// Created:  2021.12.06
//
// This code is for educational uses only, and as such no portion of it 
// should ever be used in production code.
//
#include <stdio.h>
#include <string.h>
#include <assert.h>

#define DATAFILE_NAME "5.txt" 
//#define DATAFILE_NAME "test5.txt" // Pt1: Returned 5, this was correct.
								  // Pt2: Returned 12, this was correct.
#define DATA_ROWS 601

#define VENT_UPPER_BOUND 500

#define MATRIX_DIM 1000
struct vent
{
	short int x0;
	short int y0;
	short int x1;
	short int y1;
};

int main() {
	struct vent vs[VENT_UPPER_BOUND];
	char temp_str[32];
	unsigned int vent_n = 0;
	// Read file into data
	FILE * datafile = fopen(DATAFILE_NAME,"r");
	while(fgets(temp_str, sizeof(temp_str), datafile) != NULL) {
		vs[vent_n].x0 = (short int) strtol(strtok(temp_str,",-> "),NULL,0);
		vs[vent_n].y0 = (short int) strtol(strtok(NULL,",-> "),NULL,0);
		vs[vent_n].x1 = (short int) strtol(strtok(NULL,",-> "),NULL,0);
		vs[vent_n].y1 = (short int) strtol(strtok(NULL,",-> "),NULL,0);
		vent_n++;
	}
	fclose(datafile);
	// Count number of places where lines intersect.
	// Create floor data from vent data.
	char floor[MATRIX_DIM][MATRIX_DIM] = { 0 };
	for (int i = 0; i < vent_n; i++) {
		// Check that vent data is horizontal or vertical, or diagonal with slopes +- 1.
		// If so update floor data.
		short int x0 = vs[i].x0;
		short int x1 = vs[i].x1;
		short int y0 = vs[i].y0;
		short int y1 = vs[i].y1;
		if (x0 == x1) {
			// Vertical = '|'
			short int min = (y0 < y1 ? y0 : y1);
			short int max = (y0 > y1 ? y0 : y1);
			for (short int j = min; j <= max; j++) {
				floor[j][x0] = (!floor[j][x0] ? '|' : 'X');
			}
		} else if (y0 == y1) {
			// Horizontal = '-'
			short int min = (x0 < x1 ? x0 : x1);
			short int max = (x0 > x1 ? x0 : x1);
			for (short int j = min; j <= max; j++) {
				floor[y0][j] = (!floor[y0][j] ? '-' : 'X');
			}
		} else if ((y1 - y0)/(x1 - x0) == 1 ) { // Recall that here the positive y-axis goes down
		// Diagonal '\'
			short int TLx = (x0 < x1 ? x0 : x1);
			short int BRx = (x0 > x1 ? x0 : x1);
			short int TLy = (y0 < y1 ? y0 : y1);
			for (short int j = TLx; j <= BRx; j++) {
				floor[TLy + j - TLx][j] = (!floor[TLy + j - TLx][j] ? '\\' : 'X');
			}
		} else if ((y1 - y0)/(x1 - x0) == -1 ) {
		// Diagonal '/'
			short int BLx = (x0 < x1 ? x0 : x1);
			short int TRx = (x0 > x1 ? x0 : x1);
			short int BLy = (y0 > y1 ? y0 : y1);
			for (short int j = BLx; j <= TRx; j++) {
				floor[BLy - j + BLx][j] = (!floor[BLy - j + BLx][j] ? '/' : 'X');
			}
		} else {
			assert(!"data is neither a line of -, +, \\");
		}
	}
	// Search over array for non-zero chars.
	// The debugs here print out an image of the floor, to compare with the image
	// on the AoC website.
//	printf("floor:\n"); //debug
	int vent_intersections = 0;
	for (int i = 0; i < MATRIX_DIM; i++) {
		for (int j = 0; j < MATRIX_DIM; j++) {
			if (floor[i][j]) {
//				printf("%c",floor[i][j]); // debug
				vent_intersections += (floor[i][j] == 'X');
			} else {
//				printf("."); // debug
			}
		}
//		printf("\n"); // debug
	}
	// Pt 1
	printf("vent intersections: %d\n", vent_intersections);
	// Returned 6283, this was correct.
	// Pt 2
	printf("vent intersections: %d\n", vent_intersections);
	// Returned 18864, this was correct.
	return 0;
}	

