#include <cstdio>
#include <vector>
#include <algorithm>

#include "mextools/mextools.h"
#include "loss_function.h"

using namespace std;


void mexFunction(int nlhs, mxArray  *plhs[], int nrhs, const mxArray  *prhs[])       
{                   
	if (nrhs < 2) {
		mexErrMsgTxt("loss_function(soll, ist, mode, eps, sampleweights)\n");
		return;
	}
           
  	mvector soll(prhs[0]);
	mvector ist(prhs[1]);

	const long nr_samples = soll.length();

	int mode = 0;
	
	if (nrhs > 2) {
		mode = (int) (*((double*)(mxGetPr(prhs[2]))));
	}
	
	if (nr_samples != ist.length()) {
		mexErrMsgTxt("Length of input values must be the same!\n");
		return;
	}
	
	vector<double> weights(nr_samples, 1.0);

	if (nrhs > 4) {
		mvector w(prhs[4]);
		
		if ( weights.size() != w.length() ) {
			mexErrMsgTxt("Length of input values and number of weights must be the same!\n");
			return;
		}	
		copy(w.begin(), w.end(), weights.begin());
	}
	
#ifdef VERBOSE
	printf("Anzahl Samples     : %d\n", nr_samples);

#endif

	double err = 0.0;

	switch(mode) {
		case 1: {
				double eps = 0.0;
				if (nrhs > 3) 
					eps = (*((double*)(mxGetPr(prhs[3]))));

				squared_insensitive lossfun(eps);
				err = samplewise_error(lossfun, soll, ist, weights); 	
		}
		break;
		case 2: {
				double eps = 0.0;
				if (nrhs > 3) 
					eps = (*((double*)(mxGetPr(prhs[3]))));

				absolute_insensitive lossfun(eps);
				err = samplewise_error(lossfun, soll, ist, weights); 	
		}
		break;
		default: {
			squared lossfun;				
			err = samplewise_error(lossfun, soll, ist, weights); 
		}
		break;
	}

	plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL);  
	*((double*)mxGetPr(plhs[0])) = err;	

	if (nlhs > 1) {
		plhs[1] = mxCreateDoubleMatrix(soll.length(), 1, mxREAL); 
		copy(soll.begin(), soll.end(), ((double*)mxGetPr(plhs[1])));
	}
	if (nlhs > 2) {
		plhs[2] = mxCreateDoubleMatrix(ist.length(), 1, mxREAL); 
		copy(ist.begin(),ist.end(), ((double*)mxGetPr(plhs[2])));
	}
}
