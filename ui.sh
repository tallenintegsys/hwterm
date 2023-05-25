#!/bin/bash

echo -e "                         ____________   "
echo -e "                        |   pulse    |  "
echo -e "   delay  width         |   width    |  "
echo -e " \e[100m                 \e[m ns   | \e[100m        \e[m ns|  "
echo -e "________________________|            |__"
echo
echo -e " tab=field space=redraw enter=trigger   "
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
