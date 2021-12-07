// My solution in C to the Day 6 2021 'Advent of Code' challenge.
//
// The question is available at:
//
// https://adventofcode.com/2021/day/6
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
#include <inttypes.h>

#define FILENAME "6.txt"
//#define FILENAME "test6.txt"
#define FILE_UPPER_BYTE_COUNT 1000

//#define TIME 18 // Returned 26, this was correct
//#define TIME 80 // Returned 5934 (for test6), this was correct (Pt1)
#define TIME 256

int main() {
	long long pf[9] = { 0 };
	char temp_str[1000];
	// Read file into data
	FILE * datafile = fopen(FILENAME,"r");
	// Sum of contents of initial list as a vector.
	fgets(temp_str, sizeof(temp_str), datafile);
	int data_len = strlen(temp_str);
	for (int i = 0; i < data_len; i += 2) {
		switch (temp_str[i]) {
			case '0' :
				pf[0]++;
				break;
			case '1' :
				pf[1]++;
				break;
			case '2' :
				pf[2]++;
				break;
			case '3' :
				pf[3]++;
				break;
			case '4' :
				pf[4]++;
				break;
			case '5' :
				pf[5]++;
				break;
			case '6' :
				pf[6]++;
				break;
			case '7' :
				pf[7]++;
				break;
			case '8' :
				pf[8]++;
				break;
		}
	}
	fclose(datafile);
	// Now apply function to age fish.
	long long temp;
	for (int j = 0; j < TIME ; j++) {
		temp = pf[0];
		for (int i = 0; i < 9; i++) {
			pf[i] = pf[i + 1];
		}
		pf[8] = temp;	
		pf[6] += temp;
	}
	// Print fish population
	long long pf_sum = 0;	
	for (int i = 0; i < 9; i++) {
		printf("pf[%d]: %lld\n",i, pf[i]);
		pf_sum += pf[i];
	}
	printf("lf sum: %lld\n",pf_sum);
	// Pt 1: Returned 374927, this was correct.
	// Pt 2: Returned 1687617803407, this was correct.
	return 0;
}

