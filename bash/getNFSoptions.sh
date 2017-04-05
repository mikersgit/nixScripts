#!/bin/bash
HERE=${PWD}
HOME_DIR='/home/mwroberts/gwksp'
FUNC_DIR=${HOME_DIR}'/pml-hpsmb/test/nfs'
UNIT_DIR=${HOME_DIR}'/pml-hpsmb/nfs/impl/src/test/java/com/hp/storage/pml/file/nfs/impl/model/nfs'

function getFuncTests() {
cd  ${FUNC_DIR}
echo ',,NFS FUNCTIONAL TESTS'
for t in *py
 {
echo -e "${t}"
awk '$1 ~ /^EXPORT_OPTIONS/ {gsub("\"","");printf(",\t\t%s\n",$0)}' $t
awk '$1 ~ /^CLIENT_IP/ {gsub("\"","");printf(",\t\t%s\n",$0)}' $t
#for g in $(grep "^EXPORT_OPTIONS =" $t)
#{
	#echo -e ',\t\t'\"${g}\"
#}
awk '$1 ~ /^[MODIFY|VERIFY].*EXPORT_OPTIONS/ {gsub("\"","");printf(",\t\t%s\n",$0)}' $t
#for g in $(grep "^[MODIFY|VERIFY].*EXPORT_OPTIONS =" ${t})
#{
#echo -e ",\t\t${g}"
#}
}
} # end getFuncTests()

function getUnitTests() {
cd ${UNIT_DIR}
echo ',,NFS UNIT TESTS'
for j in *.java
 {
	echo -e "=====\n$j\n========"
	awk 'BEGIN {OL=0;AL=0}
		{if ($1 ~ /optionList.add/){
			sub("optionList.add","")
			gsub(/[\050|\051|\042|\073]/,"")
		if (!OL){
			printf("\n,Options,%s",$0)
			OL=1
		}
		else
			printf(",%s",$0)
		}
		if ($1 ~ /verifyList.add/){
			OL=0
			sub("verifyList.add","")
			gsub(/[\050|\051|\042|\073]/,"")
		if (!VL){
			printf("\n,Verify,%s",$0)
			VL=1
		}
		else
			printf(",%s",$0)
		}
		if ($0 ~ /public void/) {
			if ($0 !~ /initialize/) {
			VL=0
			sub("public void","")
			gsub(/[\050|\051|\173]/,"")
			printf("\n%s\n",$0)
			}
		}
	}' $j
 }
} # end getUnitTests()

getFuncTests
getUnitTests
cd ${HERE}
