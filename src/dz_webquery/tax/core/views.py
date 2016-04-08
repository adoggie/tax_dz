# Create your views here.
#--coding:utf-8--
import traceback
import os,ConfigParser
import xlwt
import datetime
from django.http import HttpResponseRedirect,Http404,HttpResponse
from django.conf import settings
from django.shortcuts import render_to_response
from django.template import Context,RequestContext
from django.db.models import Sum
from tax.utils.pageHandle import devidePage,getPage
from tax.core.models import Invoice,InvoiceItem
from django.core import serializers
import logging
from django.core.urlresolvers import reverse,ViewDoesNotExist
from django.views.decorators.csrf import csrf_exempt
from tax.utils.MyEncoder import getJson
from tax.utils.parseConfig import getConfigValue
logger = logging.getLogger('tax_logger')


def checkLogin(user):
	if user != None:
		return True
	else:
		return False

def requires_login(view):
	def new_view(request, *args, **kwargs):
		user = request.session.get('user')
		if not checkLogin(user):
			return HttpResponseRedirect('/login/')
		else:
			return view(request, *args, **kwargs)
	return new_view

def getUser():
	'''
	从获取配置文件获取用户名和密码
	'''
	try:
		configPath = os.path.join(settings.CONFIG_DIR, 'config.ini').replace('\\','/')
		user = getConfigValue(configPath,"account",'user')
		password = getConfigValue(configPath,"account",'passwd')
		return user,password
	except:
		logger.error(u"cannot get userinfo from the config.ini")
		traceback.print_exc()
		return

def getkhjbh():
	"""
	从配置文件获取客户机编号,list形式,默认为[1,2,3,4,5,6,7,8]
	"""
	khjbhlist = [1,2,3,4,5,6,7,8]
	try:
		configPath = os.path.join(settings.CONFIG_DIR, 'args.txt').replace('\\','/')
		khjbh = getConfigValue(configPath,"template_args",'khjbh')
		khjbhlist = khjbh.split(",")
		try:
			for i in khjbhlist:
				int(i)
		except ValueError,e:
			logger.error(u"khjbh is not correct in args.txt ")
			pass
	except:
		pass
	return khjbhlist
'''
登入系统
'''
def login(request):
	logger.info("signin")
	error = u""
	try:
		if request.method == "POST":
			#验证用户名和密码
			username = request.POST.get("username")
			password = request.POST.get("password")
			userinfo = getUser()
			if username and password and userinfo:
				if username == userinfo[0]:
					if password == userinfo[1]:
						request.session["user"] = userinfo[0]
						return HttpResponseRedirect("/index/")
					else:
					 error = u"密码不正确!"
				else:
					error =u"用户不存在!"
			else:
				error = u"请输入用户名和密码!"
			pass
		else:
			#转到登入窗口
			pass
		context = Context({
			'title':u'登入',
			"error": error,
			})
		return render_to_response("signin.html",context,context_instance=RequestContext(request))
	except ViewDoesNotExist,ve:
		logger.error(ve)
		traceback.print_exc()
		raise Http404()
	except Exception,e:
		traceback.print_exc()
		raise Http404()
'''
登出系统
'''
@requires_login
def logout(request):
	logger.info(u"logout")
	try:
		del request.session['user']
#        return HttpResponse(u"你已安全退出")
		return HttpResponseRedirect('/login/')
	except KeyError:
		#return HttpResponse(u"你尚未登录，无须退出")
		return HttpResponseRedirect('/login/')
@requires_login
def get_invoice2(request,invoice_id=1):
	'''
	    根据查询条件获取发票信息
	'''
	perPageCount = 10
	get = 1
	try:
		if request.method == "GET":
			currentPage = int(request.GET.get("getPage"))
			querydict =__getSearchPara2(request)
			invoice_list = Invoice.objects.filter(**querydict)
			sumMoney = invoice_list.aggregate(summ=Sum('inv_amount')).get("summ")
			if not sumMoney:
				sumMoney = 0
			sumTax = invoice_list.aggregate(sumT=Sum('inv_tax')).get("sumT")
			if not sumTax:
				sumTax = 0
			resultCount =invoice_list.count()
			pageObject = getPage(invoice_list,currentPage,perPageCount),
			OnePage_invoice_list = pageObject[0].object_list
			num_pages = pageObject[0].paginator.num_pages
			currentPage = pageObject[0].number
			dict2={}
			dict2.update(currentPage=currentPage,perPageCount=perPageCount,resultCount=resultCount,
				num_pages=num_pages,sumMoney=sumMoney,sumTax=sumTax
			)
#			invoice_id = int(invoice_id)
#			invoice = Invoice.objects.get(pk=invoice_id)
			jsondata = getJson(invoices=OnePage_invoice_list,**dict2)
			return HttpResponse(jsondata,mimetype = 'application/javascript')
		else:
			pass
	except Invoice.DoesNotExist,e:
		logger.error(u"您访问的对象不存在,可能已被删除!")
	except Exception,e:
		traceback.print_exc()
		logger.error(e)


