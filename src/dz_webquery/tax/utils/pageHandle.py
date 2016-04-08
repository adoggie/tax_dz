# -*- coding: UTF-8 -*-
'''
Created on 2012-3-21

@author: daitr
'''
from django.core.paginator import Paginator, InvalidPage, EmptyPage

'''分页处理
'''
def devidePage(request,list,pageCount=10):
    paginator = Paginator(list, pageCount) # Show 25 contacts per page
    # Make sure page request is an int. If not, deliver first page.
    try:
        page = int(request.GET.get('page', '1'))
    except ValueError:
        pass
#    page = 1
    # If page request (9999) is out of range, deliver last page of results.
    try:
        OnepageResult = paginator.page(page)
    except (EmptyPage, InvalidPage):
        OnepageResult = paginator.page(paginator.num_pages)
    return OnepageResult

def getPage(object_list,currentPage,pageCount):
	paginator = Paginator(object_list, pageCount)
	try:
		OnepageResult = paginator.page(currentPage)
	except (EmptyPage, InvalidPage):
		OnepageResult = paginator.page(paginator.num_pages)
	return OnepageResult