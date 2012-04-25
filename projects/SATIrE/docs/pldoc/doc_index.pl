/*  $Id$

    Part of SWI-Prolog

    Author:        Jan Wielemaker
    E-mail:        wielemak@science.uva.nl
    WWW:           http://www.swi-prolog.org
    Copyright (C): 1985-2006, University of Amsterdam

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    As a special exception, if you link this library with other files,
    compiled with a Free Software compiler, to produce an executable, this
    library does not by itself cause the resulting executable to be covered
    by the GNU General Public License. This exception does not however
    invalidate any other reasons why the executable file might be covered by
    the GNU General Public License.
*/

:- module(pldoc_index,
	  [ doc_for_dir/2,		% +Dir, +Options
	    dir_index/4,		% +Dir, +Options, //
	    object_summaries/5,		% +Objs, +Section, +Options, //
	    file_index_header/4,	% +File, +Options, //
	    doc_links/4,		% +Directory, +Options, //
	    doc_file_href/2,		% +File, -/doc/...
	    source_directory/1		% ?Directory
	  ]).
:- use_module(doc_process).
:- use_module(doc_html).
:- use_module(doc_wiki).
:- use_module(doc_search).
:- use_module(doc_util).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/html_head)).
:- use_module(library(readutil)).
:- use_module(library(url)).
:- use_module(library(option)).
:- use_module(library(doc_http)).
:- include(hooks).

/** <module> Create indexes
*/

%%	doc_for_dir(+Dir, +Options) is det.
%
%	Write summary index for all files  in   Dir  to  Out. The result
%	consists of the =README= file  (if   any),  a  table holding with
%	links to objects and summary  sentences   and  finaly the =TODO=
%	file (if any).

doc_for_dir(DirSpec, Options) :-
	absolute_file_name(DirSpec,
			   [ file_type(directory),
			     access(read)
			   ],
			   Dir),
	file_base_name(Dir, Base),
	Title = Base,
	reply_html_page(title(Title),
			\dir_index(Dir, Options)).


%%	dir_index(+Dir, +Options)//
%
%	Create an index for all Prolog files appearing in Dir or in
%	any directory contained in Dir.

dir_index(Dir, Options) -->
	{ dir_source_files(Dir, Files0, Options),
	  sort(Files0, Files),
	  atom_concat(Dir, '/index.html', File),
	  b_setval(pldoc_file, File)	% for predref
	},
	html([ \doc_links(Dir, Options),
	       \dir_header(Dir, Options),
	       table(class(summary),
		     \file_indices(Files, [directory(Dir)|Options])),
	       \dir_footer(Dir, Options)
	     ]).

%%	dir_source_files(+Dir, -Files, +Options) is det
%
%	Create a list of source-files to be documented as part of Dir.

dir_source_files(DirSpec, Files, _Options) :-
	absolute_file_name(DirSpec, Dir,
			   [ file_type(directory),
			     access(read)
			   ]),
	findall(F, source_file_in_dir(Dir, F), Files).

source_file_in_dir(Dir, File) :-
	source_file(File),
	sub_atom(File, 0, _, _, Dir).

%%	dir_header(+Dir, +Options)// is det.
%
%	Create header for directory

dir_header(Dir, _Options) -->
	wiki_file(Dir, readme), !.
dir_header(Dir, _Options) -->
	{ file_base_name(Dir, Base)
	},
	html(h1(class=dir, Base)).

%%	dir_footer(+Dir, +Options)// is det.
%
%	Create footer for directory. The footer contains the =TODO= file
%	if provided.

dir_footer(Dir, _Options) -->
	wiki_file(Dir, todo), !.
dir_footer(_, _) -->
	[].

%%	wiki_file(+Dir, +Type)// is semidet.
%
%	Include text from a Wiki text-file.

