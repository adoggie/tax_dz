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
from  ui_invoice import *
import win32api,base64

from dbconn import *
from taxbase import *
import utils
import psycopg2

APP_VER='v0.2.1.0'
APP_VER='v0.2.2.0 2013/7/14'

'''
v0.1.0.0
	pay_type = models.IntegerField(default=1)    #支付方式 1 - 现金 ； 2 - 支票  ； 3 - 现金+支票 ; 4 - POS机

v0.2.0.0
	query1,query2 结算时间和开票时间 查询互换
v0.2.1.0
	导出输出金额保留float类型，以便之后计算
	
v0.2.2.0 
	1.增加以发票号排序
	2.显示作废发票金额为0 
	3.导出增加 普票、专票的汇总金额
'''


class MainWindow(QtGui.QMainWindow,Ui_MainWindow):
	def __init__(self,app):
		QtGui.QMainWindow.__init__(self)
		self.setupUi(self)
		self.app = app
		self.db = None
		self.show()

		self.init_ui()
		self.db = None

	def getDB(self):
		try:
			if not self.db:
				conf = utils.SimpleConfig().load('system.conf')
				host = conf.get('db.host')
				passwd = conf.get('db.passwd')
				dbname = conf.get('db.name')
				self.db= psycopg2.connect(host=host,database=dbname,user='postgres',password=passwd)
		except:
			traceback.print_exc()
		return self.db



	def getConfig(self):
		return utils.SimpleConfig().load('system.conf')

	def init_ui(self):
		title = self.windowTitle() + ' - '+APP_VER
		self.setWindowTitle(title)

		self.init_ui_page1()
		self.init_ui_page2()
		self.init_ui_page3()
		self.init_ui_page4()
		self.init_ui_page5()
		self.init_ui_page6()
		self.init_ui_page7()

	def init_ui_page1(self):
		curtime = QDateTime.currentDateTime ()
		t = time.localtime()
		secs = time.mktime((t.tm_year,t.tm_mon,t.tm_mday,0,0,0,0,0,0))
		curtime.setTime_t(int(secs))
		start = curtime
		self.dtStart_1.setDateTime(start)
		# end = curtime.addDays(1)
		end = start
		self.dtEnd_1.setDateTime(end)

		employees = self.getConfig().get('employees','')
		employees = employees.split(',')
		for e in employees:
			self.cbxEmployee_1.addItem(e.decode('utf-8'))
		if employees:
			self.cbxEmployee_1.setCurrentIndex(0)

		self.cbxTimeQueryType1.addItem(u'结算日期')
		self.cbxTimeQueryType1.addItem(u'开票日期')
		self.cbxTimeQueryType1.setCurrentIndex(0)
#		self.connect(self.cbxTimeQueryType1,SIGNAL('currentIndexChanged(int)'),self.onQueryTime1Change)

		self.tvList_1.setHeaderLabels([
			u'序号',
		    u'类别',
		    u'发票编号',
			u'开票日期',
			u'单    位',
			u'金额',
			u'税额',
			u'价税合计',
			u'作废标志',
			u'机器号',
			u'收款方式'
		    u'',
		])
		self.tvList_1.resizeColumnToContents(0)
		self.tvList_1.setAlternatingRowColors(True)
		self.connect(self.btnQuery_1,SIGNAL('clicked()'),self.onBtnQuery1Click)
		self.connect(self.btnExport_1,SIGNAL('clicked()'),self.onBtnExport1Click)

#	def onQueryTime1Change(self,index):
#		pass


	def getQueryDateRange(self,dtstart,dtend):
		start = dtstart.dateTime().toPyDateTime()
		start = start.replace(hour=0,minute=0,second=0)
		end = dtend.dateTime().toPyDateTime()
		end = end.replace(hour=23,minute=0,second=0)
		return start,end

	def doQuery1(self):
		employee = self.cbxEmployee_1.currentText().toUtf8().data().strip()
		# start = self.dtStart_1.dateTime().toPyDateTime()
		# end = self.dtEnd_1.dateTime().toPyDateTime()
		start,end = self.getQueryDateRange(self.dtStart_1,self.dtEnd_1)

		timefield='settlement_time'
		if self.cbxTimeQueryType1.currentIndex()!=0:
			timefield = 'inv_date'

		#sql = "select * from core_invoice where flag_zf=0 and  %s"%timefield
		sql = "select * from core_invoice where   %s"%timefield
		sql+= " between %s and %s "
		params=[start,end]
		if employee:
			sql+=" and issuer=%s "
			params.append(employee)
		sql+=" order by inv_type desc,inv_code,inv_number,%s,doc_time"%timefield
		cr = self.getDB().cursor()
		print sql
		cr.execute(sql,params)
		rs = fetchallDict(cr)
		return rs

	def onBtnQuery1Click(self):

		amount=0
		tax = 0
		amount_tax = 0

		self.tvList_1.clear()
		if self.cbxTimeQueryType1.currentIndex()==0:
			self.tvList_1.setHeaderLabels([
				u'序号',
				u'类别',
				u'发票编号',
				u'开票日期',
				u'单    位',
				u'金额',
				u'税额',
				u'价税合计',
				u'作废标志',
				u'机器号',
				u'收款方式'
				u'',
				])
		else:
			self.tvList_1.setHeaderLabels([
				u'序号',
				u'类别',
				u'发票编号',
				u'结算日期',
				u'单    位',
				u'金额',
				u'税额',
				u'价税合计',
				u'作废标志',
				u'机器号',
				u'收款方式'
				u'',
				])

		rs = self.doQuery1()
		idx = 0
		for r in rs:
			idx+=1
			invtype = u'专票'
			if r['inv_type'] ==0: #  0 - 普通 ； 1 - 专用
				invtype = u'普票'

			status = u'正常'
			if r['flag_zf']:
				status = u'已作废'
			
			

			timeval=''
			if self.cbxTimeQueryType1.currentIndex()==0:
				timeval = utils.formatDateTimeStr(r['inv_date'])
			else:
				timeval = utils.formatDateTimeStr(r['settlement_time'])
			
			row=()
			if r['flag_zf']:
				row = (str(idx),
			       invtype,
			       '%s-%s'%(r['inv_code'],r['inv_number']),
					timeval,
			        r['cust_name'].decode('utf-8'),
			        0,
			        0,
			        0,
					status,
			        str(r['client_nr']),
					TaxConsts.getPayTypeStr(r['pay_type']),
					''
				)
			else:
				amount_tax+=r['inv_amount']
				tax+=r['inv_tax']
				row = (str(idx),
					   invtype,
					   '%s-%s'%(r['inv_code'],r['inv_number']),
						timeval,
						r['cust_name'].decode('utf-8'),
						str(r['inv_amount'] - r['inv_tax']),
						r['inv_tax'],
						r['inv_amount'],
						status,
						str(r['client_nr']),
						TaxConsts.getPayTypeStr(r['pay_type']),
						''
					)
			row = map(lambda  x:unicode(x),row)
