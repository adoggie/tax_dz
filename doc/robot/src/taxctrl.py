# -- coding:utf-8 --

import traceback,os,os.path,sys,time,ctypes,datetime,base64,hashlib
import pickle,win32api,win32con,win32ui



import ctypes
from ctypes import *

ENCRYPT_KEY='#E0~RweT'

#_lib = cdll.LoadLibrary('ffmpeg.dll')
#_lib = windll.LoadLibrary('pojin/2013.3.7/6.15/plugerInterface.dll')
#_lib = windll.LoadLibrary('pojin/2013.3.7/KpPluger_mon_select/06.15/plugerInterface.dll')
_lib = None



_int_types = (c_int16, c_int32)
if hasattr(ctypes, 'c_int64'):
    # Some builds of ctypes apparently do not have c_int64
    # defined; it's a pretty good bet that these builds do not
    # have 64-bit pointers.
    _int_types += (ctypes.c_int64,)
for t in _int_types:
    if sizeof(t) == sizeof(c_size_t):
        c_ptrdiff_t = t

class c_void(Structure):
    # c_void_p is a buggy return type, converting to int, so
    # POINTER(None) == c_void_p is actually written as
    # POINTER(c_void), so it can be treated as a real pointer.
    _fields_ = [('dummy', c_int)]



ERROR_SUCCESS                       = '00000'		#;  #// 成功
ERROR_INVALID_INV_CODE              = '00201'		#;  #// 发票代码不存在
ERROR_BUFFER_TOO_SMALL              = '00202'		#;  #// buffer太小
ERROR_INVALID_SELLER_BANK_ACCOUNT   = '00301'		#;  // 销方银行帐号 不匹配
ERROR_INVALID_PARAMETER             = '00888'		#;  // 参数错误
ERROR_UNKNOWN                       = '00999'		#;
ERROR_PLUGER_UNINITIALIZED          = '10000'		#;  // 未初始化
ERROR_KP_NOT_FIND                   = '10001'		#;  // 开票软件没有运行
ERROR_INJECT_FAIL                   = '10002'		#;  // 注入失败
ERROR_KP_CLOSED                     = '10003'		#;  // 在初始化之后,开票软件被关闭了
ERROR_KP_NOT_LOGGED_IN              = '10004'		#;  // 开票软件未登录
ERROR_RESERVED                      = '20000'		#;  // 预留的,未实现的预留的,未实现的
ERROR_INVEXP_MONTH_NOT_FOUND        = '00401'		#;  // 发票导出月份选择项目不存在

_lib = None 
errmsg= ''
InitPluger = None
FreePluger = None
inv_getinfo_all = None
#增加选择月份的第一个参数 , gbk编码传入
inv_getinfo_all2 = None
inv_getinfo = None
inv_cancel = None
inv_create = None
inv_taxinfo = None
inv_unlock = None
inv_lock = None
inv_close = None
inv_open = None
inv_reset = None

