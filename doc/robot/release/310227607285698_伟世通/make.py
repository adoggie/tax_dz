# -- coding:utf-8 --

import traceback,os,os.path,sys,time,ctypes,datetime,base64,pickle,hashlib

ENCRYPT_KEY='#E0~RweT'          #加密客户的lic
ENCRYPT_KEY_DOG = 'acd4c840'    #此key将被des加密之后写入dog，机密发给供应商的授权lic



def rsa_generate():
	from Crypto.PublicKey import RSA
	from Crypto import Random
	random_generator = Random.new().read
	key = RSA.generate(1024, random_generator)


	#print key.publickey().encrypt('123213213123213213',20)
	public =  key.publickey().exportKey()
	#print key.publickey().exportKey()
	private = key.exportKey()
	return public,private

def rsa_decrypt(key,text):
	from Crypto.PublicKey import RSA
	key = RSA.importKey(key)
	
	chunksize = (key.size()+1) //8
	
	#print 'text size',len(text)
	if len(text)% chunksize:
		return ''
	
	p =0
	result=''
	while p< len(text):		
		s = key.decrypt(text[p:p+chunksize])
		p+=chunksize
		result+=s
	
	text = result
	
	pad = ord(text[-1])
	if pad == '\xff':
		return text[:-chunksize]
	text = text[:-pad]
	
	return base64.decodestring(text)
	
#!!! 加密字符串 encrypt(text), text 必须是plaintext !!!!1切记
#所以在这里进行base64编码
def rsa_encrypt(key,text):
	from Crypto.PublicKey import RSA
	key = RSA.importKey(key)
	
	text = base64.encodestring(text)
	
	chunksize = (key.size()+1) //8
	p = 0
	size = len(text)
	result=''
	reminder = len(text)%chunksize
	if reminder ==0:  # pad 8 bytes
		text+='\xff'*chunksize
	else:
		text+=chr(chunksize-reminder)* (chunksize-reminder)
	
	while p < size:		
		ciphered_text = key.encrypt(text[p:p+chunksize],128)[0]
		result+=ciphered_text
		p+=chunksize
		
	return result





def encrypt_des(key,text):
	from Crypto.Cipher import DES
	import base64
	from Crypto import Random
	#iv = Random.get_random_bytes(8)
	des = DES.new(key, DES.MODE_ECB)
	reminder = len(text)%8
	if reminder ==0:  # pad 8 bytes
		text+='\x08'*8
	else:
		text+=chr(8-reminder)* (8-reminder)
	#text+=' '*(8-len(text)%8)
	return des.encrypt(text)
	
def decrypt_des(key,text):
	from Crypto.Cipher import DES
	import base64
	print key
	des = DES.new(key, DES.MODE_ECB)
	text = des.decrypt(text)
	pad = ord(text[-1])
	if pad == '\x08':
		return text[:-8]
	return text[:-pad]

if not os.path.exists('public.rsa'):
	pub,priv = rsa_generate()
	f = open('public.rsa','w')
	f.write(pub)
	f.close()

	f = open('private.rsa','w')
	f.write(priv)
	f.close()

f = open('private.rsa')
priv_key =f.read()
f.close()

f = open('public.rsa')
pub_key =f.read()
f.close()


#r = rsa_encrypt(pub_key,'a'*2000)
##print 'result:',r
#print len(rsa_decrypt(priv_key,r))
#sys.exit()

#create .lic ,set ENCRYPT_KEY into dog
taxcode=  os.path.basename(os.getcwd()).split('_')[0]
f = open('profile.txt')
name =f.readline().strip()
f.close()

priv_key = encrypt_des(hashlib.md5(ENCRYPT_KEY_DOG).hexdigest()[:8],priv_key)
d = {'taxcode':taxcode,
    'priv_key':priv_key,
	'name':name,
	'type':'client'}



d = pickle.dumps(d)
key = hashlib.md5(ENCRYPT_KEY).hexdigest()[:8]
d = encrypt_des(key,d)
f = open('%s.lic'%taxcode,'wb')
f.write(d)
f.close()

#scan all providers
providers = os.listdir('.')
for  p in providers:
	if not os.path.isdir(p):
		continue
	d={'taxcode':taxcode,
		'name':name,
		'provider_taxcode':p.split('_')[0],
	   'pub_key':pub_key,
	   'type':'provider'}
	d = pickle.dumps(d)
	key = hashlib.md5(ENCRYPT_KEY).hexdigest()[:8]
	d = encrypt_des(key,d)
	print len(d)
	#d = decrypt_des(key,d)
	
	
	f = open('%s/%s_%s.lic'%(p,taxcode,p),'wb')
	f.write(d)
	f.close()
