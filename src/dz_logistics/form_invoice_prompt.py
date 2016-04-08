# -*- coding: utf-8 -*-
# playconsole.py
# 播放控制台

from PyQt4 import QtCore
from PyQt4 import QtGui

from PyQt4.QtCore import *
from PyQt4.QtGui import *
import ctypes
from ctypes import *

import sys,threading,time,datetime,traceback,string,json,pickle,os,os.path
import ui_invoice_prompt

import win32api


'''
	retcode:
		 0 - cancel
		 1 - invoice and print
		 2 - only invoice ,not print
'''

import win32gui, win32con

class FormPrompt(QtGui.QDialog,ui_invoice_prompt.Ui_Dialog):
	def __init__(self,parent):
		QtGui.QDialog.__init__(self,parent)
		self.setupUi(self)
		self.connect(self.btnInvoice,SIGNAL('clicked()'),self.onBtnInvoice)
		self.connect(self.btnCancel,SIGNAL('clicked()'),self.onBtnCancel)
		self.showNormal()
		self.raise_()
		#hWnd = c_ulong(self.winId())
		win32gui.SetWindowPos(self.winId(), win32con.HWND_TOPMOST, 0, 0, 0, 0,
		                      win32con.SWP_NOMOVE | win32con.SWP_NOSIZE)

	def onBtnInvoice(self):
		rc = 1
		if self.ckPrintIgnored.checkState():
			rc = 2
		self.done(rc)


	def onBtnCancel(self):
		self.done(0)

	def prompt(self,info):
		'''

		'''
		self.edtDocNr.setText(info['doc_nr'].decode('utf-8'))
		self.edtTaxCode.setText(info['taxcode'])
		self.edtTaxNumber.setText(info['taxnumber'])
		self.edtCustName.setText(info['custname'].decode('utf-8'))
		self.edtDocAmount.setText(str(info['amount']))
		return self.exec_()
