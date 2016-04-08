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

import taxctrl
import taxcache
from dbconn import *
from taxbase import *
import form_invoice_prompt
import cipher
import utils

ENCRYPT_KEY='#E0~RweT'

INV_QT_BY_ALL = 0
INV_QT_BY_INVCODE = 1
INV_QT_BY_INVNUMBER = 2
INV_QT_BY_CUSTNAME = 3
INV_QT_BY_CUSTTAXCODE = 4
INV_QT_BY_DOCNR = 5

APP_VERSION='v1.0.3.2'

'''
1.0.1.1
	导入订单时即刻写入所有订单到db（之前是开票成功写入db)
v1.0.2.0
	修正自动导入时，错误判断订单已经存在，导致开票过程终止

v1.0.3.0
	增加读取订单字段： 结算时间和支付方式

v1.0.3.1
	dz海天一路的不需要 支付、结算方式，那就27列；
	tax_base.py支持27列和29列 两种方式。 有29列则 解析支付方式和结算日期

v1.0.3.2
    form_invoice.py 发票导出，检查订单编号，去除小数部分
'''

class MainWindow(QtGui.QMainWindow,Ui_MainWindow):
	def __init__(self,app):
		QtGui.QMainWindow.__init__(self)
		self.setupUi(self)
		self.app = app
		self.db = None
		self.show()
		self.timer = QTimer()

		self.connect(self.timer,SIGNAL('timeout()'),self.onTimerTrigger)
		self.connect(self.btnInvQuery,SIGNAL('clicked()'),self.onBtnInvQueryClick)
		self.connect(self.btnInvCancel,SIGNAL('clicked()'),self.onBtnInvCancelClick)
		self.connect(self.btnInvRed,SIGNAL('clicked()'),self.onBtnInvRedClick)
		self.connect(self.btnReadDir,SIGNAL('clicked()'),self.onBtnReadDirClick)



		self.connect(self.btnInvPrint,SIGNAL('clicked()'),self.onBtnInvPrintClick)
		self.connect(self.btnInvExport,SIGNAL('clicked()'),self.onBtnInvExportClick)

		self.connect(self.tvInvMain,SIGNAL('itemClicked(QTreeWidgetItem*,int)'),self.onTreeItemClick_InvMain)
#		self.connect(self.tvInvGoods,SIGNAL('itemClicked(QTreeWidgetItem*,int)'),self.onTreeItemClick_InvGoods)


		self.connect(self.tvDocMain,SIGNAL('itemClicked(QTreeWidgetItem*,int)'),self.onTreeItemClick_DocMain)
		self.connect(self.tvDocGoods,SIGNAL('itemClicked(QTreeWidgetItem*,int)'),self.onTreeItemClick_DocGoods)

		self.connect(self.btnDocQuery,SIGNAL('clicked()'),self.onBtnDocQueryClick)
#		self.connect(self.btnTodayDoc,SIGNAL('clicked()'),self.onBtnTodayDocClick)
		self.connect(self.btnDocDel,SIGNAL('clicked()'),self.onBtnDocDelClick)
		self.connect(self.btnDocImport,SIGNAL('clicked()'),self.onBtnDocImportClick)
		self.connect(self.btnDocInvoice,SIGNAL('clicked()'),self.onBtnDocInvoiceClick)


		self.connect(self.btnSave,SIGNAL('clicked()'),self.onBtnSaveProfile)
		self.connect(self.btnSyncManual,SIGNAL('clicked()'),self.onBtnSyncManual)

		self.connect(self.btnResetClear,SIGNAL('clicked()'),self.onBtnResetClear)



#		self.initUi()

		self.mtxthis = threading.Lock()
		self.confile = 'local.profile'
		self.libfile = '%s/taxexp.dll'%(win32api.GetSystemDirectory())
		self.libfile = 'system.lib'
		self.props = {'corpname':'',
					'taxcode':'',
					'address':'',
					'bank':'',
					'branch':'',
					'server_addr':'',
					'server_port':'',
					'is_sync_server':False,
					'is_doc_autoread':False,
					'doc_readdir':''
					}

		#数据库
		self.db = taxcache.TaxMemDB(self.libfile)
		self.initData()

