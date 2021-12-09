// My solution in C to the Day 2 2021 'Advent of Code' challenge.
//
// The question is available at:
// https://adventofcode.com/2021/day/2
//
// Author:   Benjamin Thompson (github: bg-thompson)
// Email:    bgt37@cornell.edu
// Created:  2021.12.02
//
// This code is for educational uses only, and as such no portion of it 
// should ever be used in production code.
//
#include <stdio.h>
#include <string.h>

#define DATAFILE_NAME "2.txt"
//#define DATAFILE_NAME "test2.txt" // For testing, returned 15, 10 (correct) (Pt 1),
                                    // then 15, 16 (correct) (Pt 2).
#define DATAFILE_LENGTH 1001
#define DIRNUM 3

enum directions { FORWARD, DOWN, UP };

struct command
{
	enum directions direction;
	unsigned int distance;
};


void main() {
	// Read data into command array
	FILE * datafile = fopen(DATAFILE_NAME,"r");
	char command_str[16];
	char * temp_direction;
	char * temp_distance;
	struct command commands[DATAFILE_LENGTH];
	unsigned int i = 0;
	while(fgets(command_str,sizeof(command_str),datafile) != NULL) {
		if (strlen(command_str) - 1) {
			temp_direction = strtok(command_str, " ");
			switch(temp_direction[0]) { // Commands are either: "forward", "down", "up".
				case 'f':
					commands[i].direction = FORWARD;
					break;
				case 'd':
					commands[i].direction = DOWN;
					break;
				case 'u':
					commands[i].direction = UP;
					break;
			}
			temp_distance = strtok(NULL, " ");
			commands[i].distance = (int) strtol(temp_distance,NULL,0);
			i++;
		}
	}
	fclose(datafile);
	// Now calculate the distances.
	// int horizontal_d, depth_d; // Pt 1
	int horizontal_d = 0;
	int aim = 0;
	long unsigned int depth_d = 0;
	for (int k = 0; k < i; k++) {
		switch(commands[k].direction) {
			case FORWARD:
				horizontal_d += commands[k].distance;
				depth_d += aim * commands[k].distance; // Pt 2
				break;
			case DOWN:
				// depth_d += commands[k].distance; // Pt 1
				aim += commands[k].distance; // Pt 2
				break;
			case UP:
				// depth_d -= commands[k].distance; // Pt 1
				aim -= commands[k].distance; // Pt 2
				break;
		}
	}
	// Print final distances and product.
	printf("Fwd and depth distances: %d, %d\nProduct: %d\n",horizontal_d,depth_d,horizontal_d * depth_d);
	// Pt 1: 1970, 916 was printed to powershell (product: 1804520), this was correct.
	// Pt 2: 1970, 1000556 was printed to powershell (product: 1971095320), this was correct.
}
