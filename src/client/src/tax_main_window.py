# coding:utf-8

from PyQt4 import QtCore
from PyQt4 import QtGui
from PyQt4.QtCore import *
from PyQt4.QtGui import *

import os
import sys
import CommonTools
import form_Tax_MainWindow


SORT_GENRE = [{u'开票时间': 'order by invoice_date'},
              {u'开票金额': 'order by invoice_amount'},
              {u'客户名称': 'order by cust_name'}]

QUERY_GENRE = [{u'全部': ''},
               {u'订单编号': 'and document_nr = %s'},
               {u'发票编号': 'and invoice_number = %s'},
               {u'客户名称': 'and cust_name = %s'},
               {u'客户税号': 'and cust_tax_code = %s'}]

INVOICE_GENRE = [{u'全部': ''},
                 {u'普通发票': 'and invoice_type = 1'},
                 {u'专用发票': 'and invoice_type = 0'}]


class Tax_ControlWindow(QtGui.QFrame, form_Tax_MainWindow.Ui_Tax_Main):
	def __init__(self):
		QtGui.QFrame.__init__(self)
		self.setupUi(self)
		self.widgetInit()

		# self.tab_orderQuery.setLayout(self.layout_forTableWidget)
		# self.connect(self, SIGNAL('mouseReleaseEvent(QMouseEvent *)'), se lf.startDateClick)

	def startCalendarInit(self):
		self.cldw_orderStartDate = QCalendarWidget(self)
		self.cldw_orderStartDate.setParent(self)
		self.cldw_orderStartDate.setGeometry(170, 63, 248, 169)
		self.cldw_orderStartDate.hide()

	def endCalendarInit(self):
		self.cldw_orderEndDate = QCalendarWidget(self)
		self.cldw_orderEndDate.setParent(self)
		self.cldw_orderEndDate.setGeometry(300, 63, 248, 169)
		self.cldw_orderEndDate.hide()

	def tabChanged(self):
		self.cldw_orderStartDate.setHidden(True)
		self.cldw_orderEndDate.setHidden(True)

	def widgetInit(self):
		self.connect(self.tabWidget_MainUI, SIGNAL('currentChanged(int)'), self.tabChanged)

		# tabWidget_MainUI init
		self.lbl_serOnLineLable.hide()

		# tab_orderQuery init
		self.startCalendarInit()
		self.endCalendarInit()

		CommonTools.QtMethod.initComBoBoxWithList(self.cmb_invoiceGenre, INVOICE_GENRE)
		CommonTools.QtMethod.initComBoBoxWithList(self.cmb_sortGenre, SORT_GENRE)
		CommonTools.QtMethod.initComBoBoxWithList(self.cmb_queryGenre, QUERY_GENRE)

		self.led_orderStartDate.installEventFilter(self)
		self.led_orderEndDate.installEventFilter(self)
		self.led_orderStartDate.setReadOnly(True)
		self.led_orderEndDate.setReadOnly(True)

		# 取消cldw
		self.installEventFilter(self)
		self.led_orderIdentifier.installEventFilter(self)
		self.cmb_invoiceGenre.installEventFilter(self)
		self.cmb_queryGenre.installEventFilter(self)
		self.cmb_sortGenre.installEventFilter(self)
		self.chk_blankOut.installEventFilter(self)
		self.chk_makeInvoiceFail.installEventFilter(self)
		self.chk_redRush.installEventFilter(self)

		# tab_orderImport init

	def hideCalendar(self):
		self.cldw_orderEndDate.hide()
		self.cldw_orderStartDate.hide()


	def ctrlCalendar(self, cldw):
		if cldw == self.cldw_orderStartDate:
			self.cldw_orderEndDate.hide()
			if self.cldw_orderStartDate.isHidden():
				self.cldw_orderStartDate.show()
			else:
				self.cldw_orderStartDate.hide()
		else:
			self.cldw_orderStartDate.hide()
			if self.cldw_orderEndDate.isHidden():
				self.cldw_orderEndDate.show()
			else:
				self.cldw_orderEndDate.hide()

	def mouseReleaseEvent(self, event):
		pass

	def eventFilter(self, obj, event):
		if obj == self.led_orderStartDate and event.type() == QEvent.MouseButtonRelease:
			self.ctrlCalendar(self.cldw_orderStartDate)
		elif obj == self.led_orderEndDate and event.type() == QEvent.MouseButtonRelease:
			self.ctrlCalendar(self.cldw_orderEndDate)
		elif event.type() == QEvent.MouseButtonRelease:
			if not self.cldw_orderStartDate.isHidden() and 169 < event.x() < (170 + 248) and 62 < event.y() < (63 + 169):
				return False
			elif not self.cldw_orderEndDate.isHidden() and 299 < event.x() < (300 + 248) and 62 < event.y() < (63 + 169):
				return False

			self.hideCalendar()

		return False

if __name__ == '__main__':
	app = QApplication(sys.argv)
	win = Tax_ControlWindow()
	win.show()
	app.exec_()



