#		self.workthread = threading.Thread(target=self.work_thread)
#		self.workthread.start()
#		self.app_exiting =False

		self.timer.start(1000*1)

		title = self.windowTitle() + '  ( %s )'%APP_VERSION
		self.setWindowTitle(title)

	def work_thread(self):
		'''
		同步数据到服务器
		'''
		while not self.app_exiting:
			time.sleep(1)
			if not self.props['is_sync_server']:
				continue
			self.syncInvoices()


	def onTimerTrigger(self):
		try:
			#self.syncInvoices()
			self.importDocument()

		except:
			traceback.print_exc()


	def onBtnInvRedClick(self):
		QMessageBox.about(self,u'提示',u'请进入【增值税开票系统】处理!')
		return


	def onBtnResetClear(self):
		sql = '''delete from core_document;
			delete from core_documentitem;
			delete from core_invoice;
			delete from core_invoiceitem;
			'''
		db = self.db.handle()
		db.executescript(sql)
		db.commit()
		QMessageBox.about(self,u'提示',u'clear reset complished!')
		return

	def importDocument(self):
		'''
		检查erp导出目录下的订单
		'''
		if not self.ckReadDocAuto.checkState():
			return
		path = self.props['doc_readdir'].decode('utf-8')
		if not os.path.exists(path):
			QMessageBox.about(self,u'提示',u'无法访问订单目录:%s!'%path)
			self.ckReadDocAuto.setCheckState(0)
			self.props['is_doc_autoread'] = False
			return

		backdir = path+'/store'
		try:
			os.mkdir(backdir)
		except:pass
		files = os.listdir(path)
		for file in files:
			that = path+'/'+file
			if os.path.isdir(that):
				continue
			if that.find('.xls') == -1:
				continue
			#read doc xls-file
			docs = self.readDoc_xls(that)

			#remove file
			try:
				backfile = backdir+'/'+file
				if os.path.exists(backfile):
					os.remove(backfile)
				os.rename(that,backfile)
			except:
				pass

			if not docs:
				QMessageBox.about(self,u'提示',u'读取订单文件失败:%s'%that)
#				QMessageBox.about(self,u'提示',u'读取订单文件失败:%s\n已关闭自动读取订单模式!'%that)
#				self.ckReadDocAuto.setCheckState(0)
#				self.props['is_doc_autoread'] = False
				continue

			for doc in docs:
				if not self.saveDocument(doc):
					continue

			for doc in docs:
				#订单已存在直接忽略,需人工删除之后再次导入
				doc = TaxDocument.from_db(self.db.handle(),doc.doc_nr)
				# if exist:
				# 	QMessageBox.about(self,u'提示',u'订单:%s 已存在，开票取消!'%doc.doc_nr)
				# 	continue
				if doc.status:
					QMessageBox.about(self,u'提示',u'此订单:%s 已开票,不能重复操作 !'%doc.doc_nr)
					continue

				#必须重db重新加载，因为db存储的字段全为str类型
				# doc = TaxDocument.from_db(self.db.handle(),doc.doc_nr)
				# print doc.toString()
				if '1'!= utils.SimpleConfig().load('system.conf').get('import_and_invoice'):
					return

				if not self.doInvoice(doc):
	#				QMessageBox.about(self,u'提示',u'开票失败，请检查订单数据是否有效!')
					#continue
					break


	def doInvoice(self,doc):
		'''
		执行开票操作
		'''
		#----- prompt to user -------
		info = {'doc_nr':'1001','taxcode':'111223','taxnumber':'4005','custname':u'上海华港'}
		r,emsg,code,number = taxctrl.getTaxInfo(int(doc.inv_type))
		if not r:
			QMessageBox.about(self,u'提示',u'获取发票信息错误!\n请检查开票系统和金税卡是否正常\n'+emsg)
			return False
		info['doc_nr'] = doc.doc_nr
		info['taxcode'] = code
		info['taxnumber'] = number
		info['custname'] = doc.cust_name
		info['amount'] = doc.getAmount()

		form = form_invoice_prompt.FormPrompt(None)
		rc = form.prompt(info)

		if not rc:
			return
		# 执行开票操作
		mode = TaxConsts.MODE_CREATE_PRINT
		if rc == 2:
			mode = TaxConsts.MODE_CREATE
		# tax.lic控制银行账号
		# doc数据都必须转成utf-8
		#doc.seller_bankacct = cipher.decrypt_bankaccount().encode('utf-8')

		r,emsg,code,number,date,amount,tax = taxctrl.create_invoice(doc,mode)

		if not r:
			QMessageBox.about(self,u'提示',u'开票失败： ' + emsg)
			return False
