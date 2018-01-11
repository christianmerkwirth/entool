% ENTOOL - Toolbox for Ensemble Regression Modelling and Statistical Learning
%
% @ares - Primary model class for ARES (Adaptive Regression Splines) models                 
% @baseline - Primary model class for baseline models (constant output for all inputs)
% @crosstrainensemble - Secondary model class for creating crosstrained ensembles   
% @crosstrainensemble2 - Secondary model class for creating crosstrained ensembles    
% @cvensemble - Secondary model class for creating crossvalidation ensembles (e.g. for OOT validation)             
% @ensemble - Virtual base class for all ensembles classes               
% @perceptron - Primary model class for feedforward multilayer neural networks models with iRPROP+ training             
% @perceptron2 - Primary model class for feedforward singlelayer neural networks models, taken from Noorgard's NNSYSID toolbox              
% @perceptron3 - Primary model class for feedforward multilayer neural networks models with mex-file iRPROP+ training          
% @polynomial - Primary model class for multidimensional polynamial models             
% @prbfn - Primary model class for PRBFN (hybrid neural network and radial basis function models) by Shimon Cohen                 
% @quadraticbasis - Basis expander class, expands basis to all polynomials up to degree of 2     
% @rbf - Primary model class for radial basis function models by Marc Orr                    
% @ridge - Primary model class for ridge regression with automatic determination of optimal ridge penalty by means of LOO CV                  
% @subspaceensemble - Secondary model class for creating subspace ensembles (each model is trained on a subspace of all inputs)     
% @vicinal - Primary model class for k-nearest neighbor modelling with weighted metric                 
% @vicinal2 - Primary model class for k-nearest neighbor modelling with automatic feature selection                          
% demos - demo directory                 
% documentation - documentation directory              
% install.m - script for automatic compilation and installation             
% mextools - mextools directory containing C++ code (mostly .h) for fast mex-file development                
% startup.m - startup script that includes all necessary entool path              
% testsuite - directory containing m-files for testing the entool package             
% tools - directory containing single m-files and mex-files together with C++ source code and ATRIA neighbor code     
%
% Christian Merkwirth 2004


