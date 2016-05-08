%{
#define T_WORD 1
int numChars = 0, numWords = 0, numLines = 0;
%}

WORD		([^ \t\n\r\a]+)

%%
\n			{ numLines++; numChars++; }
{WORD}		{ numWords++; numChars += yyleng; return T_WORD; }
<<EOF>>		{ return 0; }
.			{ numChars++; }
%%

int main() {
	int token_type;
	while (token_type = yylex()) {
		printf("WORD:\t%s\n", yytext);
	}
	printf("\nChars\tWords\tLines\n");
	printf("%d\t%d\t%d\n", numChars, numWords, numLines);
	return 0;
}

int yywrap() {
	return 1;
}