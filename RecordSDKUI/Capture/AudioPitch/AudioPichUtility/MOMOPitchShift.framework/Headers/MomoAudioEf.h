
#ifndef _MomoAudioEf_H_
#define _MomoAudioEf_H_

#ifndef _INT16_T
#define _INT16_T
typedef	short			int16_t;
#endif /* _INT16_T */

#define BUFFER_SIZE 1920

//#define FLUSH
//变调和EQ分别提供两个独立的借口，具体的接口定义如下：
//变调模块：
typedef struct
{
    int     rate;       // 采样率
    int     nChannels;  // 声道数
    int     pitch;      // 基频变调范围 -10 ～ 10。  defalut = 0
    int     nReserved[4]; //保留字段
} Ctrl_Params_Tune;

//变调函数接口：
class PitchShift {
public:
	PitchShift();
	~PitchShift();
	void ProcessSound(int16_t*  input_buf, int input_len, Ctrl_Params_Tune &params, int16_t*  ret_ptr, int* ret_len);
	void Init(Ctrl_Params_Tune &params);
private:
	int nSamples;
	int buffSizeSamples;
	int buffSizeProc;
	void* pitchshift_ptr;
};

#endif // _MomoAudioEf_H_