#			print row
			ti = QTreeWidgetItem(row )
			self.tvList_1.addTopLevelItem(ti)
		self.tvList_1.resizeColumnToContents(0)
#		self.tvList_1.resizeColumnToContents(1)
#		self.tvList_1.resizeColumnToContents(2)
#		self.tvList_1.resizeColumnToContents(3)
#		self.tvList_1.resizeColumnToContents(4)

		amount = amount_tax - tax

		txt =u'合计: 金额=%s 税额=%s 价税合计=%s'%(amount,tax,amount_tax)
		self.txtTotal_1.setText(txt)


	def onBtnExport1Click(self):
		import xlwt
#		from xlutils.copy import copy
#		from xlrd import open_workbook


		start = self.dtStart_1.dateTime().toPyDateTime()
		end = self.dtEnd_1.dateTime().toPyDateTime()
		start = utils.formatDateTimeStr(start)
		end = utils.formatDateTimeStr(end)
		employee = self.cbxEmployee_1.currentText().toUtf8().data().strip()
		file = u'发票日报表-收银员_%s_%s.xls'%(start,end)


		file = QFileDialog.getSaveFileName(self,u'选择导出文件',file,u'统计文件(*.xls)')
		if not file:
			return
		#生成输出文件
		file = file.toUtf8().data().decode('utf-8')

		rs = self.doQuery1()

		hdr=u'类别 发票编号 开票日期 单位 金额 税额 价税合计 作废标志 机器号 收款方式'
		if self.cbxTimeQueryType1.currentIndex()!=0:
			hdr=u'类别 发票编号 结算日期 单位 金额 税额 价税合计 作废标志 机器号 收款方式'

		wbk = xlwt.Workbook()
		sheet = wbk.add_sheet('sheet 1')

