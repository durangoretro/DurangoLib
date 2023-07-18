/* Copyright 2022 Durango Computer Team

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.
*/

/** @file durango.h Main Header File **/

#ifndef _H_DURANGO
#define _H_DURANGO

// comment this define to disable PSV integration
#define PSV

//Main functions
#include "qgraph.h"
#include "glyph.h"
#include "sprites.h"
#include "geometrics.h"
#include "music.h"

//System Functions
#include "system.h"

//conio and default Font
#include "conio.h"
#include "default_font.h"

// if the define of PSV is disabled the PSV functions is not included
#ifdef PSV

//Virtual Serial Port (PSV) Functions 
#include "psv.h"

#endif

#endif

