#if !defined(LEVENSHTEIN1)
#define LEVENSHTEIN1

#define Levenshtein_DESC \
  "A C extension module for fast computation of:\n" \
  "- Levenshtein (edit) distance and edit sequence manipluation\n" \
  "- string similarity\n" \
  "- approximate median strings, and generally string averaging\n" \
  "- string sequence and set similarity\n" \
  "\n" \
  "Levenshtein has a some overlap with difflib (SequenceMatcher).  It\n" \
  "supports only strings, not arbitrary sequence types, but on the\n" \
  "other hand it's much faster.\n" \
  "\n" \
  "It supports both normal and Unicode strings, but can't mix them, all\n" \
  "arguments to a function (method) have to be of the same type (or its\n" \
  "subclasses).\n"

#define distance_DESC \
  "Compute absolute Levenshtein distance of two strings.\n" \
  "\n" \
  "distance(string1, string2)\n" \
  "\n" \
  "Examples (it's hard to spell Levenshtein correctly):\n" \
  ">>> distance('Levenshtein', 'Lenvinsten')\n" \
  "4\n" \
  ">>> distance('Levenshtein', 'Levensthein')\n" \
  "2\n" \
  ">>> distance('Levenshtein', 'Levenshten')\n" \
  "1\n" \
  ">>> distance('Levenshtein', 'Levenshtein')\n" \
  "0\n" \
  "\n" \
  "Yeah, we've managed it at last.\n"

#define ratio_DESC \
  "Compute similarity of two strings.\n" \
  "\n" \
  "ratio(string1, string2)\n" \
  "\n" \
  "The similarity is a number between 0 and 1, it's usually equal or\n" \
  "somewhat higher than difflib.SequenceMatcher.ratio(), becuase it's\n" \
  "based on real minimal edit distance.\n" \
  "\n" \
  "Examples:\n" \
  ">>> ratio('Hello world!', 'Holly grail!')\n" \
  "0.58333333333333337\n" \
  ">>> ratio('Brian', 'Jesus')\n" \
  "0.0\n" \
  "\n" \
  "Really?  I thought there was some similarity.\n"

#define hamming_DESC \
  "Compute Hamming distance of two strings.\n" \
  "\n" \
  "hamming(string1, string2)\n" \
  "\n" \
  "The Hamming distance is simply the number of differing characters.\n" \
  "That means the length of the strings must be the same.\n" \
  "\n" \
  "Examples:\n" \
  ">>> hamming('Hello world!', 'Holly grail!')\n" \
  "7\n" \
  ">>> hamming('Brian', 'Jesus')\n" \
  "5\n"

#define jaro_DESC \
  "Compute Jaro string similarity metric of two strings.\n" \
  "\n" \
  "jaro(string1, string2)\n" \
  "\n" \
  "The Jaro string similarity metric is intended for short strings like\n" \
  "personal last names.  It is 0 for completely different strings and\n" \
  "1 for identical strings.\n" \
  "\n" \
  "Examples:\n" \
  ">>> jaro('Brian', 'Jesus')\n" \
  "0.0\n" \
  ">>> jaro('Thorkel', 'Thorgier')\n" \
  "0.77976190476190477\n" \
  ">>> jaro('Dinsdale', 'D')\n" \
  "0.70833333333333337\n"

#define jaro_winkler_DESC \
  "Compute Jaro string similarity metric of two strings.\n" \
  "\n" \
  "jaro_winkler(string1, string2[, prefix_weight])\n" \
  "\n" \
  "The Jaro-Winkler string similarity metric is a modification of Jaro\n" \
  "metric giving more weight to common prefix, as spelling mistakes are\n" \
  "more likely to occur near ends of words.\n" \
  "\n" \
  "The prefix weight is inverse value of common prefix length sufficient\n" \
  "to consider the strings `identical'.  If no prefix weight is\n" \
  "specified, 1/10 is used.\n" \
  "\n" \
  "Examples:\n" \
  ">>> jaro_winkler('Brian', 'Jesus')\n" \
  "0.0\n" \
  ">>> jaro_winkler('Thorkel', 'Thorgier')\n" \
  "0.86785714285714288\n" \
  ">>> jaro_winkler('Dinsdale', 'D')\n" \
  "0.73750000000000004\n" \
  ">>> jaro_winkler('Thorkel', 'Thorgier', 0.25)\n" \
  "1.0\n"

