%{
#include <stdio.h>
#include <math.h>

int this_midi;
double this_time = 0.;
double default_time = 1.;

unsigned long this_note_properties = 0L;
#define STACCATO_PROPERTY 1L

#define MAX_CURLY_NESTING 10
int curly_stack_type[MAX_CURLY_NESTING];
double curly_stack_value[MAX_CURLY_NESTING];
int curly_stack_top = -1;
#define CURLY_TIMES 1
#define CURLY_IGNORED 2

int ignored = 0; /* grace notes */
double time_scale = 1.; /* tuplet rhythms */
int last_pitch = 60;
double time_since_last_bar = -1.;

int transposition = 0;
int transposition_let = 0;

char get_current_raw_note_name();
char get_raw_note_name_before_last();
char get_last_raw_note_name();
int get_last_raw_note_accidental();
void consume_raw_note_name();

char out_temp[10000];
char out_buf[1000000] = "";

do_out(s)
  char *s;
  {
    strcat(out_buf,s);
  }

push_curly_stack(type,value)
  int type;
  double value;
  {
    if (curly_stack_top>=MAX_CURLY_NESTING-1) {
      fprintf(stderr,"Error: curly braces too deeply nested\n");
      exit(-1);
    }
    ++curly_stack_top;
    curly_stack_type[curly_stack_top] = type;
    curly_stack_value[curly_stack_top] = value;
    if (type==CURLY_TIMES) {
      time_scale *= value;
    }
    if (type==CURLY_IGNORED) {
      ignored = 1;
    }
  }

  double
pop_curly_stack()
  {
    double value;
    if (curly_stack_top <= -1) {
      fprintf(stderr,"Error: popping curly braces too far, stack is empty\n"); /* indicates a bug in the parser if we get here */
      exit(-1);
    }
    if (curly_stack_type[curly_stack_top]==CURLY_TIMES) {
      time_scale /= curly_stack_value[curly_stack_top];
      if (fabs(time_scale-1.)<.0001) {
        time_scale = 1.;
      }
    }
    if (curly_stack_type[curly_stack_top]==CURLY_IGNORED) {
      ignored = 0;
    }
    --curly_stack_top;
  }

  char *
strip_quotes(s)
  char *s;
  {
    if (s[strlen(s)-1]=='"') {s[strlen(s)-1]='\0';}
    if (s[0]=='"') {++s;}
    return s;
  }

  char *
strip_blanks(s)
  char *s;
  {
    char *p,*q;
    p = s;
    q = s;
    for (;;) {
      if (*q != ' ') {*p++=*q;}
      if (*q=='\0') {break;}
      q++;
    }
    return s;

  }

  /* can't call this twice in a row without copying out the result */
  char *
strip_trailing_zeroes(x)
  double x;
  {
    char *p,*q;
    int has_decimal;
    static char s[1000];
    sprintf(s,"%lf",x);
    p = s;
    has_decimal = 0;
    while (*p++!='\0') {
      if (*p=='.') {has_decimal=1; break;}
    }
    if (!has_decimal) {return s;}
    q = s+strlen(s);
    while (q>p && *--q =='0') {
      *q = '\0';
    }
    if (s[strlen(s)-1]=='.') {s[strlen(s)-1]='\0';}
    return s;
  }

  report_key(tonic,mode)
    int tonic;
    char *mode;
    {
      int p = tonic%12;
      int acc = get_last_raw_note_accidental();
      char *s = "";
      if (acc == 0) {s="";}
      if (acc == 1) {s="is";}
      if (acc == -1) {s="es";}
      sprintf(out_temp,"key=%c%s \\%s\ntonic=%d\n",get_last_raw_note_name(),s,mode,60+p);
      do_out(out_temp);
    }

%}

%union {
  int midi;
  double time;
  char *string;
}

%token HEADER SLASH TIMES GRACE KEY TIMESIG TEMPO RELATIVE TRANSPOSE MAJOR MINOR FERMATA PARTIAL NOTES SCORE ORNAMENT REMINDER_ACCIDENTAL STACCATO CLEF MARKUP STAFF COLUMN

%token LEFT_CURLY RIGHT_CURLY LEFT_ROUND RIGHT_ROUND LEFT_SQUARE RIGHT_SQUARE LEFT_ANGLE RIGHT_ANGLE

%token WHITESPACE TIMEDOT TIE BAR ASTERISK CARET UNDERLINE

%token <string> META_LHS QUOTED

%token <midi> NOTELETTER REST SHARP FLAT DOWN_OCTAVE UP_OCTAVE

%type <midi> accidental accidentals octaves rawer_pitch raw_pitch pitch abspitch getabspitch

%token <time> TIME BEATS_PER_MINUTE

%type <time> duration

%%

