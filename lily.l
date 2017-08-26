%{

#include "lily.tab.h"


%}

 note_to_midi(x)
 char *x;
 {
  int midi = 60;
  char c = *x;
  if (c=='c') {midi+=0;}
  if (c=='d') {midi+=2;}
  if (c=='e') {midi+=4;}
  if (c=='f') {midi+=5;}
  if (c=='g') {midi+=7;}
  if (c=='a') {midi+=9;}
  if (c=='b') {midi+=11;}
  return midi;
 }

  debug(s)
  char *s;
  {
    if (0) {printf("%s",s);}
  }

 #define MAX_LEN 1000

 char buf1[MAX_LEN+1];
 char buf2[MAX_LEN+1];

 static char raw_note_letter_queue[MAX_LEN] = "c";
 static int  raw_note_accidental_queue[MAX_LEN]; /* supports double sharps and double flats */
 static int n_raw_note_letter_queue = 1;

 queue_raw_note(c,acc)
 char c;
 int acc;
 {
   if (n_raw_note_letter_queue>=MAX_LEN-2) {fprintf(stderr,"too many notes on raw note letter queue\n"); exit(-1);}
   /* fprintf(stderr,"queueing %c\n",c); */
   raw_note_letter_queue[n_raw_note_letter_queue] = c;
   raw_note_accidental_queue[n_raw_note_letter_queue] = acc;
   ++n_raw_note_letter_queue;
 }

   int
 get_last_raw_note_accidental()
 {
    int acc = 0;
    if (n_raw_note_letter_queue>=2) {acc= raw_note_accidental_queue[1];}
    return acc;
 }

   int
 inc_last_raw_note_accidental()
 {
    if (n_raw_note_letter_queue>=2) {++raw_note_accidental_queue[1];}
 }

   int
 dec_last_raw_note_accidental()
 {
    if (n_raw_note_letter_queue>=2) {--raw_note_accidental_queue[1];}
 }

   char
 get_current_raw_note_name()
 {
    char c = 'c';
    if (n_raw_note_letter_queue>=1) {c= raw_note_letter_queue[n_raw_note_letter_queue-1];}
    return c;
 }

   char
 get_last_raw_note_name()
 {
    char c = 'c';
    if (n_raw_note_letter_queue>=2) {c= raw_note_letter_queue[1];}
    return c;
 }

   char
 get_raw_note_name_before_last()
 {
    char c = 'c';
    if (n_raw_note_letter_queue>=1) {c= raw_note_letter_queue[0];}
    return c;
 }

   void
 consume_raw_note_name()
 {
   int i;
   for (i=0; i<n_raw_note_letter_queue-1; i++) {
     raw_note_letter_queue[i] = raw_note_letter_queue[i+1];
     raw_note_accidental_queue[i] = raw_note_accidental_queue[i+1];
   }
   -- n_raw_note_letter_queue;
 }

   void
  empty_raw_note_queue()
  {
    n_raw_note_letter_queue = 0;
  }

   void
  show_raw_note_queue()
  {
   int i;
   for (i=0; i<n_raw_note_letter_queue; i++) {
     fprintf(stderr,"%c",raw_note_letter_queue[i]);
   }
   fprintf(stderr,"\n");
  }

NUM [1-9][0-9]*
COMMENT \%.*
WH ([\t \n]|\%.*)+

%%