#define median_DESC \
  "Find an approximate generalized median string using greedy algorithm.\n" \
  "\n" \
  "median(string_sequence[, weight_sequence])\n" \
  "\n" \
  "You can optionally pass a weight for each string as the second\n" \
  "argument.  The weights are interpreted as item multiplicities,\n" \
  "although any non-negative real numbers are accepted.  Use them to\n" \
  "improve computation speed when strings often appear multiple times\n" \
  "in the sequence.\n" \
  "\n" \
  "Examples:\n" \
  ">>> median(['SpSm', 'mpamm', 'Spam', 'Spa', 'Sua', 'hSam'])\n" \
  "'Spam'\n" \
  ">>> fixme = ['Levnhtein', 'Leveshein', 'Leenshten',\n" \
  "...          'Leveshtei', 'Lenshtein', 'Lvenstein',\n" \
  "...          'Levenhtin', 'evenshtei']\n" \
  ">>> median(fixme)\n" \
  "'Levenshtein'\n" \
  "\n" \
  "Hm.  Even a computer program can spell Levenshtein better than me.\n"

#define median_improve_DESC \
  "Improve an approximate generalized median string by perturbations.\n" \
  "\n" \
  "median_improve(string, string_sequence[, weight_sequence])\n" \
  "\n" \
  "The first argument is the estimated generalized median string you\n" \
  "want to improve, the others are the same as in median().  It returns\n" \
  "a string with total distance less or equal to that of the given string.\n" \
  "\n" \
  "Note this is much slower than median().  Also note it performs only\n" \
  "one improvement step, calling median_improve() again on the result\n" \
  "may improve it further, though this is unlikely to happen unless the\n" \
  "given string was not very similar to the actual generalized median.\n" \
  "\n" \
  "Examples:\n" \
  ">>> fixme = ['Levnhtein', 'Leveshein', 'Leenshten',\n" \
  "...          'Leveshtei', 'Lenshtein', 'Lvenstein',\n" \
  "...          'Levenhtin', 'evenshtei']\n" \
  ">>> median_improve('spam', fixme)\n" \
  "'enhtein'\n" \
  ">>> median_improve(median_improve('spam', fixme), fixme)\n" \
  "'Levenshtein'\n" \
  "\n" \
  "It takes some work to change spam to Levenshtein.\n"

#define quickmedian_DESC \
  "Find a very approximate generalized median string, but fast.\n" \
  "\n" \
  "quickmedian(string[, weight_sequence])\n" \
  "\n" \
  "See median() for argument description.\n" \
  "\n" \
  "This method is somewhere between setmedian() and picking a random\n" \
  "string from the set; both speedwise and quality-wise.\n" \
  "\n" \
  "Examples:\n" \
  ">>> fixme = ['Levnhtein', 'Leveshein', 'Leenshten',\n" \
  "...          'Leveshtei', 'Lenshtein', 'Lvenstein',\n" \
  "...          'Levenhtin', 'evenshtei']\n" \
  ">>> quickmedian(fixme)\n" \
  "'Levnshein'\n"

#define setmedian_DESC \
  "Find set median of a string set (passed as a sequence).\n" \
  "\n" \
  "setmedian(string[, weight_sequence])\n" \
  "\n" \
  "See median() for argument description.\n" \
  "\n" \
  "The returned string is always one of the strings in the sequence.\n" \
  "\n" \
  "Examples:\n" \
  ">>> setmedian(['ehee', 'cceaes', 'chees', 'chreesc',\n" \
  "...            'chees', 'cheesee', 'cseese', 'chetese'])\n" \
  "'chees'\n" \
  "\n" \
  "You haven't asked me about Limburger, sir.\n"

