#include <cmath>
#include <cstdio>
#include <iostream>

#include "mex.h"
#include "mextools/sigmoids.h"

using namespace std;

void mexFunction(int nlhs, mxArray  *plhs[], int nrhs, const mxArray  *prhs[])       
{                   
	if (nrhs < 1) {
		mexErrMsgTxt("fasttanh(x)\n");
		return;
	}
    
	const long M = mxGetM(prhs[0]);
	const long N = mxGetN(prhs[0]);
	    plhs[0] = mxCreateDoubleMatrix(M,N, mxREAL);  
    
    const double* in = mxGetPr(prhs[0]);
    double* out = mxGetPr(plhs[0]);
        
    for (long i=0; i < M*N; i++) {
        *(out++) = sigmoid_tanh(*(in++)); 
    }
}


