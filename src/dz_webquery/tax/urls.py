#--coding:utf-8--
from django.conf.urls import patterns, include, url
import os
# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()
import webapi
import settings


urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'tax.views.home', name='home'),
    # url(r'^tax/', include('tax.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # url(r'^admin/', include(admin.site.urls)),
	url(r'^$',"tax.core.views.index",name="index"),
	url(r'^putInvoice/',webapi.putInvoice),
	url(r'^login/',"tax.core.views.login"),
	url(r'^export_excel/',"tax.core.views.export_to_excel"),
	url(r'^index/',"tax.core.views.index",name="index"),
	url(r'^get_invoice/',"tax.core.views.get_invoice2",name="get_invoice"),
	url(r'^get_detail_invoice/(?P<invoice_id>\d*)/',"tax.core.views.get_detail_invoice",name="get_detail_invoice"),
	url(r'^export_to_excel/',"tax.core.views.export_to_excel",name="export_to_excel"),
	url(r'^get_goods/(?P<invoice_id>\d*)/',"tax.core.views.get_goods",name="get_goods"),
	url(r'^login/',"tax.core.views.login"),
	url(r'^logout/',"tax.core.views.logout"),


)
#静态文件支持
urlpatterns += patterns('',
	url(r'^static/(?P<path>.*)$','django.views.static.serve',{'document_root':settings.STATIC_ROOT}),
	url(r'^media/(?P<path>.*)$', 'django.views.static.serve',{'document_root': settings.MEDIA_ROOT}),
)
#urlpatterns += patterns('',
#	url(r'^core/',include('core.urls' )),
#)