#--------------------------------------------------------------
def init_plugin():
	global InitPluger,FreePluger,inv_getinfo_all
	global inv_getinfo_all2,inv_getinfo
	global inv_cancel
	global inv_create
	global inv_taxinfo
	global inv_unlock
	global inv_lock
	global inv_close
	global inv_open
	global inv_reset
	global _lib,errmsg
	
	try:
		key = None
		try:
			key = win32api.RegOpenKeyEx(win32con.HKEY_LOCAL_MACHINE,u'SOFTWARE\\航天信息\\防伪开票\\版本号',0,win32con.KEY_READ)
		except:		
			key = win32api.RegOpenKeyEx(win32con.HKEY_LOCAL_MACHINE,u'SOFTWARE\\Wow6432Node\\航天信息\\防伪开票\\版本号',0,win32con.KEY_READ)
		#key = win32api.RegOpenKeyEx(win32con.HKEY_LOCAL_MACHINE,r'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\kp.exe',0,win32con.KEY_READ)
		value,type = win32api.RegQueryValueEx(key,'')
		#if not os.path.exists(value):
		#	errmsg = u'无法检测到开票程序kp.exe,"%s"'%value
		#	return False,errmsg
		#
		#info = win32api.GetFileVersionInfo(value, "\\")
		#ms = info['FileVersionMS']
		#ls = info['FileVersionLS']
		#ver = "%d.%d.%d.%d" % (win32api.HIWORD(ms), win32api.LOWORD (ms),
		#							 win32api.HIWORD (ls), win32api.LOWORD (ls))
		vers = value.split('.')
		print 'detected kp.exe:',value
		plugfile = 'lib/%s.%s/plugerInterface.dll'%(vers[0],vers[1])		
		try:
			_lib = windll.LoadLibrary(plugfile)
		except:
			errmsg = u'无法加载开票版本[%s]的插件:\n[ %s ]'%(value,plugfile)
			return False,errmsg	
	
		InitPluger = _lib.InitPluger
		InitPluger.restype = c_int
		InitPluger.argtypes = ()

		FreePluger = _lib.FreePluger
		FreePluger.restype = c_int
		FreePluger.argtypes = ()

		inv_getinfo_all = _lib.inv_getinfo_all
		inv_getinfo_all.restype = c_int
		inv_getinfo_all.argtypes = (c_char_p,POINTER(c_int))

		inv_getinfo_all2 = _lib.inv_getinfo_all2
		inv_getinfo_all2.restype = c_int
		inv_getinfo_all2.argtypes = (c_char_p,POINTER(c_int),c_char_p,c_char_p,c_int)

		#增加选择月份的第一个参数 , gbk编码传入
		inv_getinfo_all2 = _lib.inv_getinfo_all2
		inv_getinfo_all2.restype = c_int
		inv_getinfo_all2.argtypes = (c_char_p,c_char_p,POINTER(c_int),c_char_p,c_char_p,c_int)


		inv_getinfo = _lib.inv_getinfo
		inv_getinfo.restype = c_int
		inv_getinfo.argtypes = (c_int,c_char_p,c_char_p,c_char_p,POINTER(c_int))

		inv_cancel = _lib.inv_cancel
		inv_cancel.restype = c_int
		inv_cancel.argtypes = ()


		inv_create = _lib.inv_create
		inv_create.restype = c_int
		inv_create.argtypes = (c_int,c_int,c_int,c_char_p,c_int,c_char_p,c_char_p,c_char_p,c_char_p,c_char_p)

		inv_taxinfo = _lib.inv_taxinfo
		inv_taxinfo.restype = c_int
		inv_taxinfo.argtypes = [c_int,c_char_p,c_char_p,c_char_p,c_char_p,c_char_p]

		inv_unlock = _lib.inv_unlock
		inv_unlock.restype = c_int
		inv_unlock.argtypes = ()

		inv_lock = _lib.inv_lock
		inv_lock.restype = c_int
		inv_lock.argtypes = ()

		inv_close = _lib.inv_close
		inv_close.restype = c_int
		inv_close.argtypes = ()

		inv_open = _lib.inv_open
		inv_open.restype = c_int
		inv_open.argtypes = ()

		inv_reset = _lib.inv_reset
		inv_reset.restype = None
		inv_reset.argtypes = ()
		return True,plugfile
	except:
		traceback.print_exc()
		errmsg = u'开票软件未安装或系统加载出现异常!'
		return False,errmsg
	
		

CIPHER_TEXT=hashlib.md5('argtypes').hexdigest()[:8]
CRYPT_TEXT_KEY = hashlib.md5('test_create_invoice').hexdigest()[:8]

#__all__ = ['StreamByte_t', 'InitLib', 'Cleanup', 'SeekToTime']

def extport_all_invoices():
	bufsize = 5000*1024
	buf = create_string_buffer(bufsize)
	size = pointer(c_int(len(buf)))
	r = inv_getinfo_all(buf,size)
	print 'size:',size
	print 'data:',buf.value
	print r,size.contents.value
	f = open('exports_1.txt','w')
	f.write(buf.value)
	f.close()


	
from taxdoc import * 
from taxbase import * 

def create_doc():
    doc =  TaxDocument()
    

