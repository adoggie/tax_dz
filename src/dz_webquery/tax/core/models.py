#--coding:utf-8--
from django.db import models

from datetime import datetime

MAXLEN_TINY= 30
MAXLEN_TINY2 = 50
MAXLEN_SHORT= 80
MAXLEN_SHORT2= 160
MAXLEN_NORMAL = 240
MAXLEN_MEDIUM = 320
MAXLEN_LONG = 480



#已开发票信息
#保留开票时的完整填写记录
class Invoice(models.Model):
	doc_nr = models.CharField(max_length=MAXLEN_TINY,db_index=True)   #订单编号
	inv_type = models.SmallIntegerField()                   #发票种类 1 - 专用 ，0 - 普通发票
	inv_code = models.CharField(max_length=MAXLEN_SHORT)            #类别代码
	inv_number = models.CharField(max_length=MAXLEN_SHORT)          #发票号码
	client_nr =models.CharField(max_length=MAXLEN_SHORT,null=True)  #开票机编号

	cust_nr = models.CharField(max_length=MAXLEN_TINY,null=True,db_index=True)  #客户编码
	cust_name = models.CharField(max_length=MAXLEN_MEDIUM,null=True)    #客户名称
	cust_tax_code= models.CharField(max_length=MAXLEN_TINY2,null=True)   #客户税号
	cust_address_tel = models.CharField(max_length=MAXLEN_MEDIUM,null=True) #客户地址
	cust_bank_account = models.CharField(max_length=MAXLEN_MEDIUM,null=True) #客户银行及账号

	inv_date =  models.DateTimeField(max_length=MAXLEN_TINY,null=True)     #开票日期 2013-1-2
	inv_month =  models.CharField(max_length=MAXLEN_TINY,null=True)     #所属月份
	inv_amount =  models.FloatField(default=0)     #开票金额
	inv_taxrate =  models.FloatField(default=0)   #税率
	inv_tax = models.FloatField(default=0)  #税额

	memo = models.CharField(max_length=MAXLEN_NORMAL,null=True)      #备注信息
	issuer = models.CharField(max_length=MAXLEN_TINY,null=True,db_index=True)       #开票人
	checker = models.CharField(max_length=MAXLEN_TINY,null=True)        #复核人
	payee = models.CharField(max_length=MAXLEN_TINY,null=True)        #收款人
	flag_dy =  models.IntegerField(default = 0,null=True,db_index=True)      #打印标志
	flag_zf =  models.IntegerField(default = 0,null=True,db_index=True)      #作废标志 0 作废 1正常
	flag_qd =  models.IntegerField(default = 0,null=True,db_index=True)      #清单标志
	flag_xf =  models.IntegerField(default = 0,null=True,db_index=True)      #修复标志
	flag_dj =  models.IntegerField(default = 0,null=True,db_index=True)      #登记标志
	flag_wk =  models.IntegerField(default = 0,null=True,db_index=True)       #外开标志

	seller_name = models.CharField(max_length=MAXLEN_NORMAL,null=True)      #销方名称
	seller_taxcode = models.CharField(max_length=MAXLEN_NORMAL,null=True)   #销方税号
	seller_address = models.CharField(max_length=MAXLEN_NORMAL,null=True)   #销售方地址
	seller_bankacct = models.CharField(max_length=MAXLEN_NORMAL,null=True)  #销售方银行及账号
	uploadtime= models.DateTimeField(db_index=True) #记录上传时间
	doc_time = models.DateTimeField(db_index=True)   #开票操作时间 秒 unix timestamp 1970   130099238823
	pay_type = models.IntegerField(default=1)    #支付方式 1 - 现金 ； 2 - 支票  ； 3 - 现金+支票 ; 4 - POS机
	settlement_time = models.DateTimeField(null=True,db_index=True)    #结算时间

class InvoiceItem(models.Model):
	invoice = models.ForeignKey('Invoice',related_name='item_set')
	item_nr = models.CharField(max_length=MAXLEN_TINY,db_index=True)   #商品编号
	item_name = models.CharField(max_length=MAXLEN_SHORT,null=True) #商品名称
	taxitem = models.CharField(max_length=MAXLEN_TINY,null=True) #税项 5001
	spec = models.CharField(max_length=MAXLEN_SHORT,null=True) #商品规格
	unit = models.CharField(max_length=MAXLEN_TINY,null=True) #计量单位
	qty =  models.FloatField() #数量
	price =  models.FloatField() #单价
	amount = models.FloatField() #金额
	taxrate =  models.FloatField(default=0) #税率
	tax =  models.FloatField() #税额
	flag_tax =  models.IntegerField(max_length=MAXLEN_TINY,null=True)	# 0 - 不含税 ； 1 - 含税							#0为不含税价，1为含税价
	discount_amount =  models.FloatField(default=0)  #折扣金额（函数)
	discount_tax =   models.FloatField(default=0)     #折扣税额