#		rb = open_workbook('template.xls',formatting_info=True, on_demand=True)
#		rs = rb.sheet_by_index(0)
#		wbk = copy(rb)
#		sheet = wbk.get_sheet(0)

		#写表头
		fs = hdr.split(u' ')
		sheet.write( 0,0,u'大众国际洋山分公司增值税发票日报表-收银员')

		c = 0

		start = self.dtStart_1.dateTime().toPyDateTime()
		end = self.dtEnd_1.dateTime().toPyDateTime()
		start = utils.formatDateTimeStr2(start)
		end = utils.formatDateTimeStr2(end)

		if self.cbxTimeQueryType1.currentIndex()==0:
			sheet.write( 1,0,u'结算日期: %s 到 %s'%(start,end))
		else:
			sheet.write( 1,0,u'开票日期: %s 到 %s'%(start,end))

		sheet.write( 1,7,u'收银员:%s'%(employee.decode('utf-8')))

		for f in fs:
			sheet.write( 2,c,f)
			c+=1


		idx = 0

		amount=0
		tax = 0
		amount_tax = 0
		inv_norm_tax=0 #普票税额
		inv_norm_amount_tax = 0 #普票含税总额
		inv_norm_amount = 0  #普票总金额
		
		inv_spec_tax=0 #专票税额
		inv_spec_amount_tax = 0 #专票含税总额
		inv_spec_amount = 0 #专票总金额
		
		idx = 2
		for r in rs:
			idx+=1
			invtype = u'专票'
			if r['inv_type'] ==0: #  0 - 普通 ； 1 - 专用
				invtype = u'普票'

			status = u'正常'
			if r['flag_zf']:
				status = u'已作废'
				
			

			timeval = ''
			if self.cbxTimeQueryType1.currentIndex()==0:
				timeval = utils.formatDateTimeStr(r['inv_date'])
			else:
				timeval = utils.formatDateTimeStr(r['settlement_time'])
				
			row = ()
			if r['flag_zf']:
				row = (
			       invtype,
			       '%s-%s'%(r['inv_code'],r['inv_number']),
					timeval,
			        r['cust_name'].decode('utf-8'),
			        0,
			        0,
			        0,
					status,
			        str(r['client_nr']),
					TaxConsts.getPayTypeStr(r['pay_type']),
					''
				)
			else:
				amount_tax+=r['inv_amount']
				tax+=r['inv_tax']
				if r['inv_type'] ==0:
					inv_norm_tax+=r['inv_tax']
					inv_norm_amount_tax+=r['inv_amount']
				else:
					inv_spec_tax+=r['inv_tax']
					inv_spec_amount_tax+=r['inv_amount']
					
				row = (
					   invtype,
					   '%s-%s'%(r['inv_code'],r['inv_number']),
						timeval,
						r['cust_name'].decode('utf-8'),
						str(r['inv_amount'] - r['inv_tax']),
						r['inv_tax'],
						r['inv_amount'],
						status,
						str(r['client_nr']),
						TaxConsts.getPayTypeStr(r['pay_type']),
						''
					)
			row = map(lambda  x:unicode(x),row)
			row[4] = float(row[4])
			row[5] = float(row[5])
			row[6] = float(row[6])
			
			for c in range(len(row)):
				sheet.write(idx,c,row[c] )
		r = idx+1
		
		
		inv_norm_amount = inv_norm_amount_tax - inv_norm_tax
		
		sheet.write(r,0,u'-普票-')
		sheet.write(r,4,inv_norm_amount)
		sheet.write(r,5,inv_norm_tax)
		sheet.write(r,6,inv_norm_amount_tax)
		r+=1
		inv_spec_amount = inv_spec_amount_tax - inv_spec_tax
		sheet.write(r,0,u'-专票-')
		sheet.write(r,4,inv_spec_amount)
		sheet.write(r,5,inv_spec_tax)
		sheet.write(r,6,inv_spec_amount_tax)
		r+=1
		amount = amount_tax - tax
		sheet.write(r,0,u'合计')
		sheet.write(r,4,amount)
		sheet.write(r,5,tax)
		sheet.write(r,6,amount_tax)
		
		wbk.save(file)

		QMessageBox.about(self,u'提示',u'发票导出okay!')


	def init_ui_page2(self):
		curtime = QDateTime.currentDateTime ()
		t = time.localtime()
		secs = time.mktime((t.tm_year,t.tm_mon,t.tm_mday,0,0,0,0,0,0))
		# curtime.setTime_t(int(secs))
		start = curtime
		self.dtStart_2.setDateTime(start)
		end = start #curtime.addDays(1)
		self.dtEnd_2.setDateTime(end)

		mechines = self.getConfig().get('mechines','')
		mechines = mechines.split(',')
		for e in mechines:
			self.cbxMechine_2.addItem(e.decode('utf-8'))
		if mechines:
			self.cbxMechine_2.setCurrentIndex(0)


		self.cbxTimeQueryType2.addItem(u'结算日期')
		self.cbxTimeQueryType2.addItem(u'开票日期')
		self.cbxTimeQueryType2.setCurrentIndex(0)

		self.tvList_2.setHeaderLabels([
			u'序号',
		    u'类别',
		    u'发票编号',
			u'开票日期',
			u'单    位',
			u'金额',
			u'税额',
			u'价税合计',
			u'作废标志',
			u'收银员',
			u'收款方式'
		    u'',
		])
		self.tvList_2.resizeColumnToContents(0)
		self.tvList_2.setAlternatingRowColors(True)
		self.connect(self.btnQuery_2,SIGNAL('clicked()'),self.onBtnQuery2Click)
		self.connect(self.btnExport_2,SIGNAL('clicked()'),self.onBtnExport2Click)


	def doQuery2(self):
		mechine = self.cbxMechine_2.currentText().toUtf8().data().strip()
		# start = self.dtStart_2.dateTime().toPyDateTime()
		# end = self.dtEnd_2.dateTime().toPyDateTime()
		start,end = self.getQueryDateRange(self.dtStart_2,self.dtEnd_2)
		timefield = 'settlement_time'
		if self.cbxTimeQueryType2.currentIndex()!=0:
			timefield = 'inv_date'
		#sql = "select * from core_invoice where flag_zf=0 and %s "%timefield
		sql = "select * from core_invoice where %s "%timefield
		sql +=" between %s and %s "
		params=[start,end]
		if mechine:
			sql+=' and client_nr=%s '
			params.append(mechine)
		sql+="order by inv_type desc,inv_code,inv_number,%s,doc_time"%timefield
		cr = self.getDB().cursor()
		print sql
		cr.execute(sql,params)
		rs = fetchallDict(cr)
		return rs

	def onBtnQuery2Click(self):
		amount=0
		tax = 0
		amount_tax = 0

		self.tvList_2.clear()

		if self.cbxTimeQueryType2.currentIndex()==0:
			self.tvList_2.setHeaderLabels([
				u'序号',
				u'类别',
				u'发票编号',
				u'开票日期',
				u'单    位',
				u'金额',
				u'税额',
				u'价税合计',
				u'作废标志',
				u'收银员',
				u'收款方式'
				u'',
				])
		else:
			self.tvList_2.setHeaderLabels([
				u'序号',
				u'类别',
				u'发票编号',
				u'结算日期',
				u'单    位',
				u'金额',
				u'税额',
				u'价税合计',
				u'作废标志',
				u'收银员',
				u'收款方式'
				u'',
				])

		rs = self.doQuery2()
		idx = 0
		for r in rs:
			idx+=1
			invtype = u'专票'
			if r['inv_type'] ==0: #  0 - 普通 ； 1 - 专用
				invtype = u'普票'

			status = u'正常'
			if r['flag_zf']:
				status = u'已作废'
			

			timeval =''
			if self.cbxTimeQueryType2.currentIndex()==0:
				timeval = utils.formatDateTimeStr(r['inv_date'])
			else:
				timeval = utils.formatDateTimeStr(r['settlement_time'])

			row = ()
			if r['flag_zf']:
				row = (str(idx),
					   invtype,
					   '%s-%s'%(r['inv_code'],r['inv_number']),
						timeval,
						r['cust_name'].decode('utf-8'),
						0,
						0,
						0,
						status,
						r['issuer'].decode('utf-8'),
						TaxConsts.getPayTypeStr(r['pay_type']),
						''
					)
			else:
				amount_tax+=r['inv_amount']
				tax+=r['inv_tax']
				row = (str(idx),
					   invtype,
					   '%s-%s'%(r['inv_code'],r['inv_number']),
						timeval,
						r['cust_name'].decode('utf-8'),
						str(r['inv_amount'] - r['inv_tax']),
						r['inv_tax'],
						r['inv_amount'],
						status,
						r['issuer'].decode('utf-8'),
						TaxConsts.getPayTypeStr(r['pay_type']),
						''
					)
			row = map(lambda  x:unicode(x),row)
#			print row
			ti = QTreeWidgetItem(row )
			self.tvList_2.addTopLevelItem(ti)
		self.tvList_2.resizeColumnToContents(0)