def test_create_invoice():
    InitPluger()
    doc = create_doc()
    docstr = create_string_buffer(doc.toString())
    
    code = create_string_buffer(40)
    number = create_string_buffer(40)
    date = create_string_buffer(40)
    amount = create_string_buffer(40)
    tax = create_string_buffer(40)
        
    rc = inv_create(TaxConsts.INVOICE_SPECIAIL,
                TaxConsts.TAX_INCLUDE,
                TaxConsts.MODE_CREATE,
                TaxConsts.INVTYPE_NRED,
                docstr,
                len(docstr),
                code,
                number,
                date,
                amount,
                tax
                )
    
    
    FreePluger()
#test_create_invoice()
#sys.exit()

def extport_all_invoices_by_time(start,end,flag=0):
	bufsize = 5000*1024
	buf = create_string_buffer(bufsize)
	size = pointer(c_int(len(buf)))
	
	start = create_string_buffer(start)
	end = create_string_buffer(end)
	
	r = inv_getinfo_all2(buf,size,start,end,flag)
	print r
	print 'size:',size
	print 'data:',buf.value
	print r,size.contents.value
	f = open('exports_times.txt','w')
	f.write(buf.value)
	f.close()
	

def test():
	print InitPluger()
	inv_reset()
	#extport_all_invoices()
	extport_all_invoices_by_time('2013-01-08','2013-02-05',1)

	#print size.contents.value
	#return


	FreePluger()
	return

	for n in range(0):

		#FreePluger()
		code = create_string_buffer(40)
		number = create_string_buffer(40)
		stock = create_string_buffer(40)
		taxcode = create_string_buffer(40)
		limit = create_string_buffer(40)

		r = inv_taxinfo(1,code,number,stock,taxcode,limit)
		print r
		print code.value,number.value,stock.value
		time.sleep(2)
	FreePluger()


def getFlagInt(flag):
	if flag =='False':
		return 0
	return 1

class InvoiceGoodsItem:
	def __init__(self):
		self.inv_type=''        #发票种类
		self.inv_code=''        #类别代码
		self.inv_number=''      #发票号码
		self.sell_nr = ''       #销售单据编号
		self.amount=''          #金额
		self.taxrate=''         #税率
		self.tax=''             #税额
		self.item_name=''       #商品名称
		self.taxitem = ''       #商品税目
		self.spec =''           #规格型号
		self.unit=''            #计量单位
		self.qty=''             #数量
		self.price=''           #单价
		self.flag_tax=''        #含税价标志
		self.flag_1=''          #发票行性质
		self.flag_2=''          #发票明细序号
		self.goods_nr=''        #商品编号
		self.item_nr=''         #单据明细序号

	def parse(self,text):
		fields = text.split('~+f1+~')
		self.inv_type,\
		self.inv_code,\
		self.inv_number,\
		self.sell_nr,\
		self.amount,\
		self.taxrate,\
		self.tax,\
		self.item_name,\
		self.taxitem,\
		self.spec,\
		self.unit,\
		self.qty,\
		self.price,\
		self.flag_tax,\
		self.flag_1,\
		self.flag_2,\
		self.goods_nr,\
		self.item_nr=fields

#		self.flag_tax = getFlagInt(self.flag_tax)

	def hash(self):
		attrs = [s for  s in dir(self) if not s.startswith('__')]
		kvs={}
		for k in attrs:
			kvs[k] = getattr(self, k)
		#kvs = {k:getattr(obj, k) for k in attrs}
		del kvs['hash']
		del kvs['parse']
		return kvs

	def encrypt(self):
		fields = [self.inv_type,\
		self.inv_code,\
		self.inv_number,\
		self.sell_nr,\
		self.amount,\
		self.taxrate,\
		self.tax,\
		self.item_name]
		for n in  range(len(fields)):
			fields[n] = encrypt_des(CIPHER_TEXT,fields[n])
			fields[n] = base64.encodestring(fields[n])
		self.inv_type,\
		self.inv_code,\
		self.inv_number,\
		self.sell_nr,\
		self.amount,\
		self.taxrate,\
		self.tax,\
		self.item_name = fields

	def decrypt(self):
		fields = [self.inv_type,\
		          self.inv_code,\
		          self.inv_number,\
		          self.sell_nr,\
		          self.amount,\
		          self.taxrate,\
		          self.tax,\
		          self.item_name]

		for n in range(len(fields)):
			fields[n] = base64.decodestring(fields[n])
			fields[n] = decrypt_des(CIPHER_TEXT,fields[n])

		self.inv_type,\
		self.inv_code,\
		self.inv_number,\
		self.sell_nr,\
		self.amount,\
		self.taxrate,\
		self.tax,\
		self.item_name = fields

