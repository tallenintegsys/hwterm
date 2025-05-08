#!/usr/bin/python3
import sys
import os

# yosys only knows verilog, verilog is limited in how one may populate
# a BRAM. This bit of Python nonsense converts a text file to a bunch
# verilog 

class verilog:
    arrayName:str = ''                     # varilog array we are populating
    i = 0                                  # the element in the array

    def __init__(self, arrayName: str):
        self.arrayName = arrayName

    def p(self, char):
        print(f"{self.arrayName}[{self.i}] = \"{char}\";")
        self.i += 1


def main() -> int:
    if (len(sys.argv) != 3):
        print(f"usage: {sys.argv[0]} arrayname filename: Opens a file name and writes verilog statements to stdout")
        print("the varilog statements are suitable to populate a verilog array named arrayname, in an initial block.")
        exit(1)
    v = verilog(sys.argv[1])
    f = open(sys.argv[2])
    esc = False
    while 1:
        # read by character
        char = f.read(1)
        if esc:
            if char == "e":
                v.p("\\033") # esc
                esc = False
                continue
            if char == "f":
                v.p("\\014") # FF = EOF
                esc = False
                break
        if char == "\\":
            esc = True
            continue
        if char == "\n":
            v.p("\\015")
            v.p("\\012")
            continue
        if not char:
            break

        v.p(char)
    f.close()
    return 0

if __name__ == '__main__':
    sys.exit(main())  # next section explains the use of sys.exit