def __getSearchPara2(request):
	'''
	收集参数
	'''
	querydict = {}
	try:
		if request.method == "GET":
			time_select = request.GET.get("time_select").strip()
			begintime = request.GET.get("begintime").strip()
			endtime = request.GET.get("endtime").strip()
			if time_select =="1":
				if begintime:
					querydict.update(inv_date__gte=begintime)
				if endtime:
					querydict.update(inv_date__lte=endtime)
			elif  time_select=="2":
				if begintime:
					querydict.update(doc_time__gte=begintime)
				if endtime:
					querydict.update(doc_time__lte=endtime)
			search_type = request.GET.get("search_type").strip()
			search_type_value = request.GET.get("search_type_value").strip()
			if search_type_value:
				if search_type == "1":
					querydict.update(inv_code__icontains=search_type_value)
				if search_type == "2":
					querydict.update(inv_number__icontains=search_type_value)
				if search_type == "3":
					querydict.update(doc_nr__icontains=search_type_value)
				if search_type == "4":
					querydict.update(cust_name__icontains=search_type_value)
				if search_type == "5":
					querydict.update(cust_tax_code__icontains=search_type_value)
			kpjbh = request.GET.get("kpjbh").strip()
			if int(kpjbh)>0:
				querydict.update(client_nr=kpjbh)
			fplx = request.GET.get("fplx").strip()
			if fplx=="0" or fplx=="1":
				querydict.update(inv_type=fplx)
			zffs = request.GET.get("zffs").strip()
			if zffs=="1" or zffs =="2" or zffs =="3":
				querydict.update(pay_type=zffs)
			return querydict
	except Exception,e:
		logger.error(e)
		traceback.print_exc()


@requires_login
def index(request):
	'''
	进入首页
	'''
	logger.info("get_invoice")
	try:
		khjbhlist = getkhjbh()
		querydict = {}
		if request.method == "POST":
			querydict = __getSearchPara(request)
			invoice_list = Invoice.objects.filter(**querydict)
		else:
			invoice_list =Invoice.objects.all()
		context = Context({
			'khjbh':khjbhlist,
			'title':'发票查询',
			'user': request.session['user'],
			'results': devidePage(request,invoice_list,10),
			})
	except:
		logger.error("get_invoice error")
		traceback.print_exc()
		raise Http404
#	return HttpResponse(object_list)
	return render_to_response('invoice_list.html',context,context_instance=RequestContext(request))

def __getSearchPara(request):
	logger.info("getSearchPara..")
	querydict = {}
	try:
	    if request.method == "POST":
		    begintime = request.POST.get("begintime").strip()
		    if begintime:
			    querydict.update(inv_date__gte=begintime)
		    endtime = request.POST.get("endtime").strip()
		    if  endtime:
			    querydict.update(inv_date__lte=endtime)
		    ddbh = request.POST.get("ddbh").strip()
		    if ddbh:
			    querydict.update(doc_nr__icontains=ddbh)
		    fphm = request.POST.get("fphm").strip()
		    if fphm:
			    querydict.update(inv_number__icontains=fphm)
		    zffs = request.POST.get("zffs").strip()
		    if zffs:
			    querydict.update(pay_type__icontains=zffs)
		    khmc = request.POST.get("khmc").strip()
		    if khmc:
			    querydict.update(cust_name__icontains=khmc)
		    kpr = request.POST.get("kpr").strip()
		    if kpr:
			    querydict.update(issuer__icontains=kpr)
		    kpjbp = request.POST.get("kpjbp").strip()
		    if kpjbp:
			    querydict.update(client_nr__icontains=kpjbp)
		    fpdm = request.POST.get("fpdm").strip()
		    if fpdm:
			    querydict.update(inv_code__icontains=fpdm)
		    khsh = request.POST.get("khsh").strip()
		    if khsh:
			    querydict.update(cust_tax_code__icontains=khsh)
	    else:
		    pass
	except:
		traceback.print_exc()
	return querydict



@requires_login
def get_detail_invoice(request,invoice_id=1):
	'''
	获取发票的明细和商品项
	'''
	logger.info("get_detail_invoice")
	try:
		invoice_id = int(invoice_id)
		invoice = Invoice.objects.get(pk=invoice_id)
		jsondata = getJson(result="success",invoice=invoice)
		return HttpResponse(jsondata,mimetype = 'application/javascript')
	except Invoice.DoesNotExist,e:
		logger.error(u"您访问的对象不存在,可能已被删除!")
	except Exception,e:
		traceback.print_exc()
		logger.error(e)
@requires_login
def get_goods(request,invoice_id=1):
	logger.info("get_goods")
	try:
		invoice_id = int(invoice_id)
		invoice = Invoice.objects.get(pk=invoice_id)
		itmes = invoice.item_set.all()
		jsondata = getJson(result="success",invoice=invoice,items=itmes)
		return HttpResponse(jsondata,mimetype = 'application/javascript')
	except Exception,e:
		traceback.print_exc()
		logger.error(e)