class InvoiceInfo:
	def __init__(self):
		self.inv_type=''            #发票种类
		self.inv_code=''            #类别代码
		self.inv_number=''          #发票号码
		self.client_nr = ''         #开票机号
		self.cust_name=''	        #购方名称
		self.cust_tax_code=''       #  购方税号
		self.cust_address_tel=''    #  购方地址电话
		self.cust_bank_account=''   #  购方银行帐号
		self.crypt_ver=''           #  加密版本号
		self.crypt_text=''          #  密文
		self.inv_date=''            #  开票日期
		self.inv_month=''           #  所属月份
		self.inv_amount=0           #  合计金额
		self.inv_taxrate =0             #  税率
		self.inv_tax = 0            #  合计税额
		self.goods_name=''          #  主要商品名称
		self.taxitem=''         #  商品税目
		self.memo=''                #  备注
		self.issuer=''              #  开票人
		self.payee=''               #  收款人
		self.checker=''             #  复核人
		self.flag_dy=''          #  打印标志
		self.flag_zf=''         #  作废标志
		self.flag_qd=''          #  清单标志
		self.flag_xf=''         #  修复标志
		self.flag_dj =''             #  登记标志
		self.flag_wk =''             #  外开标志

		self.seller_name=''
		self.seller_taxcode = ''
		self.seller_address =  ''
		self.seller_bankacct = ''

		self.isupload = 0 #是否已经被上传

		self.items=[]



	def parse(self,text):
		main,detail = text.split('~+f3+~')

		self.inv_type,\
		self.inv_code,\
		self.inv_number,\
		self.client_nr,\
		self.cust_name,\
		self.cust_tax_code,\
		self.cust_address_tel,\
		self.cust_bank_account,\
		self.crypt_ver,\
		self.crypt_text,\
		self.inv_date,\
		self.inv_month,\
		self.inv_amount,\
		self.inv_taxrate,\
		self.inv_tax,\
		self.goods_name,\
		self.taxitem,\
		self.memo,\
		self.issuer,\
		self.payee,\
		self.checker,\
		self.flag_dy,\
		self.flag_zf,\
		self.flag_qd,\
		self.flag_xf,\
		self.flag_dj,\
		self.flag_wk = main.split('~+f1+~')

