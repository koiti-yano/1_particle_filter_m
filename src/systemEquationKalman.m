% Copyright (c), Koiti Yano, 2016
% A system equation of a state space model.
% To run this function, Statistics and Machine Learning Toolbox is required.

function [ state ] = systemEquationKalman( state, systemNoise, FF )
% This function defines a system equation of a state space model.
% A system function is defined by 
% x(t) = F * x(t-1) + v(t), v(t) ~ N(0, sigmaQ)
%

state = FF * state + systemNoise;

end

