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
from  ui_invoice_export import *
import win32api,json

import taxctrl
import taxcache
from dbconn import *

ENCRYPT_KEY='#E0~RweT'
DELIVER_SERVER = 'http://tax.mniu.net/tax/put'
VER = 'v1.5.0.2'

revisions='''
v1.5.0.1 - 增加上传到服务器

v1.5.0.2
导出发票 类型显示 ，inv_type = 's'

'''

class MainWindow(QtGui.QMainWindow,Ui_MainWindow):
	def __init__(self,app):
		QtGui.QMainWindow.__init__(self)
		self.setupUi(self)
		self.app = app
		self.db = None
		self.show()

		self.connect(self.btnQuery,SIGNAL('clicked()'),self.onBtnQueryClick)
		self.connect(self.btnExport,SIGNAL('clicked()'),self.onBtnExportClick)

		self.connect(self.tvMain,SIGNAL('itemClicked(QTreeWidgetItem*,int)'),self.onTreeItemClick_Main)
		self.connect(self.tvGoods,SIGNAL('itemClicked(QTreeWidgetItem*,int)'),self.onTreeItemClick_Goods)
		self.connect(self.btnImportInvoice,SIGNAL('clicked()'),self.onBtnImportInvoiceClick)
		self.connect(self.btnSave,SIGNAL('clicked()'),self.onBtnSaveProfile)

		self.connect(self.btnUpload,SIGNAL('clicked()'),self.onBtnUploadServerClick)



#		self.initUi()

		self.mtxthis = threading.Lock()
		self.confile = 'local.profile'
		self.libfile = '%s/taxexp.dll'%(win32api.GetSystemDirectory())
		self.libfile = 'taxexp.dll'
		self.props = {'corpname':'',
		              'taxcode':'',
		              'addres':'',
		              'bank':''}


		self.clients={}

#		self.invoices={}
		self.initData()

		self.setWindowTitle(u'发票认证输出 %s'%VER)


	def onBtnSaveProfile(self):

		self.props['corpname'] = self.edtCorpName.text().toUtf8().data().strip()
		self.props['taxcode'] =  self.edtTaxcode.text().toUtf8().data().strip()
		self.props['address'] =  self.edtAddress.text().toUtf8().data().strip()
		self.props['bank'] =  self.edtBank.text().toUtf8().data().strip()
		if len(self.props['corpname']) == 0:
			QMessageBox.about(self,u'提示',u'企业名称不能为空!')
			return
		if len(self.props['taxcode']) != 15:
			QMessageBox.about(self,u'提示',u'税号非法，必须15位长!')
			return

		if len(self.props['address']) == 0:
			QMessageBox.about(self,u'提示',u'地址和电话不能为空!')
			return
		if len(self.props['bank']) == 0:
			QMessageBox.about(self,u'提示',u'银行账号不能为空!')
			return
		f = open(self.confile,'w')
		pickle.dump(self.props,f)
		f.close()
		self.loadClientLicenses()
		QMessageBox.about(self,u'提示',u'信息写入okay!')




	def onBtnImportInvoiceClick(self):
		start = time.strptime( self.edtStartImport.text(),'%Y-%m-%d')
		startsec = time.mktime(start)
		end = time.strptime( self.edtEndImport.text(),'%Y-%m-%d')
		endsec = time.mktime(end)
		if endsec < startsec:
			QMessageBox.about(self,u'提示',u'请正确设置导入发票时间!')
			return
		start = '%04d-%02d-%02d'%(start.tm_year,start.tm_mon,start.tm_mday)
		end = '%04d-%02d-%02d'%(end.tm_year,end.tm_mon,end.tm_mday)
		
		self.lb_tips.setText(u'系统开始处理，请等待...')
		
		if not taxctrl.tax_init():
			QMessageBox.about(self,u'错误',u'处理故障： 请确保已开启【防伪开票子系统】，并显示主界面!')
			return
		print 'export invoice:',start,end
		invoices=[]
		try:
			invoices = taxctrl.extport_invoices(start,end)
		except:
			traceback.print_exc()
		#taxctrl.tax_clear()
		
		print len(invoices)
		
		
		#f = open('exports_times.txt')
		#invoices = taxctrl.parseExportData(f.read())
		#f.close()
		

		# add invoice into db
		cnt = 0
		for inv in invoices:
			#if inv.cust_tax_code not in self.clients.keys():
			#	continue	
			#if inv.flag_zf != 'False':
			#	continue
			self.db.addInvoice(inv)
			cnt+=1

		tip =u'已读取%s条记录!'%cnt
		QMessageBox.about(self,u'提示',tip)
		self.lb_tips.setText(tip)

	def onBtnUploadServerClick(self):
		import urllib

		tis = self.tvMain.selectedItems()
		#		print type(tis),tis
		if not tis:
			QMessageBox.about(self,u'提示',u'请选择要发送的发票记录!')
			return
		if not self.props.get('taxcode'):
			QMessageBox.about(self,u'提示',u'请设置本地企业税号!')
			return


		invoices = []
		cnt = 1
		for ti in tis:
			code,num = self.idxdata[ti]
			inv = self.db.getInvoice(code,num)
			#			print inv
			if inv:
				if not  self.clients.has_key(inv.cust_tax_code.strip()):
					QMessageBox.about(self,u'提示',u'无法获取客户的license信息! \n客户税号:%s \n发票代码: %s\n发票编号:%s'%(inv.cust_tax_code,inv.inv_code,inv.inv_number))
					return

				cltinfo = self.clients[inv.cust_tax_code.strip()]
				inv.seller_name = self.props['corpname']
				inv.seller_taxcode = self.props['taxcode']
				inv.seller_address = self.props.get('address')
				inv.seller_bankacct = self.props.get('bank')
				r = taxctrl.exportInvoiceForClient2(cltinfo['pub_key'],self.props.get('taxcode').strip(),inv)
				if not r:
					QMessageBox.about(self,u'提示',u'操作失败!')
					return
				invoices.append(r)
				#update to server

		for r in invoices:
			try:
				params = urllib.urlencode({'name': r[0], 'digest': r[1], 'content': r[2]})
				#print r[2]
				f = urllib.urlopen('%s?%s'%(DELIVER_SERVER, params))
				d = f.read()
