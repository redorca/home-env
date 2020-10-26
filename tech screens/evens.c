/*********************************************************************************************************************************
 *
 * Given a string of words, say a sentence, find those words with an even number of characters
 * and return the word with the greatest number. If more than one exists then return the first.
 *
 ********************************************************************************************************************************/

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>

uint8_t bignum;
char *bigword;

#define ISEVEN(a)	!(a & 0x1)
#define UPDATE_BIGGEST(a, b)	\
	if (b > bignum)	\
	{			\
		printf("Updating from (%d) %s to (%d) %s\n", bignum, bigword, b, a);	\
		bignum = b;	\
		bigword = a;	\
	}
/*
 * Sort of a strtok but returning the number of chars in
 * any word found.
 *
 */
int scan(char **sentence, char **word)
{
	char *wordy;
	uint8_t numchars;

	wordy = *sentence;
	while (!(isalpha(*wordy++))) { ; }

	*word = wordy;
	while(isalpha(*wordy++)) { ; }

	numchars = wordy - *word;
	*sentence = wordy;
	*(*sentence)++ = 0;


	return numchars;
}


int main(int argc, char *argv[])
{
	char *word, *sntnce;
	uint8_t many, count;

	printf("argc %d\n", argc);
	if (argc < 2)
	{
		printf("What? No words come to mind?\n");
		// exit -2;
		return -2;
	}

	bignum = 0;
	count = 0;
	sntnce = word = argv[argc - 1];
	while ((count < 7) && (*word != 0))
	{
		count++;
		many = scan(&sntnce, &word);
		if (ISEVEN(many))
		{
			printf("Even %d\n", many);
			UPDATE_BIGGEST(word, many);
		}
	}
}
