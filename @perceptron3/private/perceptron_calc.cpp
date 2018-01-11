#include <stdio.h>
#include <math.h>
#include <vector.h>
#include <algo.h>
#include <pair.h>

// Compile with mex  -I../../../../../entool -I../../../entool/ perceptron_calc.cpp perceptron.cpp  -O -v -DPERCEPTRON_CALC

// Defining PERCEPTRON_CALC during compilation will discard all fields and routines needed for training the network, thus saving memory


#include "mextools/mextools.h"

#include "perceptron.h"


int verbose = 0;

vector<double> calc(mmatrix& x, const network& net)
{
    const long nr_samples = x.getM();
    vector<double> yh(nr_samples);
     
    vector< pair<vector<double>, vector<double> > > activations(net.nr_layers); 
            
    for (long i=0; i < nr_samples; i++) {    
        activations[0] = forward(x.row_begin(i+1), net.layers[0]);
        
        for (long l=1; l < net.nr_layers; l++) {
            activations[l] = forward(activations[l-1].first.begin(), net.layers[l]);
        }
     
        yh[i] = net.offset.weight + activations[net.nr_layers-1].first[0]; 
    }        
           
    
    return yh;
}

void load_states(const mxArray* array, vector<state>& v, const int m, const int n)
{  
    double* ptr = mxGetPr(array);
    
    for (long i=0; i < v.size(); i++) {
        v[i].weight = ptr[i];
    }
}


void mexFunction(int nlhs, mxArray  *plhs[], int nrhs, const mxArray  *prhs[])       
{                   
	if (nrhs < 3) {
		mexErrMsgTxt("yh = perceptron_calc(x, net, offset, (verbose))\n");
		return;
	}
	if (nrhs > 3) {
	    verbose = (int) *mxGetPr(prhs[3]);
	} else {
	    verbose = 0;
	}
	    	
	const int nr_layers = mxGetM(prhs[1]) * mxGetN(prhs[1]);     // number of layers
	
	if (nr_layers < 0)  {
		mexErrMsgTxt("number of layers must be zero or higher \n");
		return;
	}
	
	mmatrix x(prhs[0]);
	const long nr_samples = mxGetM(prhs[0]);
	const long dimension = mxGetN(prhs[0]);
	
    if (verbose) {
        mexPrintf("Total number of samples of dimension %d : %d\n", dimension, nr_samples);
	 }      
	 
    vector<int> topology(nr_layers+1);
    
    topology[0] = dimension;
    for (int i = 0; i < nr_layers; i++) {
        topology[i+1] = mxGetN(mxGetCell(prhs[1], i));
	}
	
    if (verbose) {     
        for (int i=0; i < topology.size(); i++)
            mexPrintf("number of hidden neurons for layer %d : %d\n", i+1, topology[i]);
           
        mexPrintf("Size of struct state : %d\n", sizeof(state));
    }
	
    network net(topology);
    
    for (int i = 0; i < nr_layers; i++) {
        load_states(mxGetCell(prhs[1], i), net.layers[i].weights, mxGetM(mxGetCell(prhs[1], i)), mxGetN(mxGetCell(prhs[1], i)));
	}
    
    net.offset.weight = *mxGetPr(prhs[2]);
    
	vector<double> yh = calc(x, net);
 
    plhs[0] = mxCreateDoubleMatrix(yh.size(),1, mxREAL);  
    double* const yh_ptr = mxGetPr(plhs[0]);
    copy(yh.begin(), yh.end(), yh_ptr);
}

