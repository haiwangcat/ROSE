#!/usr/bin/pl -t testrun -f
% -*- prolog -*-

:- module(utils,
	  [drop/3, foldl/4, foldl1/3, last/2, replicate/3, split_at/4, take/3,
           string_to_term/2,
           term_to_string/2,
	   atom_to_string/2,
	   list_from_to/3,
	   repeat_string/3,

	   replace_all/4,
	   replace_in_atom/4,
	   replace_nth/5,
	   
	   un_op/3,
	   bin_op/4,
	   tern_op/5,
	   quad_op/6,

	   term_mod/3]).

%-----------------------------------------------------------------------
/** <module> A collection of useful general-purpose predicates.

  The predicates drop/3, foldl/4, foldl1/3, last/2, replicate/3,
  split_at/4 and take/3 are inspired by the Haskell Prelude, but are
  implemented declaratively: They can be used to generate as well as
  test.

@version   @PACKAGE_VERSION@
@copyright Copyright (C) 2007-2009 Adrian Prantl
@author    Adrian Prantl <adrian@complang.tuwien.ac.at>
@license   BSD. See COPYING for more details.
*/
%-----------------------------------------------------------------------

% List operations from the Haskell Prelude

%% drop(?N, ?List, ?Tail)
% Drop N elements from List, yielding Tail.
% ==
% drop(N, List, Tail) :-
%   length(Head, N),
%   append(Head, Tail, List).
% ==
drop(N, List, Tail) :-
  length(Head, N),
  append(Head, Tail, List).


%% last(?List, ?Elem)
% Elem is the last element of List.
% ==
% last(List, Elem) :-
%   reverse(List, [Elem|_]).
% ==
last(List, Elem) :-
  reverse(List, [Elem|_]).

%% replicate(?A, ?Num, ?As)
% Replicate A Num times yielding As.
% ==
% replicate(A, Num, As) :-
%   length(As, Num),
%   maplist(=(A),As).
% ==

% replicate(_, 0, []).
% replicate(A, N, B) :-
%   append(A, Bs, B),
%   N1 is N-1,
%   replicate(A, N1, Bs).
replicate(A, Num, As) :-
    length(As, Num),
  maplist(=(A),As).

%% split_at(?N, ?List, ?Head, ?Tail)
% Split List at element N yielding Head, Tail
% ==
% split_at(N, List, Head, Tail) :-
%   length(Head, N),
%   append(Head, Tail, List).
% ==
split_at(N, List, Head, Tail) :-
  length(Head, N),
  append(Head, Tail, List).

%% take(?N, ?List, ?Head)
% Head is unified with the first N elements of List
% ==
% take(N, List, Head) :-
%   length(Head, N),
%   append(Head, _Tail, List).
% ==
take(N, List, Head) :-
  length(Head, N),
  append(Head, _Tail, List).

%% foldl1(?List, ?Pred, ?Result)
%  Fold List left-to-right using Pred, starting with the first
%  element of List.
foldl1([X|Xs], Pred, Result) :-
  foldl(Xs, Pred, X, Result).

%% foldl(?List, ?Pred, ?Start, ?Result)
% Fold a list left-to-right using Pred, just as you would do in Haskell.
% ==
% pred(LHS, RHS, Result)
% ==
% Thanks to Markus Triska for the definition.
foldl([], _, Result, Result) :- !. 
foldl(List, Pred, Start, Result) :- 
  fold_lag(List, Start, Pred, Result). 

fold_lag([], Result, _, Result). 
fold_lag([RHS|Xs], LHS, Pred, Result) :- 
  call(Pred, LHS, RHS, Accum), 
  fold_lag(Xs, Accum, Pred, Result).

%% foldr1(?List, ?Pred, ?Result)
%  Fold List right-to-left using Pred starting with the last element
%  of List.
foldlr1(List, Pred, Result) :-
  reverse(List, ListR),
  foldl1(ListR, Pred, Result).

%% foldr(?List, ?Pred, ?Start, ?Result)
%  Fold List right-to-left using Pred starting with Start.
foldlr(List, Pred, Start, Result) :-
  reverse(List, ListR),
  foldl1(ListR, Start, Pred, Result).

