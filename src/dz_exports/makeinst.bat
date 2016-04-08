del /q /f release_exp\*.exe
del /q /f release_imp\*.exe
python setup_exp.py py2exe -i sip -d release_exp
rem python setup_imp.py py2exe -i sip -d release_imp
copy *.txt release_exp
copy *.dll release_exp
copy *.jpg release_exp
copy *.dat release_exp


copy *.txt release_imp
copy *.dll release_imp
copy *.jpg release_imp
copy *.dat release_imp

rem ren release_exp\inv_export.exe ��Ʊ����.exe
rem ren release_imp\inv_import.exe ��Ʊ��֤.exe
pause