#define seqratio_DESC \
  "Compute similarity ratio of two sequences of strings.\n" \
  "\n" \
  "seqratio(string_sequence1, string_sequence2)\n" \
  "\n" \
  "This is like ratio(), but for string sequences.  A kind of ratio()\n" \
  "is used to to measure the cost of item change operation for the\n" \
  "strings.\n" \
  "\n" \
  "Examples:\n" \
  ">>> seqratio(['newspaper', 'litter bin', 'tinny', 'antelope'],\n" \
  "...          ['caribou', 'sausage', 'gorn', 'woody'])\n" \
  "0.21517857142857144\n"

#define setratio_DESC \
  "Compute similarity ratio of two strings sets (passed as sequences).\n" \
  "\n" \
  "setratio(string_sequence1, string_sequence2)\n" \
  "\n" \
  "The best match between any strings in the first set and the second\n" \
  "set (passed as sequences) is attempted.  I.e., the order doesn't\n" \
  "matter here.\n" \
  "\n" \
  "Examples:\n" \
  ">>> setratio(['newspaper', 'litter bin', 'tinny', 'antelope'],\n" \
  "...          ['caribou', 'sausage', 'gorn', 'woody'])\n" \
  "0.28184523809523809\n" \
  "\n" \
  "No, even reordering doesn't help the tinny words to match the\n" \
  "woody ones.\n"

#define editops_DESC \
  "Find sequence of edit operations transforming one string to another.\n" \
  "\n" \
  "editops(source_string, destination_string)\n" \
  "editops(edit_operations, source_length, destination_length)\n" \
  "\n" \
  "The result is a list of triples (operation, spos, dpos), where\n" \
  "operation is one of `equal', `replace', `insert', or `delete';  spos\n" \
  "and dpos are position of characters in the first (source) and the\n" \
  "second (destination) strings.  These are operations on signle\n" \
  "characters.  In fact the returned list doesn't contain the `equal',\n" \
  "but all the related functions accept both lists with and without\n" \
  "`equal's.\n" \
  "\n" \
  "Examples:\n" \
  ">>> editops('spam', 'park')\n" \
  "[('delete', 0, 0), ('insert', 3, 2), ('replace', 3, 3)]\n" \
  "\n" \
  "The alternate form editops(opcodes, source_string, destination_string)\n" \
  "can be used for conversion from opcodes (5-tuples) to editops (you can\n" \
  "pass strings or their lengths, it doesn't matter).\n"

#define opcodes_DESC \
  "Find sequence of edit operations transforming one string to another.\n" \
  "\n" \
  "opcodes(source_string, destination_string)\n" \
  "opcodes(edit_operations, source_length, destination_length)\n" \
  "\n" \
  "The result is a list of 5-tuples with the same meaning as in\n" \
  "SequenceMatcher's get_opcodes() output.  But since the algorithms\n" \
  "differ, the actual sequences from Levenshtein and SequenceMatcher\n" \
  "may differ too.\n" \
  "\n" \
  "Examples:\n" \
  ">>> for x in opcodes('spam', 'park'):\n" \
  "...     print x\n" \
  "...\n" \
  "('delete', 0, 1, 0, 0)\n" \
  "('equal', 1, 3, 0, 2)\n" \
  "('insert', 3, 3, 2, 3)\n" \
  "('replace', 3, 4, 3, 4)\n" \
  "\n" \
  "The alternate form opcodes(editops, source_string, destination_string)\n" \
  "can be used for conversion from editops (triples) to opcodes (you can\n" \
  "pass strings or their lengths, it doesn't matter).\n"

#define inverse_DESC \
  "Invert the sense of an edit operation sequence.\n" \
  "\n" \
  "inverse(edit_operations)\n" \
  "\n" \
  "In other words, it returns a list of edit operations transforming the\n" \
  "second (destination) string to the first (source).  It can be used\n" \
  "with both editops and opcodes.\n" \
  "\n" \
  "Examples:\n" \
  ">>> inverse(editops('spam', 'park'))\n" \
  "[('insert', 0, 0), ('delete', 2, 3), ('replace', 3, 3)]\n" \
  ">>> editops('park', 'spam')\n" \
  "[('insert', 0, 0), ('delete', 2, 3), ('replace', 3, 3)]\n"