#		code,number,date,amount,tax = r
		print r,emsg,code,number,date,amount,tax

		inv = doc.toInvoice()
		inv.inv_code = code
		inv.inv_number = number
		inv.inv_date = date
		inv.inv_amount = amount
		inv.inv_tax = tax

		r = inv.save(self.db.handle())
		if not r:
			QMessageBox.about(self,u'提示',u'写入数据库失败!')
			return False
		doc.updateStatus(self.db.handle(),1)

		self.updateUnupload()
		QMessageBox.about(self,u'提示',u'订单:%s 开票成功:%s,%s!'%(doc.doc_nr,code,number))
		return True


	def updateUnupload(self):
		'''
		更新显示未上传发票记录数量
		'''
		#edtUnupload
		try:
			sql = "select count(*) as cnt from core_invoice where isuploaded = 0"
			cr = self.db.handle().cursor()
			cr.execute(sql)
			rs = fetchoneDict(cr)
			self.edtUnupload.setText( str(rs['cnt']))
		except:
			traceback.print_exc()

	def readDoc_xls(self,xls):
		'''
		'''

		return TaxDocument.from_xls(xls)
		pass

	def saveDocument(self,doc):
		'''
		保存订单信息到数据ku
		1.已存在订单，状态为0，则覆盖发票信息
		2.未存在订单，则插入记录
		'''
		doc.seller_name = self.props['corpname'].decode('utf-8')
		doc.seller_taxcode = self.props['taxcode'].decode('utf-8')
		doc.seller_address = self.props['address'].decode('utf-8')
		doc.seller_bankacct = self.props['bank'].decode('utf-8')
		doc.client_nr = self.props['branch'].decode('utf-8')

		succ,code = doc.save(self.db.handle())
		if not succ:
			if code == 1:
				QMessageBox.about(self,u'提示',u'数据写入异常!')
			elif code == 2:
				QMessageBox.about(self,u'提示',u'订单:%s 已开票，不能再次导入!\n'%doc.doc_nr)
			return False
		return True

	def syncInvoices(self):
		'''
		同步发票记录到服务器
		'''
#		print self.props['is_sync_server']
#		if not self.props['is_sync_server']:
#			return
		import urllib
		try:
			sql = "select inv_code,inv_number from core_invoice where isuploaded = 0"
			# sql = "select * from core_invoice where isuploaded = 0"
			cr = self.db.handle().cursor()
			cr.execute(sql)

			rs = fetchallDict(cr)
			invoices=[]
			dlist =[]
			for r in rs:
				inv = TaxInvoice.from_db(self.db.handle(),r['inv_code'],r['inv_number'])
				if not inv :
					continue
#				inv.client_nr = self.props['branch'] #分机号
				d = inv.to_hash()
				invoices.append(inv)
				dlist.append(d)

			if not invoices:
				QMessageBox.about(self,u'提示',u'当前无需同步的发票记录!')
				return True

			d = json.dumps(dlist) #将发票记录转成json格式
			d = base64.encodestring(d).strip() #转换成base64
			print 'sync data len:',len(d)
			params = urllib.urlencode({'invoices':d})
			f = urllib.urlopen('http://%s:%s/putInvoice/'%(self.props['server_addr'],self.props['server_port']),
			                   params)
			d = f.read()
			# print d
			# f = open('c:/html.html','w')
			# f.write(d)
			# f.close()

			d = json.loads(d)
			if d['status'] != 0:
				QMessageBox.about(self,u'提示',u'发送到服务器失败!')
				return False
			for inv in invoices:
				inv.setUploadFlag(self.db.handle())
			self.updateUnupload()
		except:
			traceback.print_exc()
			QMessageBox.about(self,u'提示',u'数据同步到服务器失败!')
			return False
		QMessageBox.about(self,u'提示',u'%s条发票记录已传送到服务器!'%len(invoices))
		return True


	def onBtnSaveProfile(self):

		self.props['corpname'] = self.edtCorpName.text().toUtf8().data().strip()
		self.props['taxcode'] =  self.edtTaxcode.text().toUtf8().data().strip()
		self.props['address'] =  self.edtAddress.text().toUtf8().data().strip()
		self.props['bank'] =  self.edtBank.text().toUtf8().data().strip()

		self.props['branch'] =  self.edtBranchNo.text().toUtf8().data().strip()

		self.props['server_addr'] =  self.edtServerAddress.text().toUtf8().data().strip()
		self.props['server_port'] =  self.edtServerPort.text().toUtf8().data().strip()

		if self.ckSyncToServer.checkState():
			self.props['is_sync_server'] = True
		else:
			self.props['is_sync_server'] = False

		if self.ckReadDocAuto.checkState():
			self.props['is_doc_autoread'] = True
		else:
			self.props['is_doc_autoread'] = False

		self.props['doc_readdir'] = self.edtReadDocDir.text().toUtf8().data().strip()


		if len(self.props['corpname']) == 0:
			QMessageBox.about(self,u'提示',u'企业名称不能为空!')
			return
		if len(self.props['taxcode']) == 0:
			QMessageBox.about(self,u'提示',u'税号不能为空!')
			return

		if len(self.props['address']) == 0:
			QMessageBox.about(self,u'提示',u'地址和电话不能为空!')
			return
		if len(self.props['bank']) == 0:
			QMessageBox.about(self,u'提示',u'银行账号不能为空!')
			return

		if len(self.props['branch']) == 0:
			QMessageBox.about(self,u'提示',u'分机号不能为空!')
			return


		f = open(self.confile,'w')
		pickle.dump(self.props,f)
		f.close()

		QMessageBox.about(self,u'提示',u'信息写入okay!')


	def onBtnSyncManual(self):
		'''
		手动同步发票到服务器
		'''
		self.setCursor(QtGui.QCursor(QtCore.Qt.WaitCursor))
		self.syncInvoices()
		self.updateUnupload()
		self.setCursor(QtGui.QCursor(QtCore.Qt.ArrowCursor))



	def onBtnDocInvoiceClick(self):
		'''
		选择发票记录开票
		'''
