BUILT_SOURCES = t1tot2.csv

t1tot2.csv:
	$(MAKE) MAKEFLAGS=$(MAKEFLAGS) check

#  if you write a self-test script named `chk', uncomment the
#  following and add `chk' to the EXTRA_DIST list

TESTS = names.sh
TESTS_ENVIRONMENT = $(SHELL) -x 

EXTRA_DIST = t1.csv t2.csv names0.q names1.q $(BUILT_SOURCES) $(TESTS)



