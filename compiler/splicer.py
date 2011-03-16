#!/usr/bin/env python
# -*- python -*-
## @package splicer
# Support functions for handling Babel Splicer blocks
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
import os,re

def replace(filename, splicer_name, text):
    """
    Replace the contents of a \c splicer_block with \c text.
    \param filename   The name of the file to edit.

    expect(string, string, string)
    """
    #print "splicing", splicer_name, "with '"+text+"'"
    if text == None: raise Exception("Empty splicer text")

    # first make a backup of the old file
    os.rename(filename, filename+'~')
    dest = open(filename, 'w')
    src = open(filename+'~', 'r')

    inside = False
    did_replace = False
    for line in src:
        if re.match(r'.*DO-NOT-DELETE splicer\.begin\('+splicer_name+r'\).*', 
                    line):
            dest.write(line)
            dest.write(text)
            inside = True
            did_replace = True
        elif (inside and
            re.match(r'.*DO-NOT-DELETE splicer\.end\('+splicer_name+r'\).*', 
                     line)):
                inside = False

        if not inside:
            dest.write(line)
                
    if inside:
        raise Exception("unclosed splicer block")

    if not did_replace:
        raise Exception("splicer block not found")

    src.close()
    dest.close()