[cdefgab]   {queue_raw_note(*yytext,0); yylval.midi = note_to_midi(yytext); return NOTELETTER;}
[cdefgab]es {queue_raw_note(*yytext,-1); yylval.midi = note_to_midi(yytext)-1; return NOTELETTER;}
[cdefgab]f  {queue_raw_note(*yytext,-1); yylval.midi = note_to_midi(yytext)-1;  return NOTELETTER;}
[cdfgb]s    {queue_raw_note(*yytext, 1); yylval.midi = note_to_midi(yytext)+1;  return NOTELETTER;}
as          {queue_raw_note('a',-1); yylval.midi = note_to_midi("a")-1;  return NOTELETTER;}
es          {queue_raw_note('e',-1); yylval.midi = note_to_midi("e")-1;  return NOTELETTER;}
[rR]        {return REST;}
(is|sharp)          {yylval.midi = 1; inc_last_raw_note_accidental(); return SHARP;}
(es|flat)           {yylval.midi = -1; dec_last_raw_note_accidental(); return FLAT;}
\-\.{WH}*           {return STACCATO;}
\!{WH}*             {return REMINDER_ACCIDENTAL;}
[,]                 {return DOWN_OCTAVE;}
[']                 {return UP_OCTAVE;}
{NUM}               {yylval.time = atof(yytext); debug("--TIME"); return TIME;}
\={WH}*{NUM}{WH}*   {yylval.time = atof(yytext+1); debug("--BPM"); return BEATS_PER_MINUTE;}
\*                  {return ASTERISK;}
\.                  {return TIMEDOT;}
\~                  {return TIE;}
{WH}+               {return WHITESPACE;}
\\version{WH}+\"[0-9\.]+\"{WH}*                    /* */;
\|{WH}*                                            {return BAR;}
\\bar{WH}*                                         {return BAR;}
\\bar{WH}*\"[^"]*\"{WH}*                           {return BAR;}
\\column            {return COLUMN;}
\\times{WH}*        {return TIMES;}
\\grace{WH}*        {return GRACE;}
\\acciaccatura{WH}* {return GRACE;}
\\header{WH}*       {return HEADER;}
\\key{WH}*          {return KEY;}
\\time{WH}*         {return TIMESIG;}
\\tempo{WH}*        {debug("--TEMPO"); return TEMPO;}
\\relative{WH}*     {return RELATIVE;}
\\transpose{WH}*    {return TRANSPOSE;}
\\major{WH}*        {return MAJOR;}
\\minor{WH}*        {return MINOR;}
\\fermata{WH}*      {return FERMATA;}
(\_|\^)\\fermata{WH}*      {return FERMATA;} /* shouldn't be necessary, but parser doesn't handle this...??? */
(\_|\^)\\turn{WH}*      /* */;
\\mark{WH}*         /* */;
\\markup{WH}*       {debug("--markup"); return MARKUP; }
\\(prall|downprall|breathe|break){WH}*      {return ORNAMENT;}
\\partial{WH}*      {return PARTIAL;}
\\notes{WH}*        {return NOTES;}
\\score{WH}*        {return SCORE;}
\\clef{WH}*(bass|treble|violin|alto|C){WH}*    /* ignored */;
(\{|\<\<)           {debug("--{"); return LEFT_CURLY; }
(\}|\>\>)           {debug("--}"); return RIGHT_CURLY; }
\<                  {return LEFT_ANGLE; }
\>                  {return RIGHT_ANGLE; }
\[{WH}*             {return LEFT_SQUARE;}
\]{WH}*             {return RIGHT_SQUARE;}
\({WH}*             {return LEFT_ROUND;}
\){WH}*             {return RIGHT_ROUND;}
\/                  {return SLASH;}
[a-zA-Z]+{WH}*\=    {strncpy(buf1,yytext,MAX_LEN); yylval.string = buf1; return META_LHS;}
\"([^"]|\n)*\"                {strncpy(buf2,yytext,MAX_LEN); yylval.string = buf2; debug("--quoted"); return QUOTED;}
\({WH}*\){WH}*                 /* ignored -- not sure what this is */;
{WH}*(\\<|\\>|\\\!|{WH})+       {return WHITESPACE;} /* crescendo and decrescendo */
{WH}*(\\((f+|p+)|mf|mp)){WH}+  {return WHITESPACE;} /* dynamics; needs whitespace after so, e.g., \partial isn't parsed as \p a */
\^                             {debug("--^"); return CARET;}
\_                             {return UNDERLINE;}
\\new{WH}+(Staff|GrandStaff){WH}*     {return STAFF;}
\\musicglyph{WH}+\#                /* */;
.                                   /* ignore (see p. 6 of lex & yacc book) */;
%%

