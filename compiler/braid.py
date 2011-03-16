#!/usr/bin/env python
# -*- python -*-
## @package parser
#
# Command line handling for the BRAID tool
#
# Please report bugs to <adrian@llnl.gov>.
#
# \authors <pre>
#
# Copyright (c) 2011, Lawrence Livermore National Security, LLC.
# Produced at the Lawrence Livermore National Laboratory
# Written by Adrian Prantl <adrian@llnl.gov>.
#  
# CODE-473891.
# All rights reserved.
#  
# This file is part of BRAID. For details, see 
# http://compose-hpc.sourceforge.net/. 
# Please read the COPYRIGHT file for Our Notice and
# for the BSD License.
#
# </pre>
#
# \mainpage
# Welcome to Braid/Babel 2!

import argparse
import sidl_parser
import codegen

if __name__ == '__main__':

    cmdline = argparse.ArgumentParser(description='''
Do magically wonderful things with SIDL (scientific interface
definition language) files.
''')
    cmdline.add_argument('sidl_files', metavar='file.sidl', nargs='+',#type=file
			 help='SIDL files to use as input')

    cmdline.add_argument('--gen-sexp', action='store_true', dest='gen_sexp',
			 help='generate an s-expression')

    cmdline.add_argument('--gen-sidl', action='store_true', dest='gen_sidl',
			 help='generate SIDL output again')


    args = cmdline.parse_args()
    for sidl_file in args.sidl_files:
	result = sidl_parser.parse(sidl_file)
	if args.gen_sexp:
	    print result.sexp()
	if args.gen_sidl:
	    print codegen.SIDLCodeGenerator().generate(result.sexp())

    exit(0)
