   /*  analyzer                                                                 
                 the syntax analysis and table building program                 
                 of the xpl system.                                             
                                                                                
      j. j. horning and w. m. mc keeman      stanford university                
                                                                                
      this program builds tables directly acceptable for use in                 
         the compiler xcom or the proto-compiler skeleton.                      
                                                                                
   input to analyzer may be nearly "free format."                               
   cards with the character $ in column 1 are treated as comment or control     
      cards, and listed unchanged.  the character in column 2 is the control    
      character, as follows:                                                    
         l   complement listing mode,                                           
         t   complement tracing mode,                                           
         p   complement punching mode,                                          
         o   complement line printer listing of computed "card output,"         
         i   complement iterative improvement mode,                             
         eog   end of grammar;  (another grammar follows).                      
                                                                                
   blank cards are ignored.                                                     
   productions are placed one to a card.                                        
   a token is                                                                   
      any consecutive group of non-blank characters not beginning with a  "<"   
         and followed by a blank,                                               
      the character "<"  followed by a blank,                                   
      the character "<"  followed by a non-blank character and then any         
         string of blank or non-blank characters up to and including the        
         next occurrence of the character "<".                                  
                                                                                
   if column 1 is non-blank, the first token on the card is taken to be the     
      left part of the production;  otherwise, the left part is taken to be     
      the left part of the previous production.                                 
   the balance of the card (up to five tokens) is taken to be the right part.   
   any symbol which does not occur as a left part is a terminal symbol.         
   any symbol which occurs only as a left part is a goal symbol.                
   all productions with the same left part must be grouped.                     
                                                                                
   productions are reformatted for readability (including the insertion of      
      the meta-symbols  ::=  and  |  )  before listing.                         
   blanks between tokens are not significant.                                   
                                                                       */       
   /* first come the global variable declarations:        */                    
                                                                                
   declare v(255) character, (left_part, right_head) (255) bit(8),              
      production(255) bit(32), (on_left, on_right) (255) bit(1);                
   declare index(255) bit(8), (ind, ind1) (255) bit(16);                        
   declare sort#(255) fixed, ambiguous bit(1);                                  
   declare (nsy, npr, sp, cp, nt, level, goal_symbol) fixed;                    
                                                                                
   declare control(255) bit(1);                                                 
   declare TRUE literally '1', FALSE literally '0';                             
   declare CARRIAGE literally '1', PUNCH literally '2', DISK literally '3',     
      page character initial ('1'), double character initial ('0'),             
      EJECT_PAGE literally 'output(1) = page',                                  
      DOUBLE_SPACE literally 'output(1) = double';                              
   declare DOLLAR literally 'byte(''$'')', BLANK literally 'byte('' '')';       
   declare change bit(1), work("4000") bit(8);                                  
   declare head(255) fixed, tail(255) bit(8);                                   
   declare STACKLIMIT literally '200', TEXTLIMIT literally '255',               
      DEPTH literally '255';   /*  must be at least 255  */                     
   declare stack(STACKLIMIT) bit(8), text(TEXTLIMIT) bit(8),                    
      token_save(DEPTH) bit(8), token fixed, mp_save(DEPTH) bit(8), mp fixed,   
      tp_save(DEPTH) bit(8), tp fixed, p_save(DEPTH) bit(8), p fixed;           
   declare head_table("2000") bit(8);                                           
      declare empty character initial('                                         
                                       ');  /* image of BLANK card  */          
   declare half_line character initial ('                                       
                           '), x12 character initial ('            ');          
   declare cardimage character, outcard character, s character, t character;    
   declare (netry, first_time, last_time, this_time) fixed;                     
   declare count(3) fixed;                                                      
   declare print(3) character initial (' ', 'y', 'n', '#');                     
   declare dots character initial (' ... ');                                    
   declare value(1) fixed initial (2, 1);                                       
   declare (i, j, k, l, m) fixed;                                               
   declare error_count fixed;                                                   
   declare terminator fixed;                                                    
   declare maxnf11 literally '5000', MAXNTRIP literally '1000';                 
   declare f11(maxnf11) fixed, nf11 fixed;                                      
   declare triple(MAXNTRIP) fixed, tv(MAXNTRIP) bit(2), ntrip fixed;            
   declare stacking bit(1) initial (TRUE);  /* controls batching of grammars  */
   declare MAXTROUBLE literally '50', trouble1(MAXTROUBLE) bit(8),              
      trouble2(MAXTROUBLE) bit(8), trouble_count fixed;                         
   declare (basic_nsy, basic_npr) fixed;                                        
   declare iteration_count fixed;                                               
                                                                                
   /* now some data packing/unpacking procedures used below   */                
                                                                                
is_head:                                                                        
   procedure (i, j) bit(1);                                                     
   /* this procedure decodes the packed head table.  TRUE if v(j) is a head     
      of v(i)     */                                                            
   /* we must simulate double subscript for array                               
      head_table(0:255, 0:255) bit(1)  */                                       
                                                                                
   declare (i, j) fixed;                                                        
   return 1 & shr(head_table(shl(i,5)+shr(j,3)), j & 7);                        
end is_head;                                                                    
                                                                                
set_head:                                                                       
   procedure (i, j);                                                            
   /* this procedure adds v(j) as a head of v(i) in the head_table  */          
                                                                                
   declare (i, j, k, l) fixed;                                                  
   change = TRUE;                                                               
   k = shl(i, 5) + shr(j, 3);                                                   
   l = shl(1, j & 7);                                                           
   head_table(k) = head_table(k) | l;                                           
end set_head;                                                                   
                                                                                
clear_heads:                                                                    
   procedure;                                                                   
   declare i fixed;                                                             
   do i = 0 to "2000";                                                          
      head_table(i) = 0;                                                        
   end;                                                                         
end clear_heads;                                                                
                                                                                
get:                                                                            
   procedure (i, j) bit(2);                                                     
   declare (i, j) fixed;                                                        
   /* this procedure decodes a 2-bit entry in the work matrix  */               
   /* we must simulate double subscript for array                               
     work(0:255, 0:255) bit(2)  */                                              
                                                                                
   return 3 & shr(work(shl(i,6)+shr(j,2)), shl(j & 3, 1));                      
end get;                                                                        
                                                                                
set:                                                                            
   procedure (i, j, val);                                                       
   /* this procedure or's a 2-bit val into the work matrix    */                
                                                                                
   declare (i, j, val) fixed;                                                   
   declare (k, l) fixed;                                                        
   k = shl(i, 6) + shr(j, 2);                                                   
   l = shl(val & 3, shl(j & 3, 1));                                             
   work(k) = work(k) | l;                                                       
end set;                                                                        
                                                                                
clear_work:                                                                     
   procedure;                                                                   
   declare i fixed;                                                             
   do i = 0 to "4000";                                                          
      work(i) = 0;                                                              
   end;                                                                         
end clear_work;                                                                 
                                                                                
pack:                                                                           
   procedure (b1, b2, b3, b4) fixed;                                            
   /* this procedure has the value of the 4 bytes packed into a 32-bit word  */ 
                                                                                
   declare (b1, b2, b3, b4) bit(8);                                             
   return (shl(b1,24) + shl(b2,16) + shl(b3,8) + b4) & "ffffffff";
end pack;                                                                       
                                                                                
error:                                                                          
   procedure (message);                                                         
      declare message character;                                                
      output = '*** error, ' || message;                                        
      error_count = error_count + 1;                                            
   end error;                                                                   
                                                                                
enter:                                                                          
   procedure (env, val);                                                        
   /* this procedure records together the 2-bit val 's for each unique env      
         to assist table lookup, the env 's are stored in ascending order.      
         they are located by a binary search    */                              
                                                                                
   declare (env, val, i, j, k) fixed;                                           
   netry = netry + 1; /* count entries vs. unique entries */                    
   i = 0;  k = ntrip + 1;                                                       
   do while i + 1 < k; /* binary look-up */                                     
      j = shr(i+k,1);                                                           
      if triple(j) > env then k = j;                                            
      else if triple(j) < env then i = j;                                       
      else                                                                      
         do;                                                                    
            tv(j) = tv(j) | val;                                                
            return;                                                             
         end;                                                                   
   end;                                                                         
   if ntrip >= MAXNTRIP then                                                    
      do;                                                                       
         call error ('too many triples for table');                             
         ntrip = 0;                                                             
      end;                                                                      
   do j = 0 to ntrip - k;  /* make room in table for new entry */               
      i = ntrip - j;                                                            
      triple(i+1) = triple(i);                                                  
      tv(i+1) = tv(i);                                                          
   end;                                                                         
   ntrip = ntrip + 1;                                                           
   triple(k) = env;                                                             
   tv(k) = val;                                                                 
end enter;                                                                      
                                                                                
add_trouble:                                                                    
   procedure (left, right);                                                     
      declare (left, right) fixed;                                              
      declare i fixed;                                                          
      if left > basic_nsy then return;                                          
      if left = terminator then return;                                         
      if trouble_count = MAXTROUBLE then return;  /* trouble enough  */         
      do i = 1 to trouble_count;                                                
         if trouble1(i) = left then if trouble2(i) = right then return;         
      end;                                                                      
      trouble_count = trouble_count + 1;                                        
      trouble1(trouble_count) = left;                                           
      trouble2(trouble_count) = right;                                          
   end add_trouble;                                                             
                                                                                
line_out:                                                                       
   procedure (number, line);                                                    
   /* number a line and print it  */                                            
                                                                                
   declare number fixed, line character;                                        
   declare n character;                                                         
   n = number;  number = 6 - length(n);  /* 6 = margin */                       
   output = substr(empty, 0, number) || n || '   ' || line;                     
end line_out;                                                                   
                                                                                
build_card:                                                                     
   procedure (item);                                                            
   /* add item to outcard and PUNCH if card boundary exceeded */                
                                                                                
   declare item character;                                                      
   if length(item) + length(outcard) >= 80 then                                 
      do;                                                                       
         if control(byte('P')) then output(PUNCH) = outcard;                    
         if control(byte('O')) then                                             
            output = '--- card output ---|' || outcard;                         
         outcard = '      ' || item;                                            
      end;                                                                      
   else outcard = outcard || ' ' || item;                                       
end build_card;                                                                 
                                                                                
punch_card:                                                                     
   procedure (item);                                                            
   /*  PUNCH outcard and item  */                                               
                                                                                
   declare item character;                                                      
   call build_card (item);                                                      
   if control(byte('P')) then output(PUNCH) = outcard;                          
   if control(byte('O')) then                                                   
      output = '--- card output ---|' || outcard;                               
   outcard = '  ';                                                              
end punch_card;                                                                 
                                                                                
print_matrix:                                                                   
   procedure (title, source);                                                   
   /* print and label the matrix specified by source (head_table or work)  */   
                                                                                
   declare title character, source fixed;                                       
   declare (i, j, k, l, m, n, bot, top, margin_size, number_across, wide) fixed,
      (margin, line, waste, bar, pages) character,                              
      digit(9) character initial ('0','1','2','3','4','5','6','7','8','9'),     
      NUMBER_HIGH literally '48',                                               
      GS literally '16';                                                        
   if source = 1 then wide = nt;  else wide = nsy;                              
   margin_size = 5;                                                             
   do i = 1 to nsy;                                                             
      if length(v(i)) >= margin_size then margin_size = length(v(i)) + 1;       
   end;                                                                         
   margin = substr('                                                            
                 ', 0, margin_size);                                            
   waste = margin || '          ';                                              
   number_across = (122 - margin_size)/(GS + 1)*GS;                             
   do i = 0 to 3;                                                               
      count(i) = 0;                                                             
   end;                                                                         
   m = 0;                                                                       
   i = (wide-1)/number_across + 1;                                              
   pages = ((nsy-1)/NUMBER_HIGH + 1)*i;                                         
   do i = 0 to (wide-1)/number_across;                                          
      bot = number_across*i + 1;                                                
      top = number_across*(i+1);                                                
      if top > wide then top = wide;                                            
      bar = substr(waste, 1) || '+';                                            
      do l = bot to top;                                                        
         bar = bar || '-';                                                      
         if l mod GS = 0 then bar = bar || '+';                                 
      end;                                                                      
      if top mod GS ~= 0 then bar = bar || '+';                                 
      do j = 0 to (nsy-1)/NUMBER_HIGH;                                          
         /*  once per page of printout  */                                      
         EJECT_PAGE;                                                            
         m = m + 1;                                                             
         output = title || ':  page ' || m || ' of ' || pages;                  
         DOUBLE_SPACE;                                                          
         l = 100;                                                               
         do while l > 0;                                                        
            line = waste;                                                       
            do n = bot to top;                                                  
               if n < l then line = line || ' ';                                
               else line = line || digit(n/l mod 10);                           
               if n mod GS = 0 then line = line || ' ';                         
            end;                                                                
            output = line;                                                      
            l = l / 10;                                                         
         end;                                                                   
         output = bar;                                                          
         n = NUMBER_HIGH*(j+1);                                                 
         if n > nsy then n = nsy;                                               
         do k = NUMBER_HIGH*j + 1 to n;                                         
            l = length(v(k));                                                   
            line = v(k) || substr(margin, l) || '|';                            
            do l = bot to top;                                                  
               if source ~= 0 then                                              
                  do;                                                           
                     n = get (k, l);                                            
                     line = line || print(n);                                   
                     count(n) = count(n) + 1;                                   
                  end;                                                          
               else line = line || print(is_head (k, l));                       
               if l mod GS = 0 then line = line || '|';                         
            end;                                                                
            if top mod GS ~= 0 then line = line || '|';                         
            call line_out (k, line);                                            
            if k mod GS = 0 then                                                
               output = bar;                                                    
         end;                                                                   
         if k mod GS ~= 1 then output = bar;                                    
      end;                                                                      
   end;                                                                         
   DOUBLE_SPACE;                                                                
   if source ~= 0 then                                                          
      do;                                                                       
         output = 'table entries summary:';                                     
         do i = 0 to 3;                                                         
            call line_out (count(i), print(i));                                 
         end;                                                                   
      end;                                                                      
end print_matrix;                                                               
                                                                                
print_triples:                                                                  
   procedure (title);                                                           
   /* format and print the (2,1) triples for c1  */                             
                                                                                
   declare title character, (i, j) fixed;                                       
   if ntrip = 0 then                                                            
      do;                                                                       
         DOUBLE_SPACE;                                                          
         output = 'no triples required.';                                       
         count(1) = 0;   /* so we don't PUNCH any  */                           
         return;                                                                
      end;                                                                      
   EJECT_PAGE;                                                                  
   output = title || ':';                                                       
   DOUBLE_SPACE;                                                                
   do i = 1 to 3;                                                               
      count(i) = 0;                                                             
   end;                                                                         
   do i = 1 to ntrip;                                                           
      j = triple(i);                                                            
      k = tv(i);                                                                
      if k = 3 then                                                             
         do;                                                                    
            call error ('stacking decision cannot be made with (2,1) context:');
            call add_trouble (shr(j, 16), shr(j, 8) & "ff");                    
         end;                                                                   
      call line_out (i, print(k) || ' for  ' || v(shr(j, 16)) || ' ' ||         
         v(shr(j, 8)&"ff") || ' ' || v(j&"ff"));                                
      count(k) = count(k) + 1;                                                  
   end;                                                                         
   DOUBLE_SPACE;                                                                
   output = netry || ' entries for ' || ntrip || ' triples.';                   
   DOUBLE_SPACE;                                                                
   output = 'table entries summary:';                                           
   do i = 1 to 3;                                                               
      call line_out (count(i), print(i));                                       
   end;                                                                         
end print_triples;                                                              
                                                                                
build_right_part:                                                               
   procedure (p);                                                               
      declare (p, pr) fixed;                                                    
      pr = production(p);                                                       
      t = '';                                                                   
      do while pr ~= 0;                                                         
         t = ' ' || v(pr&"ff") || t;                                            
         pr = shr(pr, 8);                                                       
      end;                                                                      
      t = v(right_head(p)) || t;                                                
   end build_right_part;                                                        
                                                                                
output_production:                                                              
   procedure (p);                                                               
      declare p fixed;                                                          
      call build_right_part(p);                                                 
      call line_out (p, v(left_part(p)) || '  ::=  ' || t);                     
   end output_production;                                                       
                                                                                
print_time:                                                                     
   procedure;                                                                   
   /* output elapsed times  */                                                  
                                                                                
   declare (i, j) fixed, t character;                                           
   DOUBLE_SPACE;                                                                
   this_time = time;                                                            
   i = this_time - last_time;                                                   
   j = i mod 100;                                                               
   i = i / 100;                                                                 
   t = 'time used was ' || i || '.';                                            
   if j < 10 then t = t || '0';                                                 
   output = t || j || ' seconds.';                                              
   i = this_time - first_time;                                                  
   j = i mod 100;                                                               
   i = i / 100;                                                                 
   t = 'total time is ' || i || '.';                                            
   if j < 10 then t = t || '0';                                                 
   output = t || j || ' seconds.';                                              
   last_time = this_time;                                                       
end print_time;                                                                 
                                                                                
look_up:                                                                        
   procedure (symbol) bit(8);  /* get index of symbol in v  */                  
   declare symbol character;                                                    
   declare j fixed;                                                             
   do j = 1 to nsy;                                                             
      if v(j) = symbol then return j;                                           
   end;                                                                         
   if j = 256 then                                                              
      do;                                                                       
         call error ('too many symbols');                                       
         j = 1;                                                                 
      end;                                                                      
   /* add symbol to v  */                                                       
   nsy = j;                                                                     
   v(j) = symbol;                                                               
   return j;                                                                    
end look_up;                                                                    
                                                                                
expand:                                                                         
   procedure (f11, p);  /* expand production p in the context of f11  */        
   declare (f11, i, j, p, oldp) fixed;                                          
   /* oldp remembers argument p from previous call to save repeated effort */   
   if p ~= oldp then                                                            
      do;                                                                       
         oldp = p;                                                              
         sp = 2;                                                                
         stack(sp) = right_head(p);                                             
         j = production(p);                                                     
         do while j ~= 0; /* unpack production into stack */                    
            i = shr(j, 24);
            if i ~= 0 then                                                      
               do;                                                              
                  sp = sp + 1;                                                  
                  stack(sp) = i;                                                
               end;                                                             
            j = shl(j, 8) & "ffffffff";
         end;                                                                   
      end;                                                                      
   stack(1) = shr(f11, 8) & "ff";  /* left context */                           
   stack(sp+1) = f11 & "ff";         /* right context */                        
end expand;                                                                     
                                                                                
                                                                                
   /*  now the working procedures  */                                           
                                                                                
read_grammar:                                                                   
   procedure;  /*  read in and list a grammar  */                               
   declare (p, long) fixed;                                                     
                                                                                
   scan:                                                                        
     procedure bit(8); /* get a token from input cardimage  */                  
      declare lp fixed, LEFT_BRACKET literally 'byte(''<'')',                   
         RIGHT_BRACKET literally 'byte(''>'')', stop fixed;                     
      do cp = cp to long;                                                       
         if byte(cardimage,cp) ~= BLANK & byte(cardimage,cp)
            ~= 9 then      /* not a space or a tab */
            do;                                                                 
               lp = cp; /* mark left boundary of symbol */                      
               if byte(cardimage,cp) = LEFT_BRACKET & byte(cardimage,cp+1)      
                  ~= BLANK then                                                 
                  stop = RIGHT_BRACKET;                                         
                  else stop = BLANK;                                            
               do cp = cp + 1 to long;                                          
                  if byte(cardimage, cp) = stop then go to delimit;             
               end;                                                             
               if stop ~= BLANK then                                            
                  do;                                                           
                     call error ('unmatched bracket: <');                       
                     cp = cp - 1;                                               
                     do while byte(cardimage, cp) = BLANK;  /* error recovery */
                        cp = cp - 1;                                            
                     end;                                                       
                  end;                                                          
            delimit:                                                            
               if stop ~= BLANK then cp = cp + 1; /* pick up the > */           
               t = substr(cardimage, lp, cp-lp);  /* pick up the symbol */      
               return look_up(t);                                               
            end;                                                                
      end;  /* end of card  */                                                  
      t = '';                                                                   
      return 0;                                                                 
   end scan;                                                                    
                                                                                
   get_card:                                                                    
      procedure bit(1);  /* read the next card  */                              
      cp = 0;                                                                   
      do while TRUE;                                                            
         cardimage = input;  /* get the card */                                 
         long = length(cardimage) - 1;                                          
         if long < 0 then                                                       
            do;    /*  end of file detected  */                                 
               stacking = FALSE;                                                
               return FALSE;                                                    
            end;                                                                
         if byte(cardimage) = DOLLAR then                                       
            do;  /* control card or comment */                                  
               if substr(cardimage, 1, 3) = 'eog' then return FALSE;            
               if control(byte('L')) then output = cardimage;                   
               control(byte(cardimage,1)) = ~ control(byte(cardimage,1));       
            end;                                                                
         else if length(cardimage) ~= 0 & cardimage ~= empty then
                  return TRUE;
      end;                                                                      
   end get_card;                                                                
                                                                                
   sort_v:
      procedure;  /* sort the symbol table  */
      do i = 1 to nsy;
          /* sort on 1.  terminal vs. non-terminal
                        2.  length of symbol
                           3.  original order of occurrence  */
         sort#(i) = shl(on_left(i), 16) | shl(length(v(i)), 8) | i;
         sort#(i) = sort#(i) & "ffffffff";
      end;
      /* bubble sort  */
      k, l = nsy;
      do while k <= l;
         l = 0;
         do i = 2 to k;
            l = i - 1;
            if sort#(l) > sort#(i) then
               do;
                  j = sort#(l);  sort#(l) = sort#(i);  sort#(i) = j;
                  t = v(l);  v(l) = v(i);  v(i) = t;
                  k = l;
               end;
         end;
      end;
      do i = 1 to nsy; /* build table to locate sorted symbols of v */
         index(sort#(i)&"ff") = i;
      end;
      nt = nsy;  /* prepare to count non-terminal symbols */
      do while sort#(nt) > "10000";  nt = nt - 1;  end;
      /* substitute new index numbers in productions  */
      do i = 1 to npr;
         left_part(i) = index(left_part(i));
         j = index(right_head(i));
         on_right(j) = TRUE;
         right_head(i) = j;
         l = production(i);
         do k = 0 to 3;
            j = index(shr(l,24)&"ff"); /* insurance for 36 bits */
            on_right(j) = TRUE;
            l = shl(l,8) + j;
         end;
         l = l & "ffffffff";
         production(i) = l;
      end;
      terminator = index(1);  /* add _|_ to vocabulary */
      on_right(terminator) = TRUE;
   end sort_v;                                                         
 
   print_date:
      procedure (message, d);                                                   
         declare message character, d fixed;                                    
         declare month(11) character initial ('january', 'february', 'march',   
            'april', 'may', 'june', 'july', 'august', 'september', 'october',   
            'november', 'december'), days(11) fixed initial (0, 31, 60, 91,     
            121, 152, 182, 213, 244, 274, 305, 335);                            
         declare (year, day, m) fixed;                                          
                                                                                
         year = d/1000 + 1900;                                                  
         day = d mod 1000;                                                      
         if (year & 3) ~= 0 then if day > 59 then day = day + 1;                
         m = 11;                                                                
         do while day <= days(m);  m = m - 1;  end;                             
         output = message || month(m) || ' ' || day-days(m) || ', ' ||          
            year || '.';                                                        
      end print_date;                                                           
                                                                                
   EJECT_PAGE;                                                                  
   output = 'grammar analysis -- university of louisville';
   DOUBLE_SPACE;                                                                
   call print_date ('today is ', date);                                         
   DOUBLE_SPACE;                                                                
   output = '             p r o d u c t i o n s';                               
   DOUBLE_SPACE;                                                                
   control(byte('L')) = TRUE;                                                   
   v(0) = '<error: token = 0>';                                                 
   nsy = 1;  v(1) = '_|_';                                                      
   npr, error_count = 0;                                                        
   do i = 0 to 255;  /* clear on_left and on_right  */                          
      on_left(i), on_right(i) = 0;                                              
   end;                                                                         
   do while get_card;  /* watch side effect */                                  
      if npr = 255 then call error ('too many productions');                    
      else npr = npr + 1;                                                       
      if byte(cardimage) = BLANK then left_part(npr) = left_part(npr-1);        
      else                                                                      
         do;                                                                    
            i = scan;      /* left part symbol  */                              
            left_part(npr) = i;                                                 
            on_left(i) = TRUE;                                                  
         end;                                                                   
      i = scan; /* first symbol on the right */                                 
      if i = 0 then call error ('empty right part.');                           
      right_head(npr) = i;                                                      
      j, p = 0;                                                                 
      do j = 1 to 4;                                                            
         i = scan;                                                              
         if i ~= 0 then                                                         
            p = (shl(p, 8) + i) & "ffffffff";  /* pack 4 to a word  */
      end;                                                                      
      if length(substr(cardimage,cp)) ~=0 then
         call error ('too many symbols in right part.  forced to discard  ' ||  
            substr(cardimage, cp));                                             
      production(npr) = p;                                                      
      if control(byte('L')) then                                                
         do;  /* unpack table and print production */                           
            if left_part(npr) = left_part(npr-1) then                           
               do;                                                              
                  i = length(v(left_part(npr)));                                
                  cardimage = substr(empty, 0, i) || '    |  ';                 
               end;                                                             
            else                                                                
               do;                                                              
                  output = '';                                                  
                  cardimage = v(left_part(npr)) || '  ::=  ';                   
               end;                                                             
            call build_right_part(npr);                                         
            call line_out (npr, cardimage || t);                                
         end;                                                                   
      if control(byte('P')) then                                                
         do;  /* unpack table and print pl comment */                           
            p = production(npr);                                                
            outcard = ' /*  ' || v(left_part(npr)) || ' ::= ' ||                
               v(right_head(npr));                                              
            do k = 1 to 4;                                                      
               i = shr(p, shl(4-k, 3)) & "ff";                                  
               if i ~= 0 then call build_card (v(i));                           
            end;                                                                
            call punch_card ('   */');                                          
         end;                                                                   
   end;                                                                         
   call print_time;
   call sort_v;
 
   EJECT_PAGE;
   output  = '   t e r m i n a l   s y m b o l s                                
   n o n t e r m i n a l s';
   DOUBLE_SPACE;
   if nsy - nt > nt then l = nsy - nt;  else l = nt; /* l = number of lines */  
   do i = 1 to l;  /* print v */
      if i > nt then cardimage = half_line;
      else
         do;  /* terminal symbols */
            t = i;
            j = 5 - length(t);
            cardimage = substr(substr(empty, 0, j) || t || '   ' || v(i)
               || half_line, 0, 66);
         end;
      k = i + nt;
      if k <= nsy then
         do;  /* non-terminal symbols */
            t = k;                                                              
            j = 5 - length(t);                                                  
            cardimage = cardimage || substr(empty, 0, j) || t || '   '          
               || v(k);                                                         
         end;                                                                   
      output = cardimage;                                                       
   end;                                                                         
   DOUBLE_SPACE;                                                                
   goal_symbol = 0;                                                             
   do i = 1 to nsy;   /* locate goal symbol */                                  
      if ~ on_right(i) then                                                     
         if goal_symbol = 0 then                                                
               do;                                                              
                  goal_symbol = i;                                              
                  output = v(i) || ' is the goal symbol.';                      
               end;                                                             
            else output = 'another goal: ' || v(i) || ' (will not be used)';    
   end;                                                                         
   if goal_symbol = 0 then                                                      
      do;                                                                       
         goal_symbol = left_part(1);                                            
         output = 'no goal symbol found.  ' || v(goal_symbol) ||                
            ' used for goal symbol.';                                           
      end;                                                                      
                                                                                
   basic_nsy = nsy;                                                             
   basic_npr = npr;                                                             
   trouble_count = 0;                                                           
end read_grammar;                                                               
                                                                                
improve_grammar:                                                                
   procedure;                                                                   
      declare (t1, t2, s1, s2) fixed, change bit(1),                            
         internal bit(1), add_on character initial ('0123456789abcdefghijkl');  
      EJECT_PAGE;                                                               
      output = 'grammar modification to attempt to resolve conflicts:';         
      do i = 1 to basic_nsy;                                                    
         index(i) = 0;                                                          
      end;                                                                      
      do i = 1 to trouble_count;  /* step through problems  */                  
         DOUBLE_SPACE;                                                          
         t1 = trouble1(i);                                                      
         t2 = trouble2(i);                                                      
         do p = 1 to basic_npr;                                                 
 
 
          internal, change = FALSE;                                           
            s1 = right_head(p);                                                 
            m = production(p);                                                  
            do l = 1 to 4;  /* step through right part  */                      
               s2 = shr(m, 24);                                                 
               m = (shl(m, 8) + s2) & "ffffffff";
               if s2 ~= 0 then                                                  
                  do;                                                           
                     if s1 = t1 & is_head (s2, t2) then                         
                        do;                                                     
                           j, index(t1) = index(t1) + 1;                        
                           if nsy < 255 then nsy = nsy + 1;                     
                           else call error ('too many symbols');                
                           s = substr(add_on, j, 1);                            
                           v(nsy) = '<' || v(t1) || s || '>';                   
                           if npr < 255 then npr = npr + 1;                     
                           else call error ('too many productions.');           
                           left_part(npr) = nsy;                                
                           right_head(npr) = t1;                                
                           production(npr) = 0;                                 
                           call output_production (npr);                        
                           change = TRUE;                                       
                           if internal then m = m & "ffff00ff"
                                          | (shl(nsy, 8) & "ffffffff");
                           else right_head(p) = nsy;                            
                        end;                                                    
                     internal = TRUE;                                           
                     s1 = s2;                                                   
                  end;                                                          
            end;  /* of do l  */                                                
            production(p) = m;                                                  
            if change then call output_production (p);                          
         end;  /* of do p  */                                                   
      end;  /* of do i  */                                                      
      trouble_count, error_count = 0;                                           
   end improve_grammar;                                                         
                                                                                
compute_heads:                                                                  
   procedure;  /* set up head symbol matrix  */                                 
   call clear_heads;                                                            
   call clear_work;                                                             
   do i = 1 to npr;   /* first get immediate heads */                           
      call set_head (left_part(i), right_head(i));                              
   end;                                                                         
   do while change;   /* then compute transitive completion */                  
      change = FALSE;                                                           
      do i = nt + 1 to nsy;                                                     
         do j = nt + 1 to nsy;                                                  
            if is_head (i, j) then                                              
               do k = 1 to nsy;                                                 
                  if is_head (j, k) then                                        
                     if ~ is_head (i, k) then                                   
                        call set_head (i, k);  /* side effect on change */      
               end;                                                             
         end;                                                                   
      end;                                                                      
   end;                                                                         
   change = TRUE;                                                               
   if iteration_count = 1 then                                                  
      do;                                                                       
         ambiguous = FALSE;                                                     
         do i = 1 to npr;                                                       
            j = right_head(i);  k = production(i);                              
            do while k ~= 0;  j = shr(k, 24);  k = shl(k, 8)
                             & "ffffffff";  end;
            call set (left_part(i), j, TRUE);                                   
         end;                                                                   
         do while change;                                                       
            change = FALSE;                                                     
            do i = nt + 1 to nsy;                                               
               do j = nt + 1 to nsy;                                            
                  if get (i, j) then                                            
                     do k = 1 to nsy;                                           
                        if get (j, k) then if ~ get (i, k) then                 
                           do;                                                  
                              call set (i, k, TRUE);                            
                              change = TRUE;                                    
                           end;                                                 
                     end;                                                       
               end;                                                             
            end;                                                                
         end;                                                                   
         do i = nt + 1 to nsy;                                                  
            if is_head (i, i) then if get (i, i) then                           
               do;                                                              
                  ambiguous = TRUE;                                             
                  call error ('grammar is ambiguous.  it is left and right recur
sive in the symbol  ' || v(i));                                                 
               end;                                                             
         end;                                                                   
      end;                                                                      
   do i = 0 to nsy;   /* then the reflexive transitive completion */            
      call set_head (i, i);                                                     
   end;                                                                         
   call print_matrix ('produced head symbols', 0);                              
end compute_heads;                                                              
                                                                                
produce:                                                                        
   procedure;  /* run through the generation algorithm to compute f11  */       
   declare maxlevel fixed, new bit(1);                                          
                                                                                
   never_been_here:                                                             
      procedure; /* record the f11.  return FALSE if it is already in table  */ 
      declare (new_f11, i, j, k, nf11p1) fixed;                                 
      netry = netry + 1;                                                        
      new_f11 = pack(0, stack(sp), stack(sp-1), token);                         
      i = 0;  k, nf11p1 = nf11 + 1;                                             
      do while i + 1 < k; /* binary look-up */                                  
         j = shr(i+k,1);                                                        
         if f11(j) > new_f11 then k = j;                                        
         else if f11(j) < new_f11 then i = j;                                   
         else return FALSE;  /* found it */                                     
      end;                                                                      
      /* if we got here, we didn't find it */                                   
      if nf11 >= maxnf11 then do;  call error ('f11 overflow');  nf11 = 1;  end;
      do j = 0 to nf11 - k;   /* make room to insert new entry */               
         f11(nf11p1-j) = f11(nf11-j);                                           
      end;                                                                      
      nf11 = nf11p1;                                                            
      f11(k) = new_f11;                                                         
      return TRUE;                                                              
   end never_been_here;                                                         
                                                                                
   add_item:                                                                    
      procedure (item);                                                         
      declare item character;                                                   
      if length(cardimage) + length(item) > 130 then                            
         do;                                                                    
            output = cardimage;                                                 
            cardimage = '      ';                                               
         end;                                                                   
      cardimage = cardimage || ' ' || item;                                     
   end add_item;                                                                
                                                                                
   print_form:                                                                  
      procedure; /* print the current sentential form while tracing             
                    the generating algorithm */                                 
      cardimage = 'level ' || level || ': ';                                    
      do i = 1 to sp;                                                           
         call add_item (v(stack(i)));                                           
      end;                                                                      
      call add_item ('  |  ');                                                  
      do i = 0 to tp - 1;                                                       
         call add_item (v(text(tp-i)));                                         
      end;                                                                      
      output = cardimage;                                                       
   end print_form;                                                              
                                                                                
   apply_production:                                                            
      procedure;  /* perform one parse step (on stack and text) and recur  */   
         level = level + 1;  /* simulate the effect of recursion  */            
         if level > maxlevel then if level > DEPTH then                         
            do;  call error ('level overflow');  level = 1;  end;               
            else maxlevel = level;                                              
         mp_save(level) = mp;      /* save pointer to left part of production */
         mp = sp;                                                               
         tp_save(level) = tp;      /* save pointer into text */                 
         p_save(level) = p;        /* save number of production to be applied */
         token_save(level) = token;/* save pointer into is_head array */        
         stack(sp) = right_head(p);/* expand production into stack */           
         j = production(p);                                                     
         do while j ~= 0;                                                       
            k = shr(j,24);  j = shl(j,8) & "ffffffff";
            if k ~= 0 then                                                      
               if sp = STACKLIMIT then call error ('stack overflow');           
               else do;  sp = sp + 1;  stack(sp) = k;  end;                     
            end;                                                                
         if control(byte('T')) then call print_form; /* trace */                
   end apply_production;                                                        
                                                                                
   dis_apply:                                                                   
      procedure;                                                                
      /* undo the pseudo-recursion, reversing the effect of apply */            
      token = token_save(level);                                                
      p = p_save(level);                                                        
      tp = tp_save(level);                                                      
      sp = mp;                                                                  
      mp = mp_save(level);                                                      
      stack(sp) = left_part(p);                                                 
      level = level - 1;                                                        
   end dis_apply;                                                               
                                                                                
   do i = 1 to nsy;  index(i) = 0;  end;                                        
   do i = 1 to npr;    /* make sure productions are properly grouped */         
      j = left_part(i);                                                         
      if j ~= left_part(i-1) then                                               
         if index(j) = 0 then                                                   
            index(j) = i;                                                       
         else call error ('productions separated for ' || v(j) ||               
            '.  production ' || i || ' will be ignored.');                      
   end;                                                                         
   left_part(npr+1) = 0;  /* flag end of table  */                              
   /* set initial sentential form to  _|_  <goal>  _|_  */                      
   tp = 0;                                                                      
   mp, sp = 1;                                                                  
   stack(0), text(0) = terminator;                                              
   stack(1) = goal_symbol;                                                      
   netry, nf11, level, maxlevel = 0;                                            
   EJECT_PAGE;                                                                  
   output = 'sentential form production:';                                      
   DOUBLE_SPACE;                                                                
   if control(byte('T')) then call print_form;                                  
                                                                                
                                                                                
                                                                                
   /* now comes the basic algorithm for generating the tables  */               
                                                                                
                                                                                
production_loop:                                                                
   do while sp >= mp;  /* cycle thru right part of production */                
      if stack(sp) > nt then   /* only non-terminals can expand */              
         do;                                                                    
            new = FALSE;                                                        
            i = text(tp);                                                       
            do token = 1 to nt;   /* cycle thru terminal heads */               
               if is_head (i, token) then if never_been_here then new = TRUE;   
           end;                                                                 
            if new then                                                         
               do;  /* expand stack(sp) with all applicable rules */            
                  p = index(stack(sp));                                         
                  do while left_part(p) = stack(sp);                            
                     call apply_production;                                     
                     go to production_loop;  /* now down a level  */            
                                                                                
                                                                                
            continue:      /* and now back up a level  */                       
                     p = p + 1;  /* move on to next production */               
                  end;                                                          
               end;                                                             
         end;                                                                   
      if tp = TEXTLIMIT then call error ('text overflow');                      
      else tp = tp + 1;                                                         
      text(tp) = stack(sp);  /* run the compiler backwards  */                  
      sp = sp - 1;           /* unstacking as you go */                         
   end;                                                                         
                                                                                
   /* fully expanded at this level */                                           
   call dis_apply;   /* to come up a level  */                                  
                                                                                
   if level >= 0 then go to continue;                                           
                                                                                
   if control(byte('T')) then DOUBLE_SPACE;                                     
   output = 'f11 has ' || nf11 || ' elements.';                                 
   output = 'the maximum DEPTH of recursion was ' || maxlevel || ' levels.';    
   output = netry || ' sentential forms were examined.';                        
end produce;                                                                    
                                                                                
index_f11:                                                                      
   procedure;                                                                   
   /* build an index into f11 for each production  */                           
   declare (y, yp, p) fixed;                                                    
                                                                                
   do i = 1 to npr;                                                             
      ind(i) = 0;                                                               
      ind1(i) = -1;                                                             
   end;                                                                         
                                                                                
   y, yp = 0;                                                                   
   f11(nf11+1) = shl(nsy+1, 16) & "ffffffff"; /* boundary condition  */
   do i = 1 to nf11+1;  /* check each f11  */                                   
      if f11(i) >= yp then                                                      
         do;      /* f11 for a new left part */                                 
            p = index(y);                                                       
            do while left_part(p) = y;    /* record end for old left part */    
               ind1(p) = i - 1;                                                 
               p = p + 1;                                                       
            end;                                                                
            y = shr(f11(i), 16);    /* new left part */                         
            p = index(y);                                                       
            do while left_part(p) = y;    /* record start for new left part */  
               ind(p) = i;                                                      
               p = p + 1;                                                       
            end;                                                                
            yp = shl(y+1, 16) & "ffffffff"; /*to compare with triple */
         end;                                                                   
   end;                                                                         
end index_f11;                                                                  
                                                                                
sort_productions:                                                               
   procedure;    /* re-number the productions in an optimal order for c2  */    
   do i = 1 to npr;  p_save(i) = 0;  end;                                       
   p = 0;                                                                       
   do i = 1 to npr;                                                             
      j = right_head(i);  /* convert 1 - 4 packing to 4 - 1 packing  */         
      m = production(i);                                                        
      if m = 0 then                                                             
         do;                                                                    
            m = j;                                                              
            j = 0;                                                              
            l = 7;                                                              
         end;                                                                   
      else l = 6;                                                               
      tail(i) = m & "ff";                                                       
      m = m & "ffffff00";                                                       
      do while m ~= 0;                                                          
         k = shr(m, 24);  m = shl(m, 8) & "ffffffff";
         if k ~= 0 then                                                         
            do;                                                                 
               j = (shl(j, 8) + k) & "ffffffff";
               l = l - 1;                                                       
            end;                                                                
      end;                                                                      
      head(i) = j;                                                              
      /*  sort on:  1.  tail symbol of right part                               
                       2. length of right part                                  
                          3. number of f11's                 */                 
      sort#(i) = shl(tail(i), 23) + shl(l, 20) + ind1(i) - ind(i);              
      sort#(i) = sort#(i) & "ffffffff";
      index(i) = i;                                                             
   end;  /* of do i  */                                                         
   /* bubble sort of productions  */                                            
   k, l = npr;                                                                  
   do while k <= l;                                                             
      l = -1;                                                                   
      do i = 2 to k;                                                            
         l = i - 1;                                                             
         if sort#(l) > sort#(i) then                                            
            do;                                                                 
               j = sort#(l);  sort#(l) = sort#(i);  sort#(i) = j;               
               j = index(l);  index(l) = index(i);  index(i) = j;               
               k = l;                                                           
            end;                                                                
      end;                                                                      
   end;                                                                         
   index(npr+1) = 0;                                                            
end sort_productions;                                                           
                                                                                
compute_c1:                                                                     
   procedure;                                                                   
      declare (cx, ctrip, s1, s2, s3, tr, pr) fixed;                            
                                                                                
      call clear_work;                                                          
      netry, ntrip, ctrip = 0;                                                  
      do cx = 0 to 2;      /* repeat basic loop 3 times:                        
                              1. compute pairs                                  
                                 2. compute triples for pair conflicts          
                                    3. emit diagnostics for triple conflicts  */
        do p = 1 to npr;      /* step through the productions  */               
          do i = ind(p) to ind1(p);    /* step through the expansion triples  */
            call expand (f11(i), p);                                            
            do j = 2 to sp;      /* step through right part of production  */   
               k = value(j~=sp);                                                
               s1 = stack(j-1);                                                 
               s2 = stack(j);                                                   
               l = stack(j+1);                                                  
               do s3 = 1 to nt;     /* step through the heads of stack(j+1)  */ 
                  if is_head(l, s3) then                                        
                     do case cx;                                                
                                                                                
                        /* case 0 -- enter pair  */                             
                        call set (s2, s3, k);                                   
                                                                                
                        /* case 1 -- if pair conflict then enter triple  */     
                        if get (s2, s3) = 3 then                                
                           call enter (pack (0, s1, s2, s3), k);                
                                                                                
                        /* case 2 -- if triple conflict emit diagnostic  */     
                        do;                                                     
                           tr = pack (0, s1, s2, s3);                           
                           do m = 0 to ctrip;                                   
                              if sort#(m) = tr then                             
                                 call enter (pack(m, p, stack(1), stack(sp+1)), 
                                    k);                                         
                           end;                                                 
                        end;     /* of case 2  */                               
                     end;     /* of do case  */                                 
               end;     /* of do s3  */                                         
            end;     /* of do j  */                                             
          end;    /* of do i  */                                                
        end;      /* of do p  */                                                
         do case cx;  /* clean up  */                                           
                                                                                
            /* case 0  */                                                       
            do;                                                                 
               do i = 1 to nt;      /* special relations for terminator  */     
                  if is_head (goal_symbol, i) then                              
                     call set (terminator, i, value(TRUE));                     
               end;                                                             
               call set (goal_symbol, terminator, value(FALSE));                
               call print_matrix ('c1 matrix for stacking decision', 1);        
               call print_time;                                                 
            end;                                                                
                                                                                
            /* case 1  */                                                       
            do;                                                                 
               call print_triples ('c1 triples for stacking decision');         
               if count(3) = 0 | iteration_count > 1 then return;               
               if ~ control(byte('I')) then                                     
                  if control(byte('P')) | control(byte('O')) then return;       
               call print_time;                                                 
               do i = 1 to ntrip;                                               
                  if tv(i) = 3 then                                             
                     do;                                                        
                        sort#(ctrip) = triple(i);                               
                        ctrip = ctrip + 1;                                      
                     end;                                                       
               end;                                                             
               ctrip = ctrip - 1;                                               
               netry, ntrip = 0;                                                
               DOUBLE_SPACE;                                                    
               output = 'analysis of (2,1) conflicts:';                         
            end;                                                                
                                                                                
            /* case 2  */                                                       
            do;                                                                 
               j = 1;                                                           
               do m = 0 to ctrip;  /* step through conflicts  */                
                  do k = 0 to 1;  /* step through truth values  */              
                     i = sort#(m);                                              
                     output = '';                                               
                     output = '   the triple  ' || v(shr(i,16)) || ' ' ||       
                        v(shr(i,8)&"ff") || ' ' || v(i&"ff") ||                 
                        '  must have the value ' || print(value(k)) ||          
                        ' for';                                                 
                     output = '';                                               
                     l = shl(m+1, 24) & "ffffffff";
                     i = j;                                                     
                     s1 = 0;                                                    
                     do while triple(i) < l & i <= ntrip;                       
                        if (tv(i)&value(k)) ~= 0 then                           
                           do;                                                  
                              tr = triple(i);                                   
                              p = shr(tr, 16) & "ff";                           
                              if p ~= s1 then call output_production (p);       
                              s1 = p;                                           
                              output = '         in the context  ' ||           
                                 v(shr(tr, 8)&"ff") || dots || v(tr&"ff");      
                           end;                                                 
                        i = i + 1;                                              
                     end;     /* of do while  */                                
                  end;  /* of do k  */                                          
                  j = i;                                                        
                  output = '';                                                  
               end;     /* of do m  */                                          
            end;                                                                
         end;     /* of do case  */                                             
      end;     /* of do cx  */                                                  
end compute_c1;                                                                 
                                                                                
compute_c2:                                                                     
   procedure;                                                                   
   /* determine what (if any) context must be checked for each production       
      to augment the "longest match" rule for the production selection          
      function  c2      */                                                      
                                                                                
      declare (ij, ik, tj, tk, pj, pk, jct, kct, jcl, jcr) fixed,               
         proper bit(1);                                                         
      declare context_class(3) character initial ('either (0,1) or (1,0)',      
         '(0,1)', '(1,0)', '(1,1)');                                            
                                                                                
      EJECT_PAGE;                                                               
      output = 'context check for equal and embedded right parts:';             
      do i = 1 to npr;  mp_save(i), p_save(i) = 0;  end;                        
      do j = 1 to npr - 1;                                                      
         ij = index(j);                                                         
         k = j + 1;                                                             
         ik = index(k);                                                         
         do while tail(ij) = tail(ik);  /* check all productions with same tai*/
            tj = head(ij);                                                      
            tk = head(ik);                                                      
            do while (tj & "ff") = (tk & "ff") & tj ~= 0;                       
               tj = shr(tj, 8);  tk = shr(tk, 8);                               
            end;                                                                
            if tk = 0 then                                                      
               do;      /* production ik is included in ij  */                  
                  output = '';                                                  
                  output = '   there are ' || ind1(ij)-ind(ij)+1 ||             
                     ' and ' || ind1(ik)-ind(ik)+1 ||                           
                     ' valid contexts, respectively, for';                      
                  call output_production (ij);                                  
                  call output_production (ik);                                  
                  proper = tj ~= 0;  /* ik is a proper substring  */            
                  if proper then                                                
                     do;                                                        
                        jcl = shl(tj & "ff", 8);                                
                        do i = 1 to nsy;                                        
                           on_right(i) = FALSE;                                 
                        end;                                                    
                     end;                                                       
                  else p_save(ij) = 1;  /* remember that equal right parts      
                                        must be distinguished somehow  */       
                  mp = 0;                                                       
                  do pj = ind(ij) to ind1(ij);                                  
                     jct = f11(pj) & "ffff";                                    
                     jcr = jct & "00ff";                                        
                     if proper then jct = jcl | jcr;                            
                     else jcl = jct & "ff00";                                   
                     do pk = ind(ik) to ind1(ik);                               
                        kct = f11(pk) & "ffff";                                 
                        if kct = jct then                                       
                           do;                                                  
                              if mp < 4 then call error (                       
'these productions cannot be distinguished with (1,1) context.');               
                              mp = mp | 4;                                      
                              if proper then                                    
                                 do;                                            
                                    if ~ on_right(jcr) then                     
                                       output = '   ' || v(left_part(ik)) ||    
                                          '  has  ' || v(shr(jcl, 8)) ||        
                                          dots || v(jcr) || '  as context and  '
              || v(jcr) || '  is valid right context for  ' || v(left_part(ij));
                                    on_right(jcr) = TRUE;                       
                                 end;                                           
                              else output =                                     
'   they have equal right parts and the common context  '                       
                                 || v(shr(jcl, 8)) || dots || v(jcr);           
                              call add_trouble (shr(kct, 8), left_part(ik));    
                           end;                                                 
                        else if (kct & "ff00") = jcl then                       
                           mp = mp | 1;  /* can't tell by left context */       
                        else if (kct & "00ff") = jcr then                       
                           mp = mp | 2;  /* can't tell by right context */      
                     end;     /* pk  */                                         
                  end;        /* pj  */                                         
                  if mp < 4 then                                                
                     do;      /* resolvable by context  */                      
                        if proper & (~mp) then /* context implicit in length  */
                           output = '   they can be resolved by length.';       
                        else                                                    
                           do;                                                  
                              mp_save(ij) = mp_save(ij) | mp;                   
                              output = '   they can be resolved by ' ||         
                                 context_class(mp) || ' context.';              
                           end;                                                 
                     end;                                                       
               end;     /* of tk = 0  */                                        
            k = k + 1;                                                          
            ik = index(k);                                                      
         end;     /* do while  */                                               
      end;     /* do j  */                                                      
      EJECT_PAGE;                                                               
      output = 'c2 production choice function:';                                
      tk = 0;                                                                   
      do j = 1 to npr;                                                          
         ij = index(j);                                                         
         tj = tail(ij);                                                         
         if tj ~= tk then                                                       
            do;                                                                 
               tk = tj;                                                         
               DOUBLE_SPACE;                                                    
               output = '   ' || v(tj) ||                                       
'  as stack top will cause productions to be checked in this order:';           
            end;                                                                
         output = '';                                                           
         call output_production (ij);                                           
         do case mp_save(ij) & 3;                                               
            /* case 0  */                                                       
            if p_save(ij) then go to case_1;  /* equal right part must check */ 
            else output = '         there will be no context check.';           
                                                                                
            /* case 1  */                                                       
         case_1:                                                                
            do;                                                                 
               output =                                                         
'         (0,1) context will be checked.  legal right context:';                
               do i = 1 to nsy;  on_right(i) = FALSE;  end;                     
               do pj = ind(ij) to ind1(ij);                                     
                  jcr = f11(pj) & "ff";                                         
                  if ~ on_right(jcr) then                                       
                     do;                                                        
                        on_right(jcr) = TRUE;                                   
                        output = x12 || dots || v(jcr);                         
                     end;                                                       
               end;                                                             
            end;                                                                
                                                                                
            /* case 2  */                                                       
            do;                                                                 
               output =                                                         
'         (1,0) context will be checked.  legal left context:';                 
               do i = 1 to nsy;  on_left(i) = FALSE;  end;                      
               do pj = ind(ij) to ind1(ij);                                     
                  jcl = shr(f11(pj) & "ff00", 8);                               
                  if ~ on_left(jcl) then                                        
                     do;                                                        
                        on_left(jcl) = TRUE;                                    
                        output = x12 || v(jcl) || dots;                         
                     end;                                                       
               end;                                                             
            end;                                                                
                                                                                
            /* case 3  */                                                       
            do;                                                                 
               output =                                                         
                  '         (1,1) context will be checked.  legal context:';    
               do pj = ind(ij) to ind1(ij);                                     
                  output = x12 || v(shr(f11(pj) & "ff00", 8)) ||                
                     dots || v(f11(pj) & "ff");                                 
               end;                                                             
            end;                                                                
         end;   /* of case statement  */                                        
      end;  /* of do j  */                                                      
  end compute_c2;                                                               
                                                                                
punch_productions:                                                              
   procedure;                                                                   
   declare wide fixed;                                                          
   if ~(control(byte('P')) | control(byte('O'))) then return;                   
   if control(byte('O')) then EJECT_PAGE;                                       
   outcard = '  ';                                                              
   call punch_card ('declare NSY literally ''' || NSY || ''', NT literally '''  
      || NT || ''';');                                                          
   call build_card ('declare v(NSY) character initial (');                      
   do i = 0 to NSY;                                                             
      s = v(i);                                                                 
      t = '';                                                                   
      l = length(s) - 1;                                                        
      do while byte(s, l) = BLANK;  l = l - 1;  end;                            
      if i > basic_nsy then                                                     
         do;      /* created symbol:  adjust print name  */                     
            l = l - 3;                                                          
            s = substr(s, 1);                                                   
         end;                                                                   
      do j = 0 to l;                                                            
         if substr(s, j, 1) = '''' then t = t || '''''';                        
         else t = t || substr(s, j, 1);                                         
      end;                                                                      
      if i < NSY then call build_card ('''' || t || ''',');                     
      else call punch_card ('''' || t || ''');');                               
   end;                                                                         
   l = length(v(NT));                                                           
   call build_card ('declare v_index(' || l || ') bit(8) initial (');           
   j = 1;                                                                       
   do i = 1 to l;                                                               
      call build_card (j || ',');                                               
      do while length(v(j)) = i;  j = j + 1;  end;                              
   end;                                                                         
   call punch_card (NT+1 || ');');                                              
   if NT <= 15 then wide = 16;  /* force long bit strings */                    
   else wide = NT;                                                              
   i = 2*wide + 2;                                                              
   call punch_card ('declare c1(NSY) bit(' || i || ') initial (');              
   do i = 0 to NSY;                                                             
      t = '   "(2)';                                                            
      do j = 0 to wide;                                                         
         if j mod 5 = 0 then                                                    
            do;                                                                 
               call build_card (t);                                             
               t = '';                                                          
            end;                                                                
         t = t || get (i, j);                                                   
      end;                                                                      
      if i < NSY then call punch_card (t || '",');                              
      else call punch_card (t || '");');                                        
   end;                                                                         
   k = count(1) - 1;                                                            
   if k < 0 then                                                                
      do;                                                                       
         call punch_card ('declare nc1TRIPLES literally ''0'';');               
         call punch_card ('declare c1TRIPLES(0) fixed;');                       
      end;                                                                      
   else                                                                         
      do;                                                                       
         call punch_card ('declare nc1TRIPLES literally ''' || k || ''';');     
         call build_card ('declare c1TRIPLES(nc1TRIPLES) fixed initial (');     
         j = 0;                                                                 
         do i = 1 to ntrip;                                                     
            if tv(i) = 1 then                                                   
               do;                                                              
                  if j = k then call punch_card (triple(i) || ');');            
                  else call build_card (triple(i) || ',');                      
                  j = j + 1;                                                    
               end;                                                             
         end;                                                                   
      end;                                                                      
   call build_card ('declare prtb(' || npr || ') fixed initial (0,');           
   do i = 1 to npr - 1;                                                         
      call build_card (head(index(i)) || ',');                                  
   end;                                                                         
   call punch_card (head(index(npr)) || ');');                                  
   call build_card ('declare prdtb(' || npr || ') bit(8) initial (0,');         
   do i = 1 to npr;                                                             
      l = index(i);                                                             
      if l > basic_npr then l = 0;                                              
      if i < npr then call build_card (l || ',');                               
      else call punch_card (l || ');');                                         
   end;                                                                         
   call build_card ('declare hdtb(' || npr || ') bit(8) initial (0,');          
   do i = 1 to npr - 1;                                                         
      call build_card (left_part(index(i)) || ',');                             
   end;                                                                         
   call punch_card (left_part(index(npr)) || ');');                             
   call build_card ('declare prlength(' || npr || ') bit(8) initial (0,');      
   do i = 1 to npr;                                                             
      j = 1;                                                                    
      k = head(index(i));                                                       
      do while k ~= 0;                                                          
         j = j + 1;                                                             
         k = shr(k, 8);                                                         
      end;                                                                      
      if i = npr then call punch_card ( j || ');');                             
      else call build_card (j || ',');                                          
   end;                                                                         
   call build_card ('declare context_case(' || npr || ') bit(8) initial (0,');  
   do i = 1 to NSY;  tp_save(i) = 0;  end;                                      
   do i = 1 to npr;   /* compute context case */                                
      j = mp_save(index(i));  /* set up in compute_c2, used here  */            
      k = left_part(index(i));                                                  
      do case j;                                                                
         /* case 0, can tell by either left or right context,                   
         use length to decide unless equal */                                   
         j = p_save(index(i));  /* use the cheap test, if required  */          
         /* case 1, use c1 matrix for this case */                              
         ;                                                                      
         /* case 2:  need left context table */                                 
         tp_save(k) = tp_save(k) | 1;                                           
         /* case 3:  need both left and right context */                        
         tp_save(k) = tp_save(k) | 2;                                           
      end;                                                                      
      token_save(k) = index(i);                                                 
      if i = npr then call punch_card (j || ');');                              
      else call build_card (j || ',');                                          
   end;                                                                         
   j = 0;   /* construct context tables for c2 */                               
   do i = NT + 1 to NSY;  /* cycle thru non-terminals */                        
      sort#(i) = j;                                                             
      if tp_save(i) then                                                        
         do;                                                                    
            k = token_save(i);                                                  
            m = 0;                                                              
            do l = ind(k) to ind1(k);                                           
               p = shr(f11(l), 8) & "ff";                                       
               if p ~= m then                                                   
                  do;                                                           
                     work(j), m = p;                                            
                     j = j + 1;  /* count the number of entries */              
                  end;                                                          
            end;                                                                
         end;                                                                   
   end;                                                                         
   if j = 0 then j = 1;  /* assure non-negative upper bound for array */        
   call build_card ('declare left_context(' || j - 1 ||                         
      ') bit(8) initial (');                                                    
   do i = 0 to j - 2;                                                           
      call build_card (work(i) || ',');                                         
   end;                                                                         
   call punch_card (work(j-1) || ');');                                         
   if j > 255 then k = 16;  else k = 8;  /* j < 256 allows 8 bit packing */     
   call build_card ('declare left_index(' || NSY-NT || ') bit(' || k            
      || ') initial (');                                                        
   do i = NT + 1 to NSY;                                                        
      call build_card (sort#(i) || ',');                                        
   end;                                                                         
   call punch_card (j || ');');                                                 
   j = 0;                                                                       
   do i = NT + 1 to NSY;                                                        
      sort#(i) = j;  /* record where each non-terminal starts */                
      if shr(tp_save(i), 1) then  /* need both contexts */                      
         do;                                                                    
            k = token_save(i);                                                  
            do l = ind(k) to ind1(k);                                           
               triple(j) = f11(l) & "ffff";                                     
               j = j + 1;                                                       
            end;                                                                
         end;                                                                   
   end;                                                                         
   if j = 0 then j = 1;  /* assure non-negative upper bound for array */        
   call build_card ('declare context_triple(' || j-1 || ') fixed initial (');   
   do i = 0 to j - 2;                                                           
      call build_card (triple(i) || ',');                                       
   end;                                                                         
   call punch_card (triple(j-1) || ');');                                       
   if j > 255 then k = 16;  else k = 8;  /* j < 256 allows 8 bit packing */     
   call build_card ('declare triple_index(' || NSY-NT || ') bit(' || k          
      || ') initial (');                                                        
   do i = NT + 1 to NSY;   /* PUNCH marginal index table */                     
      call build_card (sort#(i) || ',');                                        
   end;                                                                         
   call punch_card (j || ');');                                                 
   do i = 0 to NSY;  p_save(i) = 0;  end;                                       
   do i = 1 to npr;       /* cycle thru the productions */                      
      p = tail(index(i));  /* marginal index into production table */           
      if p_save(p) = 0 then p_save(p) = i;                                      
   end;                                                                         
   p_save(NSY+1) = npr + 1;  /* mark the end of the production table */         
   do j = 0 to NSY - 1;  /* take care of symbols that never end a production */ 
      i = NSY - j;                                                              
      if p_save(i) = 0 then p_save(i) = p_save(i+1);                            
   end;                                                                         
   call build_card ('declare pr_index(' || NSY || ') bit(8) initial (');        
   do i = 1 to NSY;                                                             
      call build_card (p_save(i) || ',');                                       
   end;                                                                         
   call punch_card (npr+1 || ');');                                             
   call print_time;                                                             
end punch_productions;                                                          
                                                                                
   /* the actual execution is controlled from this loop  */                     
 
   output(-2) = 'grammar file: ';
   filename(0) = input(-1);
   output(-2) = ' output file: ';
   filename(1) = input(-1);
 
                                                                                
   do while stacking;                                                           
      first_time, last_time = time;                                             
      iteration_count, trouble_count = 1;                                       
      do while trouble_count > 0;                                               
         if iteration_count = 1 then call read_grammar;                         
         else call improve_grammar;                                             
         call print_time;                                                       
         call compute_heads;                                                    
         call print_time;                                                       
         if ~ ambiguous then                                                    
            do;                                                                 
               call produce;                                                    
               call print_time;                                                 
               call index_f11;                                                  
               call sort_productions;                                           
               call compute_c1;                                                 
               call print_time;                                                 
               call compute_c2;                                                 
               call print_time;                                                 
               DOUBLE_SPACE;                                                    
            end;                                                                
         output = 'analysis complete for iteration ' || iteration_count;        
         if error_count = 0 then output = 'no errors were detected.';           
         else if error_count = 1 then output = '* one error was detected.';     
         else if error_count <= 20 then                                         
            output = substr('********************', 0, error_count) || ' ' ||   
               error_count || ' errors were detected.';                         
         else output = '******************** ... ' || error_count ||            
            ' errors were detected.';                                           
         iteration_count = iteration_count + 1;                                 
         if ambiguous | ~ control(byte('I')) then trouble_count = 0;            
      end;                                                                      
      if ~ ambiguous then call punch_productions;                               
      if control(byte('P')) then output = 'punching complete.';                 
   end;                                                                         
eof eof eof eof eof eof eof eof eof eof eof eof eof eof eof eof eof eof eof eof 
