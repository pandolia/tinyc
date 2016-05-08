import os, sys

comment_mark = ";%"
code = []
stack = []
var_table = {}
label_table = {}
func_table = {}
eip = 0
printout = []
debug = False

def is_valid_identifier(ident):
	if ident == "":
		return False
	if not (ident[0].isalpha() or ident[0] == '_'):
		return False
	for ch in ident[1:]:
		if not (ch.isalnum() or ch == '_'):
			return False
	return True

def assemb_error(line, msg):
	display(pause=False)
	print line
	print "^^^Error at last line: %s" % msg
	exit(-1)

def run_error(msg="Wrong instruction format"):
	code[eip][0] = "**%s**" % msg
	printout.append(msg)
	display(pause=False)
	exit(-1)

def assemb(asmfilename):
	if len(sys.argv) > 2 and (sys.argv[2] == '-a' or sys.argv[2] == '-da'):
		code.append(('', '$main', ''))
		code.append(('', 'exit', '~'))

	label = ""
	for line in file(asmfilename):
		line = line.strip()
		if line == "" or line[0] in comment_mark:
			continue

		_label, sep, ist = line.partition(':')
		if sep and _label.find('"') == -1 and _label.find("'") == -1:
			_label, ist = _label.strip(), ist.strip()
			if not check_label(_label):
				assemb_error(line, "Wrong label")
			label = '%s,%s' % (label, _label) if label else _label
			if ist == "" or ist[0] in comment_mark:
				continue
		elif len(line) >= 7 and line[:7] == 'ENDFUNC':
			label = '%s,%s' % (label, 'ENDFUNC') \
											if label else 'ENDFUNC'
			ist = 'ret'
		else:
			ist = line

		dire, sep, arg = ist.partition(' ')

		if len(dire) > 4 and \
			(dire[-4:] == '.arg' or dire[-4:] == '.var'):
			dire = dire[-3:]

		code.append( [label, dire, arg.strip()] )
		label = ""

	code.append(('', 'exit', '0'))

def check_label(label):
	if label == "":
		return False

	func, sep, funcName = label.partition(' @')

	if sep:
		if func.strip() != 'FUNC' \
			or not is_valid_identifier(funcName) \
			or func_table.has_key(funcName):
			return False
		else:
			func_table[funcName] = len(code)
			return True
	else:
		if not is_valid_identifier(label) \
			or func_table.has_key(label) \
			or label_table.has_key(label):
			return False
		else:
			label_table[label] = len(code)
			return True
		
def trim(s, size):
	return	s[:size-3]+"..." if len(s) > size else s

def display(pause=True):
	num_code_lines, num_terminal_lines = 24, 8
	if os.system("clear"): os.system('cls')
	print "%32s%-40s|  %-13s|Bind var" % ("", "Code", "Stack")
	j = 0
	for i in range( \
		max(eip+1-num_code_lines, 0), max(eip+1, num_code_lines) ):
		if i < len(code):
			label, dire, arg = code[i]
			line = trim(dire + " " + arg, 40)
			label = trim(label, 28)
		else:
			label, line = "", ""

		if label: label += ':'
		point = " ->" if i == eip else ""
		st = stack[j] if j < len(stack) else ""
		st = "(RetInfo)" if type(st) is tuple else str(st)
		stvar = var_table.get(j, "")
		if j == len(stack) - 1: stvar += "<-"
		
		print "%29s%3s%-40s|  %-13s|%s" % \
			(label, point, line, st, stvar)

		j += 1

	print "***Terminal***"
	n = len(printout)
	for i in range( \
		max(n-num_terminal_lines, 0), max(n, num_terminal_lines) ):
		print printout[i] if i < n else ""
		if i == n and not pause:
			break

	if pause:
		global debug
		if raw_input("\npress enter to step, -r to run.") == "-r":
			debug = False

def run():
	global eip
	eip = 0
	del stack[:]

	while True:
		if debug: display()
		label, dire, arg = code[eip]
		if dire[0] == '$':
			action, arg = call, dire[1:]			
			if not is_valid_identifier(arg):
				run_error("Wrong identifier")
		else:
			if not is_valid_identifier(dire):
				run_error("Wrong identifier")
			try:
				action = eval("do_" + dire)
			except NameError:
				run_error("Unknown instruction")
		action(arg)
		eip += 1

def do_var(arg):
	if arg == "": return
	for var in arg.split(','):
		var = var.strip()
		if not is_valid_identifier(var) or var_table.has_key(var):
			run_error("Wrong var name")
		var_table[var] = len(stack)
		var_table[len(stack)] = var
		stack.append("/")

def do_push(arg):
	try:
		arg = int(arg)
	except ValueError:
		try:
			arg = stack[var_table[arg]]
		except KeyError:
			run_error("Undefined variable")
		if type(arg) is not int:
			run_error("Cannot push uninitialed value")
	stack.append(arg)

