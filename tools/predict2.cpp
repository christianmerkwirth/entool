// 
// predict2 : predict len next points of an time-series of vector points,
//           using a local constant model
// 
//   input arguments :
//    ts - scalar time series 
//	  dim - embedding dimension
//	  delay - time delay in samples
//    len    - length of prediction in samples
//    NNR    - number of nearest neighbours to use for each prediction
//    mode (optional) - method of computing predicted values
//    exp_weighted_factor (optional) - parameter for the euclidian weighted distance calculation, may be choosen out of ]0,1] (see McNames Leuven,Belgium 1998)
// 
//  cmerk 1998
//
// mex -I. -I.. predict2.cpp -O



#include <cmath>

// C++ Standard Template Library
// this files have to be located before(!!!) the #ifdef MATLAB_MEX_FILE sequence,
// otherwise the defines will break the STL
#include <algorithm>
#include <deque>
#include <list>
#include <queue>
#include <vector>
#include <stack>

#include "mextools/mextools.h"

// this includes the code for the nearest neighbor searcher and the prediction routines
#include "NNSearcher/point_set.h"
#include "NNSearcher/nn_predictor.h"
#include "include.mex"

using namespace std;


// Access image of training vector i
template<class POINT_SET>
struct direct_prediction {
	const POINT_SET& points;
	
	direct_prediction(const POINT_SET& p) : points(p) {};
	~direct_prediction() {}

	double operator()(const long i) const {
		return *(points.point_begin(i+1));
	}
};

// Access image of training vector i
template<class POINT_SET>
struct integrated_prediction {
	const POINT_SET& points;
	
	integrated_prediction(const POINT_SET& p) : points(p) {};
	~integrated_prediction() {}

	double operator()(const long i) const {
		return *(points.point_begin(i+1)) - *(points.point_begin(i));
	}
};