#		self.importDocument()
#		if 1: return

		tis = self.tvDocMain.selectedItems()
		if not tis:
			QMessageBox.about(self,u'提示',u'请选择订单记录!')
			return
		ti = tis[0]
		doc_nr = self.idxdata_doc.get(ti)
		if not doc_nr:
			return
		doc = TaxDocument.from_db(self.db.handle(),doc_nr)
		if not doc:
			QMessageBox.about(self,u'提示',u'订单记录无法读取!')
			return

		if doc.status:
			QMessageBox.about(self,u'提示',u'此订单已开票,不能重复操作 !')
			return
		self.btnDocInvoice.setEnabled(False)
#		print 'enable:',self.btnDocInvoice.isEnabled(),self.btnDocInvoice.text()
		try:
			self.enterLock()
			if not self.doInvoice(doc):
				return
			doc.updateStatus(self.db.handle(),1) #标志已经开具
		finally:
			self.btnDocInvoice.setEnabled(True)
			self.leaveLock()

	#导入订单文件 xls
	def onBtnDocImportClick(self):


		file = QFileDialog.getOpenFileName(None,u'选择订单文件',self.last_impdir,u'开票文件(*.xls)')
		if not file:
			return
		self.last_impdir = file

		file = file.toUtf8().data().decode('utf-8')
		docs = self.readDoc_xls(file)
		if not docs:
			QMessageBox.about(self,u'提示',u'读取订单文件失败:%s\n%s'%(file,TaxConsts.g_errmsg) )
			return
		print docs

		for doc in docs:
			if not self.saveDocument(doc):
				continue

		for doc in docs:
			doc = TaxDocument.from_db(self.db.handle(),doc.doc_nr)
			if doc.status:
				QMessageBox.about(self,u'提示',u'此订单:%s 已开票,不能重复操作 !'%doc.doc_nr)
				continue
			try:
				self.enterLock()
				if not self.doInvoice(doc):
					return
			finally:
				self.leaveLock()


	def enterLock(self):
		'''
		锁定操作界面，防止重入
		'''
		self.setEnabled(False)

	def leaveLock(self):
		self.setEnabled(True)

	def onBtnReadDirClick(self):
		path = QFileDialog.getExistingDirectory(self,u'选择订单目录',
		                                        self.props['doc_readdir'].decode('utf-8'))
		if not path:
			return
		self.edtReadDocDir.setText(path)

	def onBtnDocQueryClick(self):
		'''
		查询订单
		'''
		cr = self.db.handle().cursor()
		sql = "select * from core_document where  status=0  "
		type = self.cbxDocQueryTypes.itemData(self.cbxDocQueryTypes.currentIndex()).toInt()[0]

		if type == INV_QT_BY_INVCODE:
			field="inv_code "
		elif type == INV_QT_BY_INVNUMBER:
			field="inv_number "
		elif type == INV_QT_BY_CUSTNAME:
			field= "cust_name  "
		elif type == INV_QT_BY_CUSTTAXCODE:
			field= "cust_tax_code "
		elif type == INV_QT_BY_DOCNR:
			field = 'doc_nr'

		text = self.edtDocFilterText.text().toUtf8().data().strip()
		params=()
		if type !=0 :
			sql += " and %s like '%%%s%%' " %(field,text)
#			params = (text,)

		sql+=" order by doc_nr desc"
#		print sql
		self.tvDocMain.clear()
		self.tvDocGoods.clear()

		self.idxdata_doc = {}
		cr.execute(sql,params)

		rs = fetchallDict(cr)
		nr = 1

		for r in rs:
			invtype = '专用发票'
			if r['inv_type'] !='1': #  0 - 普通 ； 1 - 专用
				invtype = '普通发票'