#		self.tvList_2.resizeColumnToContents(1)
#		self.tvList_2.resizeColumnToContents(2)
#		self.tvList_2.resizeColumnToContents(3)
#		self.tvList_2.resizeColumnToContents(4)

		amount = amount_tax - tax

		txt =u'合计: 金额=%s 税额=%s 价税合计=%s'%(amount,tax,amount_tax)
		self.txtTotal_2.setText(txt)

	def onBtnExport2Click(self):
		import xlwt

		start = self.dtStart_2.dateTime().toPyDateTime()
		end = self.dtEnd_2.dateTime().toPyDateTime()
		start = utils.formatDateTimeStr(start)
		end = utils.formatDateTimeStr(end)
		mechine = self.cbxMechine_2.currentText().toUtf8().data().strip()
		file = u'发票日报表-机器_%s_%s.xls'%(start,end)


		file = QFileDialog.getSaveFileName(self,u'选择导出文件',file,u'统计文件(*.xls)')
		if not file:
			return
		#生成输出文件
		file = file.toUtf8().data().decode('utf-8')

		rs = self.doQuery2()


		hdr=u'类别 发票编号 开票日期 单位 金额 税额 价税合计 作废标志 收银员 收款方式'
		if self.cbxTimeQueryType2.currentIndex()!=0:
			hdr=u'类别 发票编号 结算日期 单位 金额 税额 价税合计 作废标志 收银员 收款方式'

		wbk = xlwt.Workbook()
		sheet = wbk.add_sheet('sheet 1')

		#		rb = open_workbook('template.xls',formatting_info=True, on_demand=True)
		#		rs = rb.sheet_by_index(0)
		#		wbk = copy(rb)
		#		sheet = wbk.get_sheet(0)

		#写表头
		fs = hdr.split(u' ')
		sheet.write( 0,0,u'大众国际洋山分公司增值税发票日报表-机器')

		c = 0

		start = self.dtStart_2.dateTime().toPyDateTime()
		end = self.dtEnd_2.dateTime().toPyDateTime()
		start = utils.formatDateTimeStr2(start)
		end = utils.formatDateTimeStr2(end)

		if self.cbxTimeQueryType2.currentIndex()==0:
			sheet.write( 1,0,u'结算日期: %s 到 %s'%(start,end))
		else:
			sheet.write( 1,0,u'开票日期: %s 到 %s'%(start,end))
		sheet.write( 1,7,u'机器号:%s'%(mechine.decode('utf-8')))

		for f in fs:
			sheet.write( 2,c,f)
			c+=1
		idx = 0
		amount=0
		tax = 0
		amount_tax = 0
		
		inv_norm_tax=0 #普票税额
		inv_norm_amount_tax = 0 #普票含税总额
		inv_norm_amount = 0  #普票总金额
		
		inv_spec_tax=0 #专票税额
		inv_spec_amount_tax = 0 #专票含税总额
		inv_spec_amount = 0 #专票总金额
		
		idx = 2
		for r in rs:
			idx+=1
			invtype = u'专票'
			if r['inv_type'] ==0: #  0 - 普通 ； 1 - 专用
				invtype = u'普票'

			status = u'正常'
			if r['flag_zf']:
				status = u'已作废'
			
			timeval=''
			if self.cbxTimeQueryType2.currentIndex() == 0:
				timeval = utils.formatDateTimeStr(r['inv_date'])
			else:
				timeval = utils.formatDateTimeStr(r['settlement_time'])
			
			row = ()
			
			if r['flag_zf']:
				row = (
					invtype,
					'%s-%s'%(r['inv_code'],r['inv_number']),
					timeval,
					r['cust_name'].decode('utf-8'),
					0,
					0,
					0,
					status,
					r['issuer'].decode('utf-8'),
					TaxConsts.getPayTypeStr(r['pay_type']),
					''
				)
			else:
				amount_tax+=r['inv_amount']
				tax+=r['inv_tax']
				if r['inv_type'] ==0:
					inv_norm_tax+=r['inv_tax']
					inv_norm_amount_tax+=r['inv_amount']
				else:
					inv_spec_tax+=r['inv_tax']
					inv_spec_amount_tax+=r['inv_amount']
				
				row = (
					invtype,
					'%s-%s'%(r['inv_code'],r['inv_number']),
					timeval,
					r['cust_name'].decode('utf-8'),
					str(r['inv_amount'] - r['inv_tax']),
					r['inv_tax'],
					r['inv_amount'],
					status,
					r['issuer'].decode('utf-8'),
					TaxConsts.getPayTypeStr(r['pay_type']),
					''
				)
			row = map(lambda  x:unicode(x),row)
			row[4] = float(row[4])
			row[5] = float(row[5])
			row[6] = float(row[6])
			for c in range(len(row)):
				sheet.write(idx,c,row[c] )
		r = idx+1
		
		inv_norm_amount = inv_norm_amount_tax - inv_norm_tax
		sheet.write(r,0,u'-普票-')
		sheet.write(r,4,inv_norm_amount)
		sheet.write(r,5,inv_norm_tax)
		sheet.write(r,6,inv_norm_amount_tax)
		r+=1
		inv_spec_amount = inv_spec_amount_tax - inv_spec_tax
		sheet.write(r,0,u'-专票-')
		sheet.write(r,4,inv_spec_amount)
		sheet.write(r,5,inv_spec_tax)
		sheet.write(r,6,inv_spec_amount_tax)
		r+=1
		
		amount = amount_tax - tax
		sheet.write(r,0,u'合计')
		sheet.write(r,4,amount)
		sheet.write(r,5,tax)
		sheet.write(r,6,amount_tax)
		wbk.save(file)

		QMessageBox.about(self,u'提示',u'发票导出okay!')


	def init_ui_page3(self):
		curtime = QDateTime.currentDateTime ()
		# t = time.localtime()
		# secs = time.mktime((t.tm_year,t.tm_mon,t.tm_mday,0,0,0,0,0,0))
		# curtime.setTime_t(int(secs))
		# start = curtime
		self.dtStart_3.setDateTime(curtime)
		# end = curtime.addDays(1)
		self.dtEnd_3.setDateTime(curtime)

		self.tvList_3.setHeaderLabels([
			u'序号',
		    u'类别',
		    u'机器号',
			u'金额',
			u'税额',
			u'价税合计',
		    u'',
		])
		self.tvList_3.resizeColumnToContents(0)
		self.tvList_3.setAlternatingRowColors(True)

		self.connect(self.btnQuery_3,SIGNAL('clicked()'),self.onBtnQuery3Click)
		self.connect(self.btnExport_3,SIGNAL('clicked()'),self.onBtnExport3Click)


	def doQuery3(self):
		# start = self.dtStart_3.dateTime().toPyDateTime()
		# end = self.dtEnd_3.dateTime().toPyDateTime()
		start,end = self.getQueryDateRange(self.dtStart_3,self.dtEnd_3)
		sql = 'select distinct client_nr as nr from core_invoice'
		cr = self.getDB().cursor()
		cr.execute(sql)
		mechines = fetchallDict(cr)
		result = []
		for m in mechines:
			#专票
			sql = 'select sum(inv_amount) as amount,sum(inv_tax) as tax from core_invoice where client_nr=%s and ' \
					'flag_zf=0 ' \
					'and inv_type=1 and settlement_time between %s and %s'
			cr.execute(sql,(m['nr'],start,end))
			r = fetchoneDict(cr)
			r = (u'专票',m['nr'].decode('utf-8'),r['amount'],r['tax'])
			result.append( r)

			#普票
			sql = 'select sum(inv_amount) as amount,sum(inv_tax) as tax from core_invoice where client_nr=%s and ' \
			      'flag_zf=0 ' \
			      'and inv_type=0 and settlement_time between %s and %s'
			cr.execute(sql,(m['nr'],start,end))
			r = fetchoneDict(cr)

			r = (u'普票',m['nr'].decode('utf-8'),r['amount'],r['tax'])
			result.append(r)

		return result

	def onBtnQuery3Click(self):
		amount=0
		tax = 0
		amount_tax = 0

		self.tvList_3.clear()
		rs = self.doQuery3()
		idx = 0
		for r in rs:
			r = list(r)
			idx+=1
			invtype = r[0]

			if not r[2]: r[2] = 0
			if not r[3]: r[3] = 0
			print r

			row = (str(idx),
			       invtype,
			       u'机器-%s'%r[1],
			       str(r[2]-r[3]),
			       str(r[3]),
			       str(r[2]),
					''
				)
			row = map(lambda  x:unicode(x),row)
			tax+=r[3]
			amount_tax+=r[2]
			ti = QTreeWidgetItem(row )
			self.tvList_3.addTopLevelItem(ti)
		self.tvList_3.resizeColumnToContents(0)
