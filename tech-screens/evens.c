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
	while (!(isalpha(*wordy))) { wordy++; }

	*word = wordy;
	while(isalpha(*wordy)) { wordy++; }

	numchars = wordy - *word;
	*sentence = wordy;
	*(*sentence)++ = 0;


	return numchars;
}


int main(int argc, char *argv[])
{
	char *word, *sntnce;
	uint8_t many;
	if (argc < 2)
	{
		printf("What? No words come to mind?\n");
		// exit -2;
		return -2;
	}

	bignum = 0;
	sntnce = word = argv[argc - 1];
	while (*word != 0)
	{
		many = scan(&sntnce, &word);
		if (ISEVEN(many))
		{
			printf("Even [%d], %s\n", many, word);
			UPDATE_BIGGEST(word, many);
		}
	}

	printf("The word with the most even number of letters [%d] is <%ss>\n", bignum, bigword);
}
