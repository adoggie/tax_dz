# -*- coding:gb2312 -*-
import sys, traceback,threading,time

'''
http://www.python.org/dev/peps/pep-0249/
'''

####END CLASS ######################################


def fetchoneDict(cursor):
	row ={}
	rs = cursor.fetchone()
	flds = cursor.description
	if rs == None:
		return None
	# print flds
	# print rs
	for i in range(len(flds)):
		row[flds[i][0]] = rs[i]
		# print flds[i][0],rs[i],type(rs[i])
	return row

def fetchallDict(cursor):
	dict =[]
	rs = cursor.fetchall()
	if len(rs) ==0:
		return dict
	flds = cursor.description
	# print rs
	for r in rs:
		row = {}
		for i in range(len(flds)):
			row[flds[i][0]] = r[i]
		dict.append(row)
	return dict
