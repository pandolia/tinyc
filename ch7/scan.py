# -*- coding: utf-8 -*-

single_char_operators_typeA = {
    ";", ",", "(", ")", "{", "}", "[",
    "]", "/", "+", "-", "*", "%", ".",
    ":"
}

single_char_operators_typeB = {
    "<", ">", "=", "!"
}

double_char_operators = {
    ">=", "<=", "==", "~="
}

reservedWords = {
    "class", "for", "while", "if", "else",
    "return", "break", "True", "False", "raise", "pass"
    "in", "continue", "elif", "yield", "not", "def"
}

class Token:
    def __init__(self, _type, _val = None):
        if _val is None:
            self.type = "T_" + _type;
            self.val = _type;
        else:
            self.type, self.val = _type, _val
    
    def __str__(self):
        return "%-20s%s" % (self.type, self.val)

class NoneTerminateQuoteError(Exception):
    pass

def isWhiteSpace(ch):
    return ch in " \t\r\a\n"

def isDigit(ch):
    return ch in "0123456789"

def isLetter(ch):
    return ch in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

def scan(s):
    n, i = len(s), 0
    while i < n:
        ch, i = s[i], i + 1
        
        if isWhiteSpace(ch): 
            continue
        
        if ch == "#":
            return
        
        if ch in single_char_operators_typeA:
            yield Token(ch)
        elif ch in single_char_operators_typeB:
            if i < n and s[i] == "=":
                yield Token(ch + "=")
            else:
                yield Token(ch)
        elif isLetter(ch) or ch == "_":
            begin = i - 1
            while i < n and (isLetter(s[i]) or isDigit(s[i]) or s[i] == "_"):
                i += 1
            word = s[begin:i]
            if word in reservedWords:
                yield Token(word)
            else:
                yield Token("T_identifier", word)
        elif isDigit(ch):
            begin = i - 1
            aDot = False
            while i < n:
                if s[i] == ".":
                    if aDot:
                        raise Exception("Too many dot in a number!\n\tline:"+line)
                    aDot = True
                elif not isDigit(s[i]):
                    break
                i += 1
            yield Token("T_double" if aDot else "T_integer", s[begin:i])
        elif ord(ch) == 34: # 34 means '"'
            begin = i
            while i < n and ord(s[i]) != 34:
                i += 1
            if i == n:
                raise Exception("Non-terminated string quote!\n\tline:"+line)
            yield Token("T_string", chr(34) + s[begin:i] + chr(34))
            i += 1
        else:
            raise Exception("Unknown symbol!\n\tline:"+line+"\n\tchar:"+ch)
            
            
                    
if __name__ == "__main__":
    print "%-20s%s" % ("TOKEN TYPE", "TOKEN VALUE")
    print "-" * 50
    for line in file("scan.py"):
        for token in scan(line):
            print token