#define apply_edit_DESC \
  "Apply a sequence of edit operations to a string.\n" \
  "\n" \
  "apply_edit(edit_operations, source_string, destination_string)\n" \
  "\n" \
  "In the case of editops, the sequence can be arbitrary ordered subset\n" \
  "of the edit sequence transforming source_string to destination_string.\n" \
  "\n" \
  "Examples:\n" \
  ">>> e = editops('man', 'scotsman')\n" \
  ">>> apply_edit(e, 'man', 'scotsman')\n" \
  "'scotsman'\n" \
  ">>> apply_edit(e[:3], 'man', 'scotsman')\n" \
  "'scoman'\n" \
  "\n" \
  "The other form of edit operations, opcodes, is not very suitable for\n" \
  "such a tricks, because it has to always span over complete strings,\n" \
  "subsets can be created by carefully replacing blocks with `equal'\n" \
  "blocks, or by enlarging `equal' block at the expense of other blocks\n" \
  "and adjusting the other blocks accordingly.\n" \
  "\n" \
  "Examples:\n" \
  ">>> a, b = 'spam and eggs', 'foo and bar'\n" \
  ">>> e = opcodes(a, b)\n" \
  ">>> apply_edit(inverse(e), b, a)\n" \
  "'spam and eggs'\n" \
  ">>> e[4] = ('equal', 10, 13, 8, 11)\n" \
  ">>> apply_edit(e, a, b)\n" \
  "'foo and ggs'\n"

#define matching_blocks_DESC \
  "Find identical blocks in two strings.\n" \
  "\n" \
  "matching_blocks(edit_operations, source_length, destination_length)\n" \
  "\n" \
  "The result is a list of triples with the same meaning as in\n" \
  "SequenceMatcher's get_matching_blocks() output.  It can be used with\n" \
  "both editops and opcodes.  The second and third arguments don't\n" \
  "have to be actually strings, their lengths are enough.\n" \
  "\n" \
  "Examples:\n" \
  ">>> a, b = 'spam', 'park'\n" \
  ">>> matching_blocks(editops(a, b), a, b)\n" \
  "[(1, 0, 2), (4, 4, 0)]\n" \
  ">>> matching_blocks(editops(a, b), len(a), len(b))\n" \
  "[(1, 0, 2), (4, 4, 0)]\n" \
  "\n" \
  "The last zero-length block is not an error, but it's there for\n" \
  "compatibility with difflib which always emits it.\n" \
  "\n" \
  "One can join the matching blocks to get two identical strings:\n" \
  ">>> a, b = 'dog kennels', 'mattresses'\n" \
  ">>> mb = matching_blocks(editops(a,b), a, b)\n" \
  ">>> ''.join([a[x[0]:x[0]+x[2]] for x in mb])\n" \
  "'ees'\n" \
  ">>> ''.join([b[x[1]:x[1]+x[2]] for x in mb])\n" \
  "'ees'\n"

#define subtract_edit_DESC \
  "Subtract an edit subsequence from a sequence.\n" \
  "\n" \
  "subtract_edit(edit_operations, subsequence)\n" \
  "\n" \
  "The result is equivalent to\n" \
  "editops(apply_edit(subsequence, s1, s2), s2), except that is\n" \
  "constructed directly from the edit operations.  That is, if you apply\n" \
  "it to the result of subsequence application, you get the same final\n" \
  "string as from application complete edit_operations.  It may be not\n" \
  "identical, though (in amibuous cases, like insertion of a character\n" \
  "next to the same character).\n" \
  "\n" \
  "The subtracted subsequence must be an ordered subset of\n" \
  "edit_operations.\n" \
  "\n" \
  "Note this function does not accept difflib-style opcodes as no one in\n" \
  "his right mind wants to create subsequences from them.\n" \
  "\n" \
  "Examples:\n" \
  ">>> e = editops('man', 'scotsman')\n" \
  ">>> e1 = e[:3]\n" \
  ">>> bastard = apply_edit(e1, 'man', 'scotsman')\n" \
  ">>> bastard\n" \
  "'scoman'\n" \
  ">>> apply_edit(subtract_edit(e, e1), bastard, 'scotsman')\n" \
  "'scotsman'\n" \

#endif