#				print d
#				log = open('c:/debug.html','w')
#				log.write(d)
#				log.close()

				d = json.loads(d)
				if d['status'] != 0:
					QMessageBox.about(self,u'提示',u'发送到服务器失败!')
					return
				#显示发送状态
				self.labStatus.setText(u'已发送第<%s/%s>条记录到服务器..'%(cnt,len(invoices)))
				self.repaint()
				self.db.setUploaded(r[3],r[4])
			except:
				print traceback.format_exc()
				QMessageBox.about(self,u'提示',u'发送到服务器失败!')
				return
			cnt+=1

		QMessageBox.about(self,u'提示',u'共计: %s 张发票成功发送到服务器!'%(len(invoices),))
		#写入上传标记到db


		pass


	def onBtnExportClick(self):
#		print self.clients
		#tis = self.tvMain.selectedItems()
#		print type(tis),tis
		#if not tis:
		#	QMessageBox.about(self,u'提示',u'请选择要导出的发票记录!')
		#	return
		#if not self.props.get('taxcode'):
		#	QMessageBox.about(self,u'提示',u'请设置本地企业税号!')
		#	return
#		expdir = 'exports'
#		if self.ckSaveToExportDir.checkState() == 0:
#			s = QFileDialog.getExistingDirectory(self,u'选择输出目录')
#			if not s:
#				return
#			expdir = s.toUtf8().data().decode('utf-8')
		tis=[]
		for n in range(self.tvMain.topLevelItemCount()):
			ti = self.tvMain.topLevelItem(n)
			tis.append(ti)
		
		if not tis:
			QMessageBox.about(self,u'提示',u'发票记录为空!')
			return
		invoices = []

		
		for ti in tis:
			code,num = self.idxdata[ti]
			inv = self.db.getInvoice(code,num)
#			print inv
			if inv:
#				if not  self.clients.has_key(inv.cust_tax_code.strip()):
#					QMessageBox.about(self,u'提示',u'无法获取客户的license信息! \n客户税号:%s \n发票代码: %s\n发票编号:%s'%(inv.cust_tax_code,inv.inv_code,inv.inv_number))
#					return
#				cltinfo = self.clients[inv.cust_tax_code.strip()]
#				inv.seller_name = self.props['corpname']
#				inv.seller_taxcode = self.props['taxcode']
#				inv.seller_address = self.props.get('address')
#				inv.seller_bankacct = self.props.get('bank')
#				r = taxctrl.exportInvoiceForClient(cltinfo['pub_key'],self.props.get('taxcode').strip(),inv,expdir)
#				if not r:
#					QMessageBox.about(self,u'提示',u'操作失败!')
#					return
				invoices.append(inv)
		if not invoices:
			return
		file = QFileDialog.getSaveFileName(self,u'选择导出文件','',u'开票文件(*.xls)')
		if not file:
			return
		file = file.toUtf8().data().decode('utf-8')
		self.export_xls(invoices,file)
		QMessageBox.about(self,u'提示',u'共计: %s 张发票成功导入到[%s]!'%(len(invoices),file))

	def export_xls(self,invoices,file):
		'''
			file - unicode
		'''
		import xlwt
		hdr=u'作废标志 发票种类 单据号 发票代码 发票号码 客户编号 客户名称 客户税号 客户地址电话 客户银行及帐号 开票日期 备注 开票人 收款人 复核人 销方银行及帐号 销方地址电话 商品编号 商品名称 规格型号 计量单位 数量 金额（含税） 税率 税额'
		hdr=u'作废标志 发票种类 发票代码 发票号码 客户名称 客户税号 客户地址电话 客户银行及帐号 开票日期 备注 开票人 税率 税额 金额'
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
			if True:
				zf = u'是'
				if  inv.flag_zf=='0' or inv.flag_zf=='False':
					zf = u'否'

				inv_type = u'普票'
				if inv.inv_type =='s':
					inv_type=u'增票'

				values=[
					zf,inv_type,
					inv.inv_code.decode('utf-8'),
					inv.inv_number.decode('utf-8'),
					inv.cust_name.decode('utf-8'),
					inv.cust_tax_code.decode('utf-8'),
					inv.cust_address_tel.decode('utf-8'),
					inv.cust_bank_account.decode('utf-8'),
					inv.inv_date.decode('utf-8'),
					inv.memo.decode('utf-8').replace(u'\n',' '),
					inv.issuer.decode('utf-8'),
					inv.inv_taxrate,
				    float(inv.inv_tax),
				    float(inv.inv_amount)
				]
				for c in range(len(values)):
					sheet.write(r,c,values[c] )
				r+=1

		wbk.save(file)


	def onBtnQueryClick(self):
#		ti = self.listRecords.currentItem()
#		if not ti:
#			return
#		if QMessageBox.No == QMessageBox.question(self,u'提示',u'是否确定删除!',QMessageBox.Yes|QMessageBox.No,QMessageBox.No):
#			return

#		start = time.strptime( self.edtStart.text(),'%Y-%m-%d')
#		start = time.mktime(start)
#		end = time.strptime( self.edtEnd.text(),'%Y-%m-%d')
#		end = time.mktime(end)

		start = self.edtStart.text().toUtf8().data()
		end = self.edtEnd.text().toUtf8().data()

		cr = self.db.handle().cursor()
		sql = "select * from core_invoice where date(inv_date) between date(?) and date(?) "
		type = self.cbxQueryTypes.itemData(self.cbxQueryTypes.currentIndex()).toInt()[0]
		print type
		if type == 1:
			field="inv_code "
		elif type == 2:
			field="inv_number "
		elif type == 3:
			field= "cust_name  "
		elif type == 4:
			field= "cust_tax_code "

		text = self.edtFilterText.text().toUtf8().data().strip()

		params = (start,end)
		if type !=0 :
			sql += " and %s like '%%%s%%' "%(field,text)
#			sql = sql%text
			params = (start,end)


		isupload = self.cbxUploadStatus.itemData(self.cbxUploadStatus.currentIndex()).toInt()[0]
		if  isupload in (0,1): #
			sql+= " and isupload=%s "%isupload

		sql+=" order by date(inv_date) desc"