#		self.flag_dy = getFlagInt(self.flag_dy)
#		self.flag_zf= getFlagInt(self.flag_zf)         #  作废标志
#		self.flag_qd= getFlagInt(self.flag_qd)          #  清单标志
#		self.flag_xf= getFlagInt(self.flag_xf)         #  修复标志
#		self.flag_dj = getFlagInt(self.flag_dj)             #  登记标志
#		self.flag_wk = getFlagInt(self.flag_wk)

		self.crypt_text = encrypt_des(CRYPT_TEXT_KEY,self.crypt_text)
		self.crypt_text = base64.encodestring(self.crypt_text)

		goods = detail.split('~+f2+~')
		
		for text in goods:
			if not text:
				continue
			item = InvoiceGoodsItem()
			item.parse(text)
			self.items.append(item)

	def hash(self):
		attrs = [s for  s in dir(self) if not s.startswith('__')]
		kvs={}
		for k in attrs:
			kvs[k] = getattr(self, k)
		#kvs = {k:getattr(obj, k) for k in attrs}
		subitems=[]
		for item in self.items:
			subitems.append(item.hash())
		kvs['items'] =  subitems
		del kvs['hash']
		del kvs['parse']
		return kvs

	def encrypt(self):
		fields = [self.inv_type,\
		self.inv_code,\
		self.inv_number,\
		self.client_nr,\
		self.cust_name,\
		self.cust_tax_code,\
		self.cust_address_tel,\
		self.cust_bank_account,\
		self.crypt_ver,\
		self.crypt_text,\
		self.inv_date,\
		self.inv_month,\
		self.inv_amount,\
		self.inv_taxrate,\
		self.inv_tax,\
		self.goods_name]
		for n in range(len(fields)):
			fields[n] =encrypt_des(CIPHER_TEXT,fields[n])
			fields[n] = base64.encodestring(fields[n])
		self.inv_type,\
		self.inv_code,\
		self.inv_number,\
		self.client_nr,\
		self.cust_name,\
		self.cust_tax_code,\
		self.cust_address_tel,\
		self.cust_bank_account,\
		self.crypt_ver,\
		self.crypt_text,\
		self.inv_date,\
		self.inv_month,\
		self.inv_amount,\
		self.inv_taxrate,\
		self.inv_tax,\
		self.goods_name = fields

		for item in self.items:
			item.encrypt()

	def decrypt(self):
		fields = [self.inv_type,\
		          self.inv_code,\
		          self.inv_number,\
		          self.client_nr,\
		          self.cust_name,\
		          self.cust_tax_code,\
		          self.cust_address_tel,\
		          self.cust_bank_account,\
		          self.crypt_ver,\
		          self.crypt_text,\
		          self.inv_date,\
		          self.inv_month,\
		          self.inv_amount,\
		          self.inv_taxrate,\
		          self.inv_tax,\
		          self.goods_name]

		for n in range(len(fields)):
			fields[n] = base64.decodestring(fields[n])
			fields[n] =decrypt_des(CIPHER_TEXT,fields[n])

		self.inv_type,\
		self.inv_code,\
		self.inv_number,\
		self.client_nr,\
		self.cust_name,\
		self.cust_tax_code,\
		self.cust_address_tel,\
		self.cust_bank_account,\
		self.crypt_ver,\
		self.crypt_text,\
		self.inv_date,\
		self.inv_month,\
		self.inv_amount,\
		self.inv_taxrate,\
		self.inv_tax,\
		self.goods_name = fields

		for item in self.items:
			item.decrypt()

def encrypt_des(key,text):
	from Crypto.Cipher import DES
	import base64
	from Crypto import Random
	#iv = Random.get_random_bytes(8)
	des = DES.new(key, DES.MODE_ECB)
	reminder = len(text)%8
	if reminder ==0:  # pad 8 bytes
		text+='\x08'*8
	else:
		text+=chr(8-reminder)* (8-reminder)
	#text+=' '*(8-len(text)%8)
	return des.encrypt(text)
	#return base64.encodestring(des.encrypt(text))

def decrypt_des(key,text):
	from Crypto.Cipher import DES
	import base64
#	print key
	des = DES.new(key, DES.MODE_ECB)
	text = des.decrypt(text)
	pad = ord(text[-1])
	if pad == '\x08':
		return text[:-8]
	return text[:-pad]


def rsa_generate():
	from Crypto.PublicKey import RSA
	from Crypto import Random
	random_generator = Random.new().read
	key = RSA.generate(1024, random_generator)


	#print key.publickey().encrypt('123213213123213213',20)
	public =  key.publickey().exportKey()
	#print key.publickey().exportKey()
	private = key.exportKey()
	return public,private

def rsa_encrypt(key,text):
	import uuid
	from Crypto.PublicKey import RSA
	deskey = hashlib.md5(uuid.uuid1().hex).hexdigest()[:8]
	text = encrypt_des(deskey,text)

	key = RSA.importKey(key)
	r = key.encrypt(deskey,32)

	return r[0]+text # 加密的key，和des加密的数据

def rsa_decrypt(key,text):
	from Crypto.PublicKey import RSA
	try:
		rsa = RSA.importKey(key)
		deskey = text[:128]
		text = text[128:]
		deskey = rsa.decrypt(deskey)
		return decrypt_des(deskey,text)
	except:
		return ''

