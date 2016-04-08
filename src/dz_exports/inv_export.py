# -*- coding: utf-8 -*-

#playctrl.py
#播放控制

from PyQt4 import QtCore
from PyQt4 import QtGui

from PyQt4.QtCore import *
from PyQt4.QtGui import *

import sys,threading,os,os.path

from form_invoice_export import *
import taxctrl

class InvoiceExportApp(QApplication):
	def __init__(self, argv):
		QApplication.__init__(self,argv)
		rc,msg = taxctrl.init_plugin()
		if not rc:
			QMessageBox.about(None,u'错误提示',msg)
			self.closeAllWindows()
			sys.exit()
			
		if not os.path.exists('c:/windows/tax.dat'):
			QMessageBox.about(None,u'错误提示','code:9500')
			self.closeAllWindows()
			sys.exit()
			
		self.main()
		# form_usermgr.UserMgr.instance()

	def main(self):
		self.mainwnd = MainWindow(self)


	def quit(self):

		QtGui.qApp.quit()


app = InvoiceExportApp(sys.argv)

app.exec_()

taxctrl.tax_clear()

