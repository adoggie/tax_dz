# -*- coding: utf-8 -*-
import sys,os
import traceback,threading,time,struct,os,os.path,shutil,distutils.dir_util,array,base64,zlib,struct,binascii
import datetime
import json,hashlib,base64
from django.http import *
from django.db import transaction

from django.shortcuts import render_to_response
# import cipher
import pickle
from tax.core import models as cm

#from dbconn import *

import tax.utils2 as utils


from django.views.decorators.csrf import csrf_exempt




store_path='/home/invoices'
ENCRYPT_KEY='#E0~RweT'
TEST = 0
class ServiceError:
	ERROR_INTERNAL = 999

class WebCallReturn:
	SUCC = 0
	FAILED = 1
	def __init__(self,status = FAILED,
	             ecode= ServiceError.ERROR_INTERNAL ,emsg=''):
		self.status = status
		self.ecode = ecode
		self.emsg = emsg
		self.result ={}
		self.kvs={}

	def assign(self,result):
		self.result = result
		return self

	def httpResponse(self):
		'''
			if jsonp:
				callback_funcName = GET.get('callback')

		'''
		self.kvs['status'] = self.status
		self.kvs['ecode'] = self.ecode
		self.kvs['emsg'] = self.emsg
		if self.result!=None:
			self.kvs['result'] = self.result

		return HttpResponse(json.dumps(self.kvs),mimetype='application/json')

def SuccCallReturn():
	return WebCallReturn(status=WebCallReturn.SUCC,ecode=0)

def FailCallReturn(ecode=ServiceError.ERROR_INTERNAL,emsg=''):
	if not emsg and ecode == ServiceError.ERROR_INTERNAL:
		#emsg = traceback.format_exc()
		print traceback.format_exc()
	return WebCallReturn(ecode=ecode,emsg=emsg)

#@transaction.commit_manually
def save(inv):
	try:
		r = None
		rs = cm.Invoice.objects.filter(inv_code=inv.inv_code,inv_number=inv.inv_number)
		if rs.count():
			r = rs[0]
			print 'invoice matched!'
#			transaction.rollback()
#			return True
		else:
			r = cm.Invoice()
		r.doc_nr = inv.doc_nr
		r.inv_type = int(inv.inv_type)
		r.inv_code = inv.inv_code
		r.inv_number = inv.inv_number
		r.client_nr =inv.client_nr
		r.cust_nr = inv.cust_nr
		r.cust_name = inv.cust_name
		r.cust_tax_code = inv.cust_tax_code
		r.cust_address_tel = inv.cust_address_tel
		r.cust_bank_account = inv.cust_bank_account
		y,m,d = inv.inv_date.split('-')
		y = int(y)
		m = int(m)
		d = int(d)
		r.inv_date = datetime.datetime(y,m,d,12,0,0)
		r.inv_month = inv.inv_month
		r.inv_amount = inv.inv_amount
		r.inv_taxrate = inv.inv_taxrate
		r.inv_tax = inv.inv_tax
		r.uploadtime = datetime.datetime.now()
#		r.taxitem = inv.taxitem
		r.memo = '' #inv.memo 取消备注存储 2014.3.6
		r.issuer = inv.issuer
		r.checker = inv.checker
		r.payee = inv.payee
		#奇怪了, 0 (integer) sqlite读取出来会变成''
		if not inv.flag_dy: inv.flag_dy=0
		if not inv.flag_zf: inv.flag_zf=0
		if not inv.flag_qd: inv.flag_qd=0
		if not inv.flag_xf: inv.flag_xf = 0
		if not inv.flag_dj: inv.flag_dj = 0
		if not inv.flag_wk: inv.flag_wk = 0

		r.flag_dy = int(inv.flag_dy)
		r.flag_zf = int(inv.flag_zf)
		r.flag_qd = int(inv.flag_qd)
		r.flag_xf = int(inv.flag_xf)
		r.flag_dj = int(inv.flag_dj)
		r.flag_wk = int(inv.flag_wk)
		r.seller_name = inv.seller_name
		r.seller_taxcode = inv.seller_taxcode
		r.seller_address = inv.seller_address
		r.seller_bankacct = inv.seller_bankacct
		# r.isuploaded = 1
		r.doc_time = utils.mk_datetime(int(inv.doc_time))
		r.pay_type = int(inv.pay_type)
		#格式化计算日期
		sp = '-'
		print inv.settlement_time
		if inv.settlement_time.find('/')!=-1:
			sp='/'
		y,m,d = inv.settlement_time.split(sp)
		y = int(y)
		m = int(m)
		d = int(d)
		r.settlement_time = datetime.datetime(y,m,d,12,0,0) #以中午12点为基准
		r.save()


#		for item in inv.items:
#			d = cm.InvoiceItem()
#			d.invoice = r
#			# d.inv_code = inv.inv_code,
#			# d.inv_number = inv.inv_number
#			d.item_nr = item.item_nr
#			d.item_name = item.item_name
#			d.taxitem = item.taxitem
#			d.spec = item.spec
#			d.unit = item.unit
#			d.qty = item.qty
#			d.price = item.price
#			d.amount = item.amount
#			d.taxrate = item.taxrate
#			d.tax = item.tax
#			d.flag_tax = item.flag_tax
#			if not item.discount_amount: item.discount_amount = 0
#			if not item.discount_tax: item.discount_tax = 0
#			d.discount_amount = float(item.discount_amount)
#			d.discount_tax = float(item.discount_tax)
#			d.save()
#		transaction.commit()
	except:
#		transaction.rollback()
		traceback.print_exc()
		return False

	return True

class Invoice:
	def __init__(self):
		pass

def unmarshall_object(json_obj):
	inv = Invoice()
	for k,v in json_obj.items():
		setattr(inv,str(k),v)
	return inv


@csrf_exempt
def putInvoice(r):
	try:
		d = r.POST.get('invoices')
		d = base64.decodestring(d)
		invoices = json.loads(d)

		for inv in invoices:
			inv = unmarshall_object(inv)
			if not save(inv):
				return FailCallReturn(emsg='code:%s,number:%s'%(inv.inv_code,inv.inv_number))
	except: # timeout or error
		traceback.print_exc()
		return FailCallReturn(emsg=traceback.format_exc())
	return SuccCallReturn().httpResponse()

