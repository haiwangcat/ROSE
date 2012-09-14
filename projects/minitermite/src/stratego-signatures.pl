% Before doing anything else, set up handling to halt if warnings or errors
% are encountered.
:- dynamic prolog_reported_problems/0.
% If the Prolog compiler encounters warnings or errors, record this fact in
% a global flag. We let message_hook fail because that signals Prolog to
% format output as usual (otherwise, we would have to worry about formatting
% error messages).
user:message_hook(_Term, warning, _Lines) :-
    assert(prolog_reported_problems), !, fail.
user:message_hook(_Term, error, _Lines) :-
    assert(prolog_reported_problems), !, fail.

:- getenv('PWD', CurDir),
   asserta(library_directory(CurDir)),
   prolog_load_context(directory, SrcDir),
   asserta(library_directory(SrcDir)),
   (getenv('TERMITE_LIB', TermitePath)
   ; (print_message(error, 'Please set the environment variable TERMITE_LIB'),
      halt(1))
   ),
   asserta(library_directory(TermitePath)).

% END BOILERPLATE
:-
   op(1200, xfx, ::=),	    % grammar rule
   op(754,   fy, atoms),    % enumeration of terminal atoms
   op(754,   fy, functors), % enumeration of terminal functors...
   op(753,  yfy, with),	    % ... with identical argument structure
   op(752,  xfx, where),    % semantic constraints
   op(751,  xf,	 ?),	    % optional occurrence of nonterminal

% Load in the grammar spec
   consult('PP_termite_spec.pl').

% This program prints an SDF-compatible grammar for use with Stratego
% for the grammar specified in the termite grammar spec
% (src/termite/termite_spec.pl)
main :-
   retractall(visited(_)),
   retractall(sort(_)),
   retractall(constructor(_)),
   format('# Minitermite term signatures for use with SDF~n', []), !,
   start_symbol(Start),
   fmt_rule(Start),

   write('sorts '), !,
   print_sorts, nl,

   write('constructors '), !,
   print_constructors, nl.

print_sorts :-
   sort(Sort),
   format('~w ', [Sort]),
   fail.
print_sorts.

print_constructors :-
   constructor(C),
   format('  ~w~n', [C]),
   fail.
print_constructors.


fmt_rule(Nonterminal) :-
   (  visited(Nonterminal)
   -> true % skip
   ;  assert(visited(Nonterminal)),
      fail % continue
   ).

% ATOMS
fmt_rule(Nonterminal) :-
   atom(Nonterminal), !,
   ( Nonterminal ::= Rhs ),

   functor_sort(Nonterminal, Sort),
   %format(atom(S), '~w : ~w', [Nonterminal, Sort]),
   %assert(constructor(S)),
   fmt_rule1(Sort, Rhs).

fmt_rule(Nonterminal) :-
   fmt_rule1(Nonterminal, Nonterminal).

fmt_rule1(_, {_} where _) :- !.
fmt_rule1(_, {_}) :- !.
fmt_rule1(_, Var) :- var(Var), !.
fmt_rule1(_, atoms _) :- !.
fmt_rule1(_, functors _) :- !.
fmt_rule1(Sort, A|B) :- !,
   fmt_rule1(Sort, A),
   fmt_rule1(Sort, B).

fmt_rule1(_, [A]) :- !, fmt_rule(A).
fmt_rule1(_, A?)  :- !, fmt_rule(A).

fmt_rule1(Sort, Atom) :- atom(Atom), !,
	( Atom ::= Rhs ),
	fmt_rule1(Sort, Rhs).

% RULES
fmt_rule1(Sort, Nonterminal) :- 
   Nonterminal =.. [Constructor|Args], !,

   with_output_to(atom(As), print_terms(Args)),
   format(atom(S), '~w : ~w -> ~w', [Constructor, As, Sort]),

   assert(constructor(S)),
   fmt_rule(Constructor),
   maplist(fmt_rule, Args).

print_terms([]).
print_terms([T1|[T2|Ts]]) :- !, print_term(T1), write(' * '), print_terms([T2|Ts]).
print_terms([T]) :- print_term(T).

print_term(Var)         :- var(Var), !, write('UNKNOWN').
print_term([Var])       :- var(Var), !, write('UNKNOWNS').
print_term({T})         :- !, print_term(T).
print_term({T} where _) :- !, functor_sort(T, S), write(S).
print_term([T])         :- !, functor_sort(T, S), format('~w_LIST', [S]).
print_term(T?)		:- !, functor_sort(T, S), format('~w_OR_NULL', [S]).
print_term(atoms _)     :- !, write('ATOMS').
print_term(functors _)  :- !, write('FUNCTORS').
print_term(T) :- functor_sort(T, S), write(S).

uppercase(C, C1) :-
	char_type(C1, to_upper(C)).

% convert a functor to a sort just by converting it to uppercase
functor_sort(F, FSort) :-
	atom_chars(F, Cs),
	maplist(uppercase, Cs, Cs1),
	atom_chars(FSort, Cs1),
	(  sort(FSort)
	-> true % else record it in the database
	;  assert(sort(FSort))
	).