wiki_file(Dir, Type) -->
	{ wiki_file_type(Type, Base),
	  atomic_list_concat([Dir, /, Base], File),
	  access_file(File, read), !,
	  read_file_to_codes(File, String, []),
	  wiki_codes_to_dom(String, [], DOM)
	},
	pldoc_html:html(DOM).

%%	wiki_file_type(+Category, -File) is nondet.

wiki_file_type(readme, 'README').
wiki_file_type(readme, 'README.TXT').
wiki_file_type(todo,   'TODO').
wiki_file_type(todo,   'TODO.TXT').

%%	file_indices(+Files, +Options)// is det.
%
%	Provide a file-by-file index of the   contents of each member of
%	Files.

file_indices([], _) -->
	[].
file_indices([H|T], Options) -->
	file_index(H, Options),
	file_indices(T, Options).

%%	file_index(+File, +Options)// is det.
%
%	Create an index for File.

file_index(File, Options) -->
	{ Pos = File:_Line,
	  findall(doc(Obj,Pos,Summary),
		  doc_comment(Obj, Pos, Summary, _), Objs0),
	  module_info(File, ModuleOptions, Options),
	  doc_hide_private(Objs0, Objs1, ModuleOptions),
	  sort(Objs1, Objs)
	},
	html([ \file_index_header(File, Options)
	     | \object_summaries(Objs, File, ModuleOptions)
	     ]).

%%	file_index_header(+File, +Options)// is det.
%
%	Create an entry in a summary-table for File.

file_index_header(File, Options) -->
	prolog:doc_file_index_header(File, Options), !.
file_index_header(File, Options) -->
	{ file_base_name(File, Label),
	  doc_file_href(File, HREF, Options),
	  ButtonOptions = [button_height(16)|Options]
	},
	html(tr(th([colspan(3), class(file)],
		   [ span(style('float:left'), a(href(HREF), Label)),
		     span(style('float:right'),
			  [ \source_button(File, ButtonOptions),
			    \edit_button(File, ButtonOptions)
			  ])
		   ]))).


%%	doc_file_href(+File, -HREF, +Options) is det.
%
%	HREF is reference to documentation of File.

doc_file_href(File, HREF, Options) :-
	option(directory(Dir), Options),
	atom_concat(Dir, Local0, File),
	atom_concat(/, Local, Local0), !,
	(   option(files(Map), Options),	% generating files
	    memberchk(file(File, DocFile), Map)
	->  file_base_name(DocFile, HREF)
	;   HREF = Local
	).
doc_file_href(File, HREF, _) :-
	doc_file_href(File, HREF).



%%	doc_file_href(+Path, -HREF) is det.
%
%	Create a /doc HREF from Path.  There   are  some nasty things we
%	should take care of.
%
%		* Windows paths may start with =|L:|= (mapped to =|/L:|=)
%		* Paths may contain spaces and other weird stuff

doc_file_href(File0, HREF) :-
	insert_alias(File0, File),
	ensure_slash_start(File, SlashFile),
	http_location([path(SlashFile)], Escaped),
	http_location_by_id(pldoc_doc, DocRoot),
	format(string(HREF), '~w~w', [DocRoot, Escaped]).

%%	ensure_slash_start(+File0, -File) is det.
%
%	Ensure  File  starts  with  a  /.    This  maps  C:/foobar  into
%	/C:/foobar, so our paths start with /doc/ again ...

ensure_slash_start(File, File) :-
	sub_atom(File, 0, _, _, /), !.
ensure_slash_start(File0, File) :-
	atom_concat(/, File0, File).


%%	object_summaries(+Objects, +Section, +Options)// is det.
%
%	Create entries in a summary table for Objects.

object_summaries(Objects, Section, Options) -->
	{ tag_pub_priv(Objects, Tagged, Options),
	  keysort(Tagged, Ordered)
	},
	obj_summaries(Ordered, Section, Options).

obj_summaries([], _, _) -->
	[].
obj_summaries([_Tag-H|T], Section, Options) -->
	object_summary(H, Section, Options),
	obj_summaries(T, Section, Options).