#def rsa_decrypt(key,text):
#	from Crypto.PublicKey import RSA
#	key = RSA.importKey(key)
#
#	chunksize = (key.size()+1) //8
#
#	#print 'text size',len(text)
#	if len(text)% chunksize:
#		return ''
#
#	p =0
#	result=''
#	while p< len(text):
#		s = key.decrypt(text[p:p+chunksize])
#		p+=chunksize
#		result+=s
#
#	text = result
#
#	pad = ord(text[-1])
#	if pad == '\xff':
#		return text[:-chunksize]
#	text = text[:-pad]
#
#	return base64.decodestring(text)
#
##!!! 加密字符串 encrypt(text), text 必须是plaintext !!!!1切记
##所以在这里进行base64编码
#def rsa_encrypt(key,text):
#	from Crypto.PublicKey import RSA
#	key = RSA.importKey(key)
#
#	text = base64.encodestring(text)
#
#	chunksize = (key.size()+1) //8
#	p = 0
#	size = len(text)
#	result=''
#	reminder = len(text)%chunksize
#	if reminder ==0:  # pad 8 bytes
#		text+='\xff'*chunksize
#	else:
#		text+=chr(chunksize-reminder)* (chunksize-reminder)
#
#	while p < size:
#		ciphered_text = key.encrypt(text[p:p+chunksize],128)[0]
#		result+=ciphered_text
#		p+=chunksize
#		print 'chunk size:',len(result)
#
#	return result
#
#def rsa_decrypt(key,text):
#	return decrypt_des(hashlib.md5(key).hexdigest()[:8],text)
#
##!!! 加密字符串 encrypt(text), text 必须是plaintext !!!!1切记
##所以在这里进行base64编码
#def rsa_encrypt(key,text):
#	return encrypt_des(hashlib.md5(key).hexdigest()[:8],text)

def hashobject(obj):
	attrs = [s for  s in dir(obj) if not s.startswith('__')]
	kvs={}
	for k in attrs:
		kvs[k] = getattr(obj, k)
	#kvs = {k:getattr(obj, k) for k in attrs}
	return kvs

def parseExportData(data):
	invoices=[]
	try:
#		data = data.decode('gbk').strip().encode('utf-8')
		data = data.decode('gbk')
		invseglist = data.split('~+f4+~')
		for text in invseglist:
			try:
				inv = InvoiceInfo()
				inv.parse(text)
				invoices.append(inv)
			except:
				#traceback.print_exc()
				print traceback.format_exc()
	except:
		#traceback.print_exc()
		print traceback.format_exc()
	return invoices

#	text = invoices[0].crypt_text
#	crypt_text = encrypt_des('13371337',text)
#	print len(text)
#	print len(crypt_text)
	#text = decrypt_des('13371337',crypt_text)
	#print text ,len(text)

	#print invoices[0].hash()


authImportFormat = '''<?xml version="1.0" encoding="GBK" ?>
<!--DOCTYPE RZ00100 SYSTEM "RZ00100.dtd"-->
<body>
	<head>
	<code>RZ00100</code>
	<title>增值税专用发票抵扣联信息企业采集待认证数据</title>
		<nsr>%s</nsr>
		<qymc>%s</qymc>
		<scrq>%s</scrq>
		<rows>%s</rows>
	</head>
	<data>
	%s
	</data>
</body>
'''

authInvoiceDetail='''
	<row id="%s">
		<dm>%s</dm>
		<hm>%s</hm>
		<gf>%s</gf>
		<xf>%s</xf>
		<kr>%s</kr>
		<je>%s</je>
		<se>%s</se>
		<mw>%s</mw>
		<sy>%s</sy>
		<bb>%s</bb>
	</row>
'''

def exportInvoiceForAuth(invoices,corp_name,tax_code):
	'''
		输出为网上认证的xml格式
	'''
	# invoices - [InvoiceInfo, ]
	dt = datetime.datetime.now()
	dt = "%04d%02d%02d"%(dt.year,dt.month,dt.day)
	nsr = tax_code
	qymc =corp_name
	scrq = dt
	rows = len(invoices)

	id = 1
	body=''
	for inv in invoices:
		dm = inv.inv_code
		hm = inv.inv_number.strip()
		if len(hm)<8:
			hm = '0'*(8-len(hm)) + hm
		gf = tax_code
		xf = inv.seller_taxcode
		#开票日期格式 yyyymmdd
		kr =  inv.inv_date
		ymd = kr.split('-')
		if len(ymd) == 3:
			kr = '%s%s%s'%(ymd[0],ymd[1],ymd[2])
		je = inv.inv_amount
		se = inv.inv_tax		
		mw = inv.crypt_text
		mw = base64.decodestring(mw)		
		mw = decrypt_des(CRYPT_TEXT_KEY,mw)
		#inv.crypt_text = base64.decodestring(inv.crypt_text)		
		#inv.crypt_text = decrypt_des(CRYPT_TEXT_KEY,inv.crypt_text)

		mw = mw.replace('&','&amp;').replace('<','&lt;')
		sy = ''
		bb = inv.crypt_ver
		item = authInvoiceDetail%(id,dm,hm,gf,xf,kr,je,se,mw,sy,bb)
		body+=item
		id+=1

	result = authImportFormat%(nsr,qymc,scrq,rows,body)
	return result