void mexFunction(int nlhs, mxArray  *plhs[], int nrhs, const mxArray  *prhs[])
{	
    int verbose = 0;
	long i;
	
	/* check input args */
	
	if (nrhs < 5)
	{
		mexErrMsgTxt("Local constant prediction : Time series, dim, delay, length to predict, number of NN must be given, mode (0-3) and metric factor is optional\n");
		return;
	}
	
	/* handle matrix and parameter I/O */
	
	long mode = 0;		
	double metric_factor = 1;		// can be choosen out of ]0,1],   1 means : use exact euclidian metric
	
	
	const long N = mxGetM(prhs[0]) * mxGetN(prhs[0]);	
	double* ts = (double *)mxGetPr(prhs[0]);

	const long dim = (long) *((double *)mxGetPr(prhs[1]));
	const long delay = (long) *((double *)mxGetPr(prhs[2]));

	const long length 	= (long) *((double *)mxGetPr(prhs[3]));
	const long NNR  	= (long) *((double *)mxGetPr(prhs[4]));
	
	if (nrhs > 5) mode  = (long) *((double *)mxGetPr(prhs[5])); 	// averaging mode
	if (nrhs > 6) metric_factor  = (double) *((double *)mxGetPr(prhs[6])); 	// weighting factor for exponential weighted euclidian metric
	if (nrhs > 7) verbose = (long) *((double *)mxGetPr(prhs[7])); 	// verbosity
	
	
	if (dim < 1) {
		mexErrMsgTxt("Embedding dimension must be greater zero");
		return;
	}		
	if (delay < 1) {
		mexErrMsgTxt("Time delay must be greater zero");
		return;
	}		
	if (length < 1) {
		mexErrMsgTxt("Length must be greater zero");
		return;
	}		 
	if (NNR < 1) {
		mexErrMsgTxt("Number of nearest neighbors must be greater zero");
		return;
	}		
	if  ((metric_factor < 0) || (metric_factor > 1)) {
		mexErrMsgTxt("Metric factor must be out of ]0,1]");
		return;
	}		
	
	exp_weighted_euclidian_distance metric(metric_factor);
	
	embedded_time_series_point_set<exp_weighted_euclidian_distance> dummy(N, dim, delay, ts, metric);
	
	if (dummy.size() < 1) {
		mexErrMsgTxt("Time series must to short for given parameters");
		return;
	}			
	
	if (verbose) mexPrintf("Length of input time series     : %d\n", N);
	if (verbose) mexPrintf("Length of prediction            : %d\n", length);
	if (verbose) mexPrintf("Reconstruction dimension        : %d\n", dim);
	if (verbose) mexPrintf("Reconstruction delay            : %d\n", delay);
	if (verbose) mexPrintf("Number of reconstruction points : %d\n", dummy.size());	
	if (verbose) mexPrintf("Number of nearest neighbors     : %d\n", NNR);
	if (verbose) mexPrintf("Metric factor                   : %lf\n", metric_factor);
		
	plhs[0] = mxCreateDoubleMatrix(N + length, 1, mxREAL);
	double* const x = (double *) mxGetPr(plhs[0]);
	
	copy(ts, ts + N, x);	// copy time series samples to output
	
	embedded_time_series_point_set<exp_weighted_euclidian_distance> points(N + length, dim, delay, x, metric);
	
	ATRIA<embedded_time_series_point_set < exp_weighted_euclidian_distance > > searcher(points, length + 1);	
	nn_predictor< ATRIA<embedded_time_series_point_set < exp_weighted_euclidian_distance > > > predictor(searcher);

	if (predictor.geterr()) {	
		mexErrMsgTxt("Error preparing predictor : Inconsistent parameters given ?");
		return;
	}	 
										
	switch(mode) {
		case 1 :
		{
			if (verbose) mexPrintf("Local constant prediction using direct weighting\n");
		
			biquadratic_weight wg;
			direct_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > fv(points);	
			local_approx< direct_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > , biquadratic_weight> approximator(fv , wg);
		
			for (long t = 0; t < length; t++) {
			    const long actual_sample = t + dummy.size()-1;
			    const long first = actual_sample - 1;
			    const long last = actual_sample;
				x[N + t] = predictor.predict(NNR + 1, points.point_begin(actual_sample), approximator, first, last);
			}
			break;
		}	
		case 2 :
		{
			if (verbose) mexPrintf("Local constant prediction using integrated mean\n");
			constant_weight wg;
			integrated_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > fv(points);	
			local_approx< integrated_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > , constant_weight> approximator(fv , wg);
					
			for (long t = 0; t < length; t++) {
				const long actual_sample = t + dummy.size()-1;
			    const long first = actual_sample - 1;
			    const long last = actual_sample;
				x[N + t] = x[N + t - 1] + predictor.predict(NNR, points.point_begin(actual_sample), approximator, first, last);
			}
			break;
		}
		case 3 :
		{
			if (verbose) mexPrintf("Local constant prediction using integrated weighting\n");
			biquadratic_weight wg;
			integrated_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > fv(points);	
			local_approx< integrated_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > , biquadratic_weight> approximator(fv , wg);
		
			for (long t = 0; t < length; t++) {
			    const long actual_sample = t + dummy.size()-1;
			    const long first = actual_sample - 1;
			    const long last = actual_sample;
				x[N + t] = x[N + t - 1] + predictor.predict(NNR + 1, points.point_begin(actual_sample), approximator, first, last);			}
			break;
		}		
		default : 
		{
			if (verbose) mexPrintf("Local constant prediction using direct mean\n");
			constant_weight wg;
			direct_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > fv(points);	
			local_approx< direct_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > , constant_weight> approximator(fv , wg);
					
			for (long t = 0; t < length; t++) {
			    const long actual_sample = t + dummy.size()-1;
			    const long first = actual_sample - 1;
			    const long last = actual_sample;
				x[N + t] = predictor.predict(NNR, points.point_begin(actual_sample), approximator, first, last);			}
			break;
		}	
	}
}	