tag_pub_priv([], [], _).
tag_pub_priv([H|T0], [Tag-H|T], Options) :-
	(   private(H, Options)
	->  Tag = z_private
	;   Tag = a_public
	),
	tag_pub_priv(T0, T, Options).


%%	object_summary(+Object, +Section, +Options)// is det
%
%	Create a summary for Object.  Summary consists of a link to
%	the Object and a summary text as a table-row.
%
%	@tbd	Hacky interface.  Do we demand Summary to be in Wiki?

object_summary(doc(Obj, _Pos, Summary), _Section, Options) --> !,
	(   { string_to_list(Summary, Codes),
	      wiki_codes_to_dom(Codes, [], DOM0),
	      strip_leading_par(DOM0, DOM),
	      (	  private(Obj, Options)
	      ->  Class = private		% private definition
	      ;   Class = public		% public definition
	      )
	    }
	->  html(tr(class(Class),
		    [ td(\object_ref(Obj, Options)),
		      td(class(summary), DOM),
		      td([align(right), width('30')],
			 span(style('float:right'),
			      [ \object_source_button(Obj, Options),
				\object_edit_button(Obj, Options)
			      ]))
		    ]))
	;   []
	).
object_summary(Obj, Section, Options) -->
	{ prolog:doc_object_summary(Obj, _Cat, Section, Summary)
	}, !,
	object_summary(doc(Obj, _, Summary), Section, Options).
object_summary(_, _, _) -->
	[].


		 /*******************************
		 *	    NAVIGATION		*
		 *******************************/

%%	doc_links(+Directory, +Options)// is det.
%
%	Provide overview links and search facilities.

doc_links(_Directory, Options) -->
	{ option(files(_), Options), !
	}.
doc_links(Directory, Options) -->
	{   Directory == ''
	->  working_directory(Dir, Dir)
	;   Dir = Directory
	},
	html([ \html_requires(pldoc),
	       div(class(navhdr),
		   [ div(class(jump),
			  div([ \places_menu(Dir),
				\version
			      ])),
		     div(class(search), \search_form(Options)),
		     br(clear(right))
		   ])
	     ]).


%%	version// is det.
%
%	Prolog version

version -->
	{ current_prolog_flag(version_data, swi(Major, Minor, Patch, _))
	},
	html(a([ class(prolog_version),
		 href('http://www.swi-prolog.org')
	       ],
	       [' SWI-Prolog ', Major, '.', Minor, '.', Patch])).


%%	places_menu(Current)// is det
%
%	Create a =select= menu with entries for all loaded directories

places_menu(Dir) -->
	prolog:doc_places_menu(Dir), !.
places_menu(Dir) -->
	{ findall(D, source_directory(D), List),
	  sort(List, Dirs)
	},
	html(form([ action(location_by_id(pldoc_dir))
		  ],
		  [ input([type(submit), value('Go')]),
		    select(name(dir),
			   \source_dirs(Dirs, Dir))
		  ])).

source_dirs([], _) -->
	[].
source_dirs([H|T], WD) -->
	{ (   H == WD
	  ->  Attrs = [selected]
	  ;   Attrs = []
	  ),
	  format(string(IndexFile), '~w/index.html', [H]),
	  doc_file_href(IndexFile, HREF),
	  format(string(Call), 'document.location=\'~w\';', [HREF])
	},
	html(option([onClick(Call)|Attrs], H)),
	source_dirs(T, WD).

%%	source_directory(+Dir) is semidet.
%%	source_directory(-Dir) is det.
%
%	True if Dir is a directory  from   which  we  have loaded Prolog
%	sources.

source_directory(Dir) :-
	(   ground(Dir)
	->  '$time_source_file'(File, _Time1, _System1),
	    file_directory_name(File, Dir), !
	;   '$time_source_file'(File, _Time2, _System2),
	    file_directory_name(File, Dir)
	).