#			r['inv_amount'] = self.db.decrypt_s(r['inv_amount'])
			memo = r['memo'].replace('\n',' ')
			row = ( str(nr),
			        r['doc_nr'],
			        invtype,
			        r['cust_name'],
			        r['cust_tax_code'],
			        r['cust_address_tel'],
			        r['cust_bank_account'],
#			        r['taxitem'],
#			        r['memo']
					memo
			)
			row = map(lambda  x:x.decode('utf-8'),row)
			ti = QTreeWidgetItem(row )
			self.tvDocMain.addTopLevelItem(ti)
			self.idxdata_doc[ti] = r['doc_nr']
			nr+=1



	def onBtnDocDelClick(self):
		tis = self.tvDocMain.selectedItems()
		if not tis:
			QMessageBox.about(self,u'提示',u'请选择订单记录!')
			return
		ti = tis[0]
		doc_nr = self.idxdata_doc.get(ti)
		if not doc_nr:
			return

		doc = TaxDocument.from_db(self.db.handle(),doc_nr)
		if not doc:
			return

		if QMessageBox.No == QMessageBox.question(self,u'提示',u'是否确定删除!',QMessageBox.Yes|QMessageBox.No,QMessageBox.No):
			return

		doc.delete(self.db.handle())

		idx = self.tvDocMain.indexOfTopLevelItem(ti)
		self.tvDocMain.takeTopLevelItem(idx)
		del self.idxdata_doc[ti]

		self.onBtnDocQueryClick()





	def onBtnExportClick(self):
#

		QMessageBox.about(self,u'提示',u'共计: %s 张发票成功导入到[%s]目录!'%(len(invoices),expdir))


	def onTreeItemClick_DocMain(self,ti,col):
		doc_nr= self.idxdata_doc[ti]
		self.tvDocGoods.clear()
		sql = "select b.* from core_document a,core_documentitem b " \
		      "where a.status=0 and a.doc_nr = b.doc_nr and a.doc_nr=?" # inv_code=? and inv_number=?"
		cr = self.db.handle().cursor()
#		print sql
		cr.execute(sql,(doc_nr,))
		rs = fetchallDict(cr)
		nr = 1
		for r in rs:


			flag_tax = '含税'
			if r['flag_tax'] != '1':
				flag_tax = '不含税'

#			amount = float(r['qty'])*float(r['price'])
#			amount = round(amount,2)
			row = ( str(nr),
			        doc_nr,
			        r['item_name'],
#			        r['taxitem'],
			        r['spec'],
			        r['unit'],
			        r['qty'],
#			        r['price'],
			        r['amount'],
			        r['taxrate'],
#			        r['tax'],
			        flag_tax
			)
			row = map(lambda  x:str(x).decode('utf-8'),row)

			ti = QTreeWidgetItem(row )
			self.tvDocGoods.addTopLevelItem(ti)
			nr+=1
		self.tvDocGoods.resizeColumnToContents(0)



	def onTreeItemClick_DocGoods(self,ti,col):
		pass


	def onBtnInvQueryClick(self):

		start = self.edtInvStart.text().toUtf8().data()
		end = self.edtInvEnd.text().toUtf8().data()

		cr = self.db.handle().cursor()
		sql = "select * from core_invoice where date(inv_date) between date(?) and date(?) "
		type = self.cbxInvQueryTypes.itemData(self.cbxInvQueryTypes.currentIndex()).toInt()[0]
		if self.ckInvCanceled.checkState() :
			sql +=' and flag_zf=1 '

		if type == INV_QT_BY_INVCODE:
			field="inv_code "
		elif type == INV_QT_BY_INVNUMBER:
			field="inv_number "
		elif type == INV_QT_BY_CUSTNAME:
			field= "cust_name  "
		elif type == INV_QT_BY_CUSTTAXCODE:
			field= "cust_tax_code "
		elif type == INV_QT_BY_DOCNR:
			field = 'doc_nr'

		text = self.edtInvFilterText.text().toUtf8().data().strip()

		params = (start,end)
		if type !=0 :
			sql += " and %s like '%%%s%%' "%(field,text)
#			sql += " and %s like '%%\?%%' "%field
#			sql = sql%text
			params = (start,end)

		sql+=" order by date(inv_date) desc,inv_type,inv_number desc"
