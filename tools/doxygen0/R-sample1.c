/// @file R-sample1.R
/// @brief This is a sample of a script
/// 
/// Has mostly calls and instantiations.
/// Some results and scripting.
/// @note
/// This file has some comments to explain @brief and . (full stop). This is a
/// doxygen caveat.
/// @see pkg

 
 
 
/// test function returns one (no full stop not brief)
/// @param car input variable
/// @return one

 scripted1(type car){}	// 18 "./R-sample1.R" 
 
 
 
/// function no meta fields (full stop means brief).
 scripted2(type car){}	// 23 "./R-sample1.R" 
 
 
 
/// function no meta fields with blank line does not force this as brief
///
 scripted3(type car){}	// 29 "./R-sample1.R" 
 
 
 
 
 
 
 
 
 
 
/// @var type var1
/// @brief A script static.
 type var1 = c(10, 20); 
 
/// Some script's twists.
type a = d; 
 
 
 
 
