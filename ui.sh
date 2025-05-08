#!/bin/bash

echo -en "\e[2J"
echo -e "                         ______________   "
echo -e "          delay         |     pulse    |  "
echo -e "          width         |     width    |  "
echo -e "      \e[48;5;233m  12345678  \e[m ns   | \e[48;5;233m  09876543  \e[m |ns  "
echo -e "________________________|              |__"
echo    "                                          "
echo -e "  tab=field space=redraw enter=trigger    "
echo -en "\e[1;1H"
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
