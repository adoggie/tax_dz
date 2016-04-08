# -*- coding: utf-8 -*-
# playconsole.py
# 播放控制台

from PyQt4 import QtCore
from PyQt4 import QtGui

from PyQt4.QtCore import *
from PyQt4.QtGui import *
import ctypes
from ctypes import *

import sys,threading,time,datetime,traceback,string,json,pickle,os,os.path,urllib
from  ui_invoice_import import *
import win32api

import taxctrl
import taxcache
from dbconn import *

VER='v1.2.0.1'
DELIVER_SERVER = 'http://tax.mniu.net/tax/get'

class MainWindow(QtGui.QMainWindow,Ui_MainWindow):
	def __init__(self,app):
		QtGui.QMainWindow.__init__(self)
		self.setupUi(self)
		self.app = app
		self.db = None
		self.show()

		self.connect(self.btnQuery,SIGNAL('clicked()'),self.onBtnQueryClick)
		self.connect(self.btnExport,SIGNAL('clicked()'),self.onBtnExportClick)

		self.connect(self.btnAddToSelectList,SIGNAL('clicked()'),self.onBtnAddToSelectListClick)
		self.connect(self.btnDel,SIGNAL('clicked()'),self.onBtnDelClick)
		self.connect(self.btnClearAll_SelectList,SIGNAL('clicked()'),self.onBtnClearSelectListClick)
		self.connect(self.btnDel_SelectList,SIGNAL('clicked()'),self.onBtnDelSelectListClick)
		self.connect(self.btnExport_SelectList,SIGNAL('clicked()'),self.onBtnExportSelectListClick)

		self.connect(self.tvMain_SelectList,SIGNAL('itemClicked(QTreeWidgetItem*,int)'),self.onTreeItemClick_MainSelectList)


		self.connect(self.tvMain,SIGNAL('itemClicked(QTreeWidgetItem*,int)'),self.onTreeItemClick_Main)
		self.connect(self.tvGoods,SIGNAL('itemClicked(QTreeWidgetItem*,int)'),self.onTreeItemClick_Goods)
		self.connect(self.btnImportInvoice,SIGNAL('clicked()'),self.onBtnImportInvoiceClick)
		self.connect(self.btnReadLicense,SIGNAL('clicked()'),self.onBtnReadClientLicense)


		self.connect(self.btnImportInvoice_FromServer,SIGNAL('clicked()'),self.onBtnDownloadInvoice)

#		self.initUi()

		self.mtxthis = threading.Lock()
		self.confile = 'client.profile'
		self.libfile = '%s/taximp.dll'%(win32api.GetSystemDirectory())
		self.libfile = 'taximp.dll'
		self.props = {}


		self.clients={}

#		self.invoices={}
		self.initData()
		self.setWindowTitle(u'发票认证 %s'%VER)

	def onBtnSaveProfile(self):

		self.props['corpname'] = self.edtCorpName.text().toUtf8().data().strip()
		self.props['taxcode'] =  self.edtTaxcode.text().toUtf8().data().strip()
		self.props['address'] =  self.edtAddress.text().toUtf8().data().strip()
		self.props['bank'] =  self.edtBank.text().toUtf8().data().strip()
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
		f = open(self.confile,'w')
		pickle.dump(self.props,f)
		f.close()
		self.loadClientLicenses()
		QMessageBox.about(self,u'提示',u'信息写入okay!')


	def onBtnDownloadInvoice(self):
		import json,base64,hashlib
		taxcode = self.props.get('taxcode')
		key = self.props.get('priv_key')
		if not key:
			QMessageBox.about(self,u'提示',u'请检查授权信息!')
			return

		days = self.cbxDownloadTime.itemData(self.cbxDownloadTime.currentIndex()).toInt()[0]
		invoices=[]
		try:
			d = ''
			try:
				print days,type(days)
				params = urllib.urlencode({'taxcode': taxcode, 'days':days})
				f = urllib.urlopen('%s?%s'%(DELIVER_SERVER, params))
				d = f.read() # return arrays of invoice
			except:
				QMessageBox.about(self,u'提示',u'导入失败，网络故障或服务器异常!')
				return

			#print d
			invoices = json.loads(d)
			n = 0
			for inv in invoices: #这里跟外部文件一抹一样的数据
				# inv - {name,digest,content}
				d = base64.decodestring(inv['content'])
				m = hashlib.md5()
				m.update(d)
				digest = m.hexdigest()
				if digest!=inv['digest']:
					raise 'any'


				d = taxctrl.decrypt_des(taxctrl.hash_crypt_text(taxctrl.ENCRYPT_KEY),d)
				d =  taxctrl.rsa_decrypt(key,d)
				#				print d


				inv = pickle.loads(d)
				#				print inv.cust_tax_code
				if inv.cust_tax_code !=taxcode:
					continue
				self.db.addInvoice(inv)
				self.lb_tips.setText(u'已导入第<%s/%s>项发票记录'%(n+1,len(invoices)) )
				self.repaint()
		except:
			QMessageBox.about(self,u'提示',u'导入失败，数据异常!')
			print traceback.format_exc()
			return

		if invoices:
			QMessageBox.about(self,u'提示',u'已从服务器导入 %s 张发票记录!'%len(invoices))
			self.lb_tips.setText(u'已从服务器导入 %s 张发票记录!'%len(invoices))


	def onBtnImportInvoiceClick(self):
