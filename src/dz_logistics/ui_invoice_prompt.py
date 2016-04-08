# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'ui_invoice_prompt.ui'
#
# Created: Fri May 10 22:03:44 2013
#      by: PyQt4 UI code generator 4.9.6
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    def _fromUtf8(s):
        return s

try:
    _encoding = QtGui.QApplication.UnicodeUTF8
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig, _encoding)
except AttributeError:
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig)

class Ui_Dialog(object):
    def setupUi(self, Dialog):
        Dialog.setObjectName(_fromUtf8("Dialog"))
        Dialog.setWindowModality(QtCore.Qt.ApplicationModal)
        Dialog.resize(433, 206)
        Dialog.setModal(True)
        self.label = QtGui.QLabel(Dialog)
        self.label.setGeometry(QtCore.QRect(24, 17, 54, 12))
        self.label.setObjectName(_fromUtf8("label"))
        self.edtDocNr = QtGui.QLineEdit(Dialog)
        self.edtDocNr.setGeometry(QtCore.QRect(93, 13, 320, 20))
        font = QtGui.QFont()
        font.setFamily(_fromUtf8("Arial Black"))
        font.setPointSize(12)
        font.setBold(True)
        font.setWeight(75)
        self.edtDocNr.setFont(font)
        self.edtDocNr.setStyleSheet(_fromUtf8("color: rgb(255, 0, 0);"))
        self.edtDocNr.setText(_fromUtf8(""))
        self.edtDocNr.setFrame(False)
        self.edtDocNr.setObjectName(_fromUtf8("edtDocNr"))
        self.label_2 = QtGui.QLabel(Dialog)
        self.label_2.setGeometry(QtCore.QRect(24, 47, 54, 12))
        self.label_2.setObjectName(_fromUtf8("label_2"))
        self.edtTaxCode = QtGui.QLineEdit(Dialog)
        self.edtTaxCode.setGeometry(QtCore.QRect(93, 43, 320, 20))
        font = QtGui.QFont()
        font.setFamily(_fromUtf8("Arial Black"))
        font.setPointSize(12)
        font.setBold(True)
        font.setWeight(75)
        self.edtTaxCode.setFont(font)
        self.edtTaxCode.setStyleSheet(_fromUtf8("color: rgb(255, 0, 0);"))
        self.edtTaxCode.setText(_fromUtf8(""))
        self.edtTaxCode.setFrame(False)
        self.edtTaxCode.setObjectName(_fromUtf8("edtTaxCode"))
        self.edtTaxNumber = QtGui.QLineEdit(Dialog)
        self.edtTaxNumber.setGeometry(QtCore.QRect(93, 73, 320, 20))
        font = QtGui.QFont()
        font.setFamily(_fromUtf8("Arial Black"))
        font.setPointSize(12)
        font.setBold(True)
        font.setWeight(75)
        self.edtTaxNumber.setFont(font)
        self.edtTaxNumber.setStyleSheet(_fromUtf8("color: rgb(255, 0, 0);"))
        self.edtTaxNumber.setText(_fromUtf8(""))
        self.edtTaxNumber.setFrame(False)
        self.edtTaxNumber.setObjectName(_fromUtf8("edtTaxNumber"))
        self.label_3 = QtGui.QLabel(Dialog)
        self.label_3.setGeometry(QtCore.QRect(24, 77, 54, 12))
        self.label_3.setObjectName(_fromUtf8("label_3"))
        self.btnInvoice = QtGui.QPushButton(Dialog)
        self.btnInvoice.setGeometry(QtCore.QRect(126, 167, 91, 31))
        self.btnInvoice.setStyleSheet(_fromUtf8(""))
        self.btnInvoice.setObjectName(_fromUtf8("btnInvoice"))
        self.btnCancel = QtGui.QPushButton(Dialog)
        self.btnCancel.setGeometry(QtCore.QRect(256, 167, 91, 31))
        self.btnCancel.setObjectName(_fromUtf8("btnCancel"))
        self.label_4 = QtGui.QLabel(Dialog)
        self.label_4.setGeometry(QtCore.QRect(24, 107, 54, 12))
        self.label_4.setObjectName(_fromUtf8("label_4"))
        self.edtCustName = QtGui.QLineEdit(Dialog)
        self.edtCustName.setGeometry(QtCore.QRect(93, 103, 320, 20))
        font = QtGui.QFont()
        font.setFamily(_fromUtf8("Arial Black"))
        font.setPointSize(12)
        font.setBold(True)
        font.setWeight(75)
        self.edtCustName.setFont(font)
        self.edtCustName.setStyleSheet(_fromUtf8("color: rgb(255, 0, 0);"))
        self.edtCustName.setText(_fromUtf8(""))
        self.edtCustName.setFrame(False)
        self.edtCustName.setObjectName(_fromUtf8("edtCustName"))
        self.ckPrintIgnored = QtGui.QCheckBox(Dialog)
        self.ckPrintIgnored.setGeometry(QtCore.QRect(20, 175, 71, 16))
        self.ckPrintIgnored.setObjectName(_fromUtf8("ckPrintIgnored"))
        self.edtDocAmount = QtGui.QLineEdit(Dialog)
        self.edtDocAmount.setGeometry(QtCore.QRect(123, 132, 291, 20))
        font = QtGui.QFont()
        font.setFamily(_fromUtf8("Arial Black"))
        font.setPointSize(12)
        font.setBold(True)
        font.setWeight(75)
        self.edtDocAmount.setFont(font)
        self.edtDocAmount.setStyleSheet(_fromUtf8("color: rgb(85, 170, 0);"))
        self.edtDocAmount.setText(_fromUtf8(""))
        self.edtDocAmount.setFrame(False)
        self.edtDocAmount.setObjectName(_fromUtf8("edtDocAmount"))
        self.label_5 = QtGui.QLabel(Dialog)
        self.label_5.setGeometry(QtCore.QRect(25, 136, 101, 16))
        self.label_5.setObjectName(_fromUtf8("label_5"))

        self.retranslateUi(Dialog)
        QtCore.QMetaObject.connectSlotsByName(Dialog)

    def retranslateUi(self, Dialog):
        Dialog.setWindowTitle(_translate("Dialog", "开票提示", None))
        self.label.setText(_translate("Dialog", "订单编号", None))
        self.label_2.setText(_translate("Dialog", "发票代码", None))
        self.label_3.setText(_translate("Dialog", "发票号码", None))
        self.btnInvoice.setText(_translate("Dialog", "开 票", None))
        self.btnCancel.setText(_translate("Dialog", "取 消", None))
        self.label_4.setText(_translate("Dialog", "客户信息", None))
        self.ckPrintIgnored.setText(_translate("Dialog", "不打印", None))
        self.label_5.setText(_translate("Dialog", "开票金额(含税)", None))