#		print sql

		self.tvInvMain.clear()
		self.tvInvGoods.clear()
		self.idxdata_inv = {}

		cr.execute(sql,params)
		rs = fetchallDict(cr)
		nr = 1

		for r in rs:
			invtype = '专用发票'
			if r['inv_type'] !='1':
				invtype = '普通发票'

			status = '正常'
			if r['flag_zf']:
				status = '已作废'
			memo = r['memo'].replace('\n',' ')
			row = ( str(nr),
			        r['doc_nr'],
			        status,
			        invtype,
					r['inv_code'],
			        r['inv_number'],
			        r['cust_name'],
			        r['cust_tax_code'],
			        r['cust_address_tel'],
			        r['cust_bank_account'],
			        r['inv_date'],
			        r['inv_amount'],
			        r['inv_taxrate'],
			        r['inv_tax'],
			        # r['goods_name'],
#			        r['taxitem'],
#			        r['memo']
					memo
					)
			row = map(lambda  x:x.decode('utf-8'),row)
			ti = QTreeWidgetItem(row )
			self.tvInvMain.addTopLevelItem(ti)
			self.idxdata_inv[ti] = (r['inv_code'],r['inv_number'])
			nr+=1

	def onBtnInvCancelClick(self):
		'''
			发票作废
		'''

		tis = self.tvInvMain.selectedItems()
		if not tis:
			QMessageBox.about(self,u'提示',u'请选择发票记录!')
			return
		ti = tis[0]

		code,number = self.idxdata_inv.get(ti)
		inv = TaxInvoice.from_db(self.db.handle(),code,number)
		if not inv:
			QMessageBox.about(self,u'提示',u'发票记录不存在!')
			return
#		if '1'== utils.SimpleConfig().load('system.conf').get('inv_cancel_mode'):
			#调用开票程序的作废接口
#			QMessageBox.about(self,u'提示',u'准备作废...!')
#			pass
		if inv.flag_zf:
			QMessageBox.about(self,u'提示',
			                  u'发票记录:%s,%s 已作废，不允许再次作废!'%(code,number))
			return

		if QMessageBox.No == QMessageBox.question(self,u'提示',
		                                          u'是否确定作废发票:%s,%s？'%(code,number),
		                                          QMessageBox.Yes|QMessageBox.No,
		                                          QMessageBox.No):
			return

		number = '0'*8+number
		number=number[-8:]
		print code,number

		self.enterLock()
		rc,emsg = taxctrl.invoice_cancel(code,number)
		self.leaveLock()
		if not rc:
			QMessageBox.about(self,u'提示',emsg)
			return
		if not inv.cancel(self.db.handle()):
			QMessageBox.about(self,u'提示',u'数据库写入错误，操作失败!')
			return
		self.updateUnupload()
		QMessageBox.about(self,u'提示',u'发票:%s,%s作废成功!'%(code,number))


	def onBtnInvPrintClick(self):
		tis = self.tvInvMain.selectedItems()
		if not tis:
			QMessageBox.about(self,u'提示',u'请选择发票记录!')
			return
		ti = tis[0]
		code,number = self.idxdata_inv[ti]
		inv = TaxInvoice.from_db(self.db.handle(),code,number)
		if not inv:
			QMessageBox.about(self,u'提示',u'发票记录不存在!')
			return
#		if inv.flag_dy == 1:
#			QMessageBox.about(self,u'提示',u'此发票已打印，不能再次打印!')
#			return
		if QMessageBox.No == QMessageBox.question(self,u'提示',
		                                          u'是否确定要打印发票:%s,%s？'%(code,number),
		                                          QMessageBox.Yes|QMessageBox.No,
		                                          QMessageBox.No):
			return
		self.enterLock()
		rc,emsg = taxctrl.invoice_print(inv)
		self.leaveLock()
		if not rc:
			QMessageBox.about(self,u'提示',emsg)
			return
		QMessageBox.about(self,u'提示',u'发票:%s,%s打印成功!'%(code,number))


	def onBtnInvExportClick(self):
#		tis = self.tvInvMain.selectedItems()
#		if not tis:
#			QMessageBox.about(self,u'提示',u'请选择发票记录!')
#			return
		invoices=[]
		for ti in self.idxdata_inv.keys():
			code,number = self.idxdata_inv[ti]
			inv = TaxInvoice.from_db(self.db.handle(),code,number)
			if not inv:
				return