#		self.tvList_3.resizeColumnToContents(1)
#		self.tvList_3.resizeColumnToContents(2)
#		self.tvList_3.resizeColumnToContents(3)
#		self.tvList_3.resizeColumnToContents(4)
		amount = amount_tax - tax
		txt =u'合计: 金额=%s 税额=%s 价税合计=%s'%(amount,tax,amount_tax)
		self.txtTotal_3.setText(txt)

	def onBtnExport3Click(self):
		import xlwt
		start = self.dtStart_3.dateTime().toPyDateTime()
		end = self.dtEnd_3.dateTime().toPyDateTime()
		start = utils.formatDateTimeStr(start)
		end = utils.formatDateTimeStr(end)
		file = u'汇总报表-机器结算日_%s_%s.xls'%(start,end)

		file = QFileDialog.getSaveFileName(self,u'选择导出文件',file,u'统计文件(*.xls)')
		if not file:
			return
		#生成输出文件
		file = file.toUtf8().data().decode('utf-8')


		hdr=u'类别 机器号 金额 税额 价税合计'

		wbk = xlwt.Workbook()
		sheet = wbk.add_sheet('sheet 1')

		#写表头
		fs = hdr.split(u' ')
		sheet.write( 0,0,u'大众国际洋山分公司增值税发票汇总报表')

		c = 0

		start = self.dtStart_3.dateTime().toPyDateTime()
		end = self.dtEnd_3.dateTime().toPyDateTime()
		start = utils.formatDateTimeStr2(start)
		end = utils.formatDateTimeStr2(end)

		sheet.write( 1,0,u'结算日期: %s 到 %s'%(start,end))

		for f in fs:
			sheet.write( 2,c,f)
			c+=1
		idx = 0
		amount=0
		tax = 0
		amount_tax = 0
		idx = 2

		rs = self.doQuery3()

		for r in rs:
			r = list(r)
			idx+=1
			invtype = r[0]
			if not r[2]: r[2] = 0
			if not r[3]: r[3] = 0

			row = (
			       invtype,
			       u'机器-%s'%r[1],
			       str(r[2]-r[3]),
			       str(r[3]),
			       str(r[2]),
			       ''
			)
			row = map(lambda  x:unicode(x),row)
			row[2] = float(row[2])
			row[3] = float(row[3])
			row[4] = float(row[4])
			for c in range(len(row)):
				sheet.write(idx,c,row[c] )
			tax+=r[3]
			amount_tax+=r[2]


		r = idx+1
		amount = amount_tax - tax

		sheet.write(r,0,u'合计')
		sheet.write(r,2,amount)
		sheet.write(r,3,tax)
		sheet.write(r,4,amount_tax)
		wbk.save(file)
		QMessageBox.about(self,u'提示',u'发票导出okay!')


	def init_ui_page4(self):
		curtime = QDateTime.currentDateTime ()
		# t = time.localtime()
		# secs = time.mktime((t.tm_year,t.tm_mon,t.tm_mday,12,0,0,0,0,0))
		# curtime.setTime_t(int(secs))
		# start = curtime
		self.dtStart_4.setDateTime(curtime)
		# end = curtime.addDays(1)
		self.dtEnd_4.setDateTime(curtime)

		self.tvList_4.setHeaderLabels([
			u'序号',
		    u'类别',
		    u'机器号',
			u'金额',
			u'税额',
			u'价税合计',
		    u'',
		])
		self.tvList_4.resizeColumnToContents(0)
		self.tvList_4.setAlternatingRowColors(True)
		self.connect(self.btnQuery_4,SIGNAL('clicked()'),self.onBtnQuery4Click)
		self.connect(self.btnExport_4,SIGNAL('clicked()'),self.onBtnExport4Click)


	def doQuery4(self):
		# start = self.dtStart_4.dateTime().toPyDateTime()
		# end = self.dtEnd_4.dateTime().toPyDateTime()

		start,end = self.getQueryDateRange(self.dtStart_4,self.dtEnd_4)

		sql = 'select distinct client_nr as nr from core_invoice'
		cr = self.getDB().cursor()
		cr.execute(sql)
		mechines = fetchallDict(cr)
		result = []
		for m in mechines:
			#专票
			sql = 'select sum(inv_amount) as amount,sum(inv_tax) as tax from core_invoice where client_nr=%s and ' \
			      'flag_zf=0 ' \
			      'and ' \
			      'inv_type=1 and inv_date between %s and %s'
			cr.execute(sql,(m['nr'],start,end))
			r = fetchoneDict(cr)
			r = (u'专票',m['nr'].decode('utf-8'),r['amount'],r['tax'])
			result.append( r)

			#普票
			sql = 'select sum(inv_amount) as amount,sum(inv_tax) as tax from core_invoice where client_nr=%s and ' \
			      'flag_zf=0 ' \
			      'and ' \
			      'inv_type=0 and inv_date between %s and %s'
			cr.execute(sql,(m['nr'],start,end))
			r = fetchoneDict(cr)

			r = (u'普票',m['nr'].decode('utf-8'),r['amount'],r['tax'])
			result.append(r)

		return result

	def onBtnQuery4Click(self):
		amount=0
		tax = 0
		amount_tax = 0

		self.tvList_4.clear()
		rs = self.doQuery4()
		idx = 0
		for r in rs:
			r = list(r)
			idx+=1
			invtype = r[0]

			if not r[2]: r[2] = 0
			if not r[3]: r[3] = 0
			print r

			row = (str(idx),
			       invtype,
			       u'机器-%s'%r[1],
			       str(r[2]-r[3]),
			       str(r[3]),
			       str(r[2]),
					''
				)
			row = map(lambda  x:unicode(x),row)
			tax+=r[3]
			amount_tax+=r[2]
			ti = QTreeWidgetItem(row )
			self.tvList_4.addTopLevelItem(ti)
		self.tvList_4.resizeColumnToContents(0)

		amount = amount_tax - tax
		txt =u'合计: 金额=%s 税额=%s 价税合计=%s'%(amount,tax,amount_tax)
		self.txtTotal_4.setText(txt)

	def onBtnExport4Click(self):
		import xlwt
		start = self.dtStart_4.dateTime().toPyDateTime()
		end = self.dtEnd_4.dateTime().toPyDateTime()
		start = utils.formatDateTimeStr(start)
		end = utils.formatDateTimeStr(end)
		file = u'汇总报表-机器开票日_%s_%s.xls'%(start,end)

		file = QFileDialog.getSaveFileName(self,u'选择导出文件',file,u'统计文件(*.xls)')
		if not file:
			return
		#生成输出文件
		file = file.toUtf8().data().decode('utf-8')


		hdr=u'类别 机器号 金额 税额 价税合计'

		wbk = xlwt.Workbook()
		sheet = wbk.add_sheet('sheet 1')

		#写表头
		fs = hdr.split(u' ')
		sheet.write( 0,0,u'大众国际洋山分公司增值税发票汇总报表')

		c = 0

		start = self.dtStart_4.dateTime().toPyDateTime()
		end = self.dtEnd_4.dateTime().toPyDateTime()
		start = utils.formatDateTimeStr2(start)
		end = utils.formatDateTimeStr2(end)

		sheet.write( 1,0,u'结算日期: %s 到 %s'%(start,end))

		for f in fs:
			sheet.write( 2,c,f)
			c+=1
		idx = 0
		amount=0
		tax = 0
		amount_tax = 0
		idx = 2

		rs = self.doQuery4()

		for r in rs:
			r = list(r)
			idx+=1
			invtype = r[0]
			if not r[2]: r[2] = 0
			if not r[3]: r[3] = 0

			row = (
			invtype,
			u'机器-%s'%r[1],
			str(r[2]-r[3]),
			str(r[3]),
			str(r[2]),
			''
			)
			row = map(lambda  x:unicode(x),row)
			row[2] = float(row[2])
			row[3] = float(row[3])
			row[4] = float(row[4])
			
			
			for c in range(len(row)):
				sheet.write(idx,c,row[c] )
			tax+=r[3]
			amount_tax+=r[2]


		r = idx+1
		amount = amount_tax - tax

		sheet.write(r,0,u'合计')
		sheet.write(r,2,amount)
		sheet.write(r,3,tax)
		sheet.write(r,4,amount_tax)
		wbk.save(file)
		QMessageBox.about(self,u'提示',u'发票导出okay!')


	def init_ui_page5(self):
		curtime = QDateTime.currentDateTime ()
		# t = time.localtime()
		# secs = time.mktime((t.tm_year,t.tm_mon,t.tm_mday,12,0,0,0,0,0))
		# curtime.setTime_t(int(secs))
		# start = curtime
		self.dtStart_5.setDateTime(curtime)
		# end = curtime.addDays(1)
		self.dtEnd_5.setDateTime(curtime)

		self.tvList_5.setHeaderLabels([
			u'序号',
		    u'类别',
		    u'发票编号',
			u'结算日期',
			u'单    位',
			u'金额',
			u'税额',
			u'价税合计',
			u'机器号'
		    u'',
		])
		self.tvList_5.resizeColumnToContents(0)
		self.tvList_5.setAlternatingRowColors(True)
		self.connect(self.btnQuery_5,SIGNAL('clicked()'),self.onBtnQuery5Click)
		self.connect(self.btnExport_5,SIGNAL('clicked()'),self.onBtnExport5Click)


	def doQuery5(self):
		# start = self.dtStart_5.dateTime().toPyDateTime()
		# end = self.dtEnd_5.dateTime().toPyDateTime()
		start,end = self.getQueryDateRange(self.dtStart_5,self.dtEnd_5)

		sql = "select * from core_invoice where " \
		      "flag_zf=1 and  inv_date between %s and %s order by inv_type desc,doc_time"
		cr = self.getDB().cursor()
		print sql
		cr.execute(sql,(start,end))
		rs = fetchallDict(cr)
		return rs

	def onBtnQuery5Click(self):
		amount=0
		tax = 0
		amount_tax = 0

		self.tvList_5.clear()
		rs = self.doQuery5()
		idx = 0
		for r in rs:
			idx+=1
			invtype = u'专票'
			if r['inv_type'] ==0: #  0 - 普通 ； 1 - 专用
				invtype = u'普票'

			amount_tax+=r['inv_amount']
			tax+=r['inv_tax']
			row = (str(idx),
			       invtype,
			       '%s-%s'%(r['inv_code'],r['inv_number']),
					utils.formatDateTimeStr2(r['settlement_time']),
			        r['cust_name'].decode('utf-8'),
			        str(r['inv_amount'] - r['inv_tax']),
			        r['inv_tax'],
			        r['inv_amount'],
			        str(r['client_nr']),
					''
				)
			row = map(lambda  x:unicode(x),row)
