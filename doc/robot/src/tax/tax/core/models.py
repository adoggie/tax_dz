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
	inv_type = models.CharField(max_length=MAXLEN_TINY)                   #发票种类 0 - 专用 ，1 - 普通发票
	inv_code = models.CharField(max_length=MAXLEN_SHORT)            #类别代码
	inv_number = models.CharField(max_length=MAXLEN_SHORT)          #发票号码
	client_nr =models.CharField(max_length=MAXLEN_SHORT,null=True) #开票机编号
	itemcount= models.IntegerField(null=True,default=0)                   #明细行数
	cust_name = models.CharField(max_length=MAXLEN_MEDIUM,null=True)    #客户名称
	cust_tax_code= models.CharField(max_length=MAXLEN_TINY2,null=True)   #客户税号
	cust_address_tel = models.CharField(max_length=MAXLEN_MEDIUM,null=True) #客户地址
	cust_bank_account = models.CharField(max_length=MAXLEN_MEDIUM,null=True) #客户银行及账号
	crypt_ver = models.CharField(max_length=MAXLEN_TINY,null=True)    #加密版本号
	crypt_text = models.TextField(null=True)                  #加密版本号
	inv_date =  models.CharField(max_length=MAXLEN_TINY,null=True)     #开票日期
	inv_month =  models.CharField(max_length=MAXLEN_TINY,null=True)     #所属月份
	inv_amount =  models.CharField(max_length=MAXLEN_TINY,null=True)     #开票金额
	inv_taxrate =  models.CharField(max_length=MAXLEN_TINY,null=True)   #税率
	inv_tax = models.CharField(max_length=MAXLEN_TINY,null=True)  #税额
	goods_name = models.CharField(max_length=MAXLEN_MEDIUM,null=True)    #主要商品名称
	taxitem =  models.CharField(max_length=MAXLEN_SHORT,null=True)      #商品税目
	memo = models.CharField(max_length=MAXLEN_NORMAL,null=True)      #备注信息
	issuer = models.CharField(max_length=MAXLEN_TINY,null=True)       #开票人
	checker = models.CharField(max_length=MAXLEN_TINY,null=True)        #复核人
	payee = models.CharField(max_length=MAXLEN_TINY,null=True)        #收款人
	flag_dy =  models.CharField(max_length=MAXLEN_TINY,null=True)      #打印标志
	flag_zf =  models.CharField(max_length=MAXLEN_TINY,null=True)      #作废标志
	flag_qd =  models.CharField(max_length=MAXLEN_TINY,null=True)      #清单标志
	flag_xf =  models.CharField(max_length=MAXLEN_TINY,null=True)      #修复标志
	flag_dj =  models.CharField(max_length=MAXLEN_TINY,null=True)      #登记标志
	flag_wk =  models.CharField(max_length=MAXLEN_TINY,null=True)       #外开标志

	seller_name = models.CharField(max_length=MAXLEN_NORMAL,null=True)      #销方名称
	seller_taxcode = models.CharField(max_length=MAXLEN_NORMAL,null=True)   #销方税号
	seller_address = models.CharField(max_length=MAXLEN_NORMAL,null=True)   #销售方地址
	seller_bankacct = models.CharField(max_length=MAXLEN_NORMAL,null=True)  #销售方银行及账号


class InvoiceItem(models.Model):
	#invoice = models.ForeignKey('Invoice',related_name='item_set')
	inv_code = models.CharField(max_length=MAXLEN_SHORT)            #类别代码
	inv_number = models.CharField(max_length=MAXLEN_SHORT)
	taxcode = models.CharField(max_length=MAXLEN_TINY2)

	item_name = models.CharField(max_length=MAXLEN_SHORT,null=True) #商品名称
	taxitem = models.CharField(max_length=MAXLEN_TINY,null=True) #税项 5001
	spec = models.CharField(max_length=MAXLEN_SHORT,null=True) #商品规格
	unit = models.CharField(max_length=MAXLEN_TINY,null=True) #计量单位
	qty =  models.CharField(max_length=MAXLEN_TINY,null=True) #数量
	price =  models.CharField(max_length=MAXLEN_TINY,null=True) #单价
	taxrate =  models.CharField(max_length=MAXLEN_TINY,null=True) #税率
	tax =  models.CharField(max_length=MAXLEN_TINY,null=True) #税额
	flag_tax =  models.CharField(max_length=MAXLEN_TINY,null=True)	# 0 - 不含税 ； 1 - 含税							#0为不含税价，1为含税价

