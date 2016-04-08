#--coding:utf-8--
from django.db import models

from datetime import datetime

# Create your models here.
class Document(models.Model):
	document_nr =  models.CharField(max_length=40,db_index=True)
	document_type = models.SmallIntegerField(default=0)

class DocumentItems(models.Model):
	doc= models.ForeignKey(Document,related_name='item_set',db_index=True)
	item_name =  models.CharField(max_length=80,db_index=True)

	
