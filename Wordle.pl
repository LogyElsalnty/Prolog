main:-
	write('Welcome to Pro-Wordle!'), nl, write('----------------------')
	,nl,nl,build_kb,nl,nl,play.
		
build_kb:-
write('Please enter a word and its category on separate lines:'), nl,
read(X),
( X = done,nl,write('Done building the words database...'),!;
read(Y),
assert(word(X,Y)),
build_kb ).

play:-
	write('The available categories are: '),categories(L),write(L),nl,write('Choose a category:'),nl,read(Cat),trycategory(Cat,NewCat),
	write('Choose a length:'),nl,read(Length),trylength(Length,Length1,NewCat),
	nl,nl,pick_word(W,Length1,NewCat),Number_of_guesses =Length1,New_Number_of_guesses is Number_of_guesses + 1,
	tryguess(W,Length1,NewCat,New_Number_of_guesses).

tryguess(_,_,_,0):-write(' You lost!'),!.
tryguess(W,Length,NewCat,A):-write('Enter a word composed of '),write(Length),write(' letters:'),nl,read(Word),
						(string_length(Word,CountB),CountB==Length,(\+word(Word,_),write('Not a Word.Please try again.'),nl,write('Remaining Guesses are '),write(A),nl,nl,tryguess(W,Length,NewCat,A));
						string_length(Word,CountB),(
						CountB\==Length,write('Word is not composed of '),write(Length),write(' letters. Try again.'),nl,
						write('Remaining Guesses are '),write(A),nl,nl,tryguess(W,Length,NewCat,A);
						convert_to_list(W,NW)
						,convert_to_list(Word,NewWord),correct_letters(NW,NewWord,CL),correct_positions(NW,NewWord,CL1),
						string_length(CL1,Count),(Length==Count,write('You Won!');
						(NA is A-1,((NA>=1,write('Correct letters are: '),write(CL),nl,write('Correct letters in correct positions are: ')
						,write(CL1),nl,write('Remaining Guesses are '),write(NA),nl,nl,tryguess(W,Length,NewCat,NA));tryguess(W,Length,NewCat,NA)))))).
					
convert_to_list(L,NL):-string_chars(L,NL).
trycategory(Cat,NewCat):-(is_category(Cat),Cat=NewCat,nl;
		\+is_category(Cat),write('This category does not exist.'),nl,write('Choose a category'),nl,read(Y),trycategory(Y,NewCat)).
		
trylength(Length,NewLength,Cat):- 
	(\+pick_word(_,Length,Cat);\+available_length(Length)),write('There are no words of this length.'),nl,write('Choose a length:'),nl,
	read(Y),trylength(Y,NewLength,Cat);
	(write('Game started. You have '),NL is Length+1,write(NL),write(' guesses.'),Length=NewLength).


	


	
is_category(C):-word(_,X),C==X,!.
is_category(C):-
	word(_,X),X=C,
	is_category(C).

categories(L):-	
 insert1([],Newl), reverse(Newl,L).
 
insert1(Z,L):-
	word(X,Y),
	\+member(Y,Z),
	insert1([Y|Z],L),!.
	
insert1(Z,L):-
L=Z,!.

available_length(L):-
	word(W,_),string_length(W,L),!.
	
pick_word(W,L,C):-
	word(W,C),
	string_length(W,L).

correct_letters([],L2,[]).
correct_letters([H|T],L,[H|T2]):- member(H,L), 
                                   correct_letters(T,L,Y),remove_duplicates(Y,T2),!.
correct_letters([X|T],L,R):- \+member(X,L),
                              correct_letters(T,L,R).

remove_duplicates([],[]).
remove_duplicates([H | T], List) :-    
     member(H, T),
     remove_duplicates( T, List).
remove_duplicates([H | T], [H|T1]) :- 
      \+member(H, T),
      remove_duplicates( T, T1).
	
correct_positions([],_,[]):-!.
correct_positions([H1|T1],[H2|T2],[H1|T]):-  H1==H2 ,correct_positions(T1,T2,T).
correct_positions([H1|T1],[H2|T2],PL):- H1\=H2 , correct_positions(T1,T2,PL).