#读入供应商加密的发票记录文件
def importInvoiceForAuth(text,priv_key):
	inv = None
	try:
		key = hash_crypt_text(ENCRYPT_KEY)
		text = decrypt_des(key,text)
		d = rsa_decrypt(priv_key,text)
		inv = pickle.loads(d)
	except:
		inv = None
	return inv

def encryptInvoices(invoices):
	for inv in invoices:
		inv.encrypt()

def decryptInvoices(invoices):
	for inv in invoices:
		inv.decrypt()


taxwin = None
def tax_init():
	r = InitPluger()	
	if r!=0:
		return False
	#inv_reset()
	#inv_lock()
	
	global taxwin
	taxwin = win32ui.FindWindow(None,u'增值税防伪税控系统防伪开票子系统'.encode('gbk'))
	if taxwin:
		#taxwin.ShowWindow(win32con.SW_SHOW)
		pass
	return True

def tax_clear():
	#inv_unlock()
	FreePluger()
	
	global taxwin	
	#if taxwin:
	#	taxwin.ShowWindow(win32con.SW_RESTORE)
	return

#导出指定时间范围的发票信息
def extport_invoices(start,end,flag=0):
	
	inv_reset()
	invoices = []

	y = int(start.split('-')[0])
	now = datetime.datetime.now()
	m = int(start.split('-')[1])
	if now.year == y: #输入年份等于当年
		mon = u'本年%d月'%m
	elif now.year - y == 1: #上一年
		mon = u'上年%d月'%m
	else:
		return []
	#mon = u'全年度数据'
	#mon = u'本年1月'
	
	
	bufsize = 4*1024*1024
	buf = None
	size = None
	r = 202
	start = create_string_buffer(start)
	end = create_string_buffer(end)

	
	print mon
	while r == 202:
		bufsize*=2
		buf = create_string_buffer(bufsize)
		size = pointer(c_int(len(buf)))
		#r = inv_getinfo_all2(buf,size,start,end,flag)
		r = inv_getinfo_all2(mon.encode('gbk'),buf,size,start,end,flag)

	if r!=0:
		print r
		return []
	invoices = parseExportData(buf.value)
	return invoices

def getfiledigest(file,bufsize=1024*5,type='md5'):
	import md5
	m = md5.new()
	try:
		fp = open(file,'rb')
		while True:
			data = fp.read(bufsize)
			if not data:break
			m.update(data)
	except:
		traceback.print_exc()
		return ''
	return m.hexdigest()

#供应商生成发票给客户
# 供应商taxcode_客户税号_YYYY-MM-DD_taxcode_taxnumber.ixe
def exportInvoiceForClient(pub_key,provider_taxcode,inv,outdir='exports'):
	try:
		if not os.path.exists(outdir):
			os.mkdir(outdir)

		d = pickle.dumps(inv)
#		print 'export size:',len(d),',',len(pub_key)

		d = rsa_encrypt(pub_key,d)

#		print 'public-key:',len(d)
		key = hash_crypt_text(ENCRYPT_KEY)
		d = encrypt_des(key,d)


		file = u'%s/%s_%s_%s_%s_%s.ixe'%(outdir,inv.cust_tax_code,provider_taxcode,
				inv.inv_date,inv.inv_code,inv.inv_number
				)
#		print file
		f = open(file,'wb')
		f.write(d)
		f.close()
#		print 'export size_2:',len(d)
	except:
		traceback.print_exc()
		return False
	return True

