% Copyright (c), Koiti Yano, 2016
% A observation equation of a state space model.
% To run this function, Statistics and Machine Learning Toolbox is required.

function [ observation ] = observationEquationKalman( state, observationNoise, HH )
% This function defines a observation equation of a state space model.
% A system function is defined by 
% y(t) = H * x(t) + w(t), w(t) ~ N(0, sigmaR)
%
%[dimX, ~] = size(state);
%mu = zeros(dimX, 1);
%wVec = mvnrnd(mu,sigmaR, 1)';

observation = HH * state + observationNoise;

end

