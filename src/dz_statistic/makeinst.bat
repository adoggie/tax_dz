python setup_exp.py py2exe -i sip -d release
copy *.txt release
copy *.dll release
copy *.jpg release
copy *.dat release
copy *.conf release
copy *.lic release
ren release\main.exe release\大众增值税开票统计.exe
pause
