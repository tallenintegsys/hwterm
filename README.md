# hwterm
Hardware based (no CPU) terminal UI
### Purpose
A basic text based UI with fields, ANSI escape sequences. I am working towards adding a text UI to some of my tools thus making them stand-alone (no software on the workstation). Once I get there I want to add USB/UART to my gateware.
### Diagram
For now, a later goal is to integrate the USB/UART into the FPGA based tool.
```
                                                                      _____________________
    ___________________                  _______________             |                     |
 __|                   |                |      FPGA     |____________|                     |
|      USB/UART        |________________|   based tool  |____________|       thing         |
|__     dongle         |                |_______________|            |                     |
   |___________________|                                             |_____________________|

```
### Example UI
need to add a picture
