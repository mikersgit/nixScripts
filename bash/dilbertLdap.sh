#!/bin/bash

: VALUE=${1}
: ${VALUE:="whitman"}
curl --insecure \
https://g4t0029.houston.hp.com/dilbert/dilbert.cgi?column2=mail&search_choice=Common%20Name&column5=uid&column4=employeenumber&scope=sub&base=o%3Dhp.com&column3=telephonenumber&advanced_search=off&search_value=${VALUE}&ads_search=off&port=636&host=ldap.hp.com&column0=cn&column1=l
