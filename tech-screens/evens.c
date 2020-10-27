/*********************************************************************************************************************************
 *
 * Given a string of words, say a sentence, find those words with an even number of characters
 * and return the word with the greatest number. If more than one exists then return the first.
 *
 ********************************************************************************************************************************/

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

uint8_t bignum;
char *bigword;
char err_string[] = " Something's up here.";

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
	while ((wordy != NULL) && (isspace(*wordy))) { wordy++; }

	*word = wordy;
	while ((wordy != NULL) && (isalpha(*wordy))) { wordy++; }

	numchars = wordy - *word;
	*sentence = wordy;
	if (*wordy != 0)
	{
		*(*sentence)++ = 0;
	}

	return numchars;
}

/*
 * In case the string enterd was not quoted
 * collect everything from the command line
 * and assemble into a string.
 */
char *foo(int count, char *stuff[])
{
	int i, total;

	if (count == 1) return stuff[count];

	for(i = 0; i <= count; i++)
	{
		total += strlen(stuff[i]);
	}
	return err_string;
}

int main(int argc, char *argv[])
{
	char *word, *sntnce;
	uint8_t many;
	if (argc < 2)
	{
		printf("What? No words come to mind?\n");
		return -2;
	}

	bignum = 0;
	sntnce = word = foo(argc -1, argv);
	while (*sntnce != 0)
	{
		many = scan(&sntnce, &word);
		if (ISEVEN(many)) { UPDATE_BIGGEST(word, many); }
	}

	if (bignum == 0)
	{
		printf("There aren't any words of an even number of letters.\n");
		return -3;
	}
	printf("The word with the most even number of letters [%d] is <%s>\n", bignum, bigword);
}
