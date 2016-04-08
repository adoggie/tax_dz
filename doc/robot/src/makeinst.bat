del /q /f release_exp\*.exe
del /q /f release_imp\*.exe
python setup_exp.py py2exe -i sip -d release_exp
python setup_imp.py py2exe -i sip -d release_imp
copy *.txt release_exp
copy *.dll release_exp
copy *.jpg release_exp
copy *.dat release_exp


copy *.txt release_imp
copy *.dll release_imp
copy *.jpg release_imp
copy *.dat release_imp

ren release_exp\inv_export.exe 发票导出.exe
ren release_imp\inv_import.exe 发票认证.exe
pause
