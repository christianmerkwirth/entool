#include <cstdio>
//#include <algo>
#include "mextools/mextools.h"

using namespace std;

typedef pair<double, int> valpos;

struct myless : public binary_function<valpos, valpos, bool>  {
	bool operator()(const valpos& x, const valpos& y) const { 
		return (x.first < y.first);
	}
};

void mexFunction(int nlhs, mxArray  *plhs[], int nrhs, const mxArray  *prhs[])       
{                 
	if (nrhs < 2) {
		mexErrMsgTxt("weightedmedian(x, weights)\n");
		return;
	}
           
  	mmatrix x(prhs[0]);
	mmatrix weights(x.getM(), x.getN());
	double* tmp_weights = mxGetPr(prhs[1]);

	const long nr_samples = x.getM();
	const long nr_dim = x.getN();
	
	// Now check if weights are given as a vector or as a matrix of same size as x

	if (nr_dim  == mxGetM(prhs[1])*mxGetN(prhs[1])) {
		for (int j=1; j <= nr_samples; j++) {	
			for (int i=1; i <= nr_dim; i++) {
				weights(j,i) = tmp_weights[i-1];
			}
		}
	} else if ((nr_samples == mxGetM(prhs[1])) && (nr_dim == mxGetN(prhs[1])))  { 
		for (int j=1; j <= nr_samples; j++) {	
			for (int i=1; i <= nr_dim; i++) {
				weights(j,i) = tmp_weights[j-1+(i-1)*nr_samples];
			}
		}
	}
	else {
		mexErrMsgTxt("Number of weights and number of data columns does not match!\n");
		return;
	}
	
	plhs[0] = mxCreateDoubleMatrix(nr_samples,1, mxREAL);  
	mvector out(plhs[0]);	

	for (int j=1; j <= nr_samples; j++) {
		double total_sum = 0.0;

		for (int i=1; i <= nr_dim; i++) {
				total_sum += weights(j,i);	
				if (weights(j,i) < 0) {
					mexErrMsgTxt("Negative weight given!\n");
				    return;
		        }
	    }

		if (total_sum <= 0) {
			mexErrMsgTxt("Sum of weights must be positive!\n");
			return;
		}
	
		const double thresh = total_sum / 2.0;

		vector<valpos> v(nr_dim);
		
		for (int i=1; i <= nr_dim; i++) {
			v[i-1] = make_pair(x(j,i), i);
		}
		
		sort(v.begin(),v.end());
		
		double cumsum = 0.0;
		
		for (int i=0; i < nr_dim; i++) {
			cumsum += weights(j,v[i].second);
			
			if (cumsum == thresh) {
				if (i < (nr_dim-1))
					out(j) = 0.5 * (v[i].first + v[i+1].first);
				else
					out(j) = v[i].first;
				
				break;
			} else if (cumsum > thresh) {
				out(j) = v[i].first;
				break;
			}								
		}		
	}		
}
