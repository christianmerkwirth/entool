# Ensemble toolbox for Statistical Learning

## Introduction

ENTOOL is a software package dfor ensemble regression modelling. It was developed between 2002 and 2006 by Christian Merkwirth and Jörg Wichard under the supervision of Prof. Maciej Ogorzalek. It is implemented mainly in Matlab, with some time-critical parts written in C/C++ (as mex-functions). Find here an introduction to the Ensemble toolbox as PDF file.
Objectives

Extending the ensemble learning approach to heterogenous ensembles of models

Object-oriented implementation yields a transparent mixture of different models and allows the user to add own model types
Design

The ENTOOL toolbox for statistical learning is designed to make machine learning algorithms available under a common interface.

All model classes share same interface. Changing the model type (e.g. from linear to k-NN) is done by changing the constructur call. This allows for a fast comparison of several model types.

Design goals were:
* To allow construction of single models or ensembles of (optionally heterogenous) models.
* Supporting decorrelation of models by offering resampling techniques.
* Ability to work with very small data sets or moderately high-dimensional problems.

Though primarily designed for regression, it is also possible to construct ensembles of classifiers with ENTOOL
Methods

The toolbox is equipped with several model classes for out-of-box usage:

  *  Linear ridge regression with automatic tuning of the ridge penalty
  *  Polynomial regression
  *  k-nearest-neighbor models with adaptive metric
  *  Neural networks trained by RPROP backpropagation

## Requirements

Matlab (TM) version 6.5 or higher

## Supported Operating systems

Windows and Linux

## Installation

Over the years, the code became a bit rusty and needs some care to work. Before using the ENTOOL, you have to add the path to the ENTOOL directory (e.g. C:\entool1.1) to the MATLAB path. This can be done by Matlab->File->Set Path. Make sure that the file startup.m in the ENTOOL directory is called once before using the ENTOOL.

Alternative: Add the following lines to your global startup.m (replace C:\entool1.1 by the path to which you cloned the repo)

olddir = pwd;
cd('C:\entool1.1')
startup
cd(olddir)

## Acknowledgements

This work was initiated within the Research Training Network COSYC of SENS No. HPRN-CT-2000-00158 within in 5th EU Framework Program of the European Community.
