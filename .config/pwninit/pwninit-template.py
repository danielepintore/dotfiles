#!/usr/bin/env python3

from pwn import *

{bindings}

context.binary = {bin_name}
# context.terminal = ['tmux', 'splitw', '-h']

def conn():
    if args.LOCAL:
        r = process({proc_args})
    elif args.GDB:
        r = gdb.debug({proc_args}, """
	""")
    else:
        r = remote("addr", 1337)

    return r


def main():
    r = conn()

    # good luck pwning :)

    r.interactive()


if __name__ == "__main__":
    main()
