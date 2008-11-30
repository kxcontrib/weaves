#! /usr/bin/bash

regexpr "l" "abcdefghijkkl"

regexpr "(l)" "abcdefghijkkl"


regexpr "a(b)" "abc"

cat <<EOF
      -->  ok(2).
           reg(0, 2, "ab").
           reg(1, 2, "b").

EOF

regexpr "([^ .]*)\.c" " this is file.c"
cat <<EOF
      -->  ok(2).
           reg(9, 15, "file.c").
           reg(9, 13, "file").
EOF

regexpr "([[:alpha:]]*)[[:space:]]*([[:alpha:]]*)" "Andrew Davison" 
cat <<EOF
      -->  ok(3).
           reg(0, 14, "Andrew Davison").
           reg(0, 6, "Andrew").
           reg(7, 14, "Davison").
EOF