#			print row
			ti = QTreeWidgetItem(row )
			self.tvList_5.addTopLevelItem(ti)
		self.tvList_5.resizeColumnToContents(0)
		amount = amount_tax - tax

		txt =u'合计: 金额=%s 税额=%s 价税合计=%s'%(amount,tax,amount_tax)
		self.txtTotal_5.setText(txt)


	def onBtnExport5Click(self):
		import xlwt
		start = self.dtStart_5.dateTime().toPyDateTime()
		end = self.dtEnd_5.dateTime().toPyDateTime()
		start = utils.formatDateTimeStr(start)
		end = utils.formatDateTimeStr(end)
		file = u'发票作废汇总表_%s_%s.xls'%(start,end)
		file = QFileDialog.getSaveFileName(self,u'选择导出文件',file,u'统计文件(*.xls)')
		if not file:
			return
		#生成输出文件
		file = file.toUtf8().data().decode('utf-8')
		rs = self.doQuery5()
		hdr=u'类别 发票编号 结算日期 单位 金额 税额 价税合计 机器号'

		wbk = xlwt.Workbook()
		sheet = wbk.add_sheet('sheet 1')
		#写表头
		fs = hdr.split(u' ')
		c = 0
		for f in fs:
			sheet.write( 0,c,f)
			c+=1
