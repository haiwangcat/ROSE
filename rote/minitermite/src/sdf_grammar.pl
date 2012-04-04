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
   format('# Minitermite term signatures for use with SDF~n', []),
   start_symbol(Start),
   gtrace,
   print_rule(Start).

print_nonterm(Nonterminal, A|B) :- !,
   format_rule(A, Terminals),
   format('~w -> ~w {cons("~w")}~n', [Terminals, Nonterminal, Nonterminal]),
   print_rule(Nonterminal, B).

print_nonterm(Nonterminal, A) :- !,
   format_rule(A, Terminals),
   format('~w -> ~w {cons("~w")}~n', [Terminals, Nonterminal, Nonterminal]).

format_rule({_}) :- !.

format_rule(Nonterminal) :-
   atom(Nonterminal), !,
   ( Nonterminal ::= Rhs ),
   print_nonterm(Nonterminal, Rhs).

format_rule(CompoundTerm) :-
   CompoundTerm =.. [F|Args],
   format('~w \'(\'', [F]),
   print_terms(Args),
   format('\')\'').

print_terms([T]) :- write(' \',\' '), fail.
print_terms([[T]|Ts]) :- !, format('\'[\' ~w \']\'', [T]).
print_terms(T) :- format('~w', [T]).