HANGMAN := hangman

.PHONY: all clean run

all: clean $(HANGMAN)

run: all
	./$(HANGMAN)

$(HANGMAN): $(HANGMAN).s
	gcc -o $@ $<

clean:
	rm -f $(HANGMAN)