#			if inv.flag_zf =='1':
#				continue #作废票不用导出
			invoices.append(inv)
		if not invoices:
			return
		file = QFileDialog.getSaveFileName(self,u'选择导出文件',self.last_impdir,u'开票文件(*.xls)')
		if not file:
			return
		#生成输出文件
		file = file.toUtf8().data().decode('utf-8')
		try:
			self.export_xls(invoices,file)
			QMessageBox.about(self,u'提示',u'发票导出okay,文件:%s!'%file)
		except:
			traceback.print_exc()
			QMessageBox.about(self,u'提示',u'发票导出失败!')

	def export_xls(self,invoices,file):
		'''
			file - unicode
		'''
		import xlwt
		hdr=u'作废标志 发票种类 单据号 发票代码 发票号码 客户编号 客户名称 客户税号 客户地址电话 客户银行及帐号 开票日期 备注 开票人 收款人 复核人 销方银行及帐号 销方地址电话 商品编号 商品名称 规格型号 计量单位 数量 金额（含税） 税率 税额 折扣金额(含税) 折扣税额'
		hdr=u'作废标志 发票种类 单据号 发票代码 发票号码 客户编号 客户名称 客户税号 客户地址电话 客户银行及帐号 开票日期 备注 开票人 收款人 复核人 销方银行及帐号 销方地址电话 商品编号 商品名称 规格型号 计量单位 数量 金额（含税） 税率 税额'
		wbk = xlwt.Workbook()
		sheet = wbk.add_sheet('sheet 1')
		#写表头
		fs = hdr.split(u' ')
		c = 0
		for f in fs:
			sheet.write( 0,c,f)
			c+=1
		r = 1
		for inv in invoices:
			for item in inv.items:
				zf = u'是'
				if not inv.flag_zf:
					zf = u'否'
				inv_type = u'普票'
				if inv.inv_type =='1':
					inv_type=u'增票'

#				amount = float(item.qty)*float(item.price)*(1+float(item.taxrate))
#				amount = round(amount,2)
#				print amount
				doc_nr = inv.doc_nr.decode('utf-8').split('.')[0]

				values=[
						zf,inv_type,
						#inv.doc_nr.decode('utf-8'),
				        doc_nr,
						inv.inv_code.decode('utf-8'),
						inv.inv_number.decode('utf-8'),
						inv.cust_nr.decode('utf-8'),
						inv.cust_name.decode('utf-8'),
						inv.cust_tax_code.decode('utf-8'),
						inv.cust_address_tel.decode('utf-8'),
						inv.cust_bank_account.decode('utf-8'),
						inv.inv_date.decode('utf-8'),
						inv.memo.decode('utf-8'),
						inv.issuer.decode('utf-8'),
						inv.payee.decode('utf-8'),
						inv.checker.decode('utf-8'),
						inv.seller_bankacct.decode('utf-8'),
						inv.seller_address.decode('utf-8'),
						item.item_nr.decode('utf-8'),
						item.item_name.decode('utf-8'),
						item.spec.decode('utf-8'),
						item.unit.decode('utf-8'),
						str(item.qty),
#						str(item.price),
						str(item.amount),
						str(item.taxrate),
						str(item.tax)
						#'',
						#''
						]
				for c in range(len(values)):
					sheet.write(r,c,values[c] )
				r+=1
		# print file
		# print file.encode('gbk')
		wbk.save(file)



	def initData(self):
		import utils
		self.idxdata_inv={}
		self.idxdata_doc={}
		self.last_impdir=u''

		t = False
		if utils.SimpleConfig().load('system.conf').get('debug')=='1':
			t = True

		self.btnResetClear.setVisible(t)
		self.btnInvPrint.setVisible(True)
		self.btnInvRed.setVisible(False)
		self.btnInvCancel.setVisible(True)
		self.btnTodayDoc.setVisible(False)
		self.ckSyncToServer.setVisible(False)


		self.edtInvStart.setText(utils.getToDayStr2())
		#-------------------------------------------------
		#发牌管理界面
		self.cbxInvQueryTypes.addItem(u'------ 全部 ------',INV_QT_BY_ALL)
		self.cbxInvQueryTypes.addItem(u'发票代码',INV_QT_BY_INVCODE)
		self.cbxInvQueryTypes.addItem(u'发票号码',INV_QT_BY_INVNUMBER)
		self.cbxInvQueryTypes.addItem(u'客户名称',INV_QT_BY_CUSTNAME)
		self.cbxInvQueryTypes.addItem(u'客户税号',INV_QT_BY_CUSTTAXCODE)
		self.cbxInvQueryTypes.addItem(u'订单编号',INV_QT_BY_DOCNR)

		self.tvInvMain.setHeaderLabels([
			u'序号',
		    u'订单编号',
		    u'发票状态',
			u'发票种类',
			u'发票代码',u'发票号码',
			u'客户名称',u'客户税号',u'客户地址',u'客户银行及账号',
			u'开票日期',u'开票金额',u'税率',u'税额',
		    u'备注信息',
		    u'',
		])
		#self.listRecords.setHorizontalHeaderLabels(['a','b'])
		self.tvInvMain.resizeColumnToContents(0)


		self.tvInvGoods.setHeaderLabels([
			u'序号',
#		    u'商品编号',
			u'商品名称',
			#u'商品税目',
			u'商品规格',
			u'计量单位',
			u'数量',
#			u'单价',
			u'金额',
#			u'税率',
#			u'税额',
			u'是否含税'
			])
		#self.listRecords.setHorizontalHeaderLabels(['a','b'])
		self.tvInvGoods.resizeColumnToContents(0)

		now = datetime.datetime.now()
		text ='%04d-%02d-%02d'%(now.year,now.month,now.day)
		self.edtInvStart.setText(text)
		self.edtInvEnd.setText(text)
		#--------------------------------------------------
		#订单管理界面
		self.cbxDocQueryTypes.addItem(u'------ 全部 ------',INV_QT_BY_ALL)
		self.cbxDocQueryTypes.addItem(u'客户名称',INV_QT_BY_CUSTNAME)
		self.cbxDocQueryTypes.addItem(u'客户税号',INV_QT_BY_CUSTTAXCODE)
		self.cbxDocQueryTypes.addItem(u'订单编号',INV_QT_BY_DOCNR)

		self.tvDocMain.setHeaderLabels([
			u'序号',
			u'订单编号',
			u'发票种类',
			u'客户名称',u'客户税号',u'客户地址',u'客户银行及账号',
#			u'商品税目',
			u'备注信息',u''
		])
		#self.listRecords.setHorizontalHeaderLabels(['a','b'])
		self.tvDocMain.resizeColumnToContents(0)


		self.tvDocGoods.setHeaderLabels([
			u'序号',
		    u'订单编号',
			u'商品名称',
#			u'商品税目',
			u'商品规格',
			u'计量单位',
			u'数量',
#			u'单价',
			u'金额',
			u'税率',
#			u'税额',
			u'是否含税'
		])
		#self.listRecords.setHorizontalHeaderLabels(['a','b'])
		self.tvDocGoods.resizeColumnToContents(0)
		#--------------------------------------------------