%% string_to_term(+Text, -Term) is det.
% Convert a String to a Term, stripping whitespaces
string_to_term(Text, Term) :-
  string(Text), 
  string_to_list(Text, X1),
  sublist(\=(32), X1, X2), % remove whitespaces
  string_to_atom(X2, X3), 
  atom_to_term(X3, Term, _).

%% atom_to_string(+Atom, -String) is det.
% Convert an Atom to a String
atom_to_string(A, S) :-
  atom_codes(A, Cs),
  string_to_list(S, Cs).

%% term_to_string(+Term, -String) is det.
term_to_string(Term, String) :-
  term_to_atom(Term, X),
  string_to_atom(String, X).

%% list_from_to(+Start, +End, -List) is det.
% Create a list of integers [Start..End]
list_from_to(E, E, [E]) :- number(E).

list_from_to(S, E, [X|Xs]) :-
  number(S), number(E),
  S < E,
  X = S,
  S1 is S + 1,
  list_from_to(S1, E, Xs).

%% repeat_string(+S, +N, -Res) is det.
repeat_string(_, 0, "").
repeat_string(S, 1, S).
repeat_string(S, N, Res) :-
  N_1 is N-1,
  repeat_string(S, N_1, S_1),
  string_concat(S, S_1, Res).

% replace_all(+List, +What, +With, -NewList) is det.
% replace all instances of What with With in List yielding NewList
replace_all([], _, _, []).
replace_all([X|Xs], What, With, [Y|Ys]) :-
  (   X = What
  ->  Y = With
  ;   Y = X),
  replace_all(Xs, What, With, Ys).

% replace_in_atom(+Atom, +What, +With, -NewAtom) is det.
% replace 1 instance of What with With in Atom yielding NewAtom
replace_in_atom(Atom, What, With, NewAtom) :-
  sub_atom(Atom, Be, Len, _, What),
  sub_atom(Atom, 0, Be, _, A1),
  Re is Be+Len,
  sub_atom(Atom, Re, _, 0, A2),
  atomic_list_concat([A1, With, A2], NewAtom).

%% replace_nth(+Xs, +N, +E, +R, -Ys) is det.
% replace the nth element of a list with R and return it in E
replace_nth(_, [], _, []).
replace_nth([R|Xs], 0, E, R, [E|Xs]) :- !.
replace_nth([X|Xs], N, E, R, [X|Ys]) :-
  N1 is N - 1,
  replace_nth(Xs, N1, E, R, Ys).


% helper functions for basic term replacing
% FIXME: ..=
un_op(Term, F, A) :-
  functor(Term, F, 1),
  arg(1, Term, A).
bin_op(Term, F, A, B) :-
  functor(Term, F, 2),
  arg(1, Term, A),
  arg(2, Term, B).
tern_op(Term, F, A, B, C) :-
  functor(Term, F, 3),
  arg(1, Term, A),
  arg(2, Term, B),
  arg(3, Term, C).
quad_op(Term, F, A, B, C, D) :-
  functor(Term, F, 4),
  arg(1, Term, A),
  arg(2, Term, B),
  arg(3, Term, C),
  arg(4, Term, D).
quint_op(Term, F, A, B, C, D, E) :-
  functor(Term, F, 5),
  arg(1, Term, A),
  arg(2, Term, B),
  arg(3, Term, C),
  arg(4, Term, D),
  arg(5, Term, E).
seni_op(Term, F, A, B, C, D, E, Ef) :-
  functor(Term, F, 6),
  arg(1, Term, A),
  arg(2, Term, B),
  arg(3, Term, C),
  arg(4, Term, D),
  arg(5, Term, E),
  arg(6, Term, Ef).

%% term_mod(+Term, +M, -ModTerm) is nondet.
% Try to apply M on Term recursively
term_mod(Term, _, Term) :- var(Term), !.

term_mod([], _, []) :- !.

term_mod([T|Ts], M, [TM|TMs]) :- !,
  term_mod(T, M, TM),
  term_mod(Ts, M, TMs).

term_mod(Term, M, Mod) :- 
  M =.. L1,
  append(L1, [Term, Term1], L2),
  Pred =.. L2,
  Pred,

  (var(Term1)
  -> Mod = Term1
  ; (Term1 =.. [F|Ts],
     term_mod(Ts, M, Tms),
     Mod =.. [F|Tms])
  ).