#def login(request, error=''):
#	if request.method == "POST":
#		pass


# export excel to file
@csrf_exempt
@requires_login
def export_to_excel(request):
	try:
		logger.info("export_to_excel")
		if request.method == "GET":
				try:
					now = datetime.datetime.now()
					filename = now.strftime("%Y%m%d%H%M%S")+".xls"
					response = HttpResponse(mimetype="application/ms-excel")
					response['Content-Disposition'] = 'attachment; filename='+filename
					wb = xlwt.Workbook()
					ws = wb.add_sheet(u'发票')


					ws.write(0,0,u"作废标志")
					ws.write(0,1,u"发票种类")
					ws.write(0,2,u"单据号")
					ws.write(0,3,u"发票代码")
					ws.write(0,4,u"发票号码")
					ws.write(0,5,u"客户编号")
					ws.write(0,6,u"客户名称")
					ws.write(0,7,u"客户税号")
					ws.write(0,8,u"客户地址电话")
					ws.write(0,9,u"客户银行及帐号")
					ws.write(0,10,u"开票日期")
					ws.write(0,11,u"备注")
					ws.write(0,12,u"开票人")
					ws.write(0,13,u"复核人")
					ws.write(0,14,u"收款人")
					ws.write(0,15,u"销方银行及帐号")
					ws.write(0,16,u"销方地址电话")
					ws.write(0,17,u"商品编号")
					ws.write(0,18,u"商品名称")
					ws.write(0,19,u"规格型号")
					ws.write(0,20,u"计量单位")
					ws.write(0,21,u"数量")
					ws.write(0,22,u"金额（含税")
					ws.write(0,23,u"税率")
					ws.write(0,24,u"税额")
					ws.write(0,25,u"折扣金额(含税)")
					ws.write(0,26,u"折扣税额")
					querydict =__getSearchPara2(request)
					invoice_list = Invoice.objects.filter(**querydict)
					i =1
					for  invoice in invoice_list:
						good_list = invoice.item_set.all()
						if good_list.count()>0:
							for good in good_list:
								if invoice.flag_zf ==0:
									ws.write(i,0,u"作废")
								elif invoice.flag_zf ==1:
									ws.write(i,0,u"正常")
								if invoice.inv_type =="0":
									ws.write(i,1,u"专用发票")
								elif invoice.inv_type =="1":
									ws.write(i,1,u"普通发票")
								ws.write(i,2,invoice.doc_nr)
								ws.write(i,3,invoice.inv_code)
								ws.write(i,4,invoice.inv_number)
								ws.write(i,5,invoice.cust_nr)
								ws.write(i,6,invoice.cust_name)
								ws.write(i,7,invoice.cust_tax_code)
								ws.write(i,8,invoice.cust_address_tel)
								ws.write(i,9,invoice.cust_bank_account)
								ws.write(i,10,invoice.inv_date.strftime("%Y-%m-%d"))
								ws.write(i,11,invoice.memo)
								ws.write(i,12,invoice.issuer)
								ws.write(i,13,invoice.checker)
								ws.write(i,14,invoice.payee)
								ws.write(i,15,invoice.seller_bankacct)
								ws.write(i,16,invoice.seller_address)
								ws.write(i,17,good.item_nr)
								ws.write(i,18,good.item_name)
								ws.write(i,19,good.spec)
								ws.write(i,20,good.unit)
								ws.write(i,21,good.qty)
								ws.write(i,22,good.price)
								ws.write(i,23,good.taxrate)
								ws.write(i,24,good.tax)
								ws.write(i,25,good.discount_amount)
								ws.write(i,26,good.discount_tax)
								i+=1
						else:
							if invoice.flag_zf ==0:
								ws.write(i,0,u"作废")
							elif invoice.flag_zf ==1:
								ws.write(i,0,u"正常")
							if invoice.inv_type =="0":
								ws.write(i,1,u"专用发票")
							elif invoice.inv_type =="1":
								ws.write(i,1,u"普通发票")
							ws.write(i,2,invoice.doc_nr)
							ws.write(i,3,invoice.inv_code)
							ws.write(i,4,invoice.inv_number)
							ws.write(i,5,invoice.cust_nr)
							ws.write(i,6,invoice.cust_name)
							ws.write(i,7,invoice.cust_tax_code)
							ws.write(i,8,invoice.cust_address_tel)
							ws.write(i,9,invoice.cust_bank_account)
							ws.write(i,10,invoice.inv_date.strftime("%Y-%m-%d"))
							ws.write(i,11,invoice.memo)
							ws.write(i,12,invoice.issuer)
							ws.write(i,13,invoice.checker)
							ws.write(i,14,invoice.payee)
							ws.write(i,15,invoice.seller_bankacct)
							ws.write(i,16,invoice.seller_address)
							i+=1
					wb.save(response)
					return response
				except:
					logger.error("export_excel error")
					traceback.print_exc()
					raise Http404()
		else:
			raise Http404()
	except Exception,e:
		traceback.print_exc()
		logger.error(e.message)


