#include <cmath>
#include <vector>
#include "mextools/mextools.h"

// Several loss functions with derivative
// mex -v -I../../entool loss.cpp -O

using namespace std;

inline double sign(const double x) {
    if (x > 0.0) {
        return 1.0;
    }
    else if (x < 0.0) {
        return -1.0;
    }    
    else { 
        return 0.0;
    }
}

inline pair<double, double> epsquadloss(const double x, const double y, const double eps)
{
    double d = x - y;

    if (d > eps) {
        d -= eps;
    } else if (d < -eps)
    {
        d += eps;
    } else {
        d = 0.0;
    }
    
    return make_pair(d*d,  2.0*d);
}


inline pair<double, double> epsabsloss(const double x, const double y, const double eps)
{
    const double d = x - y;

    if (d > eps) {
        return make_pair(d-eps,  1.0);
    } else if (d < -eps)
    {
        return make_pair(-d-eps,  -1.0);
    } else {
        return make_pair(0.0,  0.0);
    }
}

// loss for binary classification (0/1 coding), errors only linear with eps margin
inline pair<double, double> epsclassloss(const double x, const double y, const double eps)
{
    if (x) {
        const double d = x - y;  // when x (desired) is greater than y, we have a loss
        
        if (d > eps) 
            return make_pair(d-eps,  1.0);
        else    
            return make_pair(0.0,  0.0);
    } else {
          const double d = y - x;  // when x (desired) is lower than y, we have a loss
        
            if (d > eps) 
                return make_pair(d-eps,  -1.0);
            else    
                return make_pair(0.0,  0.0);
    }
}


void mexFunction(int nlhs, mxArray  *plhs[], int nrhs, const mxArray  *prhs[])       
{                   
	if (nrhs < 1) {
		mexErrMsgTxt("[l,lder] = loss(y, yh, eps, mode)\n");
		return;
	}
	
	mvector y(prhs[0]);
	mvector yh(prhs[1]);
    
	const long N = y.length();
	const long NH = yh.length();
	
	if (N != NH) {
		mexErrMsgTxt("length of input vectors y and yh must be equal\n");
		return;
	}
	
	int mode = 0;       // mode = 0 : epsilon insensitve squared loss, mode = 1: epsilon insensitve absolut loss
	double eps = 0.0;
	
	if (nrhs > 2) {
	    eps = double(*((double*)(mxGetPr(prhs[2]))));
	}
	if (nrhs > 3) {
	    mode = long(*((double*)(mxGetPr(prhs[3]))));
	}

	
	plhs[0] = mxCreateDoubleMatrix(N,1, mxREAL);  
	mvector l(plhs[0]);     // loss value

	plhs[1] = mxCreateDoubleMatrix(N, 1, mxREAL); 
	mvector lder(plhs[1]);      // derivate of loss
	
	for (long i=1; i <= N; i++) {
	    pair<double, double> x;
	    switch(mode) {
	        case 1:
	            x = epsabsloss(y(i), yh(i), eps);
	            break;
	        case 2:
	            x = epsclassloss(y(i), yh(i), eps);
	            break;
	        default:
	            x = epsquadloss(y(i), yh(i), eps);
	            break;
	    }
	    l(i) =  x.first;
	    lder(i) = x.second;
	}  
	
	if (nlhs < 2)  {
	    mxDestroyArray(plhs[1]);
	}
}
	
