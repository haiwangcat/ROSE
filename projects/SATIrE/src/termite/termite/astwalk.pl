#!/usr/bin/pl -t testrun -f
% -*- prolog -*-

:- module(astwalk,
	  [walk_to/3,
	   goto_function/3,
	   
	   top/2,
	   up/2,
	   down/3,
	   right/2,

	   next_preorder/2,
	   
	   zip/2,
	   unzip/3,

	   distance_from_root/2]).

%-----------------------------------------------------------------------
/** <module> Flexible traversals of abstract syntax trees

This module defines commonly-used transformation utilities for the AST
exported by SATIrE. It represents an more flexible alternative to the
transformation interface provided by module ast_transform.

@version   @PACKAGE_VERSION@
@copyright Copyright (C) 2008-2009 Adrian Prantl
@author    Adrian Prantl <adrian@complang.tuwien.ac.at>
@license   See COPYING in the root folder of the SATIrE project

*/
%-----------------------------------------------------------------------

% Unit Test
%:- ast_walk(zipper(if_stmt(e,a,[r,if_stmt(e,a,b,x,x),t],x,x), []), P2).

%% zip(+Tree, -Zipper) is det.
% Creates a new Zipper from Tree.
%
% How to move around a tree and replace subtrees=branches?
%
% At each node, we cut out a branch and replace it with a free variable <Gap>.
% The original branch is given as a separate argument,
% allowing us to bind the new branch to <Gap>.
%
% In a way, this works just like Huet's zipper!
zip(X, zipper(X, [])).

%% unzip(?Zipper, ?Tree, ?Context) is det.
% Converts between the Zipper data structure and its contents.
unzip(zipper(X,Ctx), X, Ctx).

% Helper functions to navigate through a zipper

%% walk_to(+Zipper, +Context, -Zipper1) is semidet.
walk_to(Z, Ctx, Z1) :-
  reverse(Ctx, Path),
  top(Z, Top),
  walk_to1(Top, Path, Z1), !.

walk_to1(Z, [], Z).
walk_to1(Z, [Down|Ps], Z2) :-
  ( Down = down(_, _, N)
  ; Down = down_list(_, _, N)),
  down(Z, N, Z1),
  walk_to1(Z1, Ps, Z2).

%% down(+Zipper, +BranchNum, -Zipper1) is semidet.
% Navigate downwards in the tree to child #BranchNum.
%
% * Works also with lists.
down(zipper(List,Ctx), N,
     zipper(Child, [down_list(PredsR, Succs, N)|Ctx])) :- 
  is_list(List), !,
  N1 is N-1,
  length(Preds, N1),
  append(Preds, [Child|Succs], List),
  reverse(Preds, PredsR), !.
  %replace_nth(List, N1, Gap, Child, List1).

down(zipper(X,Ctx), N, zipper(Child,[down(X1,Gap,N)|Ctx])) :-
  X =.. List,
  replace_nth(List, N, Gap, Child, List1),
  X1 =.. List1.

%% up(+Zipper, -Zipper1) is semidet.
% Navigate upwards in the tree.
up(zipper(X,[down(Parent,Gap,_)|Ctx]), zipper(Parent,Ctx)) :- !, X = Gap.
up(zipper(X,[down_list(PredsR, Succs, _)|Ctx]), zipper(Parent,Ctx)) :-
  reverse(PredsR, Preds),
  append(Preds, [X|Succs], Parent),
  !.

%% right(+Zipper, -Zipper1) is semidet.
% Navigate to the next sibling in a tree or a list.
right(zipper(X, [down_list(PredsR, [Y|Succs], N)|Ctx]),
      zipper(Y, [down_list([X|PredsR], Succs, N1)|Ctx])) :- !,
  N1 is N+1.

% @tbd Could be done much(!) more efficiently, currently O(n*n)
right(zipper(X, [down(C,Gap,N)|Ctx]), X2) :-
  up(zipper(X, [down(C,Gap,N)|Ctx]), X1),
  N1 is N+1,
  down(X1, N1, X2).

%% top(+Zipper, -Zipper1) is semidet.
% Navigate back to the root of our tree.
%
% @tbd Could be implemented more efficiently, too
top(zipper(X,[]), zipper(X,[])) :- !.
top(X, X2) :- up(X, X1), top(X1, X2), !.

%% goto_function(+Zipper, ?Template, +Zipper1) is nondet.
% find a function like Template in a project or file and return its body
% if there is only a declaration available, the declaration will be returned
goto_function(P, Function, P1) :-
  (  % Prefer to find a real definition first
     find_function(P, Function, P1),
     unzip(P1, Function, _),
     Function = function_declaration(_Params, _Null, Def, _A1, _Ai1, _F1),
     Def \= null
  ; 
     find_function(P, Function, P1),
     unzip(P1, Function, _),
     Function = function_declaration(_, _, null, _, _, _)
  ), !.

find_function(P, FunctionTemplate, P3) :-
  unzip(P, project(_Files, _A, _Ai, _Fi), _), !,
  down(P, 1, P1),
  down(P1, 1, P2),
  find_function1(P2, FunctionTemplate, P3).

find_function(P, FunctionTemplate, P4) :-
  unzip(P, source_file(global(_Funcs, _A1, _Ai, _F1), _A2, _Ai2, _F2), _), !,
  down(P, 1, P1),
  down(P1, 1, P2),
  down(P2, 1, P3),
  find_function1(P3, FunctionTemplate, P4).

find_function(zipper(FuncTempl, Ctx), FuncTempl, zipper(FuncTempl, Ctx)).

find_function1(zipper([], Ctx), _, zipper([], Ctx)).
find_function1(P, FunctionTemplate, P2) :-
  (  find_function(P, FunctionTemplate, P2)
  ;
     right(P, P1),
     find_function1(P1, FunctionTemplate, P2)
  ).

%% distance_from_root(+Zipper, -Distance) is det.
% Return the current distance from the root node
distance_from_root(zipper(_, Nav), Distance) :- length(Nav, Distance).

%% next_preorder(+Zipper, -Zipper)
% @tbd change name to next_tdlr
% Return the ``next'' node in a left-to-right traversal fashion.
% Algorithm: (rechtssucher)
%   try down(1)
%   else while not try right() do up()

next_preorder(P1, P2) :- down(P1, 1, P2), !.
next_preorder(P1, P2) :- right_or_up(P1, P2).

right_or_up(P1, Pn) :- right(P1, Pn), !.
right_or_up(P1, Pn) :- 
  up(P1, P2),
  right_or_up(P2, Pn).