/* notes about whitespace:
  The lexer tries to slurp up as much as possible. If it knows that whitespace after a particular token
  is never significat, it slurps it. The main place you have to worry is after a TIME; whitespace after
  that is not slurped, and has to be explicitly allowed for, like "TIME wh".

  bugs:
  - \tempo can't have dotted note
  - [...]~ causes an error
  - assumes certain things are global (key, tempo), even if they're supposed to change during the piece
  - assumes relative notation even if \relative not given
  - nesting of \relative is ignored, \relative is just treated as part of the stream of input
  - doesn't fill in measure with tie to next bar
  - the whole mechanism for queueing extra info about notes is a disaster; should be part of return values

  limitations:
  - must give \relative explicitly, or you get bogus output
  - \grace {a} is legal, but \grace a isn't; same deal for \acciaccatura
  - ignores time signatures after the first one; first one must occur in the setup section

 */

file:
    wh top stuff wh {do_out("\n"); printf("%s",out_buf);}
  ;

top:
    header setup {do_out("\n");}
  ;

header:
      /* empty */
    | HEADER wh LEFT_CURLY wh metadata RIGHT_CURLY wh
  ;

metadata:
        /* empty */
      | metadata metadatum
  ;

metadatum:
        META_LHS wh QUOTED wh {sprintf(out_temp,"header_%s%s\n",strip_blanks($1),strip_quotes($3)); do_out(out_temp);}
  ;

setup:
        /* empty */
      | setup setup_item
  ;


setup_item:
      KEY pitch MAJOR {report_key($2,"major"); consume_raw_note_name();}
    | KEY pitch MINOR {report_key($2,"minor"); consume_raw_note_name();}
    | TIMESIG TIME SLASH TIME wh {sprintf(out_temp,"time_signature=%lf\n",((double) $2)/((double) $4)); do_out(out_temp);}
    | TEMPO TIME wh BEATS_PER_MINUTE {sprintf(out_temp,"tempo=%lf\n",((double) $4)/60./((double) $2)); do_out(out_temp);}
    | NOTES
    | SCORE
    | ignored
  ;

stuff:
      /* empty */
    | stuff thing
  ;

thing:
      notes
    | markup
    | setup_item
    | thing thing
    | thing barline
    | barline thing
    | begin thing end 
    | LEFT_ROUND thing RIGHT_ROUND
    | LEFT_SQUARE thing RIGHT_SQUARE
    | RELATIVE abspitch {
        char c; 
        c = get_last_raw_note_name();
        last_pitch=((int) $2)-12;
        empty_raw_note_queue();
        queue_raw_note(c,0); /* not really zero, but don't actually care */
      }
    | TRANSPOSE abspitch abspitch {
        transposition=((int) $3)-((int) $2);
        transposition_let=(((int) get_current_raw_note_name())-((int) get_last_raw_note_name()))%7;
        if (transposition_let<0) {transposition_let+=7;} /* bogus behavior of C's % operator */
        if (0) {fprintf(stderr,"tr %d,%d,%d,%d,%c,%c, half-st=%d\n",
            transposition_let,
            ((int) get_current_raw_note_name()),
            ((int) get_last_raw_note_name()),((int) get_raw_note_name_before_last()),
			get_last_raw_note_name(),get_raw_note_name_before_last(),transposition );}
      }
    | LEFT_CURLY wh thing RIGHT_CURLY wh 
    | wh ignored wh
    | TIMESIG TIME SLASH TIME wh /* ignore lated time signatures */
  ;

barline:
      BAR {time_since_last_bar = 0.;}
  ;

ignored:
      NOTES
    | FERMATA
    | underline_or_caret FERMATA
    | PARTIAL TIME wh
    | PARTIAL TIME ASTERISK TIME wh
    | ORNAMENT
  ;

begin:
      pre_curly LEFT_CURLY wh
  ;

pre_curly:
      TIMES wh TIME SLASH TIME wh {push_curly_stack( CURLY_TIMES , ((double) $3)/((double) $5) );}
    | GRACE wh {push_curly_stack( CURLY_IGNORED , 0 );}
    | STAFF wh {push_curly_stack(0,0);}
  ;

end:
      RIGHT_CURLY wh {pop_curly_stack();} 
  ;

notes:
      note
    | notes note
  ;

