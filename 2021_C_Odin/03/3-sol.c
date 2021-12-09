// My solution in C to the Day 3 2021 'Advent of Code' challenge.
//
// The question is available at: // https://adventofcode.com/2021/day/3
//
// Author:   Benjamin Thompson (github: bg-thompson)
// Email:    bgt37@cornell.edu
// Created:  2021.12.03
//
// This code is for educational uses only, and as such no portion of it 
// should ever be used in production code.
//
#include <stdio.h>
#include <string.h>

#define DATAFILE_NAME "3.txt"
//#define DATAFILE_NAME "test3.txt" // For testing, returned 22, 9, 198 (pt1), this was correct.
                                    // Returned 230 for pt2, this was correct.
#define DATA_ROWS 1000

//#define ROW_LEN 5 // For test3.txt
#define ROW_LEN 12
//#define MASK 0x1f // For testing
#define MASK 0x0fff

enum states { DISCARD, KEEP };
enum filter { LEAST_MOST_COMMON, DIGIT_TYPE };

struct diag_data
{
	char entry[ROW_LEN + 2];
	unsigned char oxy;
	unsigned char co2;
};


int main() {
	// Read data into matrix, and counts 1s
	struct diag_data data[DATA_ROWS];
	FILE * datafile = fopen(DATAFILE_NAME,"r");
	char temp_bin_str[16];
	unsigned int counts[ROW_LEN];
	// Initialize counts
	for (unsigned char i = 0; i < ROW_LEN; i++) {
		counts[i] = 0;
	}
	// Read data into entries 
	unsigned int row_n = 0;
	while(fgets(temp_bin_str,sizeof(temp_bin_str),datafile) != NULL) {
		if (strlen(temp_bin_str) - 1) {
			for (char i = 0; i < ROW_LEN; i++) {
				strcpy(data[row_n].entry,temp_bin_str);
				counts[i] += (data[row_n].entry[i] - '0');
				data[row_n].oxy = KEEP;
				data[row_n].co2 = KEEP;
			}
			row_n++;
		}
	}
	fclose(datafile);
// Pt 1
// Calculate rates
	short unsigned int gamma_rate = 0,
	                   epsilon_rate = 0;
	unsigned int midpoint =  row_n / 2;
	for (char i = 0; i < ROW_LEN; i++) {
		gamma_rate += (counts[i] > midpoint);
		gamma_rate <<= 1;
	}
	gamma_rate >>= 1;
	epsilon_rate = (gamma_rate ^ MASK);
	// Print rates and product (Pt 1)
	printf("gamma rate: 0x%x (%d in dec)\nepsilon_rate: 0x%x (%d in dec)\n", gamma_rate, gamma_rate, epsilon_rate, epsilon_rate);
	printf("product: %d (dec)\n", gamma_rate * epsilon_rate);
	//  The following was printed to powershell:
	//
	//  gamma rate: 0xef3 (3827 in dec)
	// 	epsilon_rate: 0x10c (268 in dec)
	// 	product: 1025636 (dec)
	//  
	//  This was correct
//  Pt 2
//  Calculate life support rating.
	enum filter oxy_filter;
	enum filter co2_filter;
    unsigned int oxy_gen_index = 0,
				 temp_index_oxy = 0,
				 co2_gen_index = 0,
				 temp_index_co2 = 0;
	for (int i = 0; i < ROW_LEN; i++) {
		// Determine highest / lowest digit of entries with tags == 1
		unsigned int temp_sum_oxy = 0,
		             temp_sum_co2 = 0,
		             temp_kept_oxy = 0,
		             temp_kept_co2 = 0;
		for (int j = 0; j < row_n; j++) {
			if (data[j].oxy == KEEP) {
				temp_index_oxy = j;
				temp_sum_oxy += (data[j].entry[i] - '0');
				temp_kept_oxy += 1;
			}
			if (data[j].co2 == KEEP) {
				temp_index_co2 = j;
				temp_sum_co2 += (data[j].entry[i] - '0');
				temp_kept_co2 += 1;
			}
		}
		// Check to see if there's only one entry, and set it if so.
		if (temp_kept_oxy == 1) {
			oxy_gen_index = temp_kept_oxy;
		}
		if (temp_kept_co2 == 1) {
			co2_gen_index = temp_index_co2;
		}
		// Determine generator ratings
		int oxy_midpoint = temp_kept_oxy / 2;
		int co2_midpoint = temp_kept_co2 / 2;
		// Determine if number of 0s and 1s are equal.
		// i.e. if twice temp_sum = temp_kept
		oxy_filter = (temp_sum_oxy * 2 == temp_kept_oxy ? DIGIT_TYPE : LEAST_MOST_COMMON);
		co2_filter = (temp_sum_co2 * 2 == temp_kept_co2 ? DIGIT_TYPE : LEAST_MOST_COMMON);
		// Set filter tags
		if (oxy_filter == DIGIT_TYPE) {
			for (int j = 0; j < row_n; j++) {
				data[j].oxy &= (data[j].entry[i] == '1');
			}
		} else {
			char oxy_digit = ( temp_sum_oxy > (temp_kept_oxy / 2));
			for (int j = 0; j < row_n; j++) {
				data[j].oxy &= ((data[j].entry[i] - '0') == oxy_digit);
			}
		}
		if (co2_filter == DIGIT_TYPE) {
			for (int j = 0; j < row_n; j++) {
				data[j].co2 &= (data[j].entry[i] == '0');
			}
		} else {
			char co2_digit = ( temp_sum_co2 <= (temp_kept_co2 / 2));
			for (int j = 0; j < row_n; j++) {
				data[j].co2 &= ((data[j].entry[i] - '0') == co2_digit);
			}
		}
	}
	// Find the oxy_gen and co2_gen;
	for (int j = 0; j < row_n; j++) {
		if (data[j].oxy) {
			oxy_gen_index = j;
		}
		if (data[j].co2) {
			co2_gen_index = j;
		}
	}
	int final_oxy = (int) strtol(data[oxy_gen_index].entry,NULL,2);
	int final_co2 = (int) strtol(data[co2_gen_index].entry,NULL,2);
	// Print out the generator ratings
	printf("oxy gen: %s(%d in dec)\n",&data[oxy_gen_index].entry[0], final_oxy);
	printf("co2 gen: %s(%d in dec)\n",&data[co2_gen_index].entry[0], final_co2);
	printf("product: %d\n", final_oxy * final_co2);
	// The following was printed to powershell:
	//
	// oxy gen: 110000010001
	// (3089 in dec)
	// co2 gen: 000100000001
	// (257 in dec)
	// product: 793873
	// 
	// This was correct.
	return 0;
}	

