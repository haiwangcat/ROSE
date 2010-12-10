#!/usr/bin/env python
# -*- python -*-
## @package ir
# Convenience definitions for intermediate representation (IR) nodes.
#
# Please report bugs to <adrian@llnl.gov>.
#
# \authors
# Copyright (c) 2010, Lawrence Livermore National Security, LLC             \n
# Produced at the Lawrence Livermore National Laboratory.                   \n
# Written by the Components Team <components@llnl.gov>                      \n
# UCRL-CODE-2002-054                                                        \n
# All rights reserved.                                                      \n
#                                                                           \n
# This file is part of Babel. For more information, see                     \n
# http://www.llnl.gov/CASC/components/. Please read the COPYRIGHT file      \n
# for Our Notice and the LICENSE file for the GNU Lesser General Public     \n
# License.                                                                  \n
#                                                                           \n
# This program is free software; you can redistribute it and/or modify it   \n
# under the terms of the GNU Lesser General Public License (as published by \n
# the Free Software Foundation) version 2.1 dated February 1999.            \n
#                                                                           \n
# This program is distributed in the hope that it will be useful, but       \n
# WITHOUT ANY WARRANTY; without even the IMPLIED WARRANTY OF                \n
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the terms and    \n
# conditions of the GNU Lesser General Public License for more details.     \n
#                                                                           \n
# You should have recieved a copy of the GNU Lesser General Public License  \n
# along with this program; if not, write to the Free Software Foundation,   \n
# Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA               \n
#                                                                           \n

# SIDL nodes
version         = 'version'
require         = 'require'
import_         = 'import'
package         = 'package'
user_type       = 'user type'
type_attribute  = 'type attribute'
identifier      = 'identifier'
enum            = 'enum'
enumerator      = 'enumerator'
struct          = 'struct'
struct_item     = 'struct_item'
class_          = 'class'
interface       = 'interface'
implements      = 'implements'
implements_all  = 'implements all'
method          = 'method'
type_           = 'type'
void            = 'void'
arg             = 'arg'
custom_attribute= 'custom attribute'
custom_attribute_assoc = 'custom attribute assoc'
mode            = 'mode'
primitive_type  = 'primitive type'
array           = 'array'

# Expressions
fn_eval         = 'fn eval'
var_ref         = 'var ref'
scoped_id       = 'scoped id'
complex_        = 'complex'

# additional Proc. IR nodes
function        = 'function'
void            = 'void'
stmt            = 'stmt'
get_struct_item = 'get_struct_item'
