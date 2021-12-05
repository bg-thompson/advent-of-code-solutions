// My solution in C to the Day 4 2021 'Advent of Code' challenge.
//
// The question is available at:
//
// https://adventofcode.com/2021/day/4
//
// Author:   Benjamin Thompson (github: bg-thompson)
// Email:    bgt37@cornell.edu
// Created:  2021.12.04
//
// This code is for educational uses only, and as such no portion of it 
// should ever be used in production code.
//
#include <stdio.h>
#include <string.h>

#define DATAFILE_NAME "4.txt"
//#define DATAFILE_NAME "test4.txt" // Returned 4512 for Pt1 testing, this was correct.
#define DATA_ROWS 601

struct board
{
	char numbers[5][5];
	char indexes[5][5];
	char bingo_index;
};

int main() {
	// Read data into r_nums and boards.
	unsigned int n_boards = 0;
	unsigned int n_random = 0;
	struct board boards[200];
	short int random_nums[100];
	FILE * datafile = fopen(DATAFILE_NAME,"r");
	char temp_str[400];
	// Read data into entries 
	// Read random numbers
	fgets(temp_str,sizeof(temp_str),datafile);
	for (char * tk = strtok(temp_str, ","); tk != NULL; tk = strtok(NULL,",")) {
		random_nums[n_random++] = (short int) strtol(tk, NULL, 0);
	}
	// Now read matrices into boards.
	while(fgets(temp_str,sizeof(temp_str),datafile) != NULL) {
		if(strlen(temp_str) == 1) {
			// New line detected, create matrix
			for (int i = 0; i < 5; i++) {
				int j = 0;
				fgets(temp_str,sizeof(temp_str),datafile);
				for(char * tk = strtok(temp_str," "); tk; tk = strtok(NULL," ")) {
					boards[n_boards].numbers[i][j++] = (char) strtol(tk,NULL,0);
				}
			}
			n_boards++;
		}
	}
	fclose(datafile);
	// Now decide which board wins first.
	// Step 1: For each number in the board, write in the index of where that number is in the random list.
	for (int j = 0; j < n_boards; j++) {
		for (int k = 0; k < 5; k++) {
			for(int l = 0; l < 5; l++) {
				for (int i = 0; i < n_random; i++) {
					if(boards[j].numbers[k][l] == random_nums[i]) {
						boards[j].indexes[k][l] = (char) i;
						break;
					}
				}
			}
		}
	}
	// Now for each board compute the max index of each row / column, and store the minimum of these.
	// in bingo_index.	
	// This can obviously be easily multithreaded... but we won't need to.
	for (int i = 0; i < n_boards; i++) {
		char btime = n_random;
		// Rows 
		for (int j = 0; j < 5; j++) {
			char t_max = 0;
			for (int k = 0; k < 5; k++) {
				t_max = (boards[i].indexes[j][k] > t_max ? boards[i].indexes[j][k] : t_max);
			}
			btime = (t_max < btime ? t_max : btime);
		}
		// Columns
		for (int k = 0; k < 5; k++) {
			char t_max = 0;
			for (int j = 0; j < 5; j++) {
				t_max = (boards[i].indexes[j][k] > t_max ? boards[i].indexes[j][k] : t_max);
			}
			btime = (t_max < btime ? t_max : btime);
		}
		boards[i].bingo_index = btime;
	}
	// Select board with lowest bingo time, and calculate score.
	int win_index = 0;
	int min_bingo_index = n_random;
	for (int i = 0; i < n_boards; i++){	
		if (boards[i].bingo_index < min_bingo_index) {
			min_bingo_index = boards[i].bingo_index;
			win_index = i;
		}
	}
	int sum_unmarked = 0;
	for (int i = 0; i < 5; i++) {
		for (int j = 0; j < 5; j++) {
			sum_unmarked += (boards[win_index].indexes[i][j] > min_bingo_index ? boards[win_index].numbers[i][j] : 0);
		}
	}
	// Print solution for Pt 1
	printf("board score: %d\n", sum_unmarked * random_nums[min_bingo_index]);
	// Powershell returned 2496, this was correct.
	//
	// Pt 2:
	// Select board with lowest score, and calculate score.
	// We just copied the above code (lines 95-110), and made the appropriate modifications:
	int lose_index = 0;
	int max_bingo_index = 0;
	for (int i = 0; i < n_boards; i++){	
		if (boards[i].bingo_index > max_bingo_index) {
			max_bingo_index = boards[i].bingo_index;
			lose_index = i;
		}
	}
	sum_unmarked = 0;
	for (int i = 0; i < 5; i++) {
		for (int j = 0; j < 5; j++) {
			sum_unmarked += (boards[lose_index].indexes[i][j] > max_bingo_index ? boards[lose_index].numbers[i][j] : 0);
		}
	}
	// Print solution for Pt 2
	printf("board score (worst): %d\n", sum_unmarked * random_nums[max_bingo_index]);
	// Console printed 25925, this was correct.
	return 0;
}	