#		print sql
		self.tvMain.clear()
		self.idxdata = {}
		cr.execute(sql,params)
		rs = fetchallDict(cr)
		nr = 1

		for r in rs:
			invtype = '专用发票'
			if r['inv_type'] !='s':
				invtype = '普通发票'

			r['inv_amount'] = self.db.decrypt_s(r['inv_amount'])
			status = '未上传'
			if r['isupload']:
				status = '已上传'
			row = ( str(nr),
			        status,invtype,
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
			        r['goods_name'],
			        r['taxitem'],
			        r['memo']
					)
			row = map(lambda  x:x.decode('utf-8'),row)
			ti = QTreeWidgetItem(row )
			self.tvMain.addTopLevelItem(ti)
			self.idxdata[ti] = (r['inv_code'],r['inv_number'])
			nr+=1




	def initTaskList(self):
		#加载计划任务
		self.cbxQueryTypes.addItem(u'------ 全部 ------',0)
		self.cbxQueryTypes.addItem(u'发票代码',1)
		self.cbxQueryTypes.addItem(u'发票号码',2)
		self.cbxQueryTypes.addItem(u'客户名称',3)
		self.cbxQueryTypes.addItem(u'客户税号',4)

		self.cbxUploadStatus.addItem(u'所有',2)
		self.cbxUploadStatus.addItem(u'已上传',1)
		self.cbxUploadStatus.addItem(u'未上传',0)

		pass


	def initData(self):
		self.idxdata={}
		self.initTaskList()
		self.tvMain.setHeaderLabels([
			u'序号',
		    u'状态',
			u'发票种类',
			u'发票代码',u'发票号码',
			u'客户名称',u'客户税号',u'客户地址',u'客户银行及账号',
			u'开票日期',u'开票金额',u'税率',u'税额',u'主要商品名称',
		    u'商品税目',u'备注信息',
		])
		#self.listRecords.setHorizontalHeaderLabels(['a','b'])
		self.tvMain.resizeColumnToContents(0)


		self.tvGoods.setHeaderLabels([
			u'序号',
			u'商品名称',
			u'商品税目',u'商品规格',
			u'计量单位',u'数量',u'单价',u'税率',
			u'税额',u'是否含税'
			])
		#self.listRecords.setHorizontalHeaderLabels(['a','b'])
		self.tvGoods.resizeColumnToContents(0)

		self.tvClients.setHeaderLabels([u'客户税号',u'客户名称'])
		self.tvClients.resizeColumnToContents(0)

		now = datetime.datetime.now()
		text ='%04d-%02d-%02d'%(now.year,now.month,now.day)
		self.edtStart.setText(text)
		self.edtEnd.setText(text)
		self.edtStartImport.setText(text)
		self.edtEndImport.setText(text)

		self.db = taxcache.TaxMemDB(self.libfile)
#		print self.libfile
		try:
			if os.path.exists(self.confile):
				f = open(self.confile)
				self.props = pickle.load(f)
				f.close()
				self.edtCorpName.setText(QString.fromUtf8(self.props['corpname']))
				self.edtTaxcode.setText(QString.fromUtf8(self.props['taxcode']))
				self.edtAddress.setText(QString.fromUtf8(self.props['address']))
				self.edtBank.setText(QString.fromUtf8(self.props['bank']))
		except:
			pass

		self.loadClientLicenses()


	def loadClientLicenses(self):
		#load license file
		self.clients ={}
		self.tvClients.clear()

		if not self.props.has_key('taxcode'):
			return

		if not os.path.exists('license'):
			os.mkdir('license')
			return

		files = os.listdir('license')
		for file in files:

			if file.find('.lic') ==-1:
				continue
			try:
				f = open('license/%s'%(file),'rb')
				d = f.read()
				f.close()
				#print 'size:', len(d),'file:',file,d
				d = taxctrl.decrypt_des(taxctrl.hash_crypt_text(ENCRYPT_KEY),d)
				d = pickle.loads(d)
				if d['type'] !='provider':
					continue

				if d['provider_taxcode'] != self.props['taxcode']:
					continue
				self.clients[d['taxcode']] = d
			except:
				traceback.print_exc()
				continue

		for code in self.clients.keys():
			client = self.clients[code]
			txt = (client['taxcode'],client['name'].decode('utf-8'))
			ti = QTreeWidgetItem(txt )
			self.tvClients.addTopLevelItem(ti)
		self.tvClients.resizeColumnToContents(0)
#		print self.clients



	def closeEvent(self,evt):
#		self.quit()
		self.app.quit()


	def evtShowPlayWnd(self):
		v = self.app.getConsoleWnd().isVisible()
		self.app.getConsoleWnd().showWindow(not v )


	
	def onTreeItemClick_Main(self,ti,col):
		code,number = self.idxdata[ti]
		self.tvGoods.clear()
		sql = "select * from core_invoiceitem where inv_code=? and inv_number=?"
		cr = self.db.handle().cursor()

		code = self.db.encrypt_s(code)
		number = self.db.encrypt_s(number)

		cr.execute(sql,(code,number))
		rs = fetchallDict(cr)
		nr = 1
		for r in rs:
			r['flag_tax'] = '含税'
			if r['flag_tax'] == 'False':
				r['flag_tax'] = '不含税'

			row = ( str(nr), r['item_name'],
					r['taxitem'],
			        r['spec'],
			        r['unit'],
			        r['qty'],
			        r['price'],
			        r['taxrate'],
			        r['tax'],
			        r['flag_tax']
					)
			row = map(lambda  x:x.decode('utf-8'),row)
			ti = QTreeWidgetItem(row )
			self.tvGoods.addTopLevelItem(ti)
			nr+=1
		self.tvGoods.resizeColumnToContents(0)

	def onTreeItemClick_Goods(self,ti,col):
		pass



if __name__=='__main__':
	pass