# -- coding:utf-8 --

import socket,traceback,os,os.path,sys,time,struct,base64,gzip,array,threading

class SimpleConfig:
	def __init__(self):
		self.props={}
		
	def clear(self):
		self.props={}
		
	def load(self,file):
		try:
			f = open(file,'r')
			lines = f.readlines()
			f.close()
			for line in lines:
				line = line.strip()
				if line[:1] =='#': continue
				try:
					key,val = line.split('=')
					self.props[key.strip()] = val.strip()
				except:pass
		except:
			pass
		
	def getValue(self,key):
		if self.props.has_key(key):
			return self.props[key]
		return ''
