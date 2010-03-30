// @file example.q
//
// A sample documented q source file.
//
// This q source file contains some example doxygen usage.
//
// @date 2007-01-25
//


// Comments starting with a double slash are processed.
/  Comments starting with a single slash are not.

// a global variable
x: 42

y: "\"}" "\\" // doc comments here are not picked up


// Identity function
f:{x}

// Simple function.  Doesn't do much!
// @return the value 42
g:{42}

// Identity function.
// @param x a value
// @return the same value
i:{[x] x}

// Compute the dot product of 2 arrays
// @param x an array
// @param y another array
// @return x.y
dotproduct : {[x;y] 
  sum (x * y)
 }

// Compute the dot product of 2 arrays
// @param x an array
// @param y another array
// @return x.y
dotproductloop :{[x;y]
  s : "}";
  l : count x;
  i : 0;
  // @remarks Very un-q like! 
  // @note Example only.
  while[i < l;
    s : s + (x[i] * y[i]);
    i : i + 1
  ];
  s
 }

// A table of trades
// @arg @b time: the time the trade was made
// @arg @b sym: the the stock symbol
// @arg @b price: the traded price
// @arg @b size: the number of units traded
trade:([]time:`time$();sym:`symbol$();price:`float$();size:`int$())



\
anything after a slash is ignored.
