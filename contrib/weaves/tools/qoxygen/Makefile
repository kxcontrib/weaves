all: 
	@${LEX} -oqoxygen.c qoxygen.l
	@${CC} -o qoxygen qoxygen.c -lfl
	@rm qoxygen.c
	@echo "You should now ensure qoxygen is in your PATH"

clean:
	@rm -fr qoxygen 
