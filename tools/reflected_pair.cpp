#include <cstdio>
#include <vector>
#include <algorithm>

#include "mextools/mextools.h"

using namespace std;

void mexFunction(int nlhs, mxArray  *plhs[], int nrhs, const mxArray  *prhs[])       
{                   
	if (nrhs < 2) {
		mexErrMsgTxt("reflected_pair(x, xsplit)\n");
		return;
	}
           
  	mvector x(prhs[0]);
	const double xsplit = double(*((double*)(mxGetPr(prhs[1]))));
		
#ifdef VERBOSE
	printf("Anzahl Samples     : %d\n", nr_samples);
#endif

    int splitdir = 0;

    if (nrhs > 2) {
        splitdir = int(*((double*)(mxGetPr(prhs[2]))));  
    }

    if (splitdir) {
  	    plhs[0] = mxCreateDoubleMatrix(x.length(),1, mxREAL);  
	    mmatrix y(plhs[0]);
	
	    for (long i=1; i <= x.length(); i++) {
	        const double z = x(i) - xsplit;
	    
	        if (z > 0) {
	            if (splitdir > 0)
	                y(i,1) = z;
	            else
	                y(i,1) = 0.0;
	        } else {
	            if (splitdir > 0)
	                y(i,1) = 0.0;
	            else
	                y(i,1) = -z;	    
	        }   
	    }  
    } else {
	    plhs[0] = mxCreateDoubleMatrix(x.length(),2, mxREAL);  
	    mmatrix y(plhs[0]);
	
	    for (long i=1; i <= x.length(); i++) {
	        const double z = x(i) - xsplit;
	    
	        if (z > 0) {
	            y(i,1) = z;
	            y(i,2) = 0.0;
	        } else {
	            y(i,1) = 0.0;
	            y(i,2) = -z;	    
	        }   
	    }
	}
}

