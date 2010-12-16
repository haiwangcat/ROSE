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

import parser
import argparse

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='''
Do magically wonderful things with SIDL (scientific interface
definition language) files.
''')
    parser.add_argument('sidl_files', metavar='file.sidl', type=file, nargs='+',
                        help='SIDL files to use as input')
    parser.add_argument('--gen-sexpr', action='store_true',
                        help='generate an s-expression')

    args = parser.parse_args()
    for sidl_file in args.sidl_files:
        sidlParse(sidl_file

    if args.gen_sexpr:
      print result.sexpr()

    return 0
)