def exportInvoiceForClient2(pub_key,provider_taxcode,inv):
	try:
		import hashlib,base64

		d = pickle.dumps(inv)
		d = rsa_encrypt(pub_key,d)
		key = hash_crypt_text(ENCRYPT_KEY)
		d = encrypt_des(key,d)
		name = '%s_%s_%s_%s_%s.ixe'%(inv.cust_tax_code,provider_taxcode,
		                                 inv.inv_date,inv.inv_code,inv.inv_number
		)
		m = hashlib.md5()
		m.update(d)
		digest = m.hexdigest()
		return (name,digest,base64.encodestring(d),inv.inv_code,inv.inv_number)
	except:
		#traceback.print_exc()
		return ()


def hash_crypt_text(key):
	return hashlib.md5(key).hexdigest()[:8]

def gen_key():
	pub,priv = rsa_generate()
	print pub,'\n',priv
#	d = rsa_encrypt(pub,'123456')
#	print rsa_decrypt(priv,d)

if __name__=='__main__':
	pub_key ='''-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCWEMTdAPU6nPhBCfGaCJmN4oIQ
/L9Qxjdm9csTqRMDJVR5pk0BNxVAruFFKPnvYKeWczx815TUBBdMTYkS3iuZWHoF
EsoBu+LAgdr1ZXPiw0zKVTlG+tfEJQICiYClu0xniNhEY9oPO8kGKoP1wdX3GuYK
dYOQLg4OzQWYE6sMxwIDAQAB
-----END PUBLIC KEY-----'''


	priv_key='''-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQCWEMTdAPU6nPhBCfGaCJmN4oIQ/L9Qxjdm9csTqRMDJVR5pk0B
NxVAruFFKPnvYKeWczx815TUBBdMTYkS3iuZWHoFEsoBu+LAgdr1ZXPiw0zKVTlG
+tfEJQICiYClu0xniNhEY9oPO8kGKoP1wdX3GuYKdYOQLg4OzQWYE6sMxwIDAQAB
AoGBAIMYOyJmR9Tgc+89ZJaPlLVifwWgBvHld1i2uKWAOl+xKM7s/LBnEmXjYGAu
n8kCwuSn3tug6R8eQ8wgn/Kfq61/sEfTl7G07P/toUTR41hnmkESLsCj/DW+B45E
qhJlVU5BInfhTKHo/GJHSJJM4qzGnFpvzboRcxJ+OWjkUoahAkEAuc2xgH4SZzkH
3xp2v45xVKpJ+OXuGZdlctLy1+hKN1RtFoXrD8P8sDBNfFjJ0g9+3qIU31HcuvXn
Kk25MCJVBQJBAM7CnUeSXQ68MYhB9Ze2SShwWLSusgdPB1BOhWrWVguLblX8vibn
gFJDH4HsmZH+1qGQ2IoVrvIvnw22NhMTxFsCQAJYOSQw8xSAYLwM/nCeYIm7+GD+
rcl+4pXXWZ8l3EHke9fr6rJxO7ARe/jUuf8/mM9AZlkHFGz7i2Y6Qtr7o+0CQDnI
0kQKd8+CcSVvqb+4xkFzBJeaq063m4eqKkdtl6aqVS/a7xnYYVicQdYB1fmji0Ck
RqBw5u/wtzcR0ZMLVzkCQDYl+2GunTk3G+SeWxQdQKjggPmyHwiX9UYAOdJs5/vL
vjARuaAJ87jZjS0jB48WPnRNITjbCn9MBncEB7asch4=
-----END RSA PRIVATE KEY-----'''

	r = rsa_encrypt(pub_key,'fauck')

	print rsa_decrypt(priv_key,r)
#	r,msg = init_plugin()
#	print r,msg.encode('gbk')
#
#	sys.exit()
	
#	if tax_init():
#		print 'ok'
#		invs = extport_invoices('2013-03-05','2013-03-06')
#		print len(invs)
#		tax_clear()
	
	sys.exit()
	
#	f = open('exports_times.txt')
#	d = f.read()
#	f.close()
#	invoices = parseExportData(d)
#	sys.exit(0)
	
#	d = exportInvoiceForAuth(invoices,'shanghai quan ge','3100000000001')
#	d = d.decode('utf-8').encode('gbk')
#	f = open('auth.txt','w')
#	f.write(d)
#	f.close()
#	sys.exit()
