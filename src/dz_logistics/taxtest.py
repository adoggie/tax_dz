# -- coding:utf-8 --

import traceback,os,os.path,sys,time,ctypes,datetime,base64,hashlib
import pickle

import taxctrl
import taxcache
import taxbase 

def formatTimestamp():
	try:
		dt = datetime.datetime.now()
		return "%04d%02d%02d %02d:%02d:%02d"%(dt.year,dt.month,dt.day,dt.hour,dt.minute,dt.second)
	except:
		return ''

taxctrl.init_plugin()
db = taxcache.TaxMemDB('system.lib')
doc = taxbase.TaxDocument.from_db(db.handle(),'amao21131511-117')
f = open('invoice.log','w')

for n in range(800):
	r,emsg,code,number,date,amount,tax = taxctrl.create_invoice(doc)
	now = formatTimestamp()
	print r,emsg,code,number,date,amount,tax
	f.write('%s : %s %s %s %s %s %s %s \n'%(now,r,emsg,code,number,date,amount,tax))
	
	time.sleep(2)
	f.flush()
f.close()
taxctrl.freepluger()

