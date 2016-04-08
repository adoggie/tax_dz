#!/usr/bin/env python
#coding=utf-8

import os



path = os.getcwd()
filelist = os.listdir(path)

for file in filelist:
	if file[-3:] == '.ui':
		name,ext = os.path.splitext(file)
		os.system(r'C:\Python26\Lib\site-packages\PyQt4\pyuic4.bat %s > %s.py' %(file,name))


main_pause = raw_input('successfully,press enter for exit'.encode('gbk'))