#		print self.libfile

		#----------------------------------------------------
		#系统设置--> 参数
		try:
			if os.path.exists(self.confile):
				f = open(self.confile)
				self.props = pickle.load(f)
				f.close()
				self.edtCorpName.setText(QString.fromUtf8(self.props['corpname']))
				self.edtTaxcode.setText(QString.fromUtf8(self.props['taxcode']))
				self.edtAddress.setText(QString.fromUtf8(self.props['address']))
				self.edtBank.setText(QString.fromUtf8(self.props['bank']))
				self.edtBranchNo.setText(QString.fromUtf8(self.props['branch']))
				self.edtServerAddress.setText(QString.fromUtf8(self.props['server_addr']))
				self.edtServerPort.setText(QString.fromUtf8(self.props['server_port']))
				if self.props['is_sync_server']:
					self.ckSyncToServer.setCheckState(2)
				else:
					self.ckSyncToServer.setCheckState(0)
				if self.props['is_doc_autoread']:
					self.ckReadDocAuto.setCheckState(2)
				else:
					self.ckReadDocAuto.setCheckState(0)

				self.edtReadDocDir.setText(QString.fromUtf8(self.props['doc_readdir']))
		except:
			pass

		self.updateUnupload()




	def closeEvent(self,evt):
#		self.quit()
		self.app.quit()


	def evtShowPlayWnd(self):
		v = self.app.getConsoleWnd().isVisible()
		self.app.getConsoleWnd().showWindow(not v )


	
	def onTreeItemClick_InvMain(self,ti,col):
		code,number = self.idxdata_inv[ti]
		self.tvInvGoods.clear()
		sql = "select * from core_invoiceitem where inv_code=? and inv_number=?"
		cr = self.db.handle().cursor()

		cr.execute(sql,(code,number))
		rs = fetchallDict(cr)
		nr = 1
		for r in rs:
			flag_tax = '含税'
			if r['flag_tax'] != '1':
				flag_tax = '不含税'
#			amount = float(r['qty'])*float(r['price'])
#			amount = round(amount,2)
			row = ( str(nr),
#			        r['item_nr'],
			        r['item_name'],
#					r['taxitem'],
			        r['spec'],
			        r['unit'],
			        r['qty'],
#			        r['price'],
			        r['amount'],
#			        r['taxrate'],
#			        r['tax'],
			        flag_tax
					)
			row = map(lambda  x:x.decode('utf-8'),row)
			ti = QTreeWidgetItem(row )
			self.tvInvGoods.addTopLevelItem(ti)
			nr+=1
		self.tvInvGoods.resizeColumnToContents(0)

	def onTreeItemClick_Goods(self,ti,col):
		pass



if __name__=='__main__':
	pass