#		start = time.strptime( self.edtStartImport.text(),'%Y-%m-%d')
#		start = time.mktime(start)
#		end = time.strptime( self.edtEndImport.text(),'%Y-%m-%d')
#		end = time.mktime(end)
#		if end < start:
#			QMessageBox.about(self,u'提示',u'请正确设置导入发票时间!')
#			return
		taxcode = self.props.get('taxcode')
		key = self.props.get('priv_key')
		if not key:
			QMessageBox.about(self,u'提示',u'请检查授权信息!')
			return

		files = QFileDialog.getOpenFileNames(self,u'选择发票文件',u'',u'开票文件(*.ixe)')
		if files.count() == 0:
			return

		self.lb_tips.setText(u'准备导入 %s 项发票记录...'%files.count())
		self.repaint()
		self.setCursor(QtGui.QCursor(QtCore.Qt.WaitCursor))

		for n in range(files.count()):
			try:
				p1 = os.path.split( files[n].toUtf8().data().split('_')[0] )[-1]
				if p1!=taxcode:
					print 'taxcode:',p1,' not matched'
					continue
				f = open(files[n],'rb')
				d = f.read()
				f.close()
#				print key
				d = taxctrl.decrypt_des(taxctrl.hash_crypt_text(taxctrl.ENCRYPT_KEY),d)
				d =  taxctrl.rsa_decrypt(key,d)
#				print d
				inv = pickle.loads(d)
#				print inv.cust_tax_code
				if inv.cust_tax_code !=taxcode:
					continue
				self.db.addInvoice(inv)

				self.lb_tips.setText(u'已导入第<%s>项发票记录:%s'%(n+1,files[n]) )
				self.repaint()
			except:
				traceback.print_exc()
				QMessageBox.about(self,u'错误',u'文件解析错误! 文件:%s'%files[n])
				self.setCursor(QtGui.QCursor(QtCore.Qt.ArrowCursor))
				return
		self.setCursor(QtGui.QCursor(QtCore.Qt.ArrowCursor))
		if files.count():
			QMessageBox.about(self,u'提示',u'已导入 %s 张发票记录!'%files.count())
			self.lb_tips.setText(u'已导入 %s 张发票记录!'%files.count())


	def formatTimestamp(self,secs):
		try:
			dt = datetime.datetime.fromtimestamp(secs)
			return "%04d%02d%02d%02d%02d%02d"%(dt.year,dt.month,dt.day,dt.hour,dt.minute,dt.second)
		except:
			return ''

	def onBtnExportClick(self):
#		print self.clients
		if not self.props.get('taxcode'):
			QMessageBox.about(self,u'提示',u'无效的用户授权!')
			return

		tis = self.tvMain.selectedItems()
#		print type(tis),tis
		if not tis:
			QMessageBox.about(self,u'提示',u'请选择要导出的发票记录!')
			return
#		if not self.props.get('taxcode'):
#			QMessageBox.about(self,u'提示',u'请设置本地企业税号!')
#			return


		timestr = self.formatTimestamp(time.time())
		filename='RZ00100%s%s.XML'%(self.props['taxcode'],timestr)
		if self.ckSaveToExportDir.checkState() == 0:
			s = QFileDialog.getSaveFileName(self,u'选择输出',filename,u'认证文件(*.xml)')
			if not s:
				return
			filename = s.toUtf8().data().decode('utf-8')
		else:
			expdir = 'exports'
			if not os.path.exists(expdir):
				os.mkdir(expdir)
			filename='exports/RZ00100%s%s.XML'%(self.props['taxcode'],timestr)

		invoices = []

		for ti in tis:
			code,num = self.idxdata[ti]
			inv = self.db.getInvoice(code,num)
#			print inv
			if inv:

				invoices.append(inv)
#		print self.props['name'].decode('utf-8')
		d = taxctrl.exportInvoiceForAuth(invoices,self.props['name'],self.props['taxcode'])
		d = d.decode('utf-8').encode('gbk')
