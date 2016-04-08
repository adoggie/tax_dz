# -- coding:utf-8 --

import traceback,os,os.path,sys,time,ctypes

'''
ffmpeg lib interface list:
===========================

typedef unsigned char  StreamByte_t;

struct MediaStreamInfo_t{
	int codec_type;
	int codec_id;
	int width;
	int height;
	int gopsize;
	int pixfmt;
	int tb_num;
	int tb_den;
	int bitrate;
	int frame_number;
	int videostream; //视频流编号
};

struct MediaVideoFrame_t{
	StreamByte_t *	rgb24;
	size_t			size;
	int				width;
	int				height;
	unsigned int	sequence; //控制播放顺序
	unsigned int	duration; //播放时间
};

struct MediaPacket_t{
 	StreamByte_t*	data;
 	size_t			size;
	AVPacket	*	pkt;
	int				stream;	//流编号 
	int				dts;
	int				pts;
	size_t			sequence;
	size_t			duration;

};

struct MediaFormatContext_t;

//解码器
struct MediaCodecContext_t{
	AVCodecContext * codecCtx;	//AVCodecContext*
	AVCodec *		codec;	
	int				stream; //流编号
	AVFrame *		rgbframe24; //
	AVFrame*		frame;	//
	StreamByte_t*	buffer;
	size_t			bufsize;
	void *			user;
	MediaStreamInfo_t si;
};

struct MediaFormatContext_t{
	AVFormatContext * fc; //AVFormatContext* 
	MediaStreamInfo_t video;	//视频信息
	
};
// 

#ifndef MEDIACODEC_EXPORTS


#ifdef __cplusplus
 extern "C" {  
#endif

int InitLib();
void Cleanup();

MediaCodecContext_t* InitAvCodec(MediaStreamInfo_t* si);
void FreeAvCodec(MediaCodecContext_t* codec);

MediaVideoFrame_t * DecodeVideoFrame(MediaCodecContext_t* ctx,MediaPacket_t* pkt);
void FreeVideoFrame(MediaVideoFrame_t* frame);

MediaPacket_t * AllocPacket();
void FreePacket(MediaPacket_t* pkt);

MediaFormatContext_t* InitAvFormatContext(char * file); //媒体文件访问上下文，申请
void FreeAvFormatContext(MediaFormatContext_t* ctx); //释放
MediaPacket_t* ReadNextPacket(MediaFormatContext_t* ctx);
void ReadReset(MediaFormatContext_t* ctx) ; //重置媒体访问读取位置
int SeekToTime(int timesec) ; //跳跃到指定时间


'''


import ctypes
from ctypes import *


_lib = cdll.LoadLibrary('ffmpeg.dll')

_int_types = (c_int16, c_int32)
if hasattr(ctypes, 'c_int64'):
    # Some builds of ctypes apparently do not have c_int64
    # defined; it's a pretty good bet that these builds do not
    # have 64-bit pointers.
    _int_types += (ctypes.c_int64,)
for t in _int_types:
    if sizeof(t) == sizeof(c_size_t):
        c_ptrdiff_t = t

class c_void(Structure):
    # c_void_p is a buggy return type, converting to int, so
    # POINTER(None) == c_void_p is actually written as
    # POINTER(c_void), so it can be treated as a real pointer.
    _fields_ = [('dummy', c_int)]



	
class MediaStreamInfo_t(Structure):
	_fields_ = [
		('codec_type', c_int),
		('codec_id', c_int),
		('width', c_int),
		('height', c_int),
		('gopsize', c_int),
		('pixfmt', c_int),
		('tb_num',c_int),
		('tb_den',c_int),
		('bitrate',c_int),
		('frame_number',c_int),
		('videostream',c_int),
		('duration',c_int),
		('extr',POINTER(c_char)), #解码器 额外hash表数据
		('extrsize',c_int),
	]

class MediaVideoFrame_t(Structure):
	_fields_=[
		('rgb24',POINTER(c_char)),
		('size',c_uint),
		('width',c_int),
		('height',c_int),
		('sequence',c_uint),
		('duration',c_uint)
	]
	
class MediaPacket_t(Structure):
	_fields_=[
		('data',POINTER(c_char)),
		('size',c_uint),
		('pkt',c_char_p),
		('stream',c_int),
		('dts',c_int),
		('pts',c_int),
		('sequence',c_uint),
		('duration',c_uint)
	]
	
	
class MediaCodecContext_t(Structure):
	_fields_=[
		('codecCtx',c_char_p),
		('codec',c_char_p),
		('stream',c_int),
		('rgbframe24',c_char_p),
		('frame',c_char_p),
		('buffer',c_char_p),
		('bufsize',c_uint),
		('user',c_char_p),
		('si',MediaStreamInfo_t)
	]	
	
class MediaFormatContext_t(Structure):
	_fields_=[
		('fc',c_char_p),
		('video',MediaStreamInfo_t)
	]
	
InitAvCodec = _lib.InitAvCodec
InitAvCodec.restype = POINTER(MediaCodecContext_t)
InitAvCodec.argtypes = [POINTER(MediaStreamInfo_t)]


FreeAvCodec = _lib.FreeAvCodec
FreeAvCodec.restype = None
FreeAvCodec.argtypes = [POINTER(MediaCodecContext_t)]
	
	
DecodeVideoFrame = _lib.DecodeVideoFrame
DecodeVideoFrame.restype = POINTER(MediaVideoFrame_t)
DecodeVideoFrame.argtypes = [POINTER(MediaCodecContext_t),POINTER(MediaPacket_t)]

FreeVideoFrame = _lib.FreeVideoFrame
FreeVideoFrame.restype = None
FreeVideoFrame.argtypes = [POINTER(MediaVideoFrame_t)]
		
AllocPacket = _lib.AllocPacket
AllocPacket.restype = POINTER(MediaPacket_t)
AllocPacket.argtypes = []
		

FreePacket = _lib.FreePacket
FreePacket.restype = None
FreePacket.argtypes = [POINTER(MediaPacket_t),c_int]

InitAvFormatContext = _lib.InitAvFormatContext
InitAvFormatContext.restype = POINTER(MediaFormatContext_t)
InitAvFormatContext.argtypes = [c_char_p]

FreeAvFormatContext = _lib.FreeAvFormatContext
FreeAvFormatContext.restype = None
FreeAvFormatContext.argtypes = [POINTER(MediaFormatContext_t)]


ReadNextPacket = _lib.ReadNextPacket
ReadNextPacket.restype = POINTER(MediaPacket_t)
ReadNextPacket.argtypes = [POINTER(MediaFormatContext_t)]


ReadReset = _lib.ReadReset
ReadReset.restype = None
ReadReset.argtypes = [POINTER(MediaFormatContext_t)]

SeekToTime = _lib.SeekToTime
SeekToTime.restype = c_int
SeekToTime.argtypes = [POINTER(MediaFormatContext_t),c_int]

FlushBuffer = _lib.FlushBuffer
FlushBuffer.restype =None
FlushBuffer.argtypes = [POINTER(MediaCodecContext_t)]

InitLib = _lib.InitLib
InitLib.restype =None
InitLib.argtypes = []

Cleanup = _lib.Cleanup
Cleanup.restype =None
Cleanup.argtypes = []



__all__ = ['StreamByte_t', 'InitLib', 'Cleanup', 'SeekToTime']


def test1():
	pass


if __name__=='__main__':
	test1()
