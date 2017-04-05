find . \( ! -path \*tests/\* -a ! -path \*.svn\* -a ! -path \*test/\* \) \( -name \*.[ch] -o -name \*.cpp -o -name \*.java -o -name \*.py -o -name \*.js \) > cscope.files

