/*
**	Dump PDP-11 object file
**
**	Author: Daniel Weaver
**
**	This program will dump PDP-10 relocatable object files.
**	It was used to validate the object file created by the PDP-10
**	XPL compiler.  This program requires 64-bit integers.
**
**	This code was written to be compiled with the XPL to C source translator.
**		https://sourceforge.net/projects/xpl-compiler/
*/

declare WORD literally 'bit(36)';
declare TRUE literally '1';
declare FALSE literally '0';

/* I/O variables */
declare rel_unit fixed;
declare rel_filename character;

/* Object file read variables */
declare raw character;		/* Input data buffer */
declare four_bits fixed;	/* leftover bits */
declare extra fixed;		/* TRUE if 'four_bits' is valid */
declare reading fixed;		/* TRUE if still reading input */

/* Object file format definitions */

declare CODE_TYPE literally '"(3)1000000"';   /* code & data type block */
declare SYMB_TYPE literally '"(3)2000000"';   /* symbol defn type block */
declare HISEG_TYPE literally '"(3)3000000"';  /* high segment type block */
declare END_TYPE literally '"(3)5000000"';    /* end type block */
declare NAME_TYPE literally '"(3)6000000"';   /* name type block */
declare START_TYPE literally '"(3)7000000"';  /* start address type block */
declare INTREQ_TYPE literally '"(3)10000000"'; /* internal request type block */
declare BLOCK_MASK literally '"(3)17000000"'; /* MASK used to select block type */
declare BLOCK_LENGTH_MASK literally '"(3)00777777"'; /* MASK used to select block size */

declare loc fixed;

/* end of definitions for relocatable binary files */

declare pp fixed;

declare opname(15) character initial (
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

declare x1 character initial(' ');
declare x7 character initial('       ');

/*
**	get_byte
**
**	Return the next 8 bits from the input stream.
*/
get_byte:
    procedure fixed;
	declare w fixed;

	if length(raw) = 0 then do;
		raw = input(rel_unit);
		if length(raw) = 0 then do;
			reading = FALSE;
		end;
	end;
	w = byte(raw);
	raw = substr(raw, 1);
	return w & 255;
    end get_byte;

/*
**      read_word()
**
**      Read 36 bits from the input stream.
**
**      Return the next 36 bit word
*/
read_word:
   procedure WORD;
	declare w WORD;
	declare i fixed;

	w = 0;
	if extra then do;
		w = four_bits & 15;
		do i = 0 to 3;
			w = shl(w, 8);
			w = w | get_byte;
		end;
		extra = 0;
	end;
	else do;
		do i = 0 to 3;
			w = shl(w, 8);
			w = w | get_byte;
		end;
		four_bits = get_byte;
		w = shl(w, 4) | shr(four_bits, 4);
		extra = 1;
	end;
	return w;
   end read_word;

/*
**	disassemble(word)
**
**	Disassemble one instruction
*/
disassemble:
    procedure(w, relocation);
	declare w WORD;
	declare (opcode, treg, indirect, operand, ireg, relocation) fixed;
	declare reloc(5) character initial('', 'd+', 'p+', 's+', '$', '$'),
              indir(1) character initial ('', '@');
	declare i fixed;
	declare card character;

	opcode = shr(w, 27) & "(3)777";
	treg = shr(w, 23) & 15;
	indirect = shr(w, 22) & 1;
	ireg = shr(w, 18) & 15;
	operand = w & "(3)777777";

	i = shr(opcode, 5);
	card = x7 || substr(opname(i), (opcode - i * 32) * 6, 6) || x1
		|| treg || ',' || indir(indirect) || reloc(relocation)
		|| operand;
	if ireg > 0 then card = card || '(' || ireg || ')';
	card = card || '; p' || pp;

	call xprintf("(c)    %012lo  %s\n", w, card);

    end disassemble;

/*
**	code_block(word)
**
**	Display a code block
*/
code_block:
    procedure(w);
	declare (w, x, y) WORD;
	declare (i, j, l) fixed;

	x = read_word;
	y = read_word;
	l = (w & BLOCK_LENGTH_MASK) - 2;
	if i > 18 then do;  /* What does this mean? */
		output = 'FIXME l = ' || l;
		return;
	end;
	i = 0;
	if (y & "(3)400000") = 0 then do;
		call xprintf("(c)%012lo %012lo %012lo CODE", w, x, y);
		do while(reading & i <= l);
			if (i & 3) = 0 then call xprintf("(c)\n   ", w);
			w = read_word;
			call xprintf("(c) %012lo", w);
			i = i + 1;
		end;
		output = '';
	end;
	else do;
		call xprintf("(c)%012lo %012lo %012lo CODE\n", w, x, y);
		do while(reading & i <= l);
			w = read_word;
			call disassemble(w, 0);
			pp = pp + 1;
			i = i + 1;
		end;
	end;
    end code_block;

/*
**	generic_block(word, header, description)
**
**	Display a block using description
*/
generic_block:
    procedure(w, header, description);
	declare w WORD, header fixed;
	declare description character;
	declare (i, j, l) fixed;

	call xprintf("(c)%012lo", w);
	l = w & BLOCK_LENGTH_MASK;
	do i = 1 to header;
		w = read_word;
		call xprintf("(c) %012lo", w);
		l = l - 1;
	end;
	call xprintf("(c) %s", description);
	i = 0;
	do while(reading & i <= l);
		if (i & 3) = 0 then call xprintf("(c)\n   ", w);
		w = read_word;
		call xprintf("(c) %012lo", w);
		i = i + 1;
	end;
	output = '';
    end generic_block;

process:
   procedure;
	declare i fixed;
	declare (word, block) WORD;

	rel_filename = '';
	do i = 1 to argc - 1;
		if byte(argv(i)) = byte('-') then do;
			/* Options */
		end;
		else do;
			rel_filename = argv(i);
		end;
	end;

	if length(rel_filename) = 0 then do;
		output(1) = 'Missing object filename.';
		return;
	end;

	rel_unit = xfopen(rel_filename, 'rb');
	if rel_unit < 0 then do;
		output(1) = 'File open error: ' || rel_filename;
		return;
	end;

	loc = 0;
	reading = TRUE;
	word = read_word;
	do while(reading);
		block = word & BLOCK_MASK;
		if block = CODE_TYPE then call code_block(word);
		else
		if block = SYMB_TYPE then call generic_block(word, 0, 'SYMB');
		else
		if block = HISEG_TYPE then call generic_block(word, 0, 'HISEG');
		else
		if block = END_TYPE then call generic_block(word, 0, 'END');
		else
		if block = NAME_TYPE then call generic_block(word, 0, 'NAME');
		else
		if block = START_TYPE then call generic_block(word, 0, 'START');
		else
		if block = INTREQ_TYPE then call generic_block(word, 1, 'INTREQ');
		else call generic_block(word, 0, 'Unknown');

		word = read_word;
		loc = loc + 1;
	end;

   end process;

rel_unit = -1;
call process;
if rel_unit >= 0 then call xfclose(rel_unit);

eof;
