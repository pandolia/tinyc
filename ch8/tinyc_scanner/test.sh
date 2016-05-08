for src in $(ls samples/*.c); do ./scanner < $src > $src.lex; done
