#!/bin/bash
IN=$1
awk 'BEGIN { FIRST=1 ; line=0 ; WATCH=0; THRESHOLD=1}
{
INP=$1
if (FIRST == 1) {
   FIRST=0
   PREV=INP
}
else {
   line+=1
   if ( INP != PREV ) {
     if ( WATCH == THRESHOLD ) { 
	print "GLITCH " line
        WATCH=0
     }
     else {
        WATCH=1
     }
   }
   else {
	WATCH=0
   }
   PREV=INP
}
}' ${IN}