note:
      superduper_note {
                 /* keep the following two lines separate because strip_trailing_zeroes uses a single buffer */
                 int midi,k;
                 char name;
                 midi = this_midi;
                 if (midi>0) {midi+=transposition;}
                 if (!ignored) {sprintf(out_temp,"%d,%s,",midi,strip_trailing_zeroes(this_time*time_scale)); do_out(out_temp);}
                 if (!ignored) {sprintf(out_temp,"%s,",strip_trailing_zeroes(time_since_last_bar)); do_out(out_temp);}
                 if (time_since_last_bar>=0.) {time_since_last_bar += this_time*time_scale;}
                 this_time = 0.;
                 if (!ignored && this_note_properties & STACCATO_PROPERTY) {do_out("s");}
                 this_note_properties = 0L;
                 if (midi>0) {
                   name = get_last_raw_note_name();
                   k=name-'a';
                   k = (k+transposition_let)%7;
                   if (k<0) {k+=7;} /* C's % operator doesn't seem to handle negative values in any reasonable way */
                   name = 'a'+k;
                   if (0) {fprintf(stderr,"transposition_let=%d, name=%c->%c, k=%d->%d\n",
				   transposition_let,get_last_raw_note_name(),name,((int) (get_last_raw_note_name()-'a')),k);}
                 }
                 else {
                   name = '-';
                 }
                 if (!ignored) {sprintf(out_temp,",%c",name); do_out(out_temp);}
                 if (!ignored) {do_out("  ");}
                 if (this_midi!= -1) {consume_raw_note_name();}
               }
    | superduper_note TIE wh {
                 if (this_midi!= -1) {consume_raw_note_name();}
               }
  ;

superduper_note:
      articulated_note
    | articulated_note underline_or_caret markup
  ;

markup:
      MARKUP LEFT_CURLY wh QUOTED wh RIGHT_CURLY wh
    | MARKUP LEFT_CURLY wh COLUMN wh LEFT_ANGLE wh QUOTED wh QUOTED wh RIGHT_ANGLE wh RIGHT_CURLY wh
  ;

underline_or_caret:
      UNDERLINE
    | CARET
  ;

articulated_note:
      one_note
    | one_note STACCATO {this_note_properties = this_note_properties | STACCATO_PROPERTY;}
  ;

one_note:
      abspitch          {this_midi=$1; this_time += default_time; }
    | abspitch duration {this_midi=$1; this_time += $2; default_time = $2; }
  ;

abspitch:
    getabspitch {if ($1!= -1) {last_pitch=$1; }                   }
  ;

getabspitch:
      pitch /* {fprintf(stderr,"got pitch = %d\n",((int) $1));} */
    | pitch octaves {$$ = $1 + $2;}
    | REST wh {$$ = -1;}
  ;

pitch:
      raw_pitch {
                 int p,up_interval;
                 char last_name,this_name;
                 int debug=0;
                 p=$1;
                 last_name = get_raw_note_name_before_last();
                 this_name = get_last_raw_note_name();
                 if (debug) {show_raw_note_queue();}
                 if (debug){ fprintf(stderr,"pitch, starting with %d, last_name=%c, this_name=%c, last_pitch=%d\n",(int) p,last_name,this_name,last_pitch);}
                 /* up_interval = interval we'd get if we went up: 0=unison, 1=second, etc. */
                 up_interval = ((int) this_name)-((int) last_name);  
                 if (up_interval<0) {up_interval+=7;}
                 up_interval++;
                 if (debug) {fprintf(stderr,"up_interval=%d\n",up_interval);}
                 while(p<last_pitch-6) {p+=12;}
                 while(p>last_pitch+6) {p-=12;}
                 if (debug) { fprintf(stderr,"got close to last one %d\n",(int) p);}
                 while (up_interval<=4 && p<last_pitch) {p+=12;}
                 while (up_interval>4 && p>last_pitch) {p-=12;}
                 if (debug) { fprintf(stderr,"pitch, ending with %d\n",(int) p);}
                 $$=p; 
               }
  ;

raw_pitch:
      rawer_pitch
    | rawer_pitch REMINDER_ACCIDENTAL
  ;

rawer_pitch:
      NOTELETTER wh
    | NOTELETTER accidentals {$$ = $1 + $2;}
  ;

accidentals: 
      /* empty */ {$$ = 0;}
    | accidentals accidental {$$ = $1 + $2;}
  ;

accidental:
    SHARP wh 
  | FLAT wh 
  ;

octaves:
      /* empty */ {$$ = 0;}
    | octaves UP_OCTAVE wh   {$$ += 12;}
    | octaves DOWN_OCTAVE wh {$$ -= 12;}
  ; 

duration:
        TIME wh {$$ = (1./$1);}
      | TIME TIMEDOT wh {$$ = (1./$1) * (3./2.);}
      | TIME TIMEDOT TIMEDOT wh {$$ = (1./$1) * (7./4.);}
  ;

wh:
      /* empty */
    | WHITESPACE
  ;

%%


extern FILE *yyin;


main() {
  do {
    yyparse();
  } while(!feof(yyin));
}

yyerror(s)
char *s;
{
  printf("error\n%s\n",s);
  exit(-1);
}


