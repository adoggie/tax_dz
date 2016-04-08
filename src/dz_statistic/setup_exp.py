# -*- coding:utf-8 -*-
from distutils.core import setup
import py2exe


excludes = ["Secur32.dll", "SHFOLDER.dll"]
setup(windows=[{"script":"main.py",
          "icon_resources":[(1, "app_tax.ico")]},],
#	options={
#		"py2exe":{
#			"includes":["sip","PyQt4._qt"],
#			"compressed": 1,
#			"optimize": 2,
#			"ascii": 1,
#			"bundle_files": 1,
#			"dll_excludes": excludes
#		}
#	}
)


#setup(name='Game EndPointService',
#			version='1.0',
#			description='Game Distribution Por',
#			author='scott',
#			author_email='zhangbin@5173.com',
#			url='',
#			#packages=['distutils', 'distutils.command'],
#			py_modules=['endpoint']
#			
#			)
