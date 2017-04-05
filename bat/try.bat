echo halo >> rel
echo maint >> rel
set src=c:\Users\mwroberts\Desktop\bugs
for /F %%i in (rel) do (
  for /F %%k in (%src%) do echo %%i and %%k
)
pause
