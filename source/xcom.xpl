 /*
                              p d p - 1 0   x p l
                              v e r s i o n   1
      a compiler-compiler for programming language 1.
                                               richard l. bisbey ii
                                               july 1971
version 4.0        november 1975.
 
      verion 4 of the compiler processes the entire xpl grammar.
version 3.0        november, 1975.
      version 3.0 contains the following differences from version 2.0:
      relocatable binary code output,
      call inline facility implemented,
      uuos used to call the run-time routines,
      some switches can be specified from the terminal,
      "compactify" is compiled from a source library,
      redundant saves of procedure results in other registers is
         avoided in most instances.
      version 2.0
      hash-coded symbol table,
      left-to-right generation of strings from numbers,
      special case checks in string catenation routine,
      faster, more efficient procedure calls,
      general input/output, file, filename procedures,
      better listing, symbol dump format, etc.
             r. w. hay,
             computer group,
             dept. of electrical eng.,
             university of toronto,
             toronto, ontario, canada.
 
      the main structure of the program is as follows:
            contents.
            recognition tables for the syntax analyzer.
            declaration of scanner/compiler variables.
            storage compactification procedure.
            scanner procedures.
            parser procedures.
            code/data emitter procedures.
            symbol table procedures.
            code generation procedures.
            initialization procedure.
            analysis algorithm.
            production rules.
   */
   declare VERSION literally '''4.0''';
         /*   these are lalr parsing tables   */
 
         declare MAXR# literally '99'; /* max read # */
 
         declare MAXL# literally '125'; /* max look # */
 
         declare MAXP# literally '125'; /* max push # */
 
         declare MAXS# literally '234'; /* max state # */
 
         declare START_STATE literally '1';
 
         declare TERMINAL# literally '42'; /* # of terminals */
 
         declare VOCAB# literally '91';
 
         declare vocab(VOCAB#) character initial ('','<','(','+','|','&','*',')'
         ,';','~','-','/',',','>',':','=','||','by','do','go','if','to','bit'
         ,'end','eof','mod','call','case','else','goto','then','fixed','label'
         ,'while','return','declare','initial','<number>','<string>','character'
         ,'literally','procedure','<identifier>','<term>','<type>','<go to>'
         ,'<group>','<ending>','<primary>','<program>','<replace>','<bit head>'
         ,'<constant>','<relation>','<variable>','<if clause>','<left part>'
         ,'<statement>','<true part>','<assignment>','<bound head>'
         ,'<expression>','<group head>','<if statement>','<initial head>'
         ,'<initial list>','<while clause>','<case selector>','<call statement>'
         ,'<logical factor>','<parameter head>','<parameter list>'
         ,'<procedure head>','<procedure name>','<statement list>'
         ,'<subscript head>','<basic statement>','<go to statement>'
         ,'<identifier list>','<logical primary>','<step definition>'
         ,'<label definition>','<return statement>','<type declaration>'
         ,'<iteration control>','<logical secondary>','<string expression>'
         ,'<declaration element>','<procedure definition>'
         ,'<arithmetic expression>','<declaration statement>'
         ,'<identifier specification>');
 
         declare P# literally '109'; /* # of productions */
 
         declare state_name(MAXR#) bit(8) initial (0,0,1,2,3,3,4,5,6,7,9,9,10,10
         ,11,12,13,16,17,18,19,20,21,22,23,25,26,27,33,34,35,36,37,37,40,42,42
         ,42,42,42,43,43,43,43,43,44,44,45,46,50,50,51,52,53,54,54,55,56,58,59
         ,60,61,61,61,61,61,61,61,61,61,61,62,64,66,67,68,69,69,70,71,72,73,74
         ,74,75,76,77,78,80,81,81,82,83,86,86,88,89,89,90,91);
 
         declare RSIZE literally '337'; /*  read states info  */
 
         declare LSIZE literally '69'; /* look ahead states info */
 
         declare ASIZE literally '105'; /* apply production states info */
 
         declare read1(RSIZE) bit(8) initial (0,8,18,19,20,26,29,34,35,42,15,2,3
         ,9,10,37,38,42,2,37,38,42,2,37,38,42,2,3,9,10,37,38,42,2,3,9,10,37,38
         ,42,2,37,38,42,22,31,32,39,2,3,10,37,38,42,1,13,15,2,37,38,42,2,37,38
         ,42,2,37,38,42,2,42,15,2,3,10,37,38,42,2,3,9,10,37,38,42,8,27,33,42,21
         ,2,3,9,10,37,38,42,2,3,9,10,37,38,42,2,42,2,37,38,42,42,2,3,9,10,37,38
         ,42,2,3,9,10,37,38,42,2,3,9,10,37,38,42,2,42,2,7,7,38,2,14,2,40,7,12,7
         ,12,6,11,25,6,11,25,6,11,25,6,11,25,6,11,25,8,8,42,8,2,3,9,10,37,38,42
         ,2,3,9,10,37,38,42,37,7,12,2,3,10,37,38,42,12,15,15,8,18,19,20,26,29,34
         ,35,42,42,8,18,19,20,26,29,34,35,42,8,37,4,30,4,4,7,12,4,4,4,7,4,4,21,4
         ,17,4,8,18,19,20,23,26,29,34,35,42,37,38,8,8,8,5,5,42,8,22,31,32,39,8
         ,18,19,20,26,29,34,35,42,2,8,22,31,32,39,8,18,19,20,24,26,29,34,35,42,8
         ,18,19,20,23,26,29,34,35,42,2,3,9,10,37,38,42,28,8,42,8,8,18,19,20,26
         ,29,34,35,41,42,8,18,19,20,23,26,29,34,35,41,42,8,36,1,9,13,15,16,16,8
         ,3,10,3,10,8,12,2,22,31,32,39);
 
         declare look1(LSIZE) bit(8) initial (0,15,0,15,0,42,0,8,0,2,14,0,2,0,40
         ,0,6,11,25,0,6,11,25,0,6,11,25,0,6,11,25,0,6,11,25,0,4,0,4,0,4,0,4,0,8
         ,0,4,0,5,0,5,0,28,0,36,0,1,9,13,15,16,0,16,0,3,10,0,3,10,0);
 
         /*  push states are built-in to the index tables  */
 
         declare apply1(ASIZE) bit(8) initial (0,0,80,0,56,58,71,82,83,0,56,89
         ,90,0,89,90,0,0,0,0,0,0,0,0,0,0,0,0,0,0,83,90,0,71,83,90,0,0,0,0,0,0,15
         ,0,0,9,79,99,0,0,0,0,0,0,0,57,0,55,0,0,3,18,22,27,28,29,49,50,84,0,6,0
         ,7,0,10,0,0,53,0,17,0,4,5,12,13,0,8,14,25,0,1,19,26,56,57,58,71,80,82
         ,83,89,90,0,0,72,0);
 
         declare read2(RSIZE) bit(8) initial (0,138,19,20,21,26,174,103,30,104
         ,213,3,4,10,12,234,233,105,3,234,233,105,3,234,233,105,3,4,10,12,234
         ,233,105,3,4,10,12,234,233,105,3,234,233,105,23,182,184,183,3,4,12,234
         ,233,105,211,212,210,3,234,233,105,3,234,233,105,3,234,233,105,190,106
         ,214,3,4,12,234,233,105,3,4,10,12,234,233,105,146,27,28,105,173,3,4,10
         ,12,234,233,105,3,4,10,12,234,233,105,186,166,3,234,233,105,105,3,4,10
         ,12,234,233,105,3,4,10,12,234,233,105,3,4,10,12,234,233,105,190,106,193
         ,9,185,178,231,168,231,34,189,191,162,164,8,14,25,8,14,25,8,14,25,8,14
         ,25,8,14,25,158,160,172,132,3,4,10,12,234,233,105,3,4,10,12,234,233,105
         ,33,192,194,3,4,12,234,233,105,198,197,197,138,19,20,21,26,174,103,30
         ,104,105,138,19,20,21,26,174,103,30,104,131,32,6,143,6,6,230,232,6,6,6
         ,228,6,6,22,6,18,6,138,19,20,21,102,26,174,103,30,104,234,233,148,149
         ,135,7,7,39,159,23,182,184,183,138,19,20,21,26,174,103,30,104,163,157
         ,23,182,184,183,138,19,20,21,126,26,174,103,30,104,138,19,20,21,102,26
         ,174,103,30,104,3,4,10,12,234,233,105,144,136,38,147,138,19,20,21,26
         ,174,103,30,161,104,138,19,20,21,102,26,174,103,30,161,104,134,31,100
         ,11,101,207,17,17,133,5,13,5,13,137,15,187,23,182,184,183);
 
         declare look2(LSIZE) bit(8) initial (0,2,208,16,209,24,165,169,29,35,35
         ,229,36,229,37,188,40,40,40,217,41,41,41,220,42,42,42,221,43,43,43,218
         ,44,44,44,219,62,170,64,155,65,154,67,195,152,69,70,153,76,199,77,200
         ,85,129,92,177,93,93,93,93,93,205,94,206,96,96,215,97,97,216);
 
         declare apply2(ASIZE) bit(8) initial (0,0,83,82,140,141,150,128,128,127
         ,120,139,139,129,142,142,130,56,58,48,71,88,151,73,74,95,80,81,79,78
         ,156,167,145,90,90,90,89,91,75,86,47,98,176,175,121,180,46,179,45,51,60
         ,99,87,181,72,196,59,50,49,57,66,117,116,113,114,112,115,68,63,61,119
         ,118,202,201,204,203,53,123,122,125,124,108,110,109,111,107,223,224,225
         ,222,54,55,171,54,54,54,54,54,54,54,54,54,227,84,52,226);
 
         declare index1(MAXS#) bit(16) initial (0,1,10,11,18,22,26,33,40,44,48
         ,54,57,61,65,69,71,72,78,85,89,90,97,104,105,106,110,111,118,125,132
         ,134,135,136,137,138,140,141,142,144,146,149,152,155,158,161,162,163
         ,164,165,172,179,180,182,188,190,191,200,201,210,211,212,214,215,218
         ,219,220,222,223,225,227,228,238,240,241,242,243,244,245,246,251,260
         ,266,276,286,293,294,295,296,297,307,318,319,320,325,326,327,329,331
         ,333,1,3,5,7,9,12,14,16,20,24,28,32,36,38,40,42,44,46,48,50,52,54,56,62
         ,64,67,1,2,2,4,4,10,10,10,10,10,10,10,10,10,14,14,14,17,18,19,20,20,20
         ,20,20,21,22,22,23,24,25,26,26,26,26,27,28,29,29,30,30,30,33,37,37,38
         ,39,40,40,41,41,42,42,44,44,44,45,45,45,45,49,50,51,51,52,52,53,54,54
         ,55,55,57,59,60,60,70,70,72,72,74,74,76,76,76,76,76,76,76,76,77,77,79
         ,79,79,79,79,81,81,81,81,86,86,86,90,90,103,103,104,104);
 
         declare index2(MAXS#) bit(8) initial (0,9,1,7,4,4,7,7,4,4,6,3,4,4,4,2,1
         ,6,7,4,1,7,7,1,1,4,1,7,7,7,2,1,1,1,1,2,1,1,2,2,3,3,3,3,3,1,1,1,1,7,7,1
         ,2,6,2,1,9,1,9,1,1,2,1,3,1,1,2,1,2,2,1,10,2,1,1,1,1,1,1,5,9,6,10,10,7,1
         ,1,1,1,10,11,1,1,5,1,1,2,2,2,5,2,2,2,2,3,2,2,4,4,4,4,4,2,2,2,2,2,2,2,2
         ,2,2,6,2,3,3,1,0,1,0,0,1,1,1,1,1,1,1,0,1,1,2,1,2,1,1,1,2,2,2,1,3,1,3,1
         ,1,2,1,2,2,3,1,2,0,2,0,1,1,1,0,1,1,1,1,0,1,2,0,2,1,3,1,0,0,0,2,1,1,0,2
         ,0,2,2,1,2,2,1,0,1,0,2,0,2,0,1,0,2,0,0,0,1,1,1,1,1,0,2,0,2,2,1,1,0,2,2
         ,2,0,0,2,0,2,1,2,0,0);
 
 
   /*  declarations for the scanner                                        */
   /* token is the index into the vocabulary v() of the last symbol scanned,
      cp is the pointer to the last character scanned in the cardimage,
      bcd is the last symbol scanned (literal character string). */
   declare token fixed, bcd character, ch fixed, cp fixed;
 
   /* set up some convenient abbreviations for printer control */
   declare TRUE literally '"1"', FALSE literally '"0"',
      FOREVER literally 'while TRUE',
      x70 character initial ('                                        
                              ');
   declare pointer character initial    ('                              
                                                           |');
   /* length of longest symbol in v */
   declare reserved_limit fixed;
   /* chartype() is used to distinguish classes of symbols in the scanner.
      tx() is a table used for translating from one character set to another.
      control() holds the value of the compiler control toggles set in $ cards.
      not_letter_or_digit() is similiar to chartype() but used in scanning
      identifiers only.
 
      all are used by the scanner and control() is set there.
   */
   declare chartype(255) bit(8), tx(255) bit(8), control(255) bit(1),
      not_letter_or_digit(255) bit(1);
   /* buffer holds the latest cardimage,
      text holds the present state of the input text
      (not including the portions deleted by the scanner),
      text_limit is a convenient place to store the pointer to the end of text,
      card_count is incremented by one for every source card read,
      error_count tabulates the errors as they are detected,
      severe_errors tabulates those errors of fatal significance.
      current_procedure contains the name of the procedure being processed.
   */
   declare buffer character, text character, text_limit fixed,
       card_count fixed, error_count fixed,
       severe_errors fixed, previous_error fixed,
       line_length  fixed,         /* length of source statement */
       current_procedure character;
   /* number_value contains the numeric value of the last constant scanned,
   */
   declare number_value fixed, jbase fixed, base fixed;
   /* each of the following contains the index into v() of the corresponding
      symbol.   we ask:    if token = ident    etc.    */
   declare ident fixed, string fixed, number fixed, divide fixed, eofile fixed,
      labelset fixed;
   declare orsymbol fixed, concatenate fixed;
   declare balance character, lb fixed ;
   declare MACRO_LIMIT literally '60', macro_name (MACRO_LIMIT) character,
      macro_text(MACRO_LIMIT) character, macro_index (255) bit (8),
      macro_count (MACRO_LIMIT) fixed, macro_declare (MACRO_LIMIT) fixed,
      top_macro fixed;
   declare expansion_count fixed, EXPANSION_LIMIT literally '300';
   /* stopit() is a table of symbols which are allowed to terminate the error
      flush process.  in general they are symbols of sufficient syntactic
      hierarchy that we expect to avoid attempting to start checking again
      right into another error producing situation.  the token stack is also
      flushed down to something acceptable to a stopit() symbol.
      failsoft is a bit which allows the compiler one attempt at a gentle
      recovery.   then it takes a strong hand.   when there is real trouble
      compiling is set to FALSE, thereby terminating the compilation.
   */
   declare stopit(TERMINAL#) bit(1), failsoft fixed, compiling fixed;
   /*   the following switch is used by the lalr parser   */
   declare no_look_ahead_done bit(1);
   declare target_register fixed;       /* for findar */
   declare trueloc fixed;               /* location of constant 1 */
   declare falseloc fixed;              /* location of constant 0 */
   declare byteptrs fixed,              /* location of 4 ptrs for ldb & dpb */
           psbits fixed;                /* byte ptrs fore move */
   declare string_check fixed,          /* compactify caller */
           catentry fixed,              /* catenation subroutine */
           nmbrentry fixed,             /* number to string subroutine */
           strcomp fixed,               /* string compare subroutine */
           calltype fixed initial (1),  /* dist between sub & function */
           mover fixed,                 /* string move subroutine */
           string_recover fixed,        /* syt location of compactify */
           corebyteloc fixed,           /* syt location of corebyte */
           limitword fixed,             /* address of freelimit */
           tsa fixed;                   /* address of freepoint */
   declare ndesc fixed;                 /* address of ndescript               */
   declare library fixed,               /* address of runtime library */
           library_save fixed,          /* place to store r11 on lib calls */
           str  fixed;                  /* descriptor of last string */
   declare stepk fixed;                 /* used for do loops */
   declare a fixed, b fixed, c fixed;   /* for catenation & conversion */
   declare lengthmask fixed;            /* addr of dv length mask */
   declare addrmask fixed;              /* address of "fffff" */
   declare label_sink fixed initial(0); /* for label generator */
   declare label_gen character;         /* contains label for next inst*/
   declare acc(15) fixed;               /* keeps track of accumulators */
   declare AVAIL literally '0', BUSY literally '1';
    /* call counts of important procedures */
   declare count_scan fixed, /* scan               */
            count_inst fixed,  /* emitinst           */
            count_force fixed, /* forceaccumulator   */
            count_arith fixed, /* arithemit          */
            count_store fixed; /* genstore           */
   declare title        character,     /*title line for listing */
           subtitle     character,     /*subtitle for listing */
           page_count   fixed,         /*current page number for listing*/
           line_count   fixed,         /*number of lines printed */
           PAGE_MAX literally '54',    /*max no of lines on page*/
           EJECT_PAGE literally 'line_count = PAGE_MAX+1';
   declare source character;           /*file name being compiled*/
   declare DATAFILE literally '2';     /* scratch file for data */
   declare CODEFILE literally '3';     /* scratch file for code */
   declare RELFILE  literally '4';     /* binary output file */
   declare LIBFILE  literally '5';     /* source library file */
   declare reading  bit(1);            /* 0 iff reading LIBFILE */
   declare datacard character;         /* data buffer */
   declare pp      fixed,              /* current program pointer */
           code(3) character,           /* the code buffer */
           code_full(3) bit(1),         /* fullness flag */
           code_head fixed,             /* front of buffer */
           code_tail fixed,             /* end of buffer */
           dp      fixed,              /* current data pointer */
           dpoffset fixed;             /* current dp byte offset */
   declare codestring character;     /*for copying code into data file*/
   /*   the following are for relocatable binary code emission */
   declare BUFFERSIZE literally '18';   /* size of binary buffers */
   declare code_buffer (BUFFERSIZE) fixed;   /*code (high) buffer */
   declare data_buffer (BUFFERSIZE) fixed;   /* data (low) buffer */
   declare label_buffer (BUFFERSIZE) fixed;  /* labels defined buffer */
   declare code_rel(3) fixed,         /* binary code buffer (see code) */
           code_pp(3) fixed,
           code_rbits(3) fixed;
   declare rptr fixed,                  /* pointer to code_buffer */
           rctr fixed,                  /* counter for code_buffer */
           dptr fixed,                   /* pointer to data_buffer */
           dctr fixed,                  /* counter for data_buffer */
           dloc fixed;                   /* location of next word in data buffer */
   declare label_count fixed;            /*no of labels in label_buffer */
   declare FOR_MAX  literally '50';      /* maximum forward references */
   declare for_ref   (FOR_MAX) fixed,    /* forward referenced labels */
           for_label (FOR_MAX) fixed,    /* label referenced */
           for_count fixed;              /* count of current forward refs */
   declare pword fixed;                  /* part-word acc. for bytes*/
   declare startloc fixed;               /* first instruction to be executed */
   declare CODE_TYPE literally '"(3)1000000"';   /* code & data type block */
   declare SYMB_TYPE literally '"(3)2000000"';   /* symbol defn type block */
   declare HISEG_TYPE literally '"(3)3000000"';  /* high segment type block */
   declare END_TYPE literally '"(3)5000000"';    /* end type block */
   declare NAME_TYPE literally '"(3)6000000"';   /* name type block */
   declare START_TYPE literally '"(3)7000000"';  /* start address type block */
   declare INTREQ_TYPE literally '"(3)10000000"'; /* internal request type block */
 
   /* end of definitions for relocatable binary files */
   declare adr     fixed;
   declare itype fixed;
   declare newdp fixed, newdsp fixed, newdpoffset fixed; /* for allocation */
   declare olddp fixed, olddsp fixed, olddpoffset fixed; /* for allocation */
   declare DESCLIMIT literally '1000', /* number of string descriptors */
           desca (DESCLIMIT) fixed,     /* string descriptor address */
           descl (DESCLIMIT) fixed,     /* string descriptor length */
           descref (DESCLIMIT) fixed,    /* last reference to string */
           dsp     fixed;              /* descriptor pointer */
   declare s character;
   declare opname (15) character initial (
'      .init..inpt..outp..exit.      .fili..filo..name.',
'call  init  uuo042uuo043uuo044uuo045uuo046calli open  ttcalluuo052uuo053uuo054
renamein    out   setstsstato getstsstatz inbuf outbufinput outputclose 
releasmtape ugetf useti useto lookupenter ',
'uuo100uuo101uuo102uuo103uuo104uuo105uuo106uuo107uuo110uuo111uuo112uuo113uuo114u
uo115uuo116uuo117uuo120uuo121uuo122uuo123uuo124uuo125uuo126uuo127ufa   dfn   fsc
   ibp   ildb  ldb   idpb  dpb   ',
'',
'move  movei movem moves movs  movsi movsm movss movn  movni movnm movns movm  m
ovmi movmm movms imul  imuli imulm imulb mul   muli  mulm  mulb  idiv  idivi idi
vm idivb div   divi  divm  divb  ',
'ash   rot   lsh   jffo  ashc  rotc  lshc  ......exch  blt   aobjp aobjn jrst  j
fcl  xct   ......pushj push  pop   popj  jsr   jsp   jsa   jra   add   addi  add
m  addb  sub   subi  subm  subb  ',
'cai   cail  caie  caile caia  caige cain  caig  cam   caml  came  camle cama  c
amge camn  camg  jump  jumpl jumpe jumplejumpa jumpgejumpn jumpg skip  skipl ski
pe skipleskipa skipgeskipn skipg ',
 'aoj   aojl  aoje  aojle aoja  aojge aojn  aojg  aos   aosl  aose  aosle aosa  a
osge aosn  aosg  soj   sojl  soje  sojle soja  sojge sojn  sojg  sos   sosl  sos
e  sosle sosa  sosge sosn  sosg  ',
'setz  setzi setzm setzb and   andi  anmd  andb  andca andcaiandcamandcabsetm  s
etmi setmm setmb andcm andcmiandcmmandcmbseta  setai setam setab xor   xori  xor
m  xorb  ior   iori  iorm  iorb  ',
'andcb andcbiandcbmandcbbeqv   eqvi  eqvm  eqvb  setca setcaisetcamsetcaborca  o
rcai orcam orcab setcm setcmisetcmmsetcmborcm  orcmi orcmm orcmb orcb  orcbi orc
bm orcbb seto  setoi setom setob ',
'hll   hlli  hllm  hlls  hrl   hrli  hrlm  hrls  hllz  hllzi hllzm hllzs hrlz  h
rlzi hrlzm hrlzs hllo  hlloi hllom hllos hrlo  hrloi hrlom hrlos hlle  hllei hll
em hlles hrle  hrlei hrlem hrles ',
'hrr   hrri  hrrm  hrrs  hlr   hlri  hlrm  hlrs  hrrz  hrrzi hrrzm hrrzs hlrz  h
lrzi hlrzm hlrzs hrro  hrroi hrrom hrros hlro  hlroi hlrom hlros hrre  hrrei hrr
em hrres hlre  hlrei hlrem hlres ',
'trn   tln   trne  tlne  trna  tlna  trnn  tlnn  tdn   tsn   tdne  tsne  tdna  t
sna  tdnn  tsnn  trz   tlz   trze  tlze  trza  tlza  trzn  tlzn  tdz   tsz   tdz
e  tsze  tdza  tsza  tdzn  tszn  ',
'trc   tlc   trce  tlce  trca  tlca  trcn  tlcn  tdc   tsc   tdce  tsce  tdca  t
sca  tdcn  tscn  tro   tlo   troe  tloe  troa  tloa  tron  tlon  tdo   tso   tdo
e  tsoe  tdoa  tsoa  tdon  tson  ',
'',
'');
   declare instruct(511) fixed;         /* count of the instructions issued */
         /* commonly used opcodes */
   declare add    fixed initial ("(3)270"),
           addi   fixed initial ("(3)271"),
           addm   fixed initial ("(3)272"),
           and    fixed initial ("(3)404"),
           andi   fixed initial ("(3)405"),
           aosa   fixed initial ("(3)354"),
           blt    fixed initial ("(3)251"),
           calli  fixed initial ("(3)047"),
           cam    fixed initial ("(3)310"),
           camge  fixed initial ("(3)315"),
           caml   fixed initial ("(3)311"),
           camle  fixed initial ("(3)313"),
           camn   fixed initial ("(3)316"),
           cmprhi fixed initial ("(3)317"),
           dpb    fixed initial ("(3)137"),
           hll    fixed initial ("(3)500"),
           hlrz   fixed initial ("(3)554"),
           hrli   fixed initial ("(3)505"),
           hrlm   fixed initial ("(3)506"),
           hrrei  fixed initial ("(3)571"),
           idiv   fixed initial ("(3)230"),
           idivi  fixed initial ("(3)231"),
           idpb   fixed initial ("(3)136"),
           ildb   fixed initial ("(3)134"),
           imul   fixed initial ("(3)220"),
           ior    fixed initial ("(3)434"),
           jrst   fixed initial ("(3)254"),
           jump   fixed initial ("(3)320"),
           jumpe  fixed initial ("(3)322"),
           jumpge fixed initial ("(3)325"),
           jumpn  fixed initial ("(3)326"),
           ldb    fixed initial ("(3)135"),
           lsh    fixed initial ("(3)242"),
           lshc   fixed initial ("(3)246"),
           move   fixed initial ("(3)200"),
           movei  fixed initial ("(3)201"),
           movem  fixed initial ("(3)202"),
           movm   fixed initial ("(3)214"),
           movn   fixed initial ("(3)210"),
           pop    fixed initial ("(3)262"),
           popj   fixed initial ("(3)263"),
           push   fixed initial ("(3)261"),
           pushj  fixed initial ("(3)260"),
           rot    fixed initial ("(3)241"),
           setca  fixed initial ("(3)450"),
           setzm  fixed initial ("(3)402"),
           skip   fixed initial ("(3)330"),
           skipe  fixed initial ("(3)332"),
           sojg   fixed initial ("(3)367"),
           sub    fixed initial ("(3)274"),
           subi   fixed initial ("(3)275");
   declare compareswap (7) fixed initial (0,7,2,5,0,3,6,1);
   declare stillcond fixed,            /* peep hole for bool branching */
           stillinzero fixed;          /* peephole for redundant moves */
   declare statement_count fixed;      /* a count of the xpl statements */
   declare idcompares fixed;
   declare x1 character initial (' ');
   declare x2 character initial ('  ');
   declare x3 character initial ('   ');
   declare x4 character initial ('    ');
   declare x7 character initial ('       ');
   declare info character;         /* for listing information*/
   declare char_temp character;
   declare i_string character;      /* for i_format */
   declare i fixed, j fixed, k fixed, l fixed;
   declare procmark fixed, ndecsy fixed, maxndecsy fixed, parct fixed;
   declare returned_type fixed;
   declare LABELTYPE     literally  '1',
           ACCUMULATOR   literally  '2',
           VARIABLE      literally  '3',
           CONSTANT      literally  '4',
           CHRTYPE       literally  '6',
           FIXEDTYPE     literally  '7',
           BYTETYPE      literally  '8',
           FORWARDTYPE   literally  '9',
           DESCRIPT      literally '10',
           SPECIAL       literally '11',
           FORWARDCALL   literally '12',
           PROCTYPE      literally '13',
           CHARPROCTYPE  literally '14';
   declare typename (14) character initial ('', 'label    ', '', '', '', '',
           'character', 'fixed    ', 'bit (9)  ' , '', '', '', '',
           'procedure','character procedure');
   /*  the symbol table is initialized with the names of all
       builtin functions and pseudo variables.  the procedure
       initialize depends on the order and placement of these
       names.  changes should be made observing due caution to
       avoid messing things up.
   */
   declare SYTSIZE literally '420';     /* the symbol table size */
   declare syt (SYTSIZE) character      /* the VARIABLE name */
      initial ('coreword', 'corebyte', 'freepoint', 'descriptor',
         'ndescript',   'length', 'substr', 'byte', 'shl', 'shr',
         'input', 'output', 'file', 'inline', 'trace', 'untrace',
         'exit', 'time', 'date', 'clock_trap', 'interrupt_trap',
         'monitor', 'addr', 'runtime', 'filename',
         'compactify', 'freelimit', 'freebase');
   declare sytype (SYTSIZE) bit (8)     /* type of VARIABLE */
      initial (FIXEDTYPE, BYTETYPE, FIXEDTYPE, FIXEDTYPE,
         FIXEDTYPE, SPECIAL, SPECIAL, SPECIAL, SPECIAL, SPECIAL,
         SPECIAL, SPECIAL, SPECIAL, SPECIAL, SPECIAL, SPECIAL,
          SPECIAL, SPECIAL, SPECIAL, SPECIAL, SPECIAL,
         SPECIAL, SPECIAL, SPECIAL, SPECIAL,
         FORWARDCALL, FIXEDTYPE, FIXEDTYPE);
   declare sytloc (SYTSIZE) fixed       /* location of VARIABLE */
      initial (0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
          0,0,0);
   declare sytseg (SYTSIZE) bit(8)      /* segment of VARIABLE */
      initial (0,0,1,3,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,1,1);
   declare sytco (SYTSIZE) fixed;       /* a count of references */
   declare sytcard (SYTSIZE) fixed;     /* where symbol is defined */
   declare hash (255)      fixed,       /* hash table into symbol table*/
           ptr  (SYTSIZE)  fixed,       /* points to next symbol in hash*/
           idx             fixed;       /* index while using hash*/
   /*  the compiler stacks declared below are used to drive the syntactic
      analysis algorithm and store information relevant to the interpretation
      of the text.  the stacks are all pointed to by the stack pointer sp.  */
   declare STACKSIZE literally '50';  /* size of stack  */
   declare state_stack (STACKSIZE)  bit (8);
   declare type        (STACKSIZE)  fixed;
   declare reg         (STACKSIZE)  fixed;
   declare inx         (STACKSIZE)  fixed;
   declare cnt         (STACKSIZE)  fixed;
   declare var         (STACKSIZE)  character;
   declare fixv        (STACKSIZE)  fixed;
   declare ppsave      (STACKSIZE)  fixed;
   declare fixl        (STACKSIZE)  fixed;
   declare sp fixed, mp fixed, mpp1 fixed;
   declare CASELIMIT literally '175',
           casestack (CASELIMIT) fixed, /* contains addr of stmts of case */
           casep  fixed;                /* points to current casestack entry */
   declare codemsg  character initial ('code = '),
           datamsg  character initial ('data = '),
           backmsg  character initial ('back up code emitter'),
           filemsg  character initial ('missing number for file');
/*
          g l o b a l   p r o c e d u r e s
*/
i_format:
   procedure (number, width);
   declare number  fixed,
           width   fixed;
   declare l       fixed;
   i_string = number;
   l = length (i_string);
   if l < width then
         i_string = substr(x70,0,width-l) || i_string;
   end  i_format;
printline:
   procedure (line, ind);
   declare line character,             /*line to be printed */
           ind fixed;                  /*format indicator*/
   declare ctl(5) character initial ('0','1','','','','');
   declare skips (5) fixed initial (2,99,0,0,0,0);
   if line_count > PAGE_MAX then
      do;
         page_count = page_count + 1;
         output(1) = title || page_count;
         output = subtitle;
         output = ' ';
         line_count = 0;
      end;
   if ind < 0 | ind > 5 then
      do;
         output = line;
         line_count = line_count + 1;
      end;
   else
      do;
         output(1) = ctl(ind) || line;
         line_count = line_count + skips(ind);
      end;
end printline;
   error:
      procedure (msg, severity);
   /* print the error message with a pointer pointing to the current token
      being scanned.  if source listing is disabled, also print the current
      source image.
   */
      declare msg character, severity fixed;
      declare i fixed;
      error_count = error_count + 1;
      if control(byte('L')) = 0 then
         do;
            i = 5 - length(card_count);
            call printline (substr (x70, 0, i) || card_count || x4 || buffer,-1);
         end;
      call printline (substr(pointer,length(pointer)-7-
            (line_length+cp-text_limit-lb-1)),-1);
      output(-1) = card_count || x4 || buffer;
      output(-1) = x7 || msg;
      if previous_error > 0 then
         msg = msg || '. last previous error was on line ' || previous_error;
      call printline ('*** error. ' || msg,-1);
      previous_error = card_count;
      if severity > 0 then
         if severe_errors > 25 then
            do;
                call printline ('*** too many severe errors, compilation aborted ***',0);
                compiling = FALSE;
             end;
           else severe_errors = severe_errors + 1;
   end error;
   /*                the scanner procedures              */
   build_bcd:
      procedure (c);
      declare c bit(9);
      if length(bcd) > 0 then bcd = bcd || x1;
      else bcd = substr(x1 || x1, 1);
      corebyte(freepoint-1) = c;
   end build_bcd;
   get_card:
      procedure;
      /* does all card reading and listing                                 */
      declare i fixed, tempo character, temp2 character;
      if lb ~= 0 then
         do;
            if cp >= 255 then
               do;
                  text = substr(text, lb);
                  cp = cp - lb;
                  call error ('identifier too long', 0);
               end;
               if lb > 255 - cp then i = 255 - cp;
               else i = lb;
               lb = lb - i;
               text = text || substr(balance, 0, i);
               balance = substr(balance, i);
               text_limit = length(text) - 1;
               return;
         end;
      expansion_count = 0;    /* checked in scanner  */
      if reading then   /* reading is FALSE initially, to read library */
         do;
            buffer = input;
            if length(buffer) = 0 then
               do;
                  call error ('eof missing', 0);
                  buffer = ' /* '' /* */ eof; end; eof; end; eof';
               end;
            else card_count = card_count + 1;
         end;
      else
         do;
            buffer = input(LIBFILE);
            if length(buffer) = 0 then
               do;
                  reading = TRUE;
                  buffer = input;
                  card_count = card_count + 1;
                  statement_count = 0;
                  control(byte('L')) = TRUE & ~ control(byte('K'));
               end;
         end;
      line_length = length (buffer);
      if cp + length(buffer) > 255 then
         do;
            i = 255 - cp;
            text = text || substr(buffer, 0, i);
            balance = substr(buffer, i);
            lb = length(balance);
         end;
      else text = text || buffer;
      text_limit = length(text) - 1;
      if control(byte('M')) then call printline(buffer,-1);
      else if control(byte('L')) then
         do;
            tempo = card_count;
            i = 5 - length (tempo);
            tempo = substr(x70, 0, i) || tempo || x2 || buffer;
            i = 88 - length(tempo);
            if i >= 70 then
               do;
                  i = i - 70;
                  tempo = tempo || x70;
               end;
            if i > 0 then tempo = tempo || substr(x70, 0, i);
            temp2 = current_procedure || info;
            if control(byte('F')) then
                   temp2 = x2 || pp || x1 || dp || x1 || dsp || temp2;
            if length (temp2) > 44 then temp2 = substr (temp2,0,44);
            call printline (tempo || temp2,-1);
         end;
      info = '';           /* clear information buffer */
   end get_card;
   char:
      procedure;
      cp = cp + 1;
      if cp <= text_limit then return;
      cp = 0;
      text = '';
      call get_card;
   end char;
   deblank:
      procedure;
      call char;
      do while byte (text, cp) = byte (' ');
         call char;
      end;
   end deblank;
   bchar:
      procedure;
      do FOREVER;
         call deblank;
         ch = byte(text, cp);
         if ch ~= byte ('(') then return;
         /*  (base width)  */
          call deblank;
         jbase = byte (text, cp) - byte ('0');  /* width */
         if jbase < 1 | jbase > 4 then
            do;
               call error ('illegal bit string width: ' || substr(text,cp,1),0);
               jbase = 4;  /* default width for error */
            end;
         base = shl(1, jbase);
         call deblank;
        if byte(text,cp)~=byte(')')then call error('missing ) in bit string',0);
      end;
   end bchar;
   scan:
      procedure;     /* get the next token from the text  */
      declare s1 fixed, s2 fixed;
   declare lstrngm character initial ('string too long');
   declare lbitm character initial ('bit string too long');
    count_scan = count_scan + 1;
      failsoft = TRUE;
      bcd = '';  number_value = 0;
   rescan:
      if cp > text_limit then
         do;
            text = '';
            call get_card;
         end;
      else
         do;
            text_limit = text_limit - cp;
            text = substr(text, cp);
         end;
      cp = 0;
   /*  branch on next character in text                  */
      do case chartype(byte(text));
         /*  case 0  */
         /* illegal characters fall here  */
         call error ('illegal character: ' || substr (text, 0, 1), 0);
         /*  case 1  */
         /*  blank  */
         do cp = 1 to text_limit;
            if byte (text, cp) ~= byte (' ') then goto rescan;
         end;
         /*  case 2  */
         do FOREVER;   /* string quote ('):  character string       */
            token = string;
            do cp = cp + 1 to text_limit;
               if byte (text, cp) = byte ('''') then
                  do;
                     if length(bcd) + cp > 257 then
                        do;
                           call error (lstrngm, 0);
                           return;
                        end;
                     if cp > 1 then
                     bcd = bcd || substr(text, 1, cp-1);
                     call char;
                      if byte (text, cp) = byte ('''') then
                         if length(bcd) = 255 then
                           do;
                             call error (lstrngm, 0);
                             return;
                           end;
                        else
                           do;
                              bcd = bcd || substr(text, cp, 1);
                              go to rescan;
                           end;
                     return;
                  end;
            end;
            /*  we have run off a card  */
            if length(bcd) + cp > 257 then
               do;
                 call error (lstrngm, 0);
                 return;
               end;
            if cp > 1 then bcd = bcd || substr(text, 1, cp-1);
            text = x1;
            cp = 0;
            call get_card;
         end;
         /*  case 3  */
         do;      /*  bit quote("):  bit string  */
            jbase = 4;  base = 16;  /* default width */
            token = number;
            s1 = 0;
            call bchar;
            do while ch ~= byte ('"');
               s1 = s1 + jbase;
               if ch >= byte ('0') & ch <= byte ('9') then s2 = ch - byte ('0');
               else s2 = ch + 10 - byte ('a');
               if s2 >= base | s2 < 0 then
                  call error ('illegal character in bit string: '
                  || substr(text, cp, 1), 0);
               if s1 > 36 then token = string;
               if token = string then
                  do while s1 - jbase >= 9;
                     if length(bcd) >= 255 then
                        do;
                           call error ( lbitm, 0);
                           return;
                        end;
                     s1 = s1 - 9;
                     call build_bcd (shr(number_value, s1-jbase));
                  end;
               number_value = shl(number_value, jbase) + s2;
               call bchar;
            end;     /* of do while ch...  */
            cp = cp + 1;
            if token = string then
               if length(bcd) >= 255 then call error (lbitm,0);
               else call build_bcd (shl(number_value, 9 - s1));
             return;
         end;
         /*  case 4  */
         do FOREVER;   /*  a letter:  identifiers and reserved words  */
            do cp = cp + 1 to text_limit;
               if not_letter_or_digit(byte(text, cp)) then
                  do;  /* end of identifier  */
                     bcd = substr(text, 0, cp);
                     if cp > 1 then if cp <= reserved_limit then
                        /* check for reserved words */
                        do i = 1 to TERMINAL#;
                           if bcd = vocab(i) then
                              do;
                                 token = i;
                                 return;
                              end;
                        end;
                     do i = macro_index(cp-1) to macro_index(cp) - 1;
                        if bcd = macro_name(i) then
                           do;
                            macro_count(i) = macro_count(i) + 1;
                              bcd = macro_text(i);
                              if expansion_count < EXPANSION_LIMIT then
                                 expansion_count = expansion_count + 1;
                              else call printline ('** warning, too many expansions for
 the macro: ' || bcd,-1);
                              text = substr(text, cp);
                              text_limit = text_limit - cp;
                              if length(bcd) + text_limit > 255 then
                                 do;
                                    if lb + text_limit > 255 then
                                       call error('macro expansion too long',0);
                                    else
                                       do;
                                          balance = text || balance;
                                          lb = length(balance);
                                          text = bcd;
                                       end;
                                 end;
                              else text = bcd || text;
                              bcd = '';
                              text_limit = length(text) - 1;
                              cp = 0;
                              go to rescan;
                           end;
                     end;
                     /*  reserved words exit higher:  therefore <identifier> */
                     token = ident;
                     return;
                  end;
            end;
            /*  end of card  */
            call get_card;
            cp = cp - 1;
         end;
         /*  case 5  */
          do FOREVER;   /*  digit:  a number  */
            token = number;
            do cp = cp to text_limit;
               s1 = byte(text, cp);
               if s1 < byte ('0') | s1 > byte ('9') then return;
               number_value = 10 * number_value + s1 - byte ('0');
            end;
            call get_card;
         end;
         /*  case 6  */
         do;      /*  a /:  may be divide or start of comment  */
            call char;
            if byte (text, cp) ~= byte ('*') then
               do;
                  token = divide;
                  return;
               end;
            /* we have a comment  */
            s1, s2 = byte (' ');
            do while s1 ~= byte ('*') | s2 ~= byte ('/');
               if s1 = byte ('$') then /* a control char */
                    control(s2) = ~control(s2) & 1;
               s1 = s2;
               call char;
               s2 = byte(text, cp);
            end;
         end;
         /*  case 7  */
         do;      /*  SPECIAL characters  */
            token = tx(byte(text));
            cp = 1;
            return;
         end;
         /*  case 8  */
         do;   /* a |:  may be  |  or  ||  */
            call char;
            if byte(text, cp) = byte('|') then
               do;
                  call char;
                  token = concatenate;
               end;
            else token = orsymbol;
            return;
         end;
      end;     /* of case on chartype  */
      cp = cp + 1;  /* advance scanner and resume search for token  */
      go to rescan;
   end scan;
   /*
            c o d e   e m i s s i o n   p r o c e d u r e s
 */
flush_data_buffer:
   procedure;
      /* clean out the data buffer and stick all current contents
         into the rel file */
      declare i fixed, j fixed;
      if (dptr+dctr) > 1 then
         do;
            j = (dptr/19)*18 + dctr -1;
            file(RELFILE) = CODE_TYPE + j;
            i = dptr+dctr-1;
            do j = 0 to i;
               file(RELFILE) = data_buffer(j);
               end;
         end;
      dptr = 0;
      dctr = 1;
   end flush_data_buffer;
flush_code_buffer:
   procedure;
      /* clean out the code buffer and stick all current contents
         into the rel file */
      declare i fixed, j fixed;
      if (rptr+rctr) > 1 then
         do;
            i = (rptr/19)*18 + rctr -1;
            j = rptr+rctr-1;
            file (RELFILE) = CODE_TYPE+i;
            do i = 0 to j;
               file(RELFILE) = code_buffer(i);
               end;
         end;
      rptr = 0;
      rctr = 1;
   end flush_code_buffer;
radix50:
   procedure (symbol);
   /* procedure to return the radix-50 representation of a symbol.
      only the first 6 characters are used. */
   declare symbol character;
   declare (i,j,k,l) fixed;
   j = 0;
   if length(symbol) < 6 then symbol = symbol || x7;
   do l = 0 to 5;
      i = byte(symbol,l);
      if i = byte(' ') then k = 0;
         else if i = byte ('.') then k = "(3)45";
         else if i = byte ('$') then k = "(3)46";
         else if i = byte ('%') then k = "(3)47";
         else if i >= byte ('0') & i <= byte ('9') then
                    k = i-byte('0') + "(3)1";
         else if i >= byte ('a') & i <= byte ('z') then
                    k = i - byte ('a') + "(3)13";
         else return j;
      j = j * "(3)50" + k;
      end;
   return j;
   end radix50;
output_codeword:
   procedure;
   /* spit out the instruction at codexxx(code_tail) */
   if code_full(code_tail) then
      do;
         if control(byte('A')) then output (CODEFILE) = code (code_tail);
         if rctr+rptr = 1 then
            do;
               code_buffer(0) =shl(1,34);
               code_buffer(1) = code_pp(code_tail) + "(3)400000";
               rctr = rctr +1;
            end;
         code_buffer(rptr) = shl(code_rbits(code_tail),36-rctr*2)|code_buffer(rptr);
         code_buffer(rptr+rctr) = code_rel(code_tail);
         rctr = rctr +1;
         if rptr+rctr > BUFFERSIZE then call flush_code_buffer;
         if rctr > 18 then
            do;
               rptr = rptr +19;
               rctr = 1;
               code_buffer(rptr) = 0;
            end;
      end;
   code_full(code_tail) = FALSE;
   code_tail = (code_tail+1) & 3;
   end output_codeword;
flush_labels:
   procedure;
      /* clean out label buffer by generating internal request
         type block and defining all labels now known */
      declare i fixed;
      if label_count = 0 then return;
      do while code_tail ~= code_head;
         call output_codeword;
         end;
      call output_codeword;
      code_tail = code_head;      /* reset pointers, since buffers now empty */
      stillcond, stillinzero = 0; /* make sure peephole works */
      call flush_code_buffer;
      file (RELFILE) = INTREQ_TYPE+label_count;
      do i = 0 to label_count;
         file (RELFILE) = label_buffer(i);
         end;
      label_count = 0;
      label_buffer(0) = 0;
   end flush_labels;
output_dataword:
   procedure (w,loc);
      /* output a word to the low segment */
      declare w  fixed, loc fixed;
      if (dptr+dctr)>BUFFERSIZE | dloc ~= loc then call flush_data_buffer;
      if dptr+dctr = 1 then
         do;
            data_buffer(0) = "(3)200000000000";
            data_buffer(1) = loc;
            data_buffer(2) = w;
            dloc = loc + 1;
            dctr = dctr + 2;
            return;
         end;
      data_buffer (dptr+dctr) = w;
      dctr = dctr +1;
      dloc = dloc + 1;
      if dptr+dctr > BUFFERSIZE then call flush_data_buffer;
      if dctr > 18 then
        do;
            dctr = 1;
            dptr = dptr + 19;
            data_buffer(dptr) = 0;
         end;
   end output_dataword;
flush_datacard:procedure;
      if control(byte('A')) | control(byte('B')) then
         do;
            datacard = datacard || '; d' || dp;
            if control(byte('A')) then output (DATAFILE) = datacard;
            if control(byte('B')) then call printline (datamsg || datacard,-1);
         end;
      call output_dataword (pword,dp);
      pword = 0;
      dpoffset = 0;
      dp = dp + 1;
end flush_datacard;
emitblock:
   procedure (i);
      /* reserve a block of i words */
      declare i fixed;
      if control(byte('A')) | control(byte('B')) then
         do;
            datacard = '       repeat ' || i || ',<0>; d' || dp;
            if control(byte('A')) then output (DATAFILE) = datacard;
            if control(byte('B')) then call printline (datamsg || datacard,-1);
         end;
      dp = dp + i;
end emitblock;
emitdataword:
   procedure (w);
      declare w fixed;
      /* send an 80 character card to the data file */
      if dpoffset > 0 then call flush_datacard;
      if control(byte('A')) | control(byte('B')) then
         do;
            datacard = x7 || w || '; d' || dp;
            if control(byte('A')) then output (DATAFILE) = datacard;
            if control(byte('B')) then call printline (datamsg || datacard,-1);
         end;
      call output_dataword(w,dp);
      dp = dp + 1;
end emitdataword;
emitbyte:
   procedure (c);
      declare c fixed;
      /* send one 9-bit byte to the data area */
      if control(byte('A')) | control(byte('B')) then
         if dpoffset = 0 then datacard = '       byte (9)'|| c;
         else datacard = datacard || ',' || c;
      pword = pword + shl(c&"(3)777",9*(3-dpoffset));
      dpoffset = dpoffset + 1;
      if dpoffset = 4 then call flush_datacard;
end emitbyte;
emitconstant:
   procedure (c);
      declare c fixed;
      declare ctab (100) fixed, cadd (100) fixed, nc fixed, i fixed;
      /* see if c has already been emited, and if not, emit it.  set up adr.  */
      do i = 1 to nc;                  /* step thru the constants */
         if ctab (i) = c then
            do;
               adr = cadd (i);
               return;
            end;
      end;
      ctab (i) = c;
      call emitdataword (c);
      adr, cadd (i) = dp - 1;
      if i < 100 then nc = i;
      if control(byte('C')) then call printline ('* CONSTANT ' || nc || ' = ' || c,-1);
         else if control(byte('L')) then info=info|| ' c'|| nc ||' = ' || c;
end emitconstant;
emitcodeword:procedure (w,word,rbits);
       declare w character;
      declare word fixed;
      declare rbits fixed;
      /* send an 80 character code card to the buffer area */
      code_head = (code_head+1) & 3;
      if code_head = code_tail then call output_codeword;
      if control(byte('A')) | control(byte('E')) then
            code(code_head) = label_gen || w;
      if control(byte('E')) then
            call printline (codemsg || code(code_head),-1);
      code_rel(code_head) = word;
      code_pp(code_head) = pp;
      code_rbits(code_head) = rbits;
      code_full(code_head) = TRUE;
      label_gen = '';
      stillcond, stillinzero = 0;
      pp = pp + 1;
end emitcodeword;
outputlabel:
   procedure (j);
   declare j fixed;
   label_count = label_count+1;
   label_buffer(0) = shl(3,36-label_count*2)|label_buffer(0);
   label_buffer(label_count) = j;
   if(label_count >= BUFFERSIZE) then call flush_labels;
   end outputlabel;
emitlabel:procedure(l,r);
      declare l fixed;
      declare r fixed;
      declare i fixed;
      declare j fixed;
      if r = 3 then
         do;
            if descref(l) = 0 then return;
            j = shl(descref(l),18) + dp;
            call outputlabel(j);
            descref(l) = 0;
            return;
         end;
      stillinzero = 0;    /* don't try optimizing over label */
      j = shl(r,18) + l;
      do i = 1 to for_count;
         if j = for_label(i) then
            do;
               j = shl(for_ref(i)+"(3)400000",18);
               if r = 4 then j = j + pp + "(3)400000";
                        else j = j + dp;
               call outputlabel(j);
               j = i;
               do while j < for_count;
                  for_label(j) = for_label(j+1);
                  for_ref(j) = for_ref(j+1);
                  j = j + 1;
               end;
               for_label(for_count) = 0;
               for_ref(for_count) = 0;
               for_count = for_count -1;
               /* put a label on the next instruction generated */
               if r = 4 & (control(byte('A')) | control(byte('E'))) then
                            label_gen = label_gen || '$' || l || ':';
               return;
            end;
      end;
      if r = 4 & (control(byte('A')) | control(byte('E'))) then
          label_gen = label_gen || '$' || l || ':';
      return;
end emitlabel;
refcheck:
   procedure (i);
      /* check to see if this satisfies any forward references.
         if so, set up label buffer.  if not, check if this
         should be chained. */
      declare i fixed;
      declare j fixed;
      if shr(i,18) = 3 then
         do;
            i = i & "(3)777777";
            j = descref(i);
            descref(i) = pp + "(3)400000";
            return j;
         end;
      j = 1;
      do while j <= for_count;
         if for_label(j) = i then
            do;
               i = for_ref(j) + "(3)400000";
               for_ref(j) = pp;
               return i;
            end;
         j=j+1;
      end;
      for_count = for_count +1;
      if for_count > FOR_MAX then call error ('too many forward references',3);
      for_ref(for_count) = pp;
      for_label(for_count) = i;
      return 0;
   end refcheck;
emitinst:procedure (opcode,treg,indirect,operand,ireg,relocation);
      declare opcode fixed,
              treg fixed,
              indirect fixed,
              operand fixed,
              ireg fixed,
              relocation fixed;
      declare rbits fixed,
              word fixed;
      /* emit a 80 character instruction image */
      declare reloc (5) character
              initial ('', 'd+', 'p+', 's+', '$', '$');
      declare i fixed,
              j fixed,
              card character,
              indir (1) character initial ('', '@');
      count_inst = count_inst + 1;
      word = shl(opcode,27) + shl(treg&"f",23) + shl(indirect&1,22)
             + shl(ireg&"f",18);
      do case relocation;
         /* case 0 : absolute address - no relocation */
         do;
            word = word + (operand&"(3)777777");
            rbits = 0;
         end;
 
         /* case 1 : relative to the beginning of data segment */
         do;
            word = word + (operand&"(3)777777");
            rbits = 1;
         end;
 
         /* case 2 : relative to beginning of code segment */
         do;
            word = word + (operand&"(3)777777") + "(3)400000";
            rbits = 1;
         end;
 
         /* case 3 : relative to beginning of strings */
         do;
            i = shl(relocation,18) + (operand&"(3)777777");
            j = refcheck(i);
            word = word + j;
            if j = 0 then rbits = 0;
                     else rbits = 1;
         end;
 
         /* case 4 : forward label reference in code area */
         do;
            j = refcheck("(3)4000000" + (operand&"(3)777777"));
            word = word + j;
            if j = 0 then rbits = 0;
                     else rbits = 1;
         end;
 
         /* case 5 : forward label reference in data area */
         do;
            j = refcheck("(3)5000000" + (operand&"(3)777777"));
            word = word + j;
            if j = 0 then rbits = 0;
                     else rbits = 1;
         end;
      end;  /* end of do case relocation */
 
      if control(byte('A')) | control(byte('E')) then
         do;
            i = shr(opcode,5);
            card = x7 || substr(opname(i),(opcode-i*32)*6,6) || x1 ||treg || ','
                   || indir(indirect) || reloc(relocation) || operand;
            if ireg > 0 then card = card || '(' || ireg || ')';
            card = card || '; p' || pp;
         end;
      instruct(opcode) = instruct(opcode) + 1;
      call emitcodeword (card,word,rbits);
end emitinst;
emitdesc:procedure (l,a);
      declare l fixed,
              a fixed;
      /* send a length and string address to the descriptor area */
      if dsp > DESCLIMIT then
         do;
            call error ('too many strings',1);
            dsp = 0;
         end;
       if control(byte('B')) then
         call printline (x70 || 'desc =        ' || l || ',' || a || '; s' || dsp,-1);
      descl(dsp) = l;
      desca(dsp) = a;
      dsp = dsp + 1;
end emitdesc;
findlabel:procedure;
      label_sink = label_sink + 1;
      return (label_sink);
end findlabel;
 /*
           s y m b o l   t a b l e   p r o c e d u r e s
 */
 
hasher:
   procedure (id);          /* calculate hash index into hash table*/
   declare id   character;
   declare l    fixed;
   l = length (id);
   return (byte (id) + byte (id, l-1) + shl (l,4)) & "ff";
   end hasher;
enter:procedure (n, t, l, s);
      declare t fixed, l fixed, s fixed;
      declare n character;
 /* enter the name n in the symbol table with type t at location l segment s */
      declare i fixed, k fixed;
      idx = hasher (n);
      i = hash (idx);
      do while i >= procmark;
         idcompares = idcompares + 1;
         if n = syt (i) then
            do;
               k = sytype (i);
               if t = LABELTYPE & (k = FORWARDTYPE | k = FORWARDCALL) then
                  do;
                     if control (byte ('E')) then
                        call printline (x70 || 'fixed references to: ' || n,-1);
                     if k = FORWARDTYPE then
                        do;
                           call emitlabel(sytloc(i),4);
                           sytloc(i) = l;
                           sytseg(i) = s;
                        end;
                     sytype (i) = t;
                  end;
               else if procmark + parct < i then
                  call error ('duplicate declaration for: ' || n, 0);
               return i;
            end;
         i = ptr (i);
      end;
      ndecsy = ndecsy + 1;
      if ndecsy > maxndecsy then
         if ndecsy > SYTSIZE then
            do;
               call error ('symbol table overflow', 1);
               ndecsy = ndecsy - 1;
            end;
         else maxndecsy = ndecsy;
      syt (ndecsy) = n;
      sytype (ndecsy) = t;
      sytloc (ndecsy) = l;
      sytseg (ndecsy) = s;
      sytco (ndecsy) = 0;
      sytcard (ndecsy) = card_count;
      ptr (ndecsy) = hash (idx);
      hash (idx) = ndecsy;
      return (ndecsy);
end enter;
 id_lookup:
   procedure (p);
      /* looks up the identifier at p in the analysis stack in the
         symbol table and initializes fixl, cnt, type, and inx
         appropriately.  if the identifier is not found, fixl is
         set to -1
      */
      declare p fixed, i fixed;
      char_temp = var (p);
      i = hash (hasher (char_temp));
      do while i ~= -1;
         idcompares = idcompares + 1;
         if syt(i) = char_temp then
            do;
               fixl (p) = i;
               cnt (p) = 0;        /* initialize subscript count */
               type (p) = VARIABLE;
               if sytype (i) = SPECIAL then
                  fixv (p) = sytloc (i);    /* builtin function */
               else
                  fixv (p) = 0;
               inx (p) = 0;       /* location of index */
               reg(p) = 0;
               sytco (i) = sytco (i) + 1;
               return;
            end;
         i = ptr (i);
      end;
      fixl (p) = -1;              /* identifier not found */
end id_lookup;
undeclared_id:
   procedure (p);
      /* issues an error message for undeclared identifiers and
         enters them with default type in the symbol table
     */
      declare p fixed;
      call error ('undeclared identifier: ' || var (p), 0);
      call emitdataword (0);
      fixl (p) = enter (var (p), FIXEDTYPE, dp-1, 1);
      cnt (p) = 0;
      fixv (p) = 0;
      inx (p) = 0;
      sytco (ndecsy) = 1;            /* count first reference */
      sytcard (ndecsy) = -1;         /* flag undeclared identifier */
      type (p) = VARIABLE;
end undeclared_id;
 /*
        a r i t h e m e t i c   p r o c e d u r e s
 */
clearars:
   procedure;
      /* free all the temproary arithemetic registers */
      do i = 0 to 11;
         acc(i) = AVAIL;
      end;
end clearars;
findar:
   procedure;
       declare i fixed;
      /* get a temporary arithemetic register */
      if target_register > -1 then
         if acc (target_register) = AVAIL then
            do;
               acc (target_register) = BUSY;
               return target_register;
            end;
      do i = 1 to 11;
         if acc(i) = AVAIL then
            do;
               acc(i) = BUSY;
               return (i);
            end;
      end;
      call error ('used all accumulators', 0);
      return (0);
end findar;
movestacks:
   procedure (f, t);
      declare f fixed, t fixed;
      /* move all compiler stacks down from f to t */
      type (t) = type (f);
      reg (t) = reg (f);
      cnt (t) = cnt (f);
      var (t) = var (f);
      fixl (t) = fixl (f);
      fixv (t) = fixv (f);
      inx (t) = inx (f);
      ppsave (t) = ppsave (f);
end movestacks;
forceaddress:
   procedure(sp);
      /* generates the address of <VARIABLE> in the analysis stack
         at sp.
      */
      declare sp fixed, j fixed, r fixed;
      r = findar;
      j = fixl(sp);
      call emitinst (movei,r,0,sytloc(j),0,sytseg(j));
      reg(j) = r;
end forceaddress;
setinit:
   procedure;
      /* places initial values into data area */
      declare tmiiil character initial ('too many items in initial list');
      if itype = CHRTYPE then
         do;
            if dsp < newdsp then
               do;
                  if type (mpp1) ~= CHRTYPE then s = fixv (mpp1);
                  else s = var (mpp1);     /* the string */
                  i = length (s);
                  if i = 0 then
                     call emitdesc (0,0);
                  else
                     do;
                        call emitdesc (i, dpoffset+shl(dp,2));
                        do j = 0 to i - 1;
                           call emitbyte (byte (s, j));
                        end;
                      end;
               end;
            else call error (tmiiil,0);
         end;
      else
         if type (mpp1) ~= CONSTANT then
            call error ('illegal CONSTANT in initial list',0);
         else
            if itype = FIXEDTYPE then
               do;
               if dp < newdp then call emitdataword (fixv(mpp1));
               else call error (tmiiil,0);
               end;
            else   /* must be BYTETYPE */
               if dp < newdp | (dp = newdp & dpoffset < newdpoffset) then
                  call emitbyte(fixv(mpp1));
               else call error (tmiiil,0);
end setinit;
save_acs:
   procedure (n);
      /* generate code to save BUSY acs, up to ac-n */
      declare n fixed;
      declare i fixed;
      do i = 1 to n;
         if (acc(i) = BUSY) then call emitinst (push,15,0,i,0,0);
      end;
end save_acs;
restore_acs:
   procedure (n);
      /* generate code to restore BUSY acs, up to ac-n  */
      declare n fixed;
      declare i fixed, j fixed;
      do i = 1 to n;
         j = n - i + 1;
         if (acc(j) = BUSY) then call emitinst (pop,15,0,j,0,0);
      end;
end restore_acs;
proc_start:
   procedure;
      /* generates code for the head of a procedure */
      ppsave(mp) = findlabel;           /* something to goto */
      call emitinst (jrst,0,0,ppsave(mp),0,4); /* go around proc */
      if sytseg(fixl(mp)) = 4 then call emitlabel(sytloc(fixl(mp)),4);
      sytseg(fixl(mp)) = 2;
      sytloc(fixl(mp)) = pp;            /* addr of proc */
end proc_start;
tdeclare:
   procedure (dim);
   /* allocates storage for identifiers in declaration */
      declare dim fixed;
      declare i   fixed;
   allocate:
      procedure (p, dim);
         /* allocates storage for the identifier at p in the analysis
            stack with dimension dim
         */
         declare p fixed, dim fixed, j fixed, k fixed;
         dim = dim + 1;                    /* actual number of items */
         do case type (p);
            ;    /*  case 0 -- dummy */
            ;    /*  case 1 -- label type */
            ;    /*  case 2 -- ACCUMULATOR */
            ;    /*  case 3 -- VARIABLE */
            ;    /*  case 4 -- CONSTANT */
            ;    /*  case 5 -- condition */
            do;   /* case 6 -- CHRTYPE */
               j = dsp; k = 3;
               newdsp = dsp + dim;
            end;
            do;  /*  case 7 -- FIXEDTYPE */
               if dpoffset > 0 then
                  do;
                     call flush_datacard;
                     olddp = dp;
                     olddpoffset = 0;
                  end;
               j = dp; k = 1;
               newdp = dp + dim; newdpoffset = 0;
            end;
            do;  /*  case 8 -- BYTETYPE */
               if dpoffset > 0 then
                  if i = 1 then 
                     do;
                        call flush_datacard;
                        olddp = dp; olddpoffset = 0;
                     end;
                  else
                     do;
                        dp = dp + 1; dpoffset = 0;
                     end;
               newdpoffset = dim mod 4;
               newdp = dp + dim/4;
               j = dp; k = 1;
            end;
            do;  /*  case 9 -- FORWARDTYPE */
               j = findlabel; k = 4;
               newdp = dp; newdpoffset = dpoffset; /* copy old pointers  */
            end;
            ;    /*  case 10 -- DESCRIPT */
            ;    /*  case 11 -- SPECIAL */
            ;    /*  case 12 -- FORWARDCALL */
            ;    /*  case 13 -- PROCTYPE */
            ;    /*  case 14 -- CHARPROCTYPE */
         end; /* case on type (p) */
         sytype (fixl(p)) = type (p);
         sytloc (fixl (p)) = j;
         sytseg (fixl (p)) = k;
   end allocate;
      olddp = dp;
      olddsp = dsp;
      olddpoffset = dpoffset;
      type(mp) = type(sp);
      casep = fixl(mp);
      do i = 1 to inx(mp);
         fixl(mp) = casestack(casep+i); /* symbol table pointer */
         call allocate (mp,dim);
         dp = newdp;
         dsp = newdsp;
         dpoffset = newdpoffset;
         end;
      dp = olddp;
      dsp = olddsp;
      dpoffset = olddpoffset;
end tdeclare;
check_string_overflow:
   procedure;
      /* generate a check to see if compactify needs to be called */
      call emitinst (pushj,15,0,string_check,0,2);
end check_string_overflow;
callsub:procedure (sl,f,p);
      /* generates code to call a function or procedure at sl
         also does housekeeping for return values
      */
      declare sl fixed, f fixed, p fixed;
      call save_acs (11);
      call emitinst (pushj,15,0,sl,0,sytseg(fixl(p)));
      call restore_acs (11);
      if f = 1 then
         do;  /* move returned value from register zero */
            i = findar;
            if i ~= 0 then call emitinst (move,i,0,0,0,0);
            type(p) = ACCUMULATOR;
            reg(p) = i;
            acc(i) = BUSY;
            stillinzero = i;
         end;
end callsub;
backup:
   procedure;
         code_full(code_head) = FALSE;
         code_head = (code_head-1) & 3;
         instruct(move) = instruct(move) -1;
         pp = pp - 1;
         stillinzero = 0;
         if control(byte('E')) then
            call printline (backmsg,-1);
   end backup;
delete_move:
   procedure (p,op,ac,ind,operand,index,reloc);
   /*  check stillinzero flag to see if the datum about to
        be moved is still in register zero.  if so, then delete 
        the last instruction generated (if a "move"),
        and move it directly from 0 to the desried dest.
        this is designed to eliminate most extra moves
        of function results. */
      declare p fixed;
      declare op fixed, ac fixed, ind fixed, operand fixed,
           index fixed, reloc fixed;
      if stillinzero ~= 0 then
         do;
            if op = movem & stillinzero = ac then
               do;
                  call backup;
                  acc(reg(p)) = AVAIL;
                  reg(p) = 0;
                  ac = 0;
               end;
            else if op = move  & stillinzero = operand
                               & (ind + index + reloc) = 0 then
               do;
                  call backup;
                  acc(reg(p)) = AVAIL;
                  reg(p) = 0;
                  operand = 0;
               end;
         end;
      call emitinst (op,ac,ind,operand,index,reloc);
   end delete_move;
emit_inline:
   procedure (flag);
   /* generate an arbitrary instruction specified by programmer */
      declare flag bit(1);
      declare fl fixed;
      declare inst(5) fixed;
      declare binlm character initial ('improper argument to inline');
      if cnt(mp) < 5 then
         do;
            if type(mpp1) = CONSTANT then inst(cnt(mp)-1) = fixv(mpp1);
            else call error (binlm,1);
            if flag then call error (binlm,1);
         end;
      else if cnt(mp) = 5 then
         do;
            if type(mpp1) = CONSTANT then
               do;
                  inst(4) = fixv(mpp1);
                  inst(5) = 0;
               end;
            else if type(mpp1) = VARIABLE then
               do;
                  fl = fixl(mpp1);
                  inst(4) = sytloc(fl);
                  inst(5) = sytseg(fl);
               end;
            else call error (binlm,1);
            call emitinst (inst(0),inst(1),inst(2),inst(4),inst(3),inst(5));
            reg(mp) = inst(1);
            type(mp) = ACCUMULATOR;
         end;
      else call error (binlm,1);  /* too many args to inline */
   end emit_inline;
library_call:   procedure (result, code, mp, sp);
   /*
   generate the code for a call to the run-time routines.
   */
   declare result fixed,   /* 0 = l.h.s. of = */
           code fixed,     /* code for run-time routine*/
           mp   fixed,     /* stack pointer */
           sp   fixed;     /* top of stack pointer */
   declare r    fixed;
   if result = 0 then
      do;
         if stillinzero = reg(sp) then
            do;
               call backup;
               acc(reg(sp)) = AVAIL;
               reg(sp) = 0;
            end;
         r = reg(sp);
      end;
   else
      r = findar;
   if cnt(mp) > 0 then call emitinst (code+1,r,0,0,reg(mp),0);
                  else call emitinst (code+1,r,0,0,0,0);
   if result ~= 0 then
      do;
         reg(mp) = r;
         type(mp) = result;
      end;
   end library_call;
monitor_call:   procedure (code, p, jobflg);
   /*
   routine to generate code for pdp-10 calli uuo.
   */
   declare code  fixed,    /* calli number */
          jobflg fixed,  /* clear ac flag */
           p     fixed;    /* stack pointer*/
   declare r     fixed;    /* contains register to use */
   r = findar;
   if jobflg then call emitinst (movei,r,0,0,0,0);
   call emitinst (calli,r,0,code,0,0);
   reg(p) = r;
   type(p) = ACCUMULATOR;
end monitor_call;
forceaccumulator:procedure (p);
      declare p fixed;
      /* force the operand at p into an ACCUMULATOR */
      declare sl fixed, tp fixed, sfp fixed, ss fixed;
      declare t1 character;
      declare r fixed;
      count_force = count_force + 1;
      tp = type(p);
      if tp = VARIABLE then
          do;
            sl = sytloc(fixl(p));
            ss = sytseg(fixl(p));
            sfp = sytype(fixl(p));
            if sfp = PROCTYPE | sfp = FORWARDCALL | sfp = CHARPROCTYPE then
               do;
                  call callsub (sl,calltype,p);
                  r = fixl(p)+cnt(p)+1;
                  if length(syt(r)) = 0 then
                     if r <= ndecsy then
                        call printline ('** warning--not all parameters supplied.',-1);
                  if sfp = CHARPROCTYPE then type(p) = DESCRIPT;
               end;
            else if sfp = SPECIAL then
               do;
                  if sl = 6 then
                     do;  /* builtin function input */
                        call check_string_overflow;
                        call emitinst (move,13,0,tsa,0,1);
                        call library_call (DESCRIPT,1,p,0);
                        call emitinst (movem,13,0,tsa,0,1);
                        call emitinst (movem,12,0,str,0,3);
                     end;
                  else if sl = 8 then
                     do;  /* built-in function file */
                      if cnt(p) ~= 1 then call error (filemsg,0);
                         else call library_call (ACCUMULATOR,5,p,0);
                     end;
                  else if sl = 12 then
                     do;  /* exit */
                        call emitinst (4,0,0,0,0,0);
                     end;
                  else if sl = 13 then call monitor_call (19,p,0);
                  else if sl = 14 then call monitor_call (12,p,0);
                  else if sl = 19 then call monitor_call (23,p,1);
                  else call error ('illegal use of ' || syt(fixl(p)),0);
               end;
            else
               do;  /* fetch the VARIABLE (all else has failed) */
                  if sfp ~= BYTETYPE then
                     do;   /* we don't have to do crazy addressing */
                        r = findar;     /* get reg for result */
                        call emitinst (move,r,0,sl,inx(p),ss);
                     end;
                  else
                     do;  /* byte addressing */
                        if inx(p) ~= 0 then
                           do; /* good grief, subscripting of bytes */
                              r = findar;
                              call emitinst (move,12,0,inx(p),0,0);
                              call emitinst (lsh,12,0,    -2,0,0);
                              call emitinst (andi,inx(p),0,3,0,0);
                              if (sl | ss) ~= 0 then call emitinst (addi,12,0,sl,0,ss);
                              call emitinst (ldb,r,0,byteptrs,inx(p),1);
                           end;
                         else
                           do; /* non-subscripted byte */
                              r = findar;
                              call emitinst (movei,12,0,sl,0,ss);
                              call emitinst (ldb,r,0,byteptrs,0,1);
                           end;
                     end;
                  if sfp = CHRTYPE then type(p) = DESCRIPT;
                  else type(p) = ACCUMULATOR;
                  reg(p) = r;
                  if inx(p) ~= 0 then acc(inx(p)) = AVAIL;
               end;
         end;
      else if tp = CONSTANT then
         do;  /* fetch a CONSTANT into an ACCUMULATOR */
            r = findar;
            if fixv(p) < "20000" & fixv(p) > - "20000" then
               call emitinst (hrrei,r,0,fixv(p),0,0);
            else
               do;  /* put down a CONSTANT and pick it up */
                  call emitconstant (fixv(p));
                  call emitinst (move,r,0,adr,0,1);
               end;
            reg(p) = r;
            type(p) = ACCUMULATOR;
         end;
      else if tp = CHRTYPE then
         do;  /* fetch a descriptor into an ACCUMULATOR */
            r = findar;
            type(p) = DESCRIPT;
            reg(p) = r;
            t1 = var(p);
            sl = length(t1);
            if sl = 0 then call emitinst (movei,r,0,0,0,0);
            else
               do;  /* generate descriptor and string, then pick it up */
                  call emitinst (move,r,0,dsp,0,3);
                  call emitdesc (sl,shl(dp,2)+dpoffset);
                  do sl = 0 to sl-1;
                     call emitbyte (byte(t1,sl));
                  end;
               end;
         end;
      else if tp ~= ACCUMULATOR then if tp ~= DESCRIPT then
               call error ('forceaccumulator failed ***',1);
end forceaccumulator;
forcedescriptor:
   procedure (p);
      /* get a descriptor for the operand p */
      declare p fixed;
      call forceaccumulator (p);
      if type (p) ~= DESCRIPT then
         do; /* use the number to decimal string conversion routine */
            call delete_move (p,movem,reg(p),0,c,0,1);  /* save as c */
            acc(reg(p)) = AVAIL;
            call save_acs (1);
            call emitinst (pushj,15,0,nmbrentry,0,2);
            call restore_acs (1);
            acc(reg(p)) = BUSY;
            if reg(p) ~= 0 then call emitinst (move,reg(p),0,0,0,0);
            type (p) = DESCRIPT;             /* it is now a string */
            stillinzero = reg(p);
         end;
end forcedescriptor;
genstore:procedure (mp, sp);
      declare mp fixed, sp fixed;
      /* generate type conversion (if necessary) & storage code --
         also handles output on the left of the replacement operator
      */
      declare sl fixed, sfp fixed, ss fixed;
      count_store = count_store + 1;
      sl = sytloc(fixl(mp));
      ss = sytseg(fixl(mp));
      sfp = sytype(fixl(mp));
      if sfp = SPECIAL then
         do;
            if sl = 7 then
               do;  /* builtin function output */
                  call forcedescriptor(sp);
                  call library_call (0,2,mp,sp);
               end;
            else if sl = 8 then
               do;   /* builtin function file */
                  if cnt(mp) ~= 1 then
                     call error (filemsg,0);
                  call forceaccumulator (sp);
                  call library_call (0,6,mp,sp);
               end;
            else if sl = 20 then
               do;    /* built-in function  filename */
                  call forcedescriptor(sp);
                  call library_call (0,7,mp,sp);
               end;
            else call error ('illegal use of ' || syt(fixl(mp)),0);
         end;
      else
         do;
            if sfp = CHRTYPE then
               do;
                  call forcedescriptor(sp);
                  call delete_move (sp,movem,reg(sp),0,sl,inx(mp),ss);
               end;
            else if type(sp) = DESCRIPT | type(sp) = CHRTYPE then
                 call error ('assignment requires illegal type conversion.',0);
            else
               do;     /* FIXEDTYPE or BYTETYPE */
                  if sfp = FIXEDTYPE then
                     do;
                     if type(sp) = CONSTANT & fixv(sp) = 0 then
                        call emitinst(setzm,0,0,sl,inx(mp),ss);
                        else
                           do;
                              call forceaccumulator(sp);
                              call delete_move (sp,movem,reg(sp),0,sl,inx(mp),ss);
                           end;
                     end;
                  else
                     do;      /* must be BYTETYPE */
                        call forceaccumulator(sp);
                        if inx(mp) ~= 0 then
                           do;  /* good grief, subscripting */
                               call emitinst (move,12,0,inx(mp),0,0);
                               call emitinst (lsh,12,0,    -2,0,0);
                               call emitinst (andi,inx(mp),0,3,0,0);
                               if (sl | ss) ~= 0 then call emitinst (addi,12,0,sl,0,ss);
                               call emitinst (dpb,reg(sp),0,byteptrs,inx(mp),1);
                           end;
                        else
                           do;
                               call emitinst (movei,12,0,sl,0,ss);
                               call emitinst (dpb,reg(sp),0,byteptrs,0,1);
                           end;
                     end;
               end;
         end;
      acc(inx(mp)) = AVAIL;
      call movestacks (sp,mp);
end genstore;
shouldcommute:procedure;
      if type(sp) = CONSTANT then return (FALSE);
      if type(mp) = CONSTANT then return (TRUE);
      if type(sp) = VARIABLE & sytype(fixl(sp)) = FIXEDTYPE then return (FALSE);
      if type(mp) = VARIABLE & sytype(fixl(mp)) = FIXEDTYPE then return (TRUE);
      return FALSE;
end shouldcommute;
arithemit:procedure(op,commutative);
   declare op fixed, commutative fixed, tp fixed;
   declare awasd character initial ('arithmetic with a string descriptor');
   /* emit an instruction for an infix operator -- connect mp & sp */
   count_arith = count_arith + 1;
   tp = 0;
   if commutative then
      if shouldcommute then
         do;
            tp = mp; mp = sp; sp = tp;
            if op >= cam & op <= cmprhi then op = compareswap(op-cam)+cam;
         end;
   call forceaccumulator(mp);  /* get the left one into an ACCUMULATOR */
   if type(mp) = DESCRIPT then call error (awasd,0);
   else if type(sp) = VARIABLE & sytype(fixl(sp)) = FIXEDTYPE then
      do;  /* operate from storage */
         call emitinst (op,reg(mp),0,sytloc(fixl(sp)),inx(sp),sytseg(fixl(sp)));
         acc(inx(sp)) = AVAIL;
      end;
   else if type(sp) = CONSTANT then
      do;
         if fixv(sp) < "40000" & fixv(sp) >= 0 then /* use immediate */
            do;
               if op >= cam & op <= cmprhi then op=op-9; /* sob code order */
                  call emitinst(op+1,reg(mp),0,fixv(sp),0,0);
            end;
         else
            do;
               call emitconstant (fixv(sp));
               call emitinst (op,reg(mp),0,adr,0,1);
            end;
      end;
   else
       do;
         call forceaccumulator(sp);
         if type(sp) ~= ACCUMULATOR then call error (awasd,0);
         else call emitinst (op,reg(mp),0,reg(sp),0,0);
         acc(reg(sp)) = AVAIL;
      end;
   if tp ~= 0 then
      do;
         sp = mp; mp = tp;
         call movestacks (sp,mp);
      end;
end arithemit;
boolbranch:procedure (sp,mp);
   declare sp fixed, mp fixed, r fixed;
   /* generate a conditional branch for do while or an if statement
      place the address of this branch in fixl(mp)
   */
   if stillcond ~= 0 then
      do;  /* we have not generated code since setting the condition */
         /* remove the movei =1 and movei =0 around the cam? */
         code_head = (code_head-2) &3; /* back up ptr */
         r = (code_head + 1) & 3;
         code(code_head) = code(r);
         code_rel(code_head) = code_rel(r);
         code_pp(code_head) = code_pp(r) -1;
         code_rbits(code_head) = code_rbits(r);
         code_full(r) = FALSE;
         code_full(r+1&3) = FALSE;
         pp = pp - 2;
         code(code_head) = code(code_head) || ' p' || pp-1;
         if control(byte('E')) then
            do;
               call printline (backmsg,-1);
               call printline (codemsg || code(code_head),-1);
            end;
         instruct(movei) = instruct(movei) - 2;
         acc(reg(sp)) = AVAIL;          /* free condition register */
         r = 4;                         /* jump always */
      end;
   else
      do;
         call forceaccumulator(sp);
         call emitinst (andi,reg(sp),0,1,0,0);  /* test only low order bit */
         acc(reg(sp)) = AVAIL;          /* free up VARIABLE register */
         r = 2;                         /* jump if register zero */
      end;
   fixl(mp) = findlabel;                /* get a new label */
   call emitinst (jump+r,reg(sp),0,fixl(mp),0,4);
end boolbranch;
setlimit:
   procedure;
      /* sets do loop limit for <iteration control> */
      if type (mpp1) = CONSTANT then
         call emitconstant (fixv(mpp1));
      else
         do;
            call forceaccumulator (mpp1);  /* get loop limit */
            call emitdataword (0);
            adr = dp - 1;
            call emitinst(movem,reg(mpp1),0,adr,0,1); /* save it */
            acc(reg(mpp1)) = AVAIL;
         end;
      fixv (mp) = adr;
 end setlimit;
stuff_parameter:
   procedure;
      /* generate code to send an actual parameter to a procedure */
      declare (i,j) fixed;
      i = fixl (mp) + cnt (mp);  j = sytloc (i);
      if length (syt(i)) = 0 then
         do;
            sytco (i) = sytco (i) + 1;  /* count the reference                */
               do;
                  if sytype(i) = BYTETYPE then
                    do;
                       call forceaccumulator(mpp1);
                       call emitinst (movei,12,0,j,0,sytseg(i));
                       call emitinst (dpb,reg(mpp1),0,byteptrs,0,1);
                    end;
                  else
                    do;
                       if type(mpp1) = CONSTANT & fixv(mpp1) = 0 then
                          do;
                             call emitinst (setzm,0,0,j,0,sytseg(i));
                             return;
                          end;
                       call forceaccumulator (mpp1);
                       call delete_move (mpp1,movem,reg(mpp1),0,j,0,sytseg(i));
                    end;
                  acc(reg(mpp1)) = AVAIL;
               end;
         end;
      else
         call error ('too many actual parameters', 1);
end stuff_parameter;
divide_code:procedure(t);
   declare t fixed, i fixed;
   /* emit code to perform a divide (t=1) or mod (t=0) */
   /* find a free register pair for the dividend */
   if type(mp) = ACCUMULATOR then
      do;   /* we may be able to use the register to the right */
         i = reg(mp);
         if acc(i+1) = AVAIL then goto fits;
      end;
   do i = t to 11;
      if acc(i) = AVAIL then if acc(i+1) = AVAIL then goto fit;
   end;
   call error ('no free registers for division or mod.',0);
   return;
fit:
   target_register = i;
   call forceaccumulator(mp);
   target_register = -1;
   if reg(mp) ~= i then
      do;
         call emitinst (move,i,0,reg(mp),0,0);
         acc(reg(mp)) = AVAIL;
         reg(mp) = i;
      end;
      acc(i) = BUSY;
 fits:
   acc(i+1) = BUSY;
   call arithemit (idiv,0);
   if t = 0 then
      do;  /* mod, switch register to point to remainder */
         acc(i) = AVAIL;                /* free quotient */
         reg(mp) = i+1;                 /* point to remainder */
      end;
   else acc(i+1) = AVAIL;               /* free remainder */
   if reg(mp) =12 then
      do;  /* transfer the mod remainder from a scratch register */
         i = findar;
         call emitinst (move,i,0,reg(mp),0,0);
         acc(reg(mp)) = AVAIL;
         reg(mp) = i;
      end;
end divide_code;
shift_code:
   procedure (op);
      declare op fixed;
      /* generate code for the builtin functions shl and shr */
      /* op: left = 0, right = 1 */
      sp = mpp1;
      if cnt (mp) ~= 2 then
         call error ('shift requires two arguments', 0);
      else
         if type (mpp1) = CONSTANT then
            do;
               if op = 1 then fixv(mpp1) = -fixv(mpp1);
               call emitinst(lsh,reg(mp),0,fixv(mpp1),0,0);
            end;
      else
         do;
            /* do shift with VARIABLE */
            call forceaccumulator(mpp1);
            if op = 1 then
                  call emitinst (movn,reg(mpp1),0,reg(mpp1),0,0);
            call emitinst (lsh,reg(mp),0,0,reg(mpp1),0);
            acc(reg(mpp1)) = AVAIL;
         end;
      type(mp) = ACCUMULATOR;
end shift_code;
stringcompare:
   procedure;
      /* generates code to compare the strings at sp and mp.
         comparisons are done first on length, and second on a
         character by character comparison using the pdp-10 collating
         sequence.
      */
      call forcedescriptor (sp);
      call delete_move (sp,movem,reg(sp),0,b,0,3);
      acc(reg(sp)) = AVAIL;
      call forcedescriptor (mp);
      call delete_move (mp,movem,reg(mp),0,a,0,3);
      call save_acs (5);
      call emitinst (pushj,15,0,strcomp,0,2); /* call string compare */
      call restore_acs (5);
      call emitinst (movei,reg(mp),0,1,0,0);
       call emitinst (skip+inx(mpp1),0,0,0,0,0);
      call emitinst (movei,reg(mp),0,0,0,0);
      type(mp) = ACCUMULATOR;
      stillcond = inx(mpp1);
end stringcompare;
symboldump:
   procedure;
      /* list the symbols in the procedure that has just been
         compiled if toggle s is enabled and l is enabled.
      */
      declare subtitle_save character;
      declare heading character initial ('type       loc   segment defined ref count');
      declare seg(4) character initial ('absolute','    data',' program',
               '  string','   label');
      declare exchanges fixed, i fixed, lmax fixed,
         j fixed, k fixed, l fixed, m fixed, sytsort (SYTSIZE) fixed;
      declare blanks character,
              tag    character;
   string_gt:
      procedure (a,b);
         /* do an honest string comparison:
            xpl can be trusted only if strings are of the same length.
            if lengths differ, let xpl see only the shorter, and the
            matching part of the longer, and arrange comparisons so
            that result is right.   */
         declare a character,
                 b character;
         declare la fixed,  lb fixed;
         la = length (a);
         lb = length (b);
         if la = lb then return (a > b);
         else if la > lb then return (substr (a,0,lb) >= b);
              else return (a > substr(b,0,la));
      end string_gt;
      if control(byte('L'))  = 0 then return; /* don't dump if not listing */
      if procmark <= ndecsy then
         do;
            call printline ('symbol table dump',0);
            lmax = 15;
            do i = procmark to ndecsy;  /* pad all names to the same length */
               if length (syt (i)) > lmax then
                  lmax = length (syt (i));
               sytsort (i) = i;
            end;
            if lmax > 70 then lmax = 70;
            blanks = substr (x70,0,lmax);
            exchanges = TRUE;
            k = ndecsy - procmark;
            do while exchanges;
               exchanges = FALSE;
               do j = 0 to k - 1;
                  i = ndecsy - j;
                  l = i - 1;
                  if string_gt(syt (sytsort(l)),syt(sytsort(i))) then
                     do;
                        m = sytsort (i);
                        sytsort (i) = sytsort (l);
                        sytsort (l) = m;
                        exchanges = TRUE;
                        k = j;          /* record the last swap */
                     end;
                end;
            end;
            i = procmark;
            do while length (syt (sytsort (i))) = 0;
               i = i + 1;               /* ignore null names */
            end;
            subtitle_save = subtitle;
            subtitle = 'symbol' || substr(blanks,0,lmax-5) || heading;
            call printline (subtitle,0);
            do i = i to ndecsy;
               k = sytsort (i);
               tag = syt(k) || substr(x70,0,lmax-length(syt(k)));
               call i_format (sytloc(k),5);
               tag = tag || x1 || typename(sytype(k)) || x1 || i_string;
               call i_format (sytcard(k),5);
               tag = tag || x1 || seg(sytseg(k)) || x2 || i_string;
               call i_format (sytco(k),5);
               if sytco(k) = 0 then i_string = i_string || ' *';
               call printline (tag || x3 || i_string,-1);
               k = k + 1;
               do while (length (syt (k)) = 0) & (k <= ndecsy);
                  j = k - sytsort (i);
                  tag = '  parameter  ' || j || substr(blanks,13) ||
                        typename(sytype(k));
                  call i_format (sytloc(k),5);
                  tag = tag || x1 || i_string;
                  call i_format (sytcard(k),5);
                  tag = tag || x1 || seg(sytseg(k)) || x2 || i_string;
                  call i_format (sytco(k),5);
                  call printline (tag || x3 || i_string,-1);
                  k = k + 1;
               end;
            end;
            subtitle = subtitle_save;
         end;
         EJECT_PAGE;
end symboldump;
dumpit:
   procedure;
      declare char360 character;
      declare t1 character, t2 character, l fixed, ll fixed;
      /* put out statistics kept within the compiler */
     if top_macro >= 0 then
          do; /* dump macro dictionary */
             call printline ( 'macro definitions:',0);
             call printline (x1,-1);
             l = length (macro_name(top_macro));
             if l > 70 then l = 70;
             subtitle = 'name' || substr (x70,0,l-2) ||
                        'at line ref count literal value';
             call printline (subtitle,-1);
             do i = 0 to top_macro;
                k = length (macro_name(i));
                if k < l then
                   do;
                       char360 = substr (x70,0,l-k);
                       macro_name (i) = macro_name (i) || char360;
                   end;
                else
                   macro_name(i) = substr(macro_name(i),0,l);
                t1 = macro_declare(i);
                t2 = macro_count(i);
                ll = length (t1);
                if ll < 8 then t1 = substr(x70,0,8-ll) || t1;
                ll = length (t2);
                if ll < 9 then t2 = substr(x70,0,9-ll) || t2;
                call printline (macro_name(i) || t1 || t2 || x4 || macro_text(i),-1);
             end;
          end;
      subtitle = '';
      call printline (x1,-1);
      call printline ('id compares       = ' || idcompares,-1);
      call printline ('symbol table size = ' || maxndecsy,-1);
      call printline ('macro definitions = ' || top_macro + 1,-1);
      call printline ('scan              = ' || count_scan,-1);
      call printline ('emitinst          = ' || count_inst,-1);
      call printline ('force ACCUMULATOR = ' || count_force,-1);
      call printline ('arithemit         = ' || count_arith,-1);
      call printline ('generate store    = ' || count_store,-1);
      call printline ('free string area  = ' || freelimit - freebase,-1);
      call printline ('compactifications = ' || count_compact,-1);
      subtitle = 'instruction frequencies';
      EJECT_PAGE;
      do i = 0 to 15;
         j = i * 32;
         do k = 0 to 31;
            if instruct(j+k) > 0 then
                call printline (substr(opname(i),k*6,6) || x4 || instruct(j+k),-1);
         end;
      end;
end dumpit;
   initialize:
      procedure;
      declare ch character;
      declare time1 fixed, hours fixed, minutes fixed, secs fixed;
      declare date1 fixed, day fixed, year fixed, l fixed;
      declare month character;
      declare months (11)character initial ('-jan-',
            '-feb-','-mar-','-apr-','-may-','-jun-','-jul-','-aug-',
            '-sep-','-oct-','-nov-','-dec-');
      output(-2) = 'filename to be compiled: ';
      char_temp = input(-1);
      source = '';
      control(byte('A')) = FALSE;
      control(byte('D')) = TRUE;
      control(byte('S')) = TRUE;
      do i = 0 to length(char_temp)-1;
         ch =  substr(char_temp,i,1);
         if byte(ch) = byte('/') then
            do;
               ch = substr(char_temp,i+1,1);
               control(byte(ch)) = ~ control(byte(ch));
               i = i + 1;
            end;
         else
            source = source || ch;
         end;
      filename (0) = 'sysin:' || source || '.xpl';
      filename (1) = 'sysout:' || source || '.lst';
      if control(byte('A')) then
         do;
            filename (DATAFILE) = source || '.mac';
            filename(CODEFILE) = source || '.tmp';
         end;
      filename(RELFILE) = source || '.rel';
      time1 = (time+500)/ 1000;
      hours = time1 /3600;
      minutes = (time1 mod 3600) / 60;
      secs = time1 mod 60;
      date1 = date;
      day = date1 mod 31 + 1;
      date1 = date1 / 31;
      month = months(date1 mod 12);
      year = date1 / 12 + 1964;
      title = '1' || source || '.xpl  compiled ' || day || month ||
             year || '  at ' ||hours || ':' || minutes || ':' || secs
             || ' by VERSION ' || VERSION;
      l = length (title);
      title = title || substr(x70,0,90-l) || 'page ';
      subtitle = ' line    source statement' || substr(x70,7)
            || 'procedure and compiler information';
      page_count = 0;
      line_count = 99;
      do i = 1 to TERMINAL#;
         s = vocab(i);
         if s = '<number>' then number = i;  else
         if s = '<identifier>' then ident = i;  else
         if s = '<string>' then string = i;  else
         if s = '/' then divide = i;  else
         if s = 'eof' then eofile = i;  else
         if s = 'declare' then stopit(i) = TRUE;  else
         if s = 'procedure' then stopit(i) = TRUE;  else
         if s = 'end' then stopit(i) = TRUE;  else
         if s = 'do' then stopit(i) = TRUE;  else
         if s = ';' then stopit(i) = TRUE;  else
         if s = '|' then orsymbol = i; else
         if s = '||' then concatenate = i;
      end;
      if ident = TERMINAL# then reserved_limit = length(vocab(TERMINAL#-1));
      else reserved_limit = length(vocab(TERMINAL#));
      stopit(eofile) = TRUE;
   do i = TERMINAL# to  VOCAB#;
      s = vocab(i);
      if s = '<label definition>' then labelset = i;
   end;
      chartype (byte(' ')) = 1;
      chartype (byte('''')) = 2;
      chartype (byte('"')) = 3;
      do i = 0 to 255;
         not_letter_or_digit(i) = TRUE;
      end;
      do i = 0 to 29;
         j = byte('abcdefghijklmnopqrstuvwxyz_$@#', i);
         not_letter_or_digit(j) = FALSE;
         chartype(j) = 4;
      end;
      do i = 0 to 9;
         j = byte('0123456789', i);
         not_letter_or_digit(j) = FALSE;
         chartype(j) = 5;
       end;
      i = 1;
      do while (length(vocab(i))= 1);
         j = byte(vocab(i));
         tx(j) = i;
         chartype(j) = 7;
         i = i + 1;
      end;
      chartype(byte('|')) = 8;
      chartype (byte('/')) = 6;
      pp = 0;            /* program origin */
      dp = 0;            /* data origin */
      dpoffset = 0;
      dsp = 0;           /* descriptor origin */
      returned_type = FIXEDTYPE;     /* initial default type */
      top_macro = -1;
      target_register = -1;
      codemsg = x70 || codemsg;
      datamsg = x70 || datamsg;
      backmsg = x70 || backmsg;
/*    initialize the symbol table and its hash table */
      procmark = 25; ndecsy = 27; parct = 0;
      do i = 0 to SYTSIZE;
         ptr (i) = -1;
      end;
      do i = 0 to "ff";
         hash (i) = -1;
      end;
      do i = 0 to ndecsy;
         idx = hasher (syt(i));
         ptr (i) = hash (idx);
         hash (idx) = i;
      end;
      rptr, dptr, dloc,for_count, label_count = 0;
      rctr, dctr = 1;
      file(RELFILE) = NAME_TYPE + 2;
      file(RELFILE) = 0;
      file(RELFILE) = radix50(source);
      file(RELFILE) = "(3)17000000" + 0;
      file(RELFILE) = HISEG_TYPE + 1;
      file(RELFILE) = "(3)200000000000" ;
      file(RELFILE) = "(3)400000400000";
      code_head, code_tail = 0;
      code_full(0) = FALSE;
      if control(byte('A')) then
         do;
            label_gen = 'p:';                /* org the code segment */
            output (DATAFILE) = '       title ' || source ;
            output (DATAFILE) = '       twoseg 400000;';
            output (DATAFILE) = '       reloc 0;';
            output (DATAFILE) = '       radix 10;';
            output (CODEFILE) = '       reloc |o400000;';
            output (DATAFILE) = '       opdef   .init. [1b8];';
            output (DATAFILE) = '       opdef   .inpt. [2b8];';
            output (DATAFILE) = '       opdef   .outp. [3b8];';
            output (DATAFILE) = '       opdef   .exit. [4b8];';
            output (DATAFILE) = '       opdef   .fili. [6b8];';
            output (DATAFILE) = '       opdef   .filo. [7b8];';
            output (DATAFILE) = '       opdef   .name. [8b8];';
            output (DATAFILE) = 'd:';
         end;
      byteptrs = dp;
      call emitdataword ("(3)331114000000"); /*   point 9,0(12),8 */
      call emitdataword ("(3)221114000000"); /*   point 9,0(12),17 */
      call emitdataword ("(3)111114000000"); /*   point 9,0(12),26 */
      call emitdataword ("(3)001114000000"); /*   point 9,0(12),35 */
      psbits = dp;
      call emitdataword ("(3)331100000000"); /*   point 9,0,8  */
      call emitdataword ("(3)221100000000"); /*   point 9,0,17 */
      call emitdataword ("(3)111100000000"); /*   point 9,0,26 */
      call emitdataword ("(3)001100000000"); /*   point 9,0,35 */
      call emitconstant (1);            /* enter a 1 */
      trueloc = adr;                    /* save its address */
      call emitconstant (0);            /* enter a 0 */
      falseloc = adr;                   /* save its address */
      tsa = dp; sytloc(2) = dp;         /* freepoint */
      call emitdataword (0);
      ndesc, sytloc(4) = findlabel;     /* ndescript */
      corebyteloc = 1;                  /* syt location of corebyte */
      string_recover = 25;              /* syt location of compactify */
      sytloc(25) = findlabel;           /* label for compactify */
      limitword = dp; sytloc(26) = dp;  /* freelimit */
      call emitdataword (0);
      str = dsp;                        /* place to save last string generated */
      call emitdesc (0,0);
      library_save = dp;                /* place to save r11 on lib calls */
      call emitdataword (0);
      library = dp;                     /* address of library goes here */
      if control(byte('A')) then
         do;
            output (DATAFILE) = '       xpllib;';
            output (DATAFILE) = '       extern xpllib;';
         end;
      dp = dp + 1;
      call emitconstant ("fffff");      /* mask for addresses only  */
      addrmask = adr;                   /* save it                  */
      call emitconstant(-134217728);  /* dv length field */
      lengthmask = adr;
 
/* check-string-overflow  see if compactify needs to be called */
      call emitblock (15);
      i = dp - 15;
      string_check = pp;
      call emitinst (move,0,0,tsa,0,1); /* pick up top of strings */
      call emitinst (camge,0,0,limitword,0,1); /* compare with limit word */
      call emitinst (popj,15,0,0,0,0);
      call emitinst (movei,0,0,i,0,1);
      call emitinst (hrli,0,0,1,0,0);
      call emitinst (blt,0,0,i+14,0,1);
      call emitinst (pushj,15,0,sytloc(string_recover),0,sytseg(string_recover));
      call emitinst (movei,0,0,1,0,0);
      call emitinst (hrli,0,0,i,0,1);
      call emitinst (blt,0,0,14,0,0);
      call emitinst (popj,15,0,0,0,0);
      sytco (string_recover) = sytco (string_recover) + 1;
 
 /* string comparison */
      a = dsp;
      call emitdesc (0,0);
      b = dsp;
      call emitdesc (0,0);
      strcomp = pp;
      call emitinst (move,0,0,a,0,3);   /* fetch left descriptor */
      call emitinst (lsh,0,0,    -27,0,0);
      call emitinst (move,1,0,b,0,3);    /* fetch right descriptor */
      call emitinst (lsh,1,0,    -27,0,0);
      call emitinst (sub,0,0,1,0,0);    /* subtract the lengths */
      call emitinst (jumpe,0,0,pp+2,0,2);
      call emitinst (popj,15,0,0,0,0);   /* return w/ -, 0, or + if length ~= */
      call emitinst (movei,2,0,0,0,0);  /* clear a length register */
      call emitinst (move,3,0,a,0,3);
      call emitinst (subi,3,0,1,0,0);
      call emitinst (lshc,2,0,  9,0,0); /* isolate the length */
      call emitinst (lshc,3,0,-11,0,0); /* isolate byte index in r4 */
      call emitinst (lsh,4,0,    -34,0,0);
      call emitinst (hll,3,0,psbits,4,1); /* build byte ptr in r3 */
      call emitinst (move,4,0,b,0,3);
      call emitinst (subi,4,0,1,0,0);
      call emitinst (lshc,4,0,    -2,0,0);
      call emitinst (lsh,5,0,    -34,0,0);
      call emitinst (hll,4,0,psbits,5,1); /* build byte ptr in r4 */
 
      /* one character goes into r0 while the other goes into r1.  length is
         controlled in r2 and the byte ptrs are in r3 & r4 for speed.
      */
      call emitinst (ildb,0,0,3,0,0);   /* fetch 1st byte */
      call emitinst (ildb,1,0,4,0,0);   /* fetch 2nd byte */
      call emitinst (camn,0,0,1,0,0);   /* skip if ~= */
      call emitinst (sojg,2,0,pp-3,0,2);/* loop for all bytes */
      call emitinst (sub,0,0,1,0,0);    /* sub diff bytes or last two equal */
      call emitinst (popj,15,0,0,0,0);
 
 /* move character subroutine */
      mover = pp;
      /* uses registers 1, 2, 11, 12, & 13 */
      call emitinst (subi,12,0,1,0,0);  /* decr addr of source */
      call emitinst (movei,11,0,0,0,0); /* clear length reg */
      call emitinst (lshc,11,0,  9,0,0);/* isolate length */
      call emitinst (lshc,12,0,-11,0,0);/* isolate byte index */
      call emitinst (lsh,13,0,    -34,0,0);
      call emitinst (hll,12,0,psbits,13,1); /* make from byteptr */
      call emitinst (move,13,0,11,0,0); /* copy length */
      call emitinst (add,13,0,1,0,0);   /* create new tsa */
      call emitinst (subi,1,0,1,0,0);   /* decr to addr */
      call emitinst (lshc,1,0,    -2,0,0); /* isolate byte index */
      call emitinst (lsh,2,0,    -34,0,0);
      call emitinst (hll,1,0,psbits,2,1);  /* to byteptr */
      /* character goes into r2, length is in r11, and the new tsa is in r13.
         byteptrs are in r1 & r12 for speed.
      */
      call emitinst (ildb,2,0,12,0,0);  /* fetch a byte */
      call emitinst (idpb,2,0,1,0,0);   /* store a byte */
      call emitinst (sojg,11,0,pp-2,0,2);  /* loop for all bytes */
      call emitinst (move,1,0,13,0,0);  /* return with new tsa */
      call emitinst (popj,15,0,0,0,0);
 
 /* catenation subroutine */
 
      catentry = pp;
      call check_string_overflow;       /* squeeze core if necessary */
      call emitinst (move,0,0,b,0,3);   /* see if length (b) = 0 */
      call emitinst (and,0,0,lengthmask,0,1);
      call emitinst (jumpn,0,0,pp+3,0,2);
      call emitinst (move,0,0,a,0,3);   /* yes, return with a */
      call emitinst (popj,15,0,0,0,0);
      call emitinst (move,1,0,a,0,3);   /* see if length(a) = 0 */
      call emitinst (and,1,0,lengthmask,0,1);
      call emitinst (jumpn,1,0,pp+3,0,2);
      call emitinst (move,0,0,b,0,3);   /* yes, return with b */
      call emitinst (popj,15,0,0,0,0);
 
      /*  we have to construct a new string.  check to see if string 'a'
        is adjacent to the first available byte.  if it is, we need
        only actually move string 'b' and dummy up a new descriptor.  */
      call emitinst (rot,1,0,9,0,0);     /* put l(a) in low end */
      call emitinst (add,1,0,a,0,3);     /* add a desc. */
      call emitinst (and,1,0,addrmask,0,1); /* keep only byte address */
      call emitinst (add,0,0,a,0,3);     /* add l(b) to desc. a */
      call emitinst (move,12,0,b,0,3);     /* ge desc. b */
      call emitinst (and,12,0,addrmask,0,1);/* keep byte address */
      call emitinst (camn,12,0,1,0,0);    /* is this same as end(a)+1? */
      call emitinst (jrst,0,0,pp+11,0,2);  /*yes. then done */
      call emitinst (caml,1,0,tsa,0,1);  /* is 'a' last string ? */
      call emitinst (jrst,0,0,pp+6,0,2); /* yes. jump to just move b */
      call emitinst (and,0,0,lengthmask,0,1); /* no. make new desc. */
      call emitinst (ior,0,0,tsa,0,1);  /* new dope vector */
      call emitinst (move,1,0,tsa,0,1); /* target of move */
      call emitinst (move,12,0,a,0,3);  /* source of move & length */
      call emitinst (pushj,15,0,mover,0,2);   /* call move subroutine */
      call emitinst (move,12,0,b,0,3);  /* source of move */
      call emitinst (pushj,15,0,mover,0,2);   /* call move subroutine*/
      call emitinst (movem,1,0,tsa,0,1);/* save new tsa */
      call emitinst (movem,0,0,str,0,3);  /* save last string descriptor */
      call emitinst (popj,15,0,0,0,0);
 
 /* number to string conversion */
      nmbrentry = pp;
      /* uses registers 0,1,12,13 */
      call emitblock (1);
      c = dp - 1;
      call check_string_overflow;
      call emitinst (move,12,0,tsa,0,1);   /* get loc'n first free byte*/
      call emitinst (subi,12,0,1,0,0);    /* adjust for idbp */
      call emitinst (movei,13,0,0,0,0);    /* clear 13 for shift */
      call emitinst (lshc,12,0,-2,0,0);    /* word address to 12 */
      call emitinst (rot,13,0,2,0,0);      /* displ. to 13 */
      call emitinst (hll,12,0,psbits,13,1);/* make byte pointer in 12 */
      call emitinst (move,0,0,c,0,1);      /* load number to be converted */
      call emitinst (movei,13,0,0,0,0);    /* clear count of bytes */
      call emitinst (jumpge,0,0,pp+5,0,2); /* jump around sign if >= 0 */
      call emitinst (movei,1,0,byte('-'),0,0);/* put - into reg. */
      call emitinst (idpb,1,0,12,0,0);     /* put byte away */
      call emitinst (movei,13,0,1,0,0);    /* set byte count to 1 */
      call emitinst (movm,0,0,0,0,0);      /* make number positive */
      call emitinst (pushj,15,0,pp+8,0,2); /* generate byte string */
      call emitinst (rot,13,0,-9,0,0);     /* put byte count in length */
      call emitinst (move,0,0,tsa,0,1);    /* pick starting address of string */
      call emitinst (add,0,0,13,0,0);      /* add length to make desc. */
      call emitinst (rot,13,0,9,0,0);      /* put count back */
      call emitinst (addm,13,0,tsa,0,1);   /* adjust tsa for next time */
      call emitinst (movem,0,0,str,0,3);   /* save new descriptor */
      call emitinst (popj,15,0,0,0,0);     /* return */
      /* subroutine to convert number to char string by repetitive
         division.  puts out digits from high-to-low order. */
      call emitinst (idivi,0,0,10,0,0);    /* quotient to 0, remainder to 1 */
      call emitinst (hrlm,1,0,0,15,0);     /* save remainder on stack */
      call emitinst (jumpe,0,0,pp+2,0,2);  /* if quotient = 0, all digits */
      call emitinst (pushj,15,0,pp-3,0,2); /* loop back for next digit */
      call emitinst (hlrz,1,0,0,15,0);     /* retrieve digit from stack */
      call emitinst (addi,1,0,byte('0'),0,0); /* convert to ascii character */
      call emitinst (idpb,1,0,12,0,0);     /* stuff byte out */
      call emitinst (addi,13,0,1,0,0);     /* increment byte counter */
      call emitinst (popj,15,0,0,0,0);     /* return (for more or to caller */
 
   /* the compiled program will begin execution here.  make the first jump
      point here, initialize the library, and fall into compile code.
   */
      startloc = pp;                      /* start location */
      call emitlabel (0,4);               /* org program here */
      /* initialize library routine, freebase, freelimit, & freepoint */
      call emitinst (jump,0,0,0,0,0);   /* patch nop */
      call emitinst (1,0,0,0,0,0);      /* init lib code */
      call emitinst (movem,12,0,tsa,0,1); /* save as freepoint */
      call emitinst (movem,12,0,dp,0,1); /* save as freebase */
      sytloc (27) = dp;
      call emitdataword (0);
      call emitinst (subi,13,0,256,0,0);
      call emitinst (movem,13,0,limitword,0,1); /* save as freelimit */
      /* routine to relocate string descriptors */
      call emitinst (movei,12,0,0,0,1); /* get address of data segment */
      call emitinst (lsh,12,0,  2,0,0);    /* multiply by 4 for byte address*/
      call emitinst (move,13,0,ndesc,0,5);   /* get # descriptors as index */
      call emitinst (skipe,0,0,0,13,3); /* don't change null desc.s */
      call emitinst (addm,12,0,0,13,3); /* add reloc to a descriptor */
      call emitinst (sojg,13,0,pp-2,0,2);    /* loop thru all descriptors */
      cp = 0;  text = '';  text_limit = -1;
      compiling = TRUE;
      reading = control(byte('X'));
      if reading then
          control(byte('L')) = ~ (control(byte('K')) | control(byte('M'))) & 1;
      filename(LIBFILE) = 'lib:xpl.lib';
      current_procedure = '*';
      call scan;
      no_look_ahead_done = FALSE;
   end initialize;
stack_dump:
   procedure;
      declare line character;
      if ~ control(byte('R')) then return;  /* 'r' is barf switch */
      line = 'partial parse to this point is: ';
      do i = 0 to sp;
         if length(line) > 105 then
            do;
               call printline (line,-1);
               line = x4;
            end;
         line = line || x1 || vocab(state_name(state_stack(i)));
      end;
      call printline (line,-1);
   end stack_dump;
 
  /*                  the synthesis algorithm for xpl                      */
synthesize:
procedure(production_number);
   declare production_number fixed;
   declare toomsg character initial ('too many arguments for ');
   stack_case:
      procedure (datum);
         declare datum fixed;
         declare dclrm character
               initial ('too many cases or factored declarations');
         if casep >= CASELIMIT then call error (dclrm,1);
                               else casep = casep + 1;
         casestack(casep) = datum;
   end stack_case;
 
      do case (production_number);
   /*  one statement for each production of the grammar*/
   ;      /*  case 0 is a dummy, because we number productions from 1  */
 
/*      1   <program> ::= <statement list> eof                       */
do;  /* end of compiling */
   compiling = FALSE;
   if mp ~= 0  then
      do;
         call error ('input did not parse to <program>.', 1);
         call stack_dump;
      end;
   do i = procmark to ndecsy;
      if sytype (i) = FORWARDTYPE | sytype (i) = FORWARDCALL then
         if sytco (i) > 0 then
             call error ('undefined label or procedure: ' || syt(i),1);
   end;
      if dpoffset > 0 then call flush_datacard;
end;
/*      2   <statement list> ::= <statement>                         */
   ;
/*      3                      | <statement list> <statement>        */
   ;
/*      4   <statement> ::= <basic statement>                        */
   do;
      statement_count = statement_count + 1;
      call clearars;
   end;
/*      5                 | <if statement>                           */
   call clearars;
/*      6   <basic statement> ::= <assignment> ;                     */
   ;
/*      7                       | <group> ;                          */
   ;
/*      8                       | <procedure definition> ;           */
   ;
/*      9                       | <return statement> ;               */
   ;
/*     10                       | <call statement> ;                 */
   ;
/*     11                       | <go to statement> ;                */
   ;
/*     12                       | <declaration statement> ;          */
   ;
/*     13                       | ;                                  */
   ;
/*     14                       | <label definition>                 */
/*     14                         <basic statement>                  */
   ;
/*     15   <if statement> ::= <if clause> <statement>               */
   call emitlabel(fixl(mp),4);            /* fix escape branch */
/*     16                    | <if clause> <TRUE part> <statement>   */
   call emitlabel (fixl(mpp1),4);         /* fix escape branch */
/*     17                    | <label definition> <if statement>     */
   ;
/*     18   <if clause> ::= if <expression> then                     */
      call boolbranch(mpp1,mp);  /* branch on FALSE over TRUE part */
/*     19   <TRUE part> ::= <basic statement> else                   */
   do; /* save the program pointer and emit the conditional branch */
      fixl(mp) = findlabel;
      call emitinst(jrst ,0,0,fixl(mp),0,4);
      call emitlabel (fixl(mp-1),4);      /* complete hop around TRUE */
      call clearars;
   end;
/*     20   <group> ::= <group head> <ending>                        */
        /* branch back to loop and fix escape branch */
      if inx (mp) = 1 | inx (mp) = 2 then
         do;  /* step or while loop fixup */
            call emitinst (jrst ,0,0,ppsave(mp),0,2);
            call emitlabel(fixl(mp),4);
         end;
       else if inx (mp) = 3 then
         do;  /* case group */
            call emitlabel(fixl(mp),4);   /* fix branch into jump list */
            do i = ppsave (mp) to casep - 1;
               call emitinst (jrst ,0,0,casestack(i),0,2); /* jump list */
               end;
            casep = ppsave (mp) - 1;
            call emitlabel(fixv(mp),4);   /* fix escape branch */
         end;
 
/*     21   <group head> ::= do ;                                    */
   inx (mp) = 0;                       /* zero denotes ordinary group */
/*     22                  | do <step definition> ;                  */
   do;
      call movestacks (mpp1, mp);
      inx (mp) = 1;                    /* one denotes step */
      call clearars;
   end;
/*     23                  | do <while clause> ;                     */
   do;
      call movestacks (mpp1,mp);
      inx (mp) = 2;                    /* two denotes while */
      call clearars;
   end;
/*     24                  | do <case selector> ;                    */
   do;
      call movestacks (mpp1, mp);
      inx (mp) = 3;                    /* three denotes case */
      call clearars;
      info = info || ' case 0.';
   end;
/*     25                  | <group head> <statement>                */
   if inx (mp) = 3 then
      do; /* case group, must record statement addresses */
         call emitinst (jrst ,0,0,fixv(mp),0,4);
         call stack_case (pp);
         info = info || ' case ' || casep - ppsave(mp) || '.';
      end;
/*     26   <step definition> ::= <VARIABLE> <replace>               */
/*     26                         <expression> <iteration control>   */
   do; /* emit code for stepping do loops */
      call forceaccumulator (mp+2);     /* get initial value */
      stepk = findlabel;
      call emitinst (jrst ,0,0,stepk,0,4);/* branch around incr code */
      ppsave(mp) = pp;                  /* save address for later fix */
      if cnt (mp) > 0 then call error ('do index may not be subscripted',0);
                       /*  increment induction VARIABLE */
      if sytype(fixl(mp)) = FIXEDTYPE & fixl(sp) = trueloc then
         do;           /* use aos if incrementing by 1 */
            reg(mp) = reg(mp+2);
            call emitinst (aosa,reg(mp),0,sytloc(fixl(mp)),0,1);
            type(mp) = ACCUMULATOR;
         end;
      else
         do;           /* can't use aos inst. */
            acc(reg(mp+2)) = AVAIL;     /* make sure same register is used */
            target_register = reg(mp+2);
            call forceaccumulator (mp); /* fetch the index     */
            target_register = -1;
            call emitinst(add,reg(mp),0,fixl(mp+3),0,1);
         end;
                       /* update induction VARIABLE and test for end */
      call emitlabel(stepk,4);
      call genstore (mp,mp);
      call emitinst (camle,reg(mp),0,fixv(sp),0,1);
      fixl (mp) = findlabel;
      call emitinst (jrst ,0,0,fixl(mp),0,4);
      acc(reg(mp)) = AVAIL;
   end;
/*     27   <iteration control> ::= to <expression>                  */
   do;
      fixl(mp) = trueloc;   /* point at the CONSTANT one for step */
      call setlimit;
   end;
/*     28                         | to <expression> by               */
/*     28                           <expression>                     */
   do;
      if type (sp) = CONSTANT then call emitconstant (fixv(sp));
      else
         do;
            call forceaccumulator (sp);
            call emitdataword (0);
            adr = dp - 1;
            call emitinst (movem,reg(sp),0,adr,0,1);
            acc(reg(sp)) = AVAIL;
         end;
      fixl (mp) =adr;
      call setlimit;
   end;
/*     29   <while clause> ::= while <expression>                    */
   call boolbranch (sp,mp);
/*     30   <case selector> ::= case <expression>                    */
   /* the following use is made of the parallel stacks below <case selector>
         ppsave     previous maximum case stack pointer
         fixl       address of indexed goto into list
         fixv       address of escape goto for cases
   */
   do;
      call forceaccumulator (sp);       /* get the index in to ar */
      acc(reg(sp)) = AVAIL;
      fixl(mp) = findlabel;
      call emitinst (jrst ,0,1,fixl(mp),reg(sp),4);/* indirect indexed branch */
      fixv(mp) = findlabel;             /* address of escape branch */
      call stack_case (pp);
      ppsave (mp) = casep;
   end;
/*     31   <procedure definition> ::= <procedure head>              */
/*     31                              <statement list> <ending>     */
   /* the following use is made of the parallel stacks below
      <procedure head>
      ppsave           address of previous proc return
      fixl             address of previous proc ACCUMULATOR area
      fixv             pointer to symbol table for this block
      cnt              count of the parameters of previous proc
   */
   do;   /* procedure is defined, restore symbol table */
      if length (var(sp)) > 0 then
         if substr (current_procedure,1) ~= var(sp) then
            call error ('procedure' || current_procedure || ' closed by end '
                        || var(sp), 0);
      if control(byte('S')) then call symboldump;
      do i = procmark to ndecsy;
         if sytype (i) = FORWARDTYPE | sytype (i) = FORWARDCALL then
            if sytco (i) > 0 then
               call error ('undefined label or procedure: ' || syt (i), 1);
      end;
      do i = 0 to (ndecsy + 1) - (procmark + parct);
         j = ndecsy - i;
         if (j >= (procmark + parct)) & (length(syt(j)) > 0) then
            do;
               hash (hasher(syt(j))) = ptr (j);
               ptr (j) = -1;
            end;
      end;
      do i = procmark + parct to ndecsy;
          syt (i) = x1;
      end;
      ndecsy = procmark + parct - 1;
      /* parameter addresses must be saved but names discarded */
      if parct > 0 then
         do j = 0 to ndecsy - procmark;
            i = ndecsy - j;
            if sytype (i) = 0 then
               do;
                  call error ('undeclared parameter: ' || syt (i), 0);
                  sytype (i) = FIXEDTYPE;
                  call emitdataword (0);
                  sytloc(i) = dp -1;
               end;
            hash (hasher(syt(i))) = ptr (i);
            ptr (i) = -1;
            syt (i) = '';
         end;
      procmark = fixv (mp);
      parct = cnt (mp);
      current_procedure = var (mp);
      /* emit a gratuitous return */
      call emitinst (popj,15,0,0,0,0);
      /* complete jump around the procedure definition */
      call emitlabel(ppsave(mp),4);
      returned_type = type(mp);
   end;
/*     32   <procedure head> ::= <procedure name> ;                  */
   do;      /* must point at first parameter even if non existant */
      /* save old parameter count */
      cnt (mp) = parct;
      parct = 0;
      /* save old procedure mark in symbol table */
      fixv(mp) = procmark;
      procmark = ndecsy + 1;
      type(mp) = returned_type;
      returned_type = 0;
      call proc_start;
   end;
/*     33                      | <procedure name> <type> ;           */
   do;
      cnt (mp) = parct;           /* save old parameter count */
      parct = 0;
      fixv(mp) = procmark;        /* save old procedure mark in symbol table */
      procmark = ndecsy + 1;
      type(mp) = returned_type;
      returned_type = type(sp-1);
      if returned_type = CHRTYPE then sytype(fixl(mp)) = CHARPROCTYPE;
      call proc_start;
   end;
/*     34                      | <procedure name> <parameter list>   */
/*     34                        ;                                   */
   do;
      cnt(mp) = cnt(mpp1);  /* save parameter count */
      fixv(mp) = fixv (mpp1);
      type(mp) = returned_type;
      returned_type = 0;
      call proc_start;
   end;
/*     35                      | <procedure name> <parameter list>   */
/*     35                        <type> ;                            */
   do;
      cnt(mp) = cnt(mpp1);  /* save parameter count */
      fixv(mp) = fixv (mpp1);
      type(mp) = returned_type;
      returned_type = type(sp-1);
      if returned_type = CHRTYPE then sytype(fixl(mp)) = CHARPROCTYPE;
      call proc_start;
   end;
/*     36   <procedure name> ::= <label definition> procedure        */
   do;
      sytype (fixl (mp)) = PROCTYPE;
      s = current_procedure;
      current_procedure = x1 || var (mp);
      var (mp) = s;
   end;
/*     37   <parameter list> ::= <parameter head> <identifier> )     */
   do;
      parct = parct + 1;   /* bump the parameter count */
      call enter (var(mpp1), 0, 0, 0);
   end;
/*     38   <parameter head> ::= (                                   */
   do;  /* point at the first parameter for symbol table */
      fixv(mp) = procmark;
      procmark = ndecsy + 1;
      cnt (mp) = parct;        /* save old parameter count */
      parct = 0;
   end;
/*     39                      | <parameter head> <identifier> ,     */
   do;
       parct = parct + 1;          /* bump the parameter count */
      call enter (var(mpp1), 0, 0, 0);
   end;
/*     40   <ending> ::= end                                         */
   ;
/*     41              | end <identifier>                            */
   var (mp) = var (sp);
 
/*     42              | <label definition> <ending>                 */
   ;
/*     43   <label definition> ::= <identifier> :                    */
   fixl(mp) = enter (var(mp), LABELTYPE, pp, 2);
 
/*     44   <return statement> ::= return                            */
   do;
      call emitinst (popj,15,0,0,0,0);
   end;
/*     45                        | return <expression>               */
   do;  /* emit a return and pass a value */
      target_register = 0;
      if returned_type = CHRTYPE then
         call forcedescriptor(sp);
      else
         call forceaccumulator (sp);
      target_register = -1;
      if reg(sp) ~= 0 then call emitinst(move,0,0,reg(sp),0,0);
      call emitinst (popj,15,0,0,0,0);
   end;
/*     46   <call statement> ::= call <VARIABLE>                     */
   do;
      i = sytype(fixl(sp));
      if i=PROCTYPE | i=FORWARDCALL | i = CHARPROCTYPE
                    | (i=SPECIAL & sytloc(fixl(sp))=12)
                    | (i=SPECIAL & sytloc(fixl(sp))=9)  then
         do;
            calltype = 0;               /* no return value */
            call forceaccumulator(sp);
            calltype = 1;
         end;
      else call error ('undefined procedure: ' || syt(fixl(sp)),0);
   end;
/*     47   <go to statement> ::= <go to> <identifier>               */
   do;
      call id_lookup(sp);
      j = fixl (sp);
      if j < 0 then
         do;  /* first ocurrance of the label */
            i = findlabel;
            call emitinst (jrst ,0,0,i,0,4);
            j = enter (var(sp),FORWARDTYPE,i,4);
            sytco (j) = 1;
         end;
      else if sytype(j) = LABELTYPE | sytype(j) = FORWARDTYPE then
          call emitinst (jrst ,0,0,sytloc(j),0,sytseg(j));
      else
        call error ('target of goto is not a label', 0);
   end;
/*     48   <go to> ::= go to                                        */
   ;
/*     49             | goto                                         */
   ;
/*     50   <declaration statement> ::= declare                      */
/*     50                               <declaration element>        */
   ;
/*     51                             | <declaration statement> ,    */
/*     51                               <declaration element>        */
   ;
/*     52   <declaration element> ::= <type declaration>             */
      if type (mp) = CHRTYPE then
         do while (dsp < newdsp);
            call emitdesc (0,0);
         end;
      else
         do;
            if dp < newdp then
               do;
                  if dpoffset > 0 then call flush_datacard;
                  if dp < newdp then call emitblock (newdp-dp);
               end;
            do while (dpoffset < newdpoffset);
               call emitbyte(0);
            end;
         end;
 
/*     53                           | <identifier> literally         */
/*     53                             <string>                       */
   if top_macro >= MACRO_LIMIT then
      call error ('macro table overflow', 1);
   else do;
      top_macro = top_macro + 1;
      i = length(var(mp));
      j = macro_index(i);
      do l = 1 to top_macro - j;
         k = top_macro - l;
         macro_name(k+1) = macro_name(k);
         macro_text(k+1) = macro_text(k);
         macro_count(k+1) = macro_count(k);
         macro_declare(k+1) = macro_declare(k);
      end;
      macro_name(j) = var(mp);
      macro_text(j) = var(sp);
      macro_count(j) = 0;
      macro_declare(j) = card_count;
      do j = i to 255;
         macro_index(j) = macro_index(j) + 1;
      end;
   end;
/*     54   <type declaration> ::= <identifier specification>        */
/*     54                          <type>                            */
   call tdeclare (0);
/*     55                        | <bound head> <number> ) <type>    */
   call tdeclare (fixv(mpp1));
/*     56                        | <type declaration>                */
/*     56                          <initial list>                    */
   ;
/*     57   <type> ::= fixed                                         */
   type (mp) = FIXEDTYPE;
/*     58            | character                                     */
   type (mp) = CHRTYPE;
/*     59            | label                                         */
   type (mp) = FORWARDTYPE;
/*     60            | <bit head> <number> )                         */
   if fixv(mpp1) <= 9 then type (mp) = BYTETYPE; else
      if fixv (mpp1) <= 36 then type (mp) = FIXEDTYPE; else
         type (mp) = CHRTYPE;
/*     61   <bit head> ::= bit (                                     */
   ;
/*     62   <bound head> ::= <identifier specification> (            */
   ;
/*     63   <identifier specification> ::= <identifier>              */
   do;
      inx(mp) = 1;
      fixl(mp) = casep;
      call stack_case (enter(var(mp),0,0,0));
   end;
/*     64                                | <identifier list>         */
/*     64                                  <identifier> )            */
   do;
      inx(mp) = inx(mp) + 1;
      call stack_case (enter(var(mpp1),0,0,0));
   end;
/*     65   <identifier list> ::= (                                  */
   do;
      inx(mp) = 0;
      fixl(mp) = casep;
   end;
/*     66                       | <identifier list> <identifier> ,   */
   do;
      inx(mp) = inx(mp) + 1;
      call stack_case (enter(var(mpp1),0,0,0));
   end;
/*     67   <initial list> ::= <initial head> <CONSTANT> )           */
   call setinit;
/*     68   <initial head> ::= initial (                             */
   if inx(mp-1) = 1 then
      itype = type (mp-1);  /* copy information from <type declaration> */
   else
      do;
         call error ('initial may not be used with identifier list',0);
         itype = 0;
      end;
/*     69                    | <initial head> <CONSTANT> ,           */
   call setinit;
/*     70   <assignment> ::= <VARIABLE> <replace> <expression>       */
   call genstore(mp,sp);
/*     71                  | <left part> <assignment>                */
   call genstore(mp,sp);
/*     72   <replace> ::= =                                          */
   ;
/*     73   <left part> ::= <VARIABLE> ,                             */
   ;
/*     74   <expression> ::= <logical factor>                        */
   ;
/*     75                  | <expression> | <logical factor>         */
   call arithemit (ior,1);
/*     76   <logical factor> ::= <logical secondary>                 */
   ;
/*     77                      | <logical factor> &                  */
/*     77                        <logical secondary>                 */
   call arithemit (and,1);
/*     78   <logical secondary> ::= <logical primary>                */
   ;
/*     79                         | ~ <logical primary>              */
   do;
      call movestacks (sp, mp);
       /* get 1's complement */
      call forceaccumulator(mp);
      call emitinst (setca,reg(mp),0,0,0,0);
   end;
/*     80   <logical primary> ::= <string expression>                */
   ;
/*     81                       | <string expression> <relation>     */
/*     81                         <string expression>                */
      /* relations are encoded as to their cam? instriction code */
      /*
         <     1
         >     7
         ~=    6
         =     2
         <=    3
         ~>    3
         >=    5
         ~<    5
      */
   do;
      i = type (mp);
      j = type (sp);
      if i = DESCRIPT | i = CHRTYPE then call stringcompare; else
      if i = VARIABLE & sytype(fixl(mp)) = CHRTYPE then call stringcompare; else
      if j = DESCRIPT | j = CHRTYPE then call stringcompare; else
      if j = VARIABLE & sytype(fixl(sp)) = CHRTYPE then call stringcompare; else
         do;
            if i = VARIABLE & sytype(fixl(mp)) = BYTETYPE then
                   call forceaccumulator(mp);
            if j = VARIABLE & sytype(fixl(sp)) = BYTETYPE then
                   call forceaccumulator(sp);
            if shouldcommute then call forceaccumulator(sp);
            else call forceaccumulator(mp);
            i = findar;
            call emitinst(movei,i,0,1,0,0);
            call arithemit (cam+inx(mpp1),1);
            call emitinst (movei,i,0,0,0,0);
            stillcond = inx(mpp1);
            acc(reg(mp))=AVAIL;
            reg(mp) = i;
            type(mp) = ACCUMULATOR;
         end;
   end;
/*     82   <relation> ::= =                                         */
   inx(mp) = 2;
/*     83                | <                                         */
   inx(mp) = 1;
/*     84                | >                                         */
   inx(mp) = 7;
/*     85                | ~ =                                       */
   inx(mp) = 6;
/*     86                | ~ <                                       */
   inx (mp) = 5;
/*     87                | ~ >                                       */
   inx(mp) = 3;
/*     88                | < =                                       */
   inx(mp) = 3;
/*     89                | > =                                       */
   inx (mp) = 5;
/*     90   <string expression> ::= <arithmetic expression>          */
   ;
/*     91                         | <string expression> ||           */
/*     91                           <arithmetic expression>          */
    do; /* catenate two strings */
      call forcedescriptor (mp);
      call delete_move (mp,movem,reg(mp),0,a,0,3);
      acc(reg(mp)) = AVAIL;
      call forcedescriptor (sp);
      call delete_move (sp,movem,reg(sp),0,b,0,3);
      acc(reg(sp)) = AVAIL;
      call save_acs (2);
      if acc(11) ~= AVAIL then call emitinst (push,15,0,11,0,0);
      call emitinst (pushj,15,0,catentry,0,2);
      if acc(11) ~= AVAIL then call emitinst (pop,15,0,11,0,0);
      call restore_acs (2);
      i = findar;
      call emitinst (move,i,0,0,0,0);
      stillinzero = i;
      reg(mp) = i;
   end;
/*     92   <arithmetic expression> ::= <term>                       */
   ;
/*     93                             | <arithmetic expression> +    */
/*     93                               <term>                       */
   call arithemit (add,1);
/*     94                             | <arithmetic expression> -    */
/*     94                               <term>                       */
   call arithemit (sub,0);
/*     95                             | + <term>                     */
   call movestacks (mpp1, mp);
/*     96                             | - <term>                     */
   do;
      call movestacks (mpp1, mp);
      if type (mp) = CONSTANT then fixv (mp) = - fixv (mp);
      else
         do;
            call forceaccumulator (mp);
            call emitinst (movn,reg(mp),0,reg(mp),0,0);
         end;
   end;
/*     97   <term> ::= <primary>                                     */
   ;
/*     98            | <term> * <primary>                            */
   call arithemit (imul,1);
/*     99            | <term> / <primary>                            */
   call divide_code(1);
/*    100            | <term> mod <primary>                          */
   call divide_code(0);
/*    101   <primary> ::= <CONSTANT>                                 */
   ;
/*    102               | <VARIABLE>                                 */
   ;
/*    103               | ( <expression> )                           */
   call movestacks (mpp1, mp);
/*    104   <VARIABLE> ::= <identifier>                              */
   /* the following use is made of the parallel stacks below <VARIABLE>
          cnt      the number of subscripts
          fixl     the symbol table pointer
          fixv     builtin code if SPECIAL
          type     VARIABLE
          inx      zero or ACCUMULATOR of subscript
      after the VARIABLE is forced into an ACCUMULATOR
          type     ACCUMULATOR or DESCRIPT
          reg      current ACCUMULATOR
   */
   do;   /* find the identifier in the symbol table */
      call id_lookup (mp);
       if fixl (mp) = -1 then call undeclared_id (mp);
   end;
/*    105                | <subscript head> <expression> )           */
   do; /* either a procedure call, array, or builtin function */
      cnt (mp) = cnt (mp) + 1;          /* count subscripts */
      i = fixv (mp);                    /* zero or builtin function number */
      if i < 6 then do case i;
         /* case 0 -- array or call */
         do;
            if sytype (fixl (mp)) = PROCTYPE
             | sytype (fixl (mp)) = CHARPROCTYPE then call stuff_parameter;
            else
               if cnt (mp) > 1 then
                  call error ('multiple subscripts not allowed', 0);
               else
                  do;
                     call forceaccumulator (mpp1);
                     inx (mp) = reg(mpp1);
                  end;
         end;
         /* case 1 -- builtin function length */
         do;
            call forcedescriptor (mpp1);
            call emitinst(lsh,reg(mpp1),0,    -27,0,0);/* shift out address */
            type (mp) = ACCUMULATOR;
            reg(mp) = reg(mpp1);
         end;
         /* case 2 -- builtin function substr */
         do;  /* builtin function substr */
            if cnt(mp) = 2 then
               do;
                  if type(mpp1) = CONSTANT then
                     do;  /* emit a complex CONSTANT */
                        call emitconstant (shl(fixv(mpp1),27)-fixv(mpp1));
                        call emitinst (sub,reg(mp),0,adr,0,1);
                     end;
                  else
                     do;
                       call forceaccumulator (mpp1);
                       call emitinst (add,reg(mp),0,reg(mpp1),0,0);
                       call emitinst (lsh,reg(mpp1),0,    27,0,0);
                       call emitinst (sub,reg(mp),0,reg(mpp1),0,0);
                       acc(reg(mpp1)) = AVAIL;
                     end;
               end;
            else
               do;  /* three arguments */
                  if type(mpp1) = CONSTANT then
                     do;  /* make a CONSTANT length to or in */
                        call emitconstant (shl(fixv(mpp1),27));
                        call emitinst (ior,reg(mp),0,adr,0,1);
                     end;
                  else
                     do;
                        call forceaccumulator (mpp1);
                        call emitinst (lsh,reg(mpp1),0,    27,0,0);
                        call emitinst(ior,reg(mp),0,reg(mpp1),0,0);
                         acc(reg(mpp1)) = AVAIL;
                     end;
               end;
            type (mp) = DESCRIPT;
         end;
         /* case 3 -- builtin function byte */
         do;  /* builtin function byte */
            if cnt(mp) = 1 then
               do;
                  if type (mpp1) = CHRTYPE then
                     do;
                        fixv(mp) = byte(var(mpp1));
                        type (mp) = CONSTANT;
                     end;
                  else
                     do;
                        call forcedescriptor (mpp1);
                        call emitinst (and,reg(mpp1),0,addrmask,0,1);
                        /* fake a corebyte */
                        type(mpp1) = VARIABLE;
                        fixl(mpp1) = corebyteloc;
                        inx(mpp1) = reg(mpp1);
                        cnt(mpp1) = 1;
                        call forceaccumulator (mpp1);
                        type(mp) = type(mpp1);
                        reg(mp) = reg(mpp1);
                     end;
               end;
            else if cnt (mp) = 2 then
               do;
                  sp = mpp1;  /* so we can use arithemit */
                  call arithemit (add,1);
                  /* fake a corebyte */
                  type(mpp1) = VARIABLE;
                  fixl(mpp1) = corebyteloc;
                        cnt(mpp1) = 1;
                  inx(mpp1) = reg(mp);
                  call forceaccumulator(mpp1);
                  type(mp) = type(mpp1);
                  reg(mp) = reg(mpp1);
               end;
            else call error (toomsg || syt(fixl(mp)),0);
         end;
         /* case 4 -- builtin function shl */
         call shift_code (0);           /* <- */
         /* case 5 -- builtin function shr */
         call shift_code (1);           /* -> */
      end; /* case on i */
      else if i = 9 then call emit_inline(1);  /*built-in function inline */
      else if i = 18 then
         do;  /* builtin function addr */
            call forceaddress (mpp1);
            type (mp) = ACCUMULATOR;
         end;
      else do;    /* some sort of builtin function */
              call forceaccumulator(mpp1);
              if cnt(mp) = 1 then reg(mp) = reg(mpp1);
               else inx(mp) = reg(mpp1);
           end;
   end;
/*    106   <subscript head> ::= <identifier> (                      */
   do;
      call id_lookup(mp);
      if fixl(mp) = -1 then call undeclared_id (mp);
   end;
/*    107                      | <subscript head> <expression> ,     */
   do; /* builtin function or procedure call */
      cnt (mp) = cnt (mp) + 1;
      if fixv (mp) = 0 then
         do; /* not a builtin function */
            if sytype(fixl(mp)) = PROCTYPE
             | sytype(fixl(mp)) = CHARPROCTYPE then call stuff_parameter;
            else call forceaccumulator (mpp1);
         end;
      else if fixv(mp) = 2 | fixv (mp) = 3 then
         do; /* substr or byte */
            if cnt(mp) = 1 then
               do;
                  call forcedescriptor (mpp1);
                  type (mp) = ACCUMULATOR;
                  reg(mp) = reg(mpp1);
               end;
            else if cnt (mp) = 2 & fixv (mp) = 2 then
               do; /* just substr, we'll note error on byte later */
                  if type(mpp1) ~= CONSTANT | fixv(mpp1) ~= 0 then
                     do;
                        sp = mpp1;  /* so we can use arithemit */
                       call arithemit (add,1);
                        fixv(mp) = 2; /* if it commutes, arithmit changes it */
                     end;
                  call emitinst(and,reg(mp),0,addrmask,0,1);/* and out length */
               end;
            else call error (toomsg || syt(fixl(mp)),0);
         end;
      else if fixv(mp) = 4 | fixv (mp) = 5 then
         do; /* shr or shl */
            call forceaccumulator (mpp1);
            reg(mp) = reg(mpp1);
         end;
      else if fixv(mp) = 9 then call emit_inline(0); /* inline */
      else do; /* some sort of builtin function */
              if cnt (mp) = 1 then
                 do;
                    call forceaccumulator (mpp1); /* pick up the VARIABLE */
                    reg(mp) = reg(mpp1);
                 end;
              else call error (toomsg || syt(fixl(mp)),0);
           end;
   end;
/*    108   <CONSTANT> ::= <string>                                  */
   type (mp) = CHRTYPE;
/*    109                | <number>                                  */
   type (mp) = CONSTANT;
end;  /* of case on production number */
end synthesize;
  /*              syntactic parsing functions                              */
 conflict: procedure (current_state);
         declare i fixed, current_state fixed;
         /*   this proc is TRUE if the current token is not   */
         /*   a transition symbol from the current state      */
         /*   (a conflict therefore exists between the        */
         /*   current state and the next token)               */
         i = index1(current_state);   /*   starting point for state        */
                                      /*   transition symbols              */
         do i = i to i+index2(current_state)-1;   /*   compare with each   */
         if read1(i) = token then return (FALSE); /*   found it            */
         end;
         return (TRUE);   /*   not there   */
         end conflict;
 recover: procedure;
         declare answer bit(1);
         /*   this is a very crude error recovery procedure               */
         /*   it returns TRUE if the parse must be resumed in             */
         /*   a new state (the one in the current position of the state   */
         /*   stack)                                                      */
         /*   it returns FALSE if the parse is resumed with the same      */
         /*   state as was intended before recover was called             */
         answer = FALSE;
         /*   if this is the second successive call to recover, discard   */
         /*   one symbol (failsoft is set TRUE by scan)                   */
         if ~ failsoft & 1 then call scan;
         failsoft = FALSE;
         /*   find something solid in the text   */
         do while (~stopit(token) & 1);
         call scan;
         end;
         no_look_ahead_done = FALSE;
         /*   delete parse stack until the hard token is   */
         /*   legal as a transition symbol                 */
         do while conflict (state_stack(sp));
         if sp > 0
              then do;
                   /*   delete one item from the stack   */
                   sp = sp - 1;
                   answer = TRUE;   /*   parse to be resumed in new state   */
                   end;
              else do;   /*   stack is empty   */
                   /*   try to find a legal token (for start state)   */
                    call scan;
                   if token = eofile
                        then do;
                             /*   must stop compiling                */
                             /*   resume parse in an illegal state   */
                             answer = TRUE;
                             state_stack(sp) = 0;
                             return (answer);
                             end;
                   end;
         end;
         /*   found an acceptable token from which to resume the parse   */
         call printline ('resume:' || substr(pointer,length(pointer)-
            (line_length+cp-text_limit-lb-1)+length(bcd)),-1);
         return (answer);
         end recover;
 compilation_loop:
   procedure;
 
         declare overflow character initial (
         'stack overflow *** compilation aborted ***');
         declare i fixed, j fixed, state fixed;
         declare end_of_file character initial (
         'end of file found unexpectedly *** compilation aborted ***');
         /*   this proc parses the input string (by calling the scanner)   */
         /*   and calls the code emission proc (synthesize) whenever a     */
         /*   production can be applied                                    */
         /*   initialize                                                   */
         compiling = TRUE;
         state = START_STATE;
         sp = -1;
         /*   stop compiling if finished                                   */
 comp:   do while (compiling);
         /*   find which of the four kinds of states we are dealing with:  */
         /*   read,apply production,lookahead, or push state               */
         if state <= MAXR#
              then do;   /*   read state   */
                   sp = sp+1;   /*   add an element to the stack   */
                   if sp = STACKSIZE
                        then do;
                             call error (overflow,2);
                             return;
                             end;
                   state_stack(sp) = state;   /*   push present state   */
                   i = index1(state);         /*   get starting point   */
                   if no_look_ahead_done
                        then do;   /*   read if necessary   */
                             call scan;
                             no_look_ahead_done = FALSE;
                             end;
                   /*   compare token with each transition symbol in    */
                   /*   read state                                      */
                    do i = i to i+index2(state)-1;
                   if read1(i) = token
                        then do;   /*   found it   */
                             var(sp) = bcd;
                             fixv(sp) = number_value;
                             fixl(sp) = card_count;
                             ppsave(sp) = pp;
                             state = read2(i);
                             no_look_ahead_done = TRUE;
                             go to comp;
                             end;
                   end;
                   /*   found an error   */
                   call error ('illegal symbol pair: ' ||
                               vocab(state_name(state)) || x1 ||
                               vocab(token),1);
                   call stack_dump;    /*  display the stack   */
                   /*   try to recover   */
                   if recover
                        then do;
                             state = state_stack(sp);   /*   new starting pt  */
                             if state = 0
                                  then do;   /*   unexpected eofile   */
                                       call error (end_of_file,2);
                                       return;
                                       end;
                             end;
                   sp = sp-1;   /*   stack at sp contains junk   */
                   end;
              else
         if state > MAXP#
              then do;   /*   apply production state   */
                   /*   sp points at right end of production   */
                   /*   mp points at lest end of production   */
                   mp = sp-index2(state);
                   mpp1 = mp+1;
                   call synthesize (state-MAXP#);   /*   apply production   */
                   sp = mp;   /*   reset stack pointer   */
                   i = index1(state);
                   /*   compare top of state stack with tables   */
                   j = state_stack(sp);
                   do while apply1(i) ~= 0;
                   if j = apply1(i) then go to top_match;
                   i = i+1;
                   end;
                   /*   has the program goal been reached   */
        top_match: if apply2(i) =0
                        then do;   /*   yes it has   */
                             compiling = FALSE;
                             return;
                             end;
                   state = apply2(i);   /*   pick up the next state   */
                   end;
              else
         if state <= MAXL#
              then do;   /*   lookahead state   */
                    i = index1(state);   /*   index into the table   */
                   if no_look_ahead_done
                        then do;   /*   get a token   */
                             call scan;
                             no_look_ahead_done = FALSE;
                             end;
                   /*   check token against legal lookahead transition symbols*/
                   do while look1(i) ~= 0;
                   if look1(i) = token
                        then go to look_match;   /*   found one   */
                   i = i+1;
                   end;
       look_match: state = look2(i);
                   end;
              else do;   /*   push state   */
                   sp = sp+1;   /*   push a non-terminal onto the stack   */
                   if sp = STACKSIZE
                        then do;
                             call error (overflow,2);
                             return;
                             end;
                   /*   push a state # into the state_stack   */
                   state_stack(sp) = index2(state);
                   /*   get next state                        */
                   state = index1(state);
                   end;
         end;   /*   of compile loop   */
         end compilation_loop;
print_time:
   procedure (text, time);
   /* print text followed by time, which is in milliseconds */
      declare text character, time fixed;
      k = time;
      i = k / 60000;
      j = k mod 60000 / 1000;
      k = k mod 1000;
      call printline (text || i || ':' || j || '.' || k,-1);
   end print_time;
 
   /*   e x e c u t i o n   s t a r t s   h e r e                          */
   declare time_start fixed,
           time_init fixed,
           time_compile fixed,
           time_finish fixed;
   time_start = runtime;           /* get time(cpu) started*/
   call initialize;
   time_init = runtime;     /* time to initialize */
   call compilation_loop;
   time_compile = runtime;     /* time to compile the program*/
   control(byte('E')) = FALSE;
   control(byte('B')) = FALSE;
   subtitle = '';
   if control(byte('S')) then call symboldump;
   else EJECT_PAGE;
   /* now enter the value of ndescript                                        */
   call emitlabel (ndesc,5);            /* generate label */
   if control(byte('A')) then
      output(DATAFILE) = '$' || ndesc || ':'; /* label for assembler */
   call emitdataword (dsp-1);           /* put down number of desc's */
   if control(byte('A')) then
      output(DATAFILE) = 's=.;';           /* start string segment */
   /* add the descriptors to the data segment                                 */
   do i = 0 to dsp-1;
      if control(byte('A')) then
         output(DATAFILE)='       byte (9)'||descl(i)|| '(27)' ||desca(i)|| ';';
      call output_dataword (shl(descl(i),27) + desca(i), dp);
      call emitlabel (i,3);
      dp = dp + 1;
   end;
   /* final code for system interface                                         */
   call emitinst (4,0,0,0,0,0);
   call flush_data_buffer;
   call flush_labels;
   do while code_tail ~= code_head;
      call output_codeword;
      end;
   call output_codeword;
   call flush_code_buffer;
   if control(byte('A')) then
      do;
         output (CODEFILE) = '       end $0;';
         /* copy code file to end of data file */
         codestring = input(CODEFILE);
         do while length(codestring) > 0;
            output(DATAFILE) = codestring;
            codestring = input(CODEFILE);
         end;
         output (CODEFILE) = ' ';
      end;
   file(RELFILE) = SYMB_TYPE + 2;      /* generate external refs */
   file(RELFILE) = "(3)040000000000";
   file(RELFILE) = "(3)600000000000" + radix50 ('xpllib');
   file(RELFILE) = library;
   file(RELFILE) = START_TYPE + 1;
   file(RELFILE) = "(3)200000000000";
   file(RELFILE) = "(3)400000" + startloc;
   file(RELFILE) = END_TYPE + 2;
   file(RELFILE) = "(3)240000000000";
   file(RELFILE) = "(3)400000" + pp;
   file(RELFILE) = dp;
   time_finish = runtime;   /* time to do all but final stats */
   call printline (substr(x70, 0, 40) || 'c o m p i l e r   s t a t i s t i c s',-1);
   call printline (card_count || ' lines containing ' || statement_count ||
      ' statements were compiled.',0);
   if error_count = 0 then call printline ('no errors were detected.',-1);
   else if error_count > 1 then
      call printline (error_count || ' errors (' || severe_errors
      || ' severe) were detected.',-1);
   else if severe_errors = 1 then call printline ('one severe error was detected.',-1);
      else call printline ('one error was detected.',-1);
    if previous_error > 0 then
       call printline ('last error was on line ' || previous_error ,-1);
   call printline (pp || ' words of program, ' || dp-dsp || ' words of data, and ' ||
      dsp || ' words of descriptors.  total core requirement ' || pp+dp ||
      ' words.',-1);
/* now compute times and print them */
   time_init = time_init - time_start;
   time_compile = time_compile - time_start;
   time_finish = time_finish - time_start;
   call print_time ('total time in compiler    = ',time_finish);
   call print_time ('initialization time       = ',time_init);
   call print_time ('actual compilation time   = ',time_compile - time_init);
   call print_time ('post-compilation clean-up = ',time_finish-time_compile);
   if control(byte('D')) then call dumpit;
eof eof eof eof eof eof eof eof eof eof eof eof eof eof eof eof eof eof eof eof
