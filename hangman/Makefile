HANGMAN := hangman
ASM_OBJ := hangman.o read_line.o print_word.o

.PHONY: all clean run

all: clean $(HANGMAN)

run: all
	./$(HANGMAN)

$(HANGMAN): $(ASM_OBJ)
	$(CC) -o $@ $^

clean:
	rm -f $(HANGMAN)
