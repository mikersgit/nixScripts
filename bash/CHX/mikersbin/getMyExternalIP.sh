#!/bin/bash
IPproviders=(https://ipinfo.io/ip ifconfig.me http://ipecho.net/plain icanhazip.com)
for P in ${IPproviders[*]}
{
	echo "Provider: $P"
	mIP=$(curl -s ${P})
	if [[ ${#mIP} -gt 7 ]] && [[ ${#mIP} -lt 16 ]]
	then
		echo $mIP
		exit 0
	fi
}
echo "Trying dig of google"
myIP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com)
echo $mIP
# the URLs below have become obfuscated and hard to parse
#URL='https://duckduckgo.com/?q=what+is+my+ip&atb=v418-1&ia=answer'
#URL='https://www.google.com/search?q=what+is+my+ip'
#match="Client IP address"
#curl ${URL} 2>/dev/null |
     #awk '{mtch="Your IP address is "
          #lm=length(mtch)
          #i=index($0,mtch)
             #if (i>0)
             #{
                #p=substr($0,(i+lm))
                #j=(index(p,")"))
                #l=length(p)
                #m=(match(p,/[:digit:]/))
	        #adr=substr(p,m,(l-(l-j)-1))
		#sub(/^ /,"",adr)
	        #print adr
	     #}
	  #}'