#		print dir(filename)
		f = open(filename,'w')
		f.write(d)
		f.close()
		QMessageBox.about(self,u'提示',u'共计: %s 张发票成功保存到[%s]!'%(len(invoices),filename))



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
			field= "seller_name  "
		elif type == 4:
			field= "seller_taxcode "

		text = self.edtFilterText.text().toUtf8().data().strip()

		params = (start,end)
		if type !=0 :
			sql += " and %s like '%%%s%%' "%(field,text)
#			sql = sql%text
			params = (start,end)

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
			row = ( str(nr),invtype,
			        r['seller_name'],
			        r['seller_taxcode'],
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
		self.cbxQueryTypes.addItem(u'供应商名称',3)
		self.cbxQueryTypes.addItem(u'供应商税号',4)

		self.cbxDownloadTime.addItem(u'近 5 天',5)
		self.cbxDownloadTime.addItem(u'近 15 天',15)
		self.cbxDownloadTime.addItem(u'近 30 天',30)
		self.cbxDownloadTime.addItem(u'近 60 天',60)
		self.cbxDownloadTime.addItem(u'近 120 天',120)
		pass


	def initData(self):
		self.idxdata={}     #{ti:(taxcode,taxnumber)}
		self.selected_invoices={} #{ti:{invoice_fields}}

		self.initTaskList()
		self.tvMain.setHeaderLabels([
			u'序号',
			u'发票种类',
			u'供应商名称',u'供应商税号',
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


		now = datetime.datetime.now()
		text ='%04d-%02d-%02d'%(now.year,now.month,now.day)
		self.edtStart.setText(text)
		self.edtEnd.setText(text)

		#---------------------------------------------------------------
		self.tvMain_SelectList.setHeaderLabels([
#			u'序号',
			u'发票种类',
			u'供应商名称',u'供应商税号',
			u'发票代码',u'发票号码',
			u'客户名称',u'客户税号',u'客户地址',u'客户银行及账号',
			u'开票日期',u'开票金额',u'税率',u'税额',u'主要商品名称',
			u'商品税目',u'备注信息',
			])
		#self.listRecords.setHorizontalHeaderLabels(['a','b'])
		self.tvMain_SelectList.resizeColumnToContents(0)


		self.tvGoods_SelectList.setHeaderLabels([
			u'序号',
			u'商品名称',
			u'商品税目',u'商品规格',
			u'计量单位',u'数量',u'单价',u'税率',
			u'税额',u'是否含税'
		])
		#self.listRecords.setHorizontalHeaderLabels(['a','b'])
		self.tvGoods_SelectList.resizeColumnToContents(0)

		self.db = taxcache.TaxMemDB(self.libfile)

		r = self.loadClientLicense()

	def onBtnAddToSelectListClick(self):
		tis = self.tvMain.selectedItems()
		if not tis:
			return
		for ti in tis:
			code,num = self.idxdata[ti]
			inv = self.db.getInvoice(code,num)
			#			print inv
			if inv:
				existlist = self.selected_invoices.values()
				isexisted = False
				for e in existlist:
					if e.inv_code == inv.inv_code and e.inv_number == inv.inv_number:
						isexisted = True
						break
				if isexisted:
					continue

				invtype = '专用发票'
				if inv.inv_type !='s':
					invtype = '普通发票'

				row = ( invtype,
				        inv.seller_name,
				        inv.seller_taxcode,
				        inv.inv_code,
				        inv.inv_number,
				        inv.cust_name,
				        inv.cust_tax_code,
				        inv.cust_address_tel,
				        inv.cust_bank_account,
				        inv.inv_date,
				        inv.inv_amount,
				        inv.inv_taxrate,
				        inv.inv_tax,
				        inv.goods_name,
				        inv.taxitem,
				        inv.memo
				)
				row = map(lambda  x:x.decode('utf-8'),row)
				ti = QTreeWidgetItem(row )
				self.tvMain_SelectList.addTopLevelItem(ti)
				self.selected_invoices[ti] = inv
		self.lb_invoice_num.setText( '%s'%len(self.selected_invoices))

	def onBtnDelClick(self):
		tis = self.tvMain.selectedItems()

		if not tis:
			return
			#QMessageBox.about(self,u'提示',u'请选择要导出的发票记录!')
			#return
		r = QMessageBox.question(self,u'提示',u'确定删除当前选择的发票记录吗?',QMessageBox.Yes|QMessageBox.No)
		if r!= QMessageBox.Yes:
			return
		for ti in tis:
			code,number = self.idxdata[ti]
			if self.db.deleteInvoice(code,number):
				idx = self.tvMain.indexOfTopLevelItem(ti)
				del self.idxdata[ti]
				self.tvMain.takeTopLevelItem(idx)
		self.onBtnQueryClick()

	def onBtnClearSelectListClick(self):
		self.selected_invoices={}
		self.tvMain_SelectList.clear()
		self.tvGoods_SelectList.clear()
		self.lb_invoice_num.setText( '%s'%len(self.selected_invoices))

	def onBtnDelSelectListClick(self):
		tis = self.tvMain_SelectList.selectedItems()
		if not tis:
			QMessageBox.about(self,u'提示',u'请选择要删除的发票记录!')
			return
		for ti in tis:
			idx = self.tvMain_SelectList.indexOfTopLevelItem(ti)
			self.tvMain_SelectList.takeTopLevelItem(idx)
			del self.selected_invoices[ti]

		#return
		self.tvGoods_SelectList.clear()
		self.lb_invoice_num.setText( '%s'%len(self.selected_invoices))

	def onBtnExportSelectListClick(self):

		if not self.selected_invoices.values():
			return

		if not self.props.get('taxcode'):
			QMessageBox.about(self,u'提示',u'无效的用户授权!')
			return

		timestr = self.formatTimestamp(time.time())
		filename='RZ00100%s%s.XML'%(self.props['taxcode'],timestr)
		if self.ckSaveToExportDir_SelectList.checkState() == 0:
			s = QFileDialog.getSaveFileName(self,u'选择输出',filename,u'认证文件(*.xml)')
			if not s:
				return
			filename = s.toUtf8().data().decode('utf-8')
		else:
			expdir = 'exports'
			if not os.path.exists(expdir):
				os.mkdir(expdir)
			filename='exports/RZ00100%s%s.XML'%(self.props['taxcode'],timestr)

		invoices = self.selected_invoices.values()

		d = taxctrl.exportInvoiceForAuth(invoices,self.props['name'],self.props['taxcode'])
		d = d.decode('utf-8').encode('gbk')
		f = open(filename,'w')
		f.write(d)
		f.close()
		QMessageBox.about(self,u'提示',u'共计: %s 张发票成功保存到[%s]!'%(len(invoices),filename))



	def onTreeItemClick_MainSelectList(self,ti,col):
		'''
		选择发票列表，显示发票明细
		'''
		inv = self.selected_invoices[ti]
		#code,number = self.idxdata[ti]

		self.tvGoods_SelectList.clear()
		nr = 1
		for r in inv.items:
			r.flag_tax = '含税'
			if r.flag_tax == 'False':
				r.flag_tax = '不含税'

			row = ( str(nr), r.item_name,
			        r.taxitem,
			        r.spec,
			        r.unit,
			        r.qty,
			        r.price,
			        r.taxrate,
			        r.tax,
			        r.flag_tax
			)
			row = map(lambda  x:x.decode('utf-8'),row)
			ti = QTreeWidgetItem(row )
			self.tvGoods_SelectList.addTopLevelItem(ti)
			nr+=1
		self.tvGoods_SelectList.resizeColumnToContents(0)


	def onBtnReadClientLicense(self):
		self.loadClientLicense()

	def loadClientLicense(self):


		#load taxcode in dog
		#load encrypt_text in dog
		import taxdog

		dog = taxdog.EncryptDevice()
		if not dog.open():
			QMessageBox.about(self,u'提示',u'加密件打开失败!')
			return False

		taxcode_dog = dog.lic['taxcode']
		crypt_dog = dog.lic['key'][:8]

		self.props ={}

		if not os.path.exists('license'):
			os.mkdir('license')

		files = os.listdir('license')
		for file in files:
			if file.find('.lic') ==-1:
				continue
			try:
				f = open('license/%s'%(file),'rb')
				d = f.read()
				f.close()
				#print 'size:', len(d),'file:',file,d
				d = taxctrl.decrypt_des(taxctrl.hash_crypt_text(taxctrl.ENCRYPT_KEY),d)
				self.props = pickle.loads(d)
				if self.props['type'] !='client':
					continue
				if self.props['taxcode'] != taxcode_dog:
					continue
				# decode priv_key

				self.props['priv_key'] = taxctrl.decrypt_des(taxctrl.hash_crypt_text(crypt_dog),self.props['priv_key'])
#				print self.props.get('name').decode('utf-8')
				self.edtCorpName.setText(QString.fromUtf8(self.props.get('name')))
				self.edtTaxcode.setText(QString.fromUtf8(self.props.get('taxcode')))
#				print self.props
				return True
			except:
				traceback.print_exc()
				self.props ={}
				continue

		QMessageBox.about(self,u'提示',u'读取授权信息失败! \n 请检查授权文件和加密件是否匹配!')
		return False




	def closeEvent(self,evt):
#		self.quit()
		self.app.quit()



	
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