#!/bin/bash

echo -e "                         ______________   "
echo -e "                        |     pulse    |  "
echo -e "   delay  width         |     width    |  "
echo -e "      \e[48;5;233m  b16b00b5  \e[m ns   | \e[48;5;233m  b00bb00b  \e[m |ns  "
echo -e "________________________|              |__"
echo
echo -e " tab=field space=redraw enter=trigger   "
exit 0
echo -en "\e[4A\e[3G\e[100m"
read -n13 
echo -e "\e[m"
exit

echo -e "                     ________________   "
echo -e "                    |                |  "
echo -e "  delay  width      | pulse  width   |  "
echo -e "  ____________ ns   | ____________ ns|  "
echo -e "____________________|                |__"
echo
echo -e " tab=field space=redraw enter=trigger   "
