#!/bin/bash

curl https://www.google.com/search?q=what+is+my+ip 2>/dev/null |
     awk '{mtch="Client IP address:"
          lm=length(mtch)
          i=index($0,mtch)
             if (i>0)
             {
                p=substr($0,(i+lm))
                j=(index(p,")"))
                l=length(p)
                m=(match(p,/[:digit:]/))
	        adr=substr(p,m,(l-(l-j)-1))
		sub(/^ /,"",adr)
	        print adr
	     }
	  }'