#		row = 1
		idx = 0

		amount=0
		tax = 0
		amount_tax = 0

		for r in rs:
			idx+=1
			invtype = u'专票'
			if r['inv_type'] ==0: #  0 - 普通 ； 1 - 专用
				invtype = u'普票'
			amount_tax+=r['inv_amount']
			tax+=r['inv_tax']
			row = (
#					str(idx),
			       invtype,
			       '%s-%s'%(r['inv_code'],r['inv_number']),
					utils.formatDateTimeStr2(r['doc_time']),
			        r['cust_name'].decode('utf-8'),
			        str(r['inv_amount'] - r['inv_tax']),
			        r['inv_tax'],
			        r['inv_amount'],
			        str(r['client_nr'])
				)
			row = map(lambda  x:unicode(x),row)
			row[4] = float(row[4])
			row[5] = float(row[5])
			row[6] = float(row[6])
			
			for c in range(len(row)):
				sheet.write(idx,c,row[c] )
#			row+=1
		r = idx+1
		amount = amount_tax - tax
		txt =u'合计: 金额=%s 税额=%s 价税合计=%s'%(amount,tax,amount_tax)
		sheet.write(r,0,u'合计')
		sheet.write(r,4,amount)
		sheet.write(r,5,tax)
		sheet.write(r,6,amount_tax)

		wbk.save(file)

		QMessageBox.about(self,u'提示',u'发票导出okay!')

	def init_ui_page6(self):

		employees = self.getConfig().get('employees','')
		employees = employees.split(',')
		for e in employees:
			self.cbxEmployee_6.addItem(e.decode('utf-8'))
		if employees:
			self.cbxEmployee_6.setCurrentIndex(0)


		mechines = self.getConfig().get('mechines','')
		mechines = mechines.split(',')
		for e in mechines:
			self.cbxMechine_6.addItem(e.decode('utf-8'))
		if mechines:
			self.cbxMechine_6.setCurrentIndex(0)


		curtime = QDateTime.currentDateTime ()
		# t = time.localtime()
		# secs = time.mktime((t.tm_year,t.tm_mon,t.tm_mday,0,0,0,0,0,0))
		# curtime.setTime_t(int(secs))
		# start = curtime
		self.dtStart_6.setDateTime(curtime)
		# end = curtime.addDays(1)
		self.dtEnd_6.setDateTime(curtime)

		self.tvList_6.setHeaderLabels([
		    u'结算方式',
		    u'票数',
			u'金额',
			u'税额',
			u'价税合计',
		    u'',
		])
		self.tvList_6.resizeColumnToContents(0)
		self.tvList_6.setAlternatingRowColors(True)
		self.connect(self.btnQuery_6,SIGNAL('clicked()'),self.onBtnQuery6Click)
		self.connect(self.btnExport_6,SIGNAL('clicked()'),self.onBtnExport6Click)


	def doQuery6(self):
		# start = self.dtStart_6.dateTime().toPyDateTime()
		# end = self.dtEnd_6.dateTime().toPyDateTime()
		start,end = self.getQueryDateRange(self.dtStart_6,self.dtEnd_6)

		employee = self.cbxEmployee_6.currentText().toUtf8().data().strip()
		mechine = self.cbxMechine_6.currentText().toUtf8().data().strip()
		items= (TaxConsts.PAYTYPE_CASH,
				TaxConsts.PAYTYPE_CHECK,
				TaxConsts.PAYTYPE_CASHCHECK,
		        TaxConsts.PAYTYPE_POS
				)

		result=[]
		count =0
		amount = 0
		tax = 0
		amount_tax=0
		for pay in items:
			sql = "select sum(inv_amount) as amount_tax,sum(inv_tax) as tax,count(*) as cnt from core_invoice where " \
			      "flag_zf=0 and  settlement_time between %s and %s and pay_type=%s "
			params = [start,end,pay]
			if employee:
				sql+=' and issuer=%s '
				params.append(employee)
			if mechine:
				sql+=' and client_nr=%s '
				params.append(mechine)

			cr = self.getDB().cursor()
			cr.execute(sql,params)
			r = fetchoneDict(cr)
			if not r['amount_tax']: r['amount_tax'] = 0
			if not r['tax']: r['tax'] = 0
			payname = TaxConsts.getPayTypeStr(pay)
			result.append([ payname,r['cnt'],r['amount_tax']-r['tax'],r['tax'],r['amount_tax'] ])
			count+=r['cnt']
			amount += r['amount_tax']-r['tax']
			amount_tax += r['amount_tax']
			tax += r['tax']

		result.append([ u'合计',count,amount,tax,amount_tax ])
		return result

	def onBtnQuery6Click(self):
		amount=0
		tax = 0
		amount_tax = 0

		self.tvList_6.clear()
		rs = self.doQuery6()

		for r in rs:
			row = r
			row = map(lambda  x:unicode(x),row)

			ti = QTreeWidgetItem(row )
			self.tvList_6.addTopLevelItem(ti)
		self.tvList_6.resizeColumnToContents(0)


	def onBtnExport6Click(self):
		import xlwt
		start = self.dtStart_6.dateTime().toPyDateTime()
		end = self.dtEnd_6.dateTime().toPyDateTime()
		start = utils.formatDateTimeStr(start)
		end = utils.formatDateTimeStr(end)
		file = u'收银员收款日报表_%s_%s.xls'%(start,end)
		file = QFileDialog.getSaveFileName(self,u'选择导出文件',file,u'统计文件(*.xls)')
		if not file:
			return
		#生成输出文件
		file = file.toUtf8().data().decode('utf-8')
		rs = self.doQuery6()
		hdr=u'结算方式 票数 金额 税额 价税合计'

		wbk = xlwt.Workbook()
		sheet = wbk.add_sheet('sheet 1')
		#写表头
		fs = hdr.split(u' ')
		c = 0
		for f in fs:
			sheet.write( 4,c,f)
			c+=1