def do_pop(arg):
	value = stack.pop()
	if arg == "":
		return
	if type(value) is not int:
		run_error("Cannot pop non-number value to variable")
	try:
		stack[var_table[arg]] = value
	except KeyError:
		run_error("Undefined variable")

def do_exit(arg):
	global going, exit_code
	going = False

	if arg == "~":
		exit_code = stack[-1]
	elif arg:
		try:
			exit_code = int(arg)
		except ValueError:
			try:
				exit_code = stack[var_table[arg]]
			except KeyError:
				run_error("Undefined variable")

	if type(exit_code) is not int:
		run_error("Wrong exit code")

	if debug:
		display(pause=False)

	exit(exit_code)



def do_add(arg):   stack[-2] += stack[-1]; stack.pop()
def do_sub(arg):   stack[-2] -= stack[-1]; stack.pop()
def do_mul(arg):   stack[-2] *= stack[-1]; stack.pop()
def do_div(arg):   stack[-2] /= stack[-1]; stack.pop()
def do_mod(arg):   stack[-2] %= stack[-1]; stack.pop()
def do_and(arg):   stack[-2] = int(stack[-2]!=0 and stack[-1]!=0); stack.pop()
def do_or(arg):    stack[-2] = int(stack[-2]!=0 or  stack[-1]!=0); stack.pop()
def do_cmpeq(arg): stack[-2] = int(stack[-2]==stack[-1]);stack.pop()
def do_cmpne(arg): stack[-2] = int(stack[-2]!=stack[-1]);stack.pop()
def do_cmpgt(arg): stack[-2] = int(stack[-2]>stack[-1]); stack.pop()
def do_cmplt(arg): stack[-2] = int(stack[-2]<stack[-1]); stack.pop()
def do_cmpge(arg): stack[-2] = int(stack[-2]>=stack[-1]);stack.pop()
def do_cmple(arg): stack[-2] = int(stack[-2]<=stack[-1]);stack.pop()
def do_neg(arg):   stack[-1] = -stack[-1]
def do_not(arg):   stack[-1] = int(not stack[-1])

def do_print(fmt):
	if len(fmt) < 2 or fmt[0] != fmt[-1] or fmt[0] not in '"\'':
		run_error("Format string error")
	argc = fmt.count("%d")
	out = fmt[1:-1] % tuple(stack[len(stack)-argc:])
	print out
	printout.append(out)
	del stack[len(stack)-argc:]

def do_readint(msg):
	if len(msg) < 2 or msg[0] != msg[-1] or msg[-1] not in '"\'':
		run_error("Message string error")
	msg = msg.strip('"').strip("'")
	if debug: display(pause=False)
	string = raw_input(msg)
	try:
		value = int(string)
	except ValueError:
		value = 0
	stack.append(value)
	printout.append("\n  " + msg + str(value))

def do_jmp(label):
	global eip
	try:
		# note: here we set eip just befor the label,
		#       and when back to run(), we do eip += 1
		eip = label_table[label] - 1
	except KeyError:
		run_error("Wrong label")

def do_jz(label):
	global eip
	try:
		# set eip just befor the label,
		# when back to run(), do eip += 1
		new_eip = label_table[label] - 1
	except KeyError:
		run_error("Wrong label")
	if stack.pop() == 0:
		eip = new_eip

def call(funcName):
	global var_table, eip

	try:
		entry = func_table[funcName]
	except KeyError:
		run_error("Undefined function")

	if code[entry][1] == "arg":
		arg_list = code[entry][2].split(',')
	else:
		arg_list = []

	new_var_table = {}
	for addr, arg  in enumerate(arg_list, len(stack)-len(arg_list)):		
		arg = arg.strip()
		if not is_valid_identifier(arg) or new_var_table.has_key(arg):
			run_error("Wrong arg name")

		new_var_table[arg] = addr
		new_var_table[addr] = arg

	stack.append( (len(arg_list), eip, var_table) )
	var_table = new_var_table
	eip = entry if len(arg_list) else entry -1

def do_ret(arg):
	global var_table, eip

	if arg == "~":
		retval = stack[-1]
	elif arg:
		try:
			retval = int(arg)
		except ValueError:
			try:
				retval = stack[var_table[arg]]
			except KeyError:
				run_error("Undefined variable")
	else:
		retval = '/'

	i = len(stack) - 1
	while type(stack[i]) is not tuple:
		i -= 1
	argc, eip, var_table = stack[i]
	del stack[i-argc:]
	stack.append(retval)

if __name__ == "__main__":
	asmfileName = sys.argv[1]
	if len(sys.argv) > 2:
		debug = sys.argv[2] == '-d' or sys.argv[2] == '-da'
	assemb(asmfileName)
	run()