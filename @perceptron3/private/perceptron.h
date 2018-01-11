#ifndef PERCEPTRON_H
#define PERCEPTRON_H

#include <stdio.h>
#include <math.h>
#include <vector.h>
#include <algo.h>

#include "mextools/mextools.h"
#include "mextools/random.h"

// when PERCEPTRON_CALC  is defined, the code that is purely needed for the training is omitted, resulting in smaller executable size
// and smaller memory requiredment for storing the state of each neuron
#ifdef PERCEPTRON_CALC  
    #define ONLY_CALC
#endif

#include "mextools/nnetwork.h"

//static Random<MT_RNG> rng;

class layer {
    public:
    
    int nr_inputs;
    int nr_outputs;
    
    int nonlinearity;
    
    double weightdecay; 
    
    vector<state> weights;
    state offset;               // scalar intercept
    
    layer(const int NR_inputs, const int NR_outputs, const int Nonlinearity = 1) : 
        nr_inputs(NR_inputs+1), nr_outputs(NR_outputs), nonlinearity(Nonlinearity),  weightdecay(0.0),
        weights(nr_inputs * nr_outputs)
        {};
       
    ~layer() {};    

#ifndef PERCEPTRON_CALC    
    void initialize(const double initial_weightspan, const double initial_stepsize, const double Weightdecay) {
        
        weightdecay = Weightdecay;
        
        for (long i=0; i < weights.size(); i++) {
            weights[i].weight = initial_weightspan * (rng()+rng()-1.0);
            weights[i].grad = 0.0;
            weights[i].lastgrad = 0.0;
            weights[i].stepsize = initial_stepsize;
            weights[i].laststep = 0.0;
        }

        offset.weight = initial_weightspan * (rng()+rng()-1.0);
        offset.grad = 0.0;
        offset.lastgrad = 0.0;
        offset.stepsize = initial_stepsize;
        offset.laststep = 0.0;
    }
    
    // perform one iRPROP step 
    double rprop_step(const double err, const double lasterr, const double weightlimit) {
        // update only weights actually used
    
        double sum_squared_weights = 0.0;
        
        for (long i=0; i < weights.size(); i++) {
            sum_squared_weights += weights[i].rprop_step(err, lasterr, weightdecay, weightlimit);
        }
        
        sum_squared_weights += offset.rprop_step(err, lasterr, weightdecay, weightlimit);
        
        return sum_squared_weights;
    }
#endif    
};


class network {
    public:
        long nr_layers;
     
        vector<layer> layers;
        state offset;
        
        double weightdecay;
        
        network(const vector<int> topology) : nr_layers(topology.size()-1) 
        {
            for (int i=0; i < nr_layers; i++) {
                if (i == (nr_layers - 1)) {
                    // no nonlinearity for last layer
                    layers.push_back(layer(topology[i], topology[i+1], 0));
                } else {
                    layers.push_back(layer(topology[i], topology[i+1], 1));
                }
            }
        };
        ~network() {};
        
#ifndef PERCEPTRON_CALC            
        void initialize(const double initial_weightspan, const double initial_stepsize, const double Weightdecay) {
            weightdecay = Weightdecay;
        
            // initialize all layers 
            for (long i=0; i < layers.size(); i++) {
                layers[i].initialize(initial_weightspan, initial_stepsize, weightdecay);
            }
                
            offset.weight = initial_weightspan * (rng()+rng()-1.0);
            offset.grad = 0.0;
            offset.lastgrad = 0.0;
            offset.stepsize = initial_stepsize;
            offset.laststep = 0.0;
        }
        
        // perform one iRPROP step 
        double rprop_step(const double err, const double lasterr, const double weightlimit) {
            double sum_squared_weights = 0.0;
        
            for (long i=0; i < layers.size(); i++) {
                sum_squared_weights += layers[i].rprop_step(err, lasterr, weightlimit);    
            }

            //  No weight decay for this offset
            offset.rprop_step(err, lasterr, 0.0, weightlimit);
            
            return sum_squared_weights;
        }

#endif        
};        
        

template<class iterator>
pair<vector<double>, vector<double> > forward(iterator input, const layer& lay)
{
    vector<double> z(lay.nr_outputs);
    vector<double> zder(lay.nr_outputs);
    
    vector<state>::const_iterator it = lay.weights.begin();
    
    for(long j=0; j < lay.nr_outputs; j++) {
        z[j] = (*(it++)).weight; 
        for(long i=0; i < lay.nr_inputs-1; i++) {
            z[j] += input[i] * (*(it++)).weight;
        }
        
        if (lay.nonlinearity) {
            pair<double, double> act;
 		
		    if (j % 2) {
			    act =  sigmoid(z[j]);     
		    } else {
			    act =  rbf(z[j]);
		    }	
		    z[j] = act.first;
		    zder[j] = act.second;
        } else {
            zder[j] = 1.0;
        }
    }
    
    return make_pair(z, zder);
}

#ifndef PERCEPTRON_CALC
template<class iterator>
vector<double> backward(vector<double> gprevious, const vector<double>& zder, iterator input, layer& lay)
{
    vector<double> g(lay.nr_inputs-1, 0.0);
    
    vector<state>::iterator it = lay.weights.begin();
    
    for(long j=0; j < lay.nr_outputs; j++) {
        gprevious[j] *= zder[j];
        
        (*(it++)).grad += gprevious[j];
        for(long i=0; i < lay.nr_inputs-1; i++) {
            g[i] += gprevious[j] * (*(it)).weight;
            (*it).grad += gprevious[j] * input[i];
            
            it++;    
        }
    }
    
    return g;       // give gradient information back to previous layer
}
#endif

#endif