#		row = 1
		idx = 4

		for r in rs:
			idx+=1
			row = r
			#row = map(lambda  x:unicode(x),row)
			for c in range(len(row)):
				sheet.write(idx,c,row[c] )
		r = idx+1

		sheet.write(r,0,u'收银员签字')
		sheet.write(r,4,u'审核签收')

		sheet.write(0,0,u'大众国际洋山分公司收银员收银日报表')
		start = self.dtStart_6.dateTime().toPyDateTime()
		end = self.dtEnd_6.dateTime().toPyDateTime()
		start = utils.formatDateTimeStr2(start)
		end = utils.formatDateTimeStr2(end)
		sheet.write(2,0,u'结算日期：%s 至 %s'%(start,end))

		employee = self.cbxEmployee_6.currentText().toUtf8().data().strip()
		mechine = self.cbxMechine_6.currentText().toUtf8().data().strip()

		sheet.write(2,1,u'收银员：%s'%employee.decode('utf-8'))
		sheet.write(2,3,u'机器号：%s'%mechine.decode('utf-8'))
		sheet.write(3,4,u'单位：元')

		wbk.save(file)

		QMessageBox.about(self,u'提示',u'导出okay!')

	def init_ui_page7(self):
		curtime = QDateTime.currentDateTime ()
		# t = time.localtime()
		# secs = time.mktime((t.tm_year,t.tm_mon,t.tm_mday,0,0,0,0,0,0))
		# curtime.setTime_t(int(secs))
		# start = curtime
		self.dtStart_7.setDateTime(curtime)
		# end = curtime.addDays(1)
		self.dtEnd_7.setDateTime(curtime)

		self.tvList_7.setHeaderLabels([
			u'收银员',
		    u'票数(现金)',
		    u'金额(现金)',
			u'票数(支票)',
		    u'金额(支票)',
		    u'票数(现金+支票)',
		    u'金额(现金+支票)',
		    u'票数(POS收款)',
		    u'金额(POS收款)',
		    u'票数(小计)',
		    u'金额(小计)',
		    u'',
		])
		self.tvList_7.setAlternatingRowColors(True)
		self.tvList_7.resizeColumnToContents(0)

		self.connect(self.btnQuery_7,SIGNAL('clicked()'),self.onBtnQuery7Click)
		self.connect(self.btnExport_7,SIGNAL('clicked()'),self.onBtnExport7Click)


	def doQuery7(self):
		# start = self.dtStart_7.dateTime().toPyDateTime()
		# end = self.dtEnd_7.dateTime().toPyDateTime()
		start,end = self.getQueryDateRange(self.dtStart_7,self.dtEnd_7)

		cr = self.getDB().cursor()
		sql = 'select distinct issuer from core_invoice'
		cr.execute(sql)
		rs = fetchallDict(cr)
		issuers=[]
		for r in rs:
			issuers.append(r['issuer'])

		count =0
		amount = 0
		tax = 0
		amount_tax=0
		result=[]
		paytypes =(TaxConsts.PAYTYPE_CASH,
				TaxConsts.PAYTYPE_CHECK,
				TaxConsts.PAYTYPE_CASHCHECK,
		        TaxConsts.PAYTYPE_POS
				)
		for issuer in issuers:

			line=[issuer.decode('utf-8')]
			count = 0
			amount_tax = 0
			for pay in paytypes:
				sql = "select sum(inv_amount) as amount_tax,count(*) as cnt from core_invoice where " \
				      "flag_zf=0 and  settlement_time between %s and %s and pay_type=%s and issuer=%s"
				params = [start,end,pay,issuer]
				cr.execute(sql,params)
				r = fetchoneDict(cr)
				if not r['amount_tax']: r['amount_tax'] = 0
				line.append(r['cnt'])
				line.append(r['amount_tax'])
				amount_tax+=r['amount_tax']
				count+=r['cnt']
			line.append(count)
			line.append(amount_tax)
			result.append(line)
		#合计
		count = 0
		amount_tax =0
		line=[u'合计']+[0]*(len(paytypes)+1)*2
		for col in range(len(paytypes)+1):
			for r in result:
				line[1+col*2] += r[1+col*2]
				line[1+col*2+1] += r[1+col*2+1]
		result.append(line)
		return result


	def onBtnQuery7Click(self):

		self.tvList_7.clear()
		rs = self.doQuery7()

		for r in rs:
			row = r
			row = map(lambda  x:unicode(x),row)
#			print row
			ti = QTreeWidgetItem(row )
			self.tvList_7.addTopLevelItem(ti)
		self.tvList_7.resizeColumnToContents(0)
		ti = self.tvList_7.topLevelItem(self.tvList_7.topLevelItemCount()-1)
		ti.setBackground(0,QBrush(QColor('red')))




	def onBtnExport7Click(self):
		import xlwt
		start = self.dtStart_7.dateTime().toPyDateTime()
		end = self.dtEnd_7.dateTime().toPyDateTime()
		start = utils.formatDateTimeStr(start)
		end = utils.formatDateTimeStr(end)
		file = u'收银员收款汇总日报表_%s_%s.xls'%(start,end)
		file = QFileDialog.getSaveFileName(self,u'选择导出文件',file,u'统计文件(*.xls)')
		if not file:
			return
		#生成输出文件
		file = file.toUtf8().data().decode('utf-8')

		hdr=u'收银员 票数(现金) 金额(现金) 票数(支票) 金额(支票) 票数(现金+支票) 金额(现金+支票) 票数(POS收款) 金额(POS收款) 票数(小计) 金额(小计)'

		wbk = xlwt.Workbook()
		sheet = wbk.add_sheet('sheet 1')
		#写表头
		sheet.write( 0,0,u'大众国际洋山分公司收银员收银汇总日报表')

		start = self.dtStart_7.dateTime().toPyDateTime()
		end = self.dtEnd_7.dateTime().toPyDateTime()
		start = utils.formatDateTimeStr2(start)
		end = utils.formatDateTimeStr2(end)
		sheet.write( 2,0,u'结算日期：%s 至 %s'%(start,end))
		sheet.write( 2,7,u'单位：元')

		fs = hdr.split(u' ')
		c = 0
		for f in fs:
			sheet.write( 3,c,f)
			c+=1
#		row = 1
		idx = 3

#		amount=0
#		tax = 0
#		amount_tax = 0
#
		rs = self.doQuery7()

		for r in rs:
			idx+=1
			row = r
			#row = map(lambda  x:unicode(x),row)

			for c in range(len(row)):
				sheet.write(idx,c,row[c] )
#			row+=1
		r = idx+1

		sheet.write(r,7,u'审核签收')
		wbk.save(file)
		QMessageBox.about(self,u'提示',u'导出okay!')


if __name__=='__main__':
	pass