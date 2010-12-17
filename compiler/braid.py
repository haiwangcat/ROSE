#!/usr/bin/env python
# -*- python -*-
## @package parser
#
# Command line handling for the BRAID tool
#
# Please report bugs to <adrian@llnl.gov>.
#
# \authors <pre>
# Copyright (c) 2010, Lawrence Livermore National Security, LLC
# Produced at the Lawrence Livermore National Laboratory.
# Written by the Components Team <components@llnl.gov>
# UCRL-CODE-????-???
# All rights reserved.
#
# This file is part of Babel. For more information, see
# http://www.llnl.gov/CASC/components/. Please read the COPYRIGHT file
# for Our Notice and the LICENSE file for ????
# License.
#
# </pre>    \TODO insert License
#
# \mainpage
# Welcome to Braid/Babel 2!

import sidl_parser
import argparse

if __name__ == '__main__':

    cmdline = argparse.ArgumentParser(description='''
Do magically wonderful things with SIDL (scientific interface
definition language) files.
''')
    cmdline.add_argument('sidl_files', metavar='file.sidl', #type=file,
                         nargs='+', help='SIDL files to use as input')
    cmdline.add_argument('--gen-sexp', action='store_true', dest='gen_sexp',
                         help='generate an s-expression')

    args = cmdline.parse_args()
    for sidl_file in args.sidl_files:
        result = sidl_parser.parse(sidl_file)

        if args.gen_sexp:
            print result.sexp()

    exit(0)



