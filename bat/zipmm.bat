; create archive of mind map files for storage in evernote
; use -o to update zip file with date of newest map file
; use -f to freshen the zip file with any changed files that are in
; the list file 'ziplist.txt'
cd c:\Users\mwroberts\Desktop\FreeMind
c:\"program files"\Winzip\wzzip -o -f MindMap @ziplist.txt
