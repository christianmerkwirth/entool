#include <cmath>
#include <cstdio>
#include <iostream>

#include "mex.h"

// Fast activation function

// mex -v -f ../../entool/tools/mexopts.bat fastact.cpp -O

using namespace std;

inline double pl(const double x)
{
    if (x < 0.5)
        return x;
    else if (x < 1.5)
        return 0.5 + 0.5*(x-0.5);
    else if (x < 4.5)
        return 1.0 + 0.05 * (x-1.5);
    else 
        return 1.15 + 0.01 * (x-4.5);    
}

inline double plinv(const double x)
{
    if (x < 0.5)
        return x;
    else if (x < 1.0)
        return 0.5 + 2*(x-0.5);
    else if (x < 1.15)
        return 1.5 + 20*(x-1.0);
    else 
        return 4.5 + 100 * (x-1.15);    
}


inline double pld(const double x)
{
    if (x < 0.5)
        return 1.0;
    else if (x < 1.5)
        return 0.5;
    else if (x < 4.5)
        return 0.05;
    else
        return 0.01;    
}

inline double piecewice_linear(const double x, const bool inv) 
{
    if (inv) {
        if (x >= 0)
            return plinv(x);
        else
            return -plinv(-x);
    } else {
        if (x >= 0)
            return pl(x);
        else
            return -pl(-x);
    }
}

inline double piecewice_linear_derivative(const double x) 
{
    if (x >= 0)
        return pld(x);
    else
        return pld(-x);
}

void mexFunction(int nlhs, mxArray  *plhs[], int nrhs, const mxArray  *prhs[])       
{               
    bool inv = false;       // if true, return inverse function of activation function
    
	if (nrhs < 1) {
		mexErrMsgTxt("[act,der] = fastact(x, mode)\n");
		return;
	}
  
	if (nrhs > 1) {
	    inv = (bool)(*((double*)mxGetPr(prhs[1])));
	}

	const long M = mxGetM(prhs[0]);
	const long N = mxGetN(prhs[0]);
	
    plhs[0] = mxCreateDoubleMatrix(M,N, mxREAL);  
    
    const double* in = mxGetPr(prhs[0]);
    double* out = mxGetPr(plhs[0]);
    
    if (nlhs > 1)  {
        plhs[1] = mxCreateDoubleMatrix(M,N, mxREAL); 
        double* out2 = mxGetPr(plhs[1]);
        
        for (long i=0; i < M*N; i++) {
            const double x = *(in++);
            *(out++) = piecewice_linear(x, false);
            *(out2++) = piecewice_linear_derivative(x);
        }  
    } else {
        for (long i=0; i < M*N; i++) {
            *(out++) = piecewice_linear(*(in++), inv);
        }  
    }
}

