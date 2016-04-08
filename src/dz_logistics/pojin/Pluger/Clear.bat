call	:ClearTmpFile Src\
call	:ClearTmpFile Src\Caller\
call	:ClearTmpFile Src\Pluger\
call	:ClearTmpFile Src\PlugerInterface\
call	:ClearTmpFile Src\Public\

: ClearTmpFile
del     %1\*.~*
del	%1\*.dcu
