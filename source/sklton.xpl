 /*   skeleton
  06-jul-77, jbd - changes made to sklton.xpl:
	references to trace and untrace were removed. this of course,
	renders the $t switch completly useless.
	all "[" were changed to ~. (character set incompatibilities)
	reference to date_of_generation and time_of_generation were
	 removed.
 
  15-jul-77, jbd - more changes:
	code was added to take source from a file.
	the access mechanism to c1 had to be changed in order to
	handle 9-bit bytes...ugh.
	stuff was added here and there to tell the user what was
	happening in synthesize.
	x70 was all tabs, so i had to change that.
	it handles tabs, but the listing comes out jagging.
		the proto-compiler of the xpl system
 
 
w. m. mckeeman	       j. j. horning	       d. b. wortman
 
information &	       computer science        computer science
computer science,      department,	       department,
 
university of	       stanford 	       stanford
california at	       university,	       university,
 
santa cruz,	       stanford,	       stanford,
california	       california	       california
95060		       94305		       94305
 
developed at the stanford computation center, campus facility,	 1966-69
and the university of california computation center, santa cruz, 1968-69.
 
distributed through the share organization.
this version of skeleton is a syntax checker for the following grammar:
 
<program>  ::=	<statement list>
 
<statement list>  ::=  <statement>
		    |  <statement list> <statement>
 
<statement>  ::=  <assignment> ;
 
<assignment>  ::=  <variable> = <expression>
 
<expression>  ::=  <arith expression>
		|  <if clause> then <expression> else <expression>
 
<if clause>  ::=  if <log expression>
 
<log expression>  ::=  true
		    |  false
		    |  <expression> <relation> <expression>
		    |  <if clause> then <log expression> else <log expression>
 
<relation>  ::=  =
	      |  <
	      |  >
 
<arith expression>  ::=  <term>
		      |  <arith expression> + <term>
		      |  <arith expression> - <term>
 
<term>	::=  <primary>
	  |  <term> * <primary>
	  |  <term> / <primary>
 
<primary>  ::=	<variable>
	     |	<number>
	     |	( <expression> )
 
<variable>  ::=  <identifier>
	      |  <variable> ( <expression> )
									      */
 
   /*  first we initialize the global constants that depend upon the input
      grammar.	the following cards are punched by the syntax pre-processor  */
 
   declare NSY literally '32', NT literally '18';
   declare v(NSY) character initial ( '<error: token = 0>', ';', '=', '<', '>',
      '+', '-', '*', '/', '(', ')', 'if', '_|_', 'then', 'else', 'true',
      'false', '<number>', '<identifier>', '<term>', '<program>', '<primary>',
      '<variable>', '<relation>', '<statement>', '<if clause>', '<assignment>',
      '<expression>', '<statement list>', '<arith expression>',
      '<log expression>', 'else', 'else');
   declare v_index(12) bit(16) initial ( 1, 11, 12, 13, 16, 17, 17, 17, 18, 18,
      18, 18, 19);
   declare c1(NSY) bit(38) initial (
      "(2) 00000 00000 00000 0000",
      "(2) 00000 00000 00200 0002",
      "(2) 00000 00003 03000 0033",
      "(2) 00000 00002 02000 0022",
      "(2) 00000 00002 02000 0022",
      "(2) 00000 00001 00000 0011",
      "(2) 00000 00001 00000 0011",
      "(2) 00000 00001 00000 0011",
      "(2) 00000 00001 00000 0011",
      "(2) 00000 00001 01000 0011",
      "(2) 02222 22222 20022 0000",
      "(2) 00000 00001 01000 1111",
      "(2) 00000 00000 00000 0001",
      "(2) 00000 00001 01000 1111",
      "(2) 00000 00002 02000 2222",
      "(2) 00000 00000 00022 0000",
      "(2) 00000 00000 00022 0000",
      "(2) 02222 22220 20022 0000",
      "(2) 02222 22222 20022 0000",
      "(2) 02222 22110 20022 0000",
      "(2) 00000 00000 00000 0000",
      "(2) 02222 22220 20022 0000",
      "(2) 02322 22221 20022 0000",
      "(2) 00000 00001 01000 0011",
      "(2) 00000 00000 00200 0002",
      "(2) 00000 00000 00010 0000",
      "(2) 01000 00000 00000 0000",
      "(2) 02333 00000 30023 0000",
      "(2) 00000 00000 00200 0001",
      "(2) 02222 11000 20022 0000",
      "(2) 00000 00000 00023 0000",
      "(2) 00000 00001 01000 0011",
      "(2) 00000 00001 01000 1111");
   declare nc1TRIPLES literally '17';
   declare c1TRIPLES(nc1TRIPLES) fixed initial ( 596746, 727810, 727811, 727812,
      792066, 858882, 858883, 858884, 858894, 859662, 1442313, 1442315, 1442321,
      1442322, 1840642, 2104066, 2104067, 2104068);
   declare prtb(28) fixed initial (0, 26, 0, 0, 0, 1444123, 2331, 0, 0, 0, 0, 0,
      0, 7429, 7430, 0, 4871, 4872, 0, 0, 28, 0, 420289311, 5634, 6935, 0, 0,
      420290080, 11);
   declare prdtb(28) bit(8) initial (0, 4, 13, 14, 15, 26, 24, 0, 0, 9, 10, 23,
      25, 17, 18, 16, 20, 21, 19, 22, 3, 2, 7, 5, 11, 1, 6, 12, 8);
   declare hdtb(28) bit(8) initial (0, 24, 23, 23, 23, 22, 21, 31, 32, 30, 30,
      21, 22, 29, 29, 29, 19, 19, 19, 21, 28, 28, 27, 26, 30, 20, 27, 30, 25);
   declare prlength(28) bit(8) initial (0, 2, 1, 1, 1, 4, 3, 1, 1, 1, 1, 1, 1,
      3, 3, 1, 3, 3, 1, 1, 2, 1, 5, 3, 3, 1, 1, 5, 2);
   declare context_case(28) bit(8) initial (0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
   declare left_context(0) bit(8) initial ( 27);
   declare left_index(14) bit(8) initial ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 1, 1);
   declare context_triple(0) fixed initial ( 0);
   declare triple_index(14) bit(8) initial ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 1);
   declare pr_index(32) bit(8) initial ( 1, 2, 3, 4, 5, 5, 5, 5, 5, 5, 7, 7, 7,
      7, 9, 10, 11, 12, 13, 16, 16, 19, 20, 20, 22, 22, 22, 25, 26, 27, 29, 29,
      29);
 
   /*  end of cards punched by syntax					   */
 
   /*  declarations for the scanner					   */
 
   /* token is the index into the vocabulary v() of the last symbol scanned,
      cp is the pointer to the last character scanned in the cardimage,
      bcd is the last symbol scanned (literal character string). */
   declare (token, cp) fixed, bcd character;
 
   /* set up some convenient abbreviations for printer control */
   declare EJECT_PAGE literally 'output(1) = page',
      page character initial ('1'), double character initial ('0'),
      DOUBLE_SPACE literally 'output(1) = double',
      x70 character initial ('                                                   
                    ');
 
   /* length of longest symbol in v */
   declare (reserved_limit, margin_chop) fixed;
 
   /* chartype() is used to distinguish classes of symbols in the scanner.
      tx() is a table used for translating from one character set to another.
      control() holds the value of the compiler control toggles set in $ cards.
      not_letter_or_digit() is similiar to chartype() but used in scanning
      identifiers only.
 
      all are used by the scanner and control() is set there.
   */
   declare (chartype, tx) (255) bit(8),
	   (control, not_letter_or_digit)(255) bit(1);
 
   /* alphabet consists of the symbols considered alphabetic in building
      identifiers     */
   declare alphabet character initial ('abcdefghijklmnopqrstuvwxyz_$@#');
 
   /* buffer holds the latest cardimage,
      text holds the present state of the input text
      (not including the portions deleted by the scanner),
      text_limit is a convenient place to store the pointer to the end of text,
      card_count is incremented by one for every source card read,
      error_count tabulates the errors as they are detected,
      severe_errors tabulates those errors of fatal significance.
   */
   declare (buffer, text) character,
      (text_limit, card_count, error_count, severe_errors, previous_error) fixed
      ;
 
   /* number_value contains the numeric value of the last constant scanned,
   */
   declare number_value fixed;
 
   /* each of the following contains the index into v() of the corresponding
      symbol.	we ask:    if token = ident    etc.    */
   declare (ident, number, divide, eofile) fixed;
 
   /* stopit() is a table of symbols which are allowed to terminate the error
      flush process.  in general they are symbols of sufficient syntactic
      hierarchy that we expect to avoid attempting to start checking again
      right into another error producing situation.  the token stack is also
      flushed down to something acceptable to a stopit() symbol.
      failsoft is a bit which allows the compiler one attempt at a gentle
      recovery.   then it takes a strong hand.	 when there is real trouble
      compiling is set to false, thereby terminating the compilation.
   */
   declare stopit(100) bit(1), (failsoft, compiling) bit(1);
 
   declare s character;  /* a temporary used various places */
 
   /* the entries in prmask() are used to select out portions of coded
      productions and the stack top for comparison in the analysis algorithm */
   declare prmask(5) fixed initial (0, 0, "ff", "ffff", "ffffff", "ffffffff");
 
 
   /*the proper substring of pointer is used to place an  |  under the point
      of detection of an error during checking.  it marks the last character
      scanned.	*/
   declare pointer character initial ('
					   |');
   declare callcount(20) fixed	 /* count the calls of important procedures */
      initial(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
 
   /* record the times of important points during checking */
   declare clock(5) fixed;
 
 
   /* commonly used strings */
   declare x1 character initial(' '), x4 character initial('	');
   declare period character initial ('.');
 
   /* temporaries used throughout the compiler */
   declare (i, j, k, l) fixed;
 
   declare TRUE literally '1', FALSE literally '0', FOREVER literally 'while 1';
 
   /*  the stacks declared below are used to drive the syntactic
      analysis algorithm and store information relevant to the interpretation
      of the text.  the stacks are all pointed to by the stack pointer sp.  */
 
   declare STACKSIZE literally '75';  /* size of stack	*/
   declare parse_stack (STACKSIZE) bit(8); /* tokens of the partially parsed
					      text */
   declare var (STACKSIZE) character;/* ebcdic name of item */
   declare fixv (STACKSIZE) fixed;   /* fixed (numeric) value */
 
   /* sp points to the right end of the reducible string in the parse stack,
      mp points to the left end, and
      mpp1 = mp+1.
   */
   declare (sp, mp, mpp1) fixed;
 
 
 /*	to mask out the remaining 4 bits from a 36 bit word	*/
   declare b32 literally '&"ffffffff"';
 
 
 
   /*		    p r o c e d u r e s 				 */
 
 
 
pad:
   procedure (string, width) character;
      declare string character, (width, l) fixed;
 
      l = length(string);
      if l >= width then return string;
      else return string || substr(x70, 0, width-l);
   end pad;
 
i_format:
   procedure (number, width) character;
      declare (number, width, l) fixed, string character;
 
      string = number;
      l = length(string);
      if l >= width then return string;
      else return substr(x70, 0, width-l) || string;
   end i_format;
 
error:
   procedure(msg, severity);
      /* prints and accounts for all error messages */
      /* if severity is not supplied, 0 is assumed */
      declare msg character, severity fixed;
      error_count = error_count + 1;
      /* if listing is suppressed, force printing of this line */
      if ~ control(byte('L')) then
	 output = i_format (card_count, 4) || ' |' || buffer || '|';
      output = substr(pointer, text_limit-cp+margin_chop);
      output(-1), output = '*** error, ' || msg ||
	    '.	last previous error was detected on line ' ||
	    previous_error || '.  ***';
      previous_error = card_count;
      if severity > 0 then
	 if severe_errors > 25 then
	    do;
	       output = '*** too many severe errors, checking aborted ***';
	       compiling = FALSE;
	    end;
	 else severe_errors = severe_errors + 1;
   end error;
 
 
 
 
 
  /*		       card image handling procedure			  */
 
 
get_card:
   procedure;
      /* does all card reading and listing				   */
      declare i fixed, (temp, temp0, rest) character, reading bit(1);
	    buffer = input;
	    if length(buffer) = 0 then
	       do; /* signal for eof */
		  call error ('eof missing or comment starting in column 1.',1);
		  buffer = pad (' /*''/* */ eof;end;eof', 80);
	       end;
	    else card_count = card_count + 1;  /* used to print on listing */
	     buffer = pad(buffer,80);
      if margin_chop > 0 then
	 do; /* the margin control from dollar | */
	    i = length(buffer) - margin_chop;
	    rest = substr(buffer, i);
	    buffer = substr(buffer, 0, i);
	 end;
      else rest = '';
      text = buffer;
      text_limit = length(text) - 1;
      if control(byte('M')) then output = buffer;
      else if control(byte('L')) then
	 output = i_format (card_count, 4) || ' |' || buffer || '|' || rest;
      cp = 0;
   end get_card;
 
 
   /*		     the scanner procedures		 */
 
 
char:
   procedure;
      /* used for strings to avoid card boundary problems */
      cp = cp + 1;
      if cp <= text_limit then return;
      call get_card;
   end char;
 
 
scan:
   procedure;
      declare (s1, s2) fixed;
      callcount(3) = callcount(3) + 1;
      failsoft = TRUE;
      bcd = '';  number_value = 0;
   scan1:
      do FOREVER;
	 if cp > text_limit then call get_card;
	 else
	    do; /* discard last scanned value */
	       text_limit = text_limit - cp;
	       text = substr(text, cp);
	       cp = 0;
	    end;
	 /*  branch on next character in text		       */
	 do case chartype(byte(text));
 
	    /*	case 0	*/
 
	    /* illegal characters fall here  */
	    call error ('illegal character: ' || substr(text, 0, 1)
		 || '(' || byte(text) || ')');
 
	    /*	case 1	*/
 
	    /*	blank  */
	    do;
	       cp = 1;
	       do while chartype(byte(text,cp)) = 1 & cp <= text_limit;
		  cp = cp + 1;
	       end;
	       cp = cp - 1;
	    end;
 
	    /*	case 2	*/
 
	;   /*	not used in skeleton (but used in xcom)  */
 
	    /*	case 3	*/
 
	;   /*	not used in skeleton (but used in xcom)  */
 
	    /*	case 4	*/
 
	    do FOREVER;  /* a letter:  identifiers and reserved words */
	       do cp = cp + 1 to text_limit;
		  if not_letter_or_digit(byte(text, cp)) then
		     do;  /* end of identifier	*/
			if cp > 0 then bcd = bcd || substr(text, 0, cp);
			s1 = length(bcd);
			if s1 > 1 then if s1 <= reserved_limit then
			   /* check for reserved words */
			   do i = v_index(s1-1) to v_index(s1) - 1;
			      if bcd = v(i) then
				 do;
				    token = i;
				    return;
				 end;
			   end;
			/*  reserved words exit higher: therefore <identifier>*/
			token = ident;
			return;
		     end;
	       end;
	       /*  end of card	*/
	       bcd = bcd || text;
	       call get_card;
	       cp = -1;
	    end;
 
	    /*	case 5	*/
 
	    do;      /*  digit:  a number  */
	       token = number;
	       do FOREVER;
		  do cp = cp to text_limit;
		     s1 = byte(text, cp);
		     if (s1 < 48) | (s1 > 57) then return;
		     number_value = 10*number_value + s1 - 48;
		  end;
		  call get_card;
	       end;
	    end;
 
	    /*	case 6	*/
 
	    do;      /*  a /:  may be divide or start of comment  */
	       call char;
	       if byte(text, cp) ~= byte('*') then
		  do;
		     token = divide;
		     return;
		  end;
	       /* we have a comment  */
	       s1, s2 = byte(' ');
	       do while s1 ~= byte('*') | s2 ~= byte('/');
		  if s1 = byte('$') then
		     do;  /* a control character  */
			control(s2) = ~ control(s2);
			if s2 = byte('|') then
			   if control(s2) then
			      margin_chop = text_limit - cp + 1;
			   else
			      margin_chop = 0;
		     end;
		  s1 = s2;
		  call char;
		  s2 = byte(text, cp);
	       end;
	    end;
 
	    /*	case 7	*/
	    do;      /*  special characters  */
	       token = tx(byte(text));
	       cp = 1;
	       return;
	    end;
 
	    /*	case 8	*/
	;   /*	not used in skeleton (but used in xcom)  */
 
	 end;	  /* of case on chartype  */
	 cp = cp + 1;  /* advance scanner and resume search for token  */
      end;
   end scan;
 
 
 
 
  /*			   time and date				 */
 
 
print_time:
   procedure (message, t);
      declare message character, t fixed;
      message = message || t/360000 || ':' || t mod 360000 / 6000 || ':'
	 || t mod 6000 / 100 || '.';
      t = t mod 100;  /* decimal fraction  */
      if t < 10 then message = message || '0';
      output = message || t || '.';
   end print_time;
 
print_date_and_time:
   procedure (message, d, t);
      declare message character, (d, t, year, day, m) fixed;
      declare month(11) character initial ('january', 'february', 'march',
	 'april', 'may', 'june', 'july', 'august', 'september', 'october',
	 'november', 'december'),
      days(12) fixed initial (0, 31, 60, 91, 121, 152, 182, 213, 244, 274,
	 305, 335, 366);
      year = d/1000 + 1900;
      day = d mod 1000;
      if (year & "3") ~= 0 then if day > 59 then day = day + 1; /* not leap year*/
      m = 1;
      do while day > days(m);  m = m + 1;  end;
      call print_time(message || month(m-1) || x1 || day-days(m-1) ||  ', '
	 || year || '.	clock time = ', t);
   end print_date_and_time;
 
  /*			   initialization				      */
 
 
 
initialization:
   procedure;
   declare filen character, ext fixed;
	output(-2) = 'filename: ';
	filen = input(-1);
	if filen = ' ' then filen = '';
	if length(filen) = 0 then do;
		filename(0) = 'tty:skeltn.skl';
		filename(1) = 'dsk:skeltn.lst';
		output(-1) = 'input program from tty:';
		end;
 
	else	do;
		ext = 0;
		do i = 0 to length(filen)-1;
			if byte(filen,i) = byte('.') then ext = i;
			end;
		if ext = 0 then do;
			filename(0) = filen || '.skl';
			filename(1) = filen || '.lst';
			end;
		else	do;
			filename(0) = filen;
			filename(1) = substr(filen,0,ext+1)||'.lst'||
				      substr(filen,ext+4);
			end;
		end;
      EJECT_PAGE;
   call print_date_and_time ('   syntax check -- university of louisville -- iii version ', date, time);
      DOUBLE_SPACE;
      call print_date_and_time ('today is ', date, time);
      DOUBLE_SPACE;
      do i = 1 to NT;
	 s = v(i);
	 if s = '<number>' then number = i;  else
	 if s = '<identifier>' then ident = i;	else
	 if s = '/' then divide = i;  else
	 if s = '_|_' then eofile = i;	else
	 if s = ';' then stopit(i) = TRUE;  else
	 ;
      end;
      if ident = NT then reserved_limit = length(v(NT-1));
      else reserved_limit = length(v(NT));
      v(eofile) = 'eof';
      stopit(eofile) = TRUE;
      chartype(byte(' ')) = 1;
      chartype(9) = 1;     /* ascii tab character */
      chartype(0) = 1;		/* do same for null, which pops up */
      do i = 0 to 255;
	 not_letter_or_digit(i) = TRUE;
      end;
      do i = 0 to length(alphabet) - 1;
	 j = byte(alphabet, i);
	 tx(j) = i;
	 not_letter_or_digit(j) = FALSE;
	 chartype(j) = 4;
      end;
      do i = 0 to 9;
	 j = byte('0123456789', i);
	 not_letter_or_digit(j) = FALSE;
	 chartype(j) = 5;
      end;
      do i = v_index(0) to v_index(1) - 1;
	 j = byte(v(i));
	 tx(j) = i;
	 chartype(j) = 7;
      end;
      chartype(byte('/')) = 6;
      /* first set up global variables controlling scan, then call it */
      cp = 0;  text_limit = -1;
      text = '';
      control(byte('L')) = TRUE;
      call scan;
 
      /* initialize the parse stack */
      sp = 1;	 parse_stack(sp) = eofile; 
 
   end initialization;
 
 
 
 
 
 
dumpit:
   procedure;	 /* dump out the statistics collected during this run  */
      DOUBLE_SPACE;
      /*  put out the entry count for important procedures */
 
      output = 'stacking decisions= ' || callcount(1);
      output = 'scan		  = ' || callcount(3);
      output = 'free string area  = ' || freelimit - freebase;
   end dumpit;
 
 
stack_dump:
   procedure;
      declare line character;
      line = 'partial parse to this point is: ';
      do i = 2 to sp;
	 if length(line) > 105 then
	    do;
	       output = line;
	       line = x4;
	    end;
	 line = line || x1 || v(parse_stack(i));
      end;
      output = line;
   end stack_dump;
 
 
  /*		      the synthesis algorithm for xpl			   */
 
 
synthesize:
procedure(production_number);
   declare production_number fixed;
 
   /*  this procedure is responsible for the semantics (code synthesis), if
      any, of the skeleton compiler.  its argument is the number of the
      production which will be applied in the pending reduction.  the global
      variables mp and sp point to the bounds in the stacks of the right part
      of this production.
       normally, this procedure will take the form of a giant case statement
      on production_number.  however, the syntax checker has semantics (the
      termination of checking) only for production 1.			  */
 
   if production_number = 1 then
 
 /*  <program>	::=  <statement list>	 */
   do;
      if mp ~= 2 then  /* we didn't get here legitimately  */
	 do;
	    call error ('eof at invalid point', 1);
	    call stack_dump;
	 end;
      compiling = FALSE;
   end;
  else do;
	output(-1)='synthesize--production#: '||production_number;
	output(-1)='synthesize--token is: '||v(token);
	output(-1) = 'synthesize--sp: '||sp||' mp: '||mp||' parse_stack is:';
	do i = 1 to sp;
	  output(-1) = 'synthesize--'||i||' '||v(parse_stack(i));
		end;
	output(-1)=' ';
	end;
end synthesize;
 
 
 
 
  /*		  syntactic parsing functions				   */
 
 
right_conflict:
   procedure (left) bit(1);
      declare left fixed;
	declare (bit#,byte#,check,case#) fixed;
      /*  this procedure is TRUE if token is not a legal right context of left*/
 /*    return ("c0" & shl(byte(c1(left), shr(token,2)), shl(token,1)
	 & "06")) = 0;	*/
	bit# = shl(token,1);
	byte# = bit# / 9;
	check = bit# mod 9;
	if check ~= 8 then  /* extract decision from a byte */
		case# = shr(byte(c1(parse_stack(sp)),byte#),7-check)&"3";
	else  /* extract decision from 2 bytes (crosses boundary) */
	case# = shl(byte(c1(parse_stack(sp)),byte#)&1,1) +
               shr(byte(c1(parse_stack(sp)),byte#+1),8);
	return case#=0;
   end right_conflict;
 
 
recover:
   procedure;
      /* if this is the second successive call to recover, discard one symbol */
      if ~ failsoft then call scan;
      failsoft = FALSE;
      do while ~ stopit(token);
	 call scan;  /* to find something solid in the text  */
      end;
      do while right_conflict (parse_stack(sp));
	 if sp > 2 then sp = sp - 1;  /* and in the stack  */
	 else call scan;  /* but don't go too far  */
      end;
      output = 'resume:' || substr(pointer, text_limit-cp+margin_chop+7);
   end recover;
 
stacking:
   procedure bit(1);  /* stacking decision function */
	declare (bit#,byte#,check,case#) fixed;
      callcount(1) = callcount(1) + 1;
      do FOREVER;    /* until return  */
      /* note: the dec-10 implementation has 9-bit bytes */
      bit# = shl(token,1);	/* (token * 2) */
      byte# = bit#/9;
      check = bit# mod 9;
      if check ~= 8 then  /* extract decision from a byte */
         case# = shr(byte(c1(parse_stack(sp)),byte#),7-check)&"3";
      else  /* extract decision from 2 bytes (crosses boundary) */
         case# = shl(byte(c1(parse_stack(sp)),byte#)&1,1) +
               shr(byte(c1(parse_stack(sp)),byte#+1),8);
      do case case#;
 
	    /*	case 0	*/
	    do;    /* illegal symbol pair  */
	       call error('illegal symbol pair: ' || v(parse_stack(sp)) || x1 ||
		  v(token), 1);
	       call stack_dump;
	       call recover;
	    end;
 
	/* case 1 */
	do;
	    return TRUE;      /*  stack token  */
	    end;
	    /*	case 2	*/
	    do;
	    return FALSE;     /* don't stack it yet  */
	    end;
	    /*	case 3	*/
 
	    do;      /* must check TRIPLES  */
	       j = shl(parse_stack(sp-1)&"ffff",16)
		 + shl(parse_stack(sp)&"ffffff", 8) + token;
	       i = -1;	k = nc1TRIPLES + 1;  /* binary search of TRIPLES  */
	       do while i + 1 < k;
		  l = shr(i+k, 1);
		  if c1TRIPLES(l) > j then k = l;
		  else if c1TRIPLES(l) < j then i = l;
		  else return TRUE;  /* it is a valid triple  */
	       end;
	       return FALSE;
	    end;
 
	 end;	 /* of do case	*/
      end;   /*  of do FOREVER */
   end stacking;
 
pr_ok:
   procedure(prd) bit(1);
      /* decision procedure for context check of equal or imbedded right parts*/
      declare (h, i, j, prd) fixed;
      do case context_case(prd);
 
	 /*  case 0 -- no check required  */
 
	 return TRUE;
 
	 /*  case 1 -- right context check  */
 
	 return ~ right_conflict (hdtb(prd));
 
	 /*  case 2 -- left context check  */
 
	 do;
	    h = hdtb(prd) - NT;
	    i = parse_stack(sp - prlength(prd));
	    do j = left_index(h-1) to left_index(h) - 1;
	       if left_context(j) = i then return TRUE;
	    end;
	    return FALSE;
	 end;
 
	 /*  case 3 -- check TRIPLES  */
 
	 do;
	    h = hdtb(prd) - NT;
	    i = shl(parse_stack(sp - prlength(prd)), 8) + token;
	    do j = triple_index(h-1) to triple_index(h) - 1;
	       if context_triple(j) = i then return TRUE;
	    end;
	    return FALSE;
	 end;
 
      end;  /* of do case  */
   end pr_ok;
 
 
  /*			 analysis algorithm				     */
 
 
 
reduce:
   procedure;
      declare (i, j, prd) fixed;
      /* pack stack top into one word */
      do i = sp - 4 to sp - 1;
	 j = shl(j, 8) + parse_stack(i);
      end;
 
      do prd = pr_index(parse_stack(sp)-1) to pr_index(parse_stack(sp)) - 1;
	 if (prmask(prlength(prd)) & j) = prtb(prd) then
	    if pr_ok(prd) then
	    do;  /* an allowed reduction */
	       mp = sp - prlength(prd) + 1; mpp1 = mp + 1;
	       call synthesize(prdtb(prd));
	       sp = mp;
	       parse_stack(sp) = hdtb(prd);
	       return;
	    end;
      end;
 
      /* look up has failed, error condition */
      call error('no production is applicable',1);
      call stack_dump;
      failsoft = FALSE;
      call recover;
   end reduce;
 
compilation_loop:
   procedure;
 
      compiling = TRUE;
      do while compiling;     /* once around for each production (reduction)  */
	 do while stacking;
	    sp = sp + 1;
	    if sp = STACKSIZE then
	       do;
		  call error ('stack overflow *** checking aborted ***', 2);
		  return;   /* thus aborting checking */
	       end;
	    parse_stack(sp) = token;
	    var(sp) = bcd;
	    fixv(sp) = number_value;
	    call scan;
	 end;
 
	 call reduce;
      end;     /* of do while compiling  */
   end compilation_loop;
 
 
 
 
print_summary:
   procedure;
      declare i fixed;
      call print_date_and_time ('end of checking ', date, time);
      output = '';
      output = card_count || ' cards were checked.';
      if error_count = 0 then output = 'no errors were detected.';
      else if error_count > 1 then
	 output = error_count || ' errors (' || severe_errors
	    || ' severe) were detected.';
      else if severe_errors = 1 then output = 'one severe error was detected.';
	 else output = 'one error was detected.';
      if previous_error > 0 then
	 output = 'the last detected error was on line ' || previous_error
	    || period;
      if control(byte('D')) then call dumpit;
      DOUBLE_SPACE;
      clock(3) = time;
      do i = 1 to 3;   /* watch out for midnight */
	 if clock(i) < clock(i-1) then clock(i) = clock(i) +  8640000;
      end;
      call print_time ('total time in checker	 ', clock(3) - clock(0));
      call print_time ('set up time		 ', clock(1) - clock(0));
      call print_time ('actual checking time	 ', clock(2) - clock(1));
      call print_time ('clean-up time at end	 ', clock(3) - clock(2));
      if clock(2) > clock(1) then   /* watch out for clock being off */
      output = 'checking rate: ' || 6000*card_count/(clock(2)-clock(1))
	 || ' cards per minute.';
   end print_summary;
 
main_procedure:
   procedure;
      clock(0) = time;	/* keep track of time in execution */
      call initialization;
	output(-1)='main_procedure--initialization finished';
 
      clock(1) = time;
 
      call compilation_loop;
	output(-1) = 'main_procedure--compilation_loop finished';
 
      clock(2) = time;
 
      /* clock(3) gets set in print_summary */
      call print_summary;
 
   end main_procedure;
 
 
call main_procedure;
 
eof eof eof
