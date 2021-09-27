% Copyright (c) 2012, Diego Andres Alvarez Marin
% All rights reserved.
% http://www.mathworks.com/matlabcentral/fileexchange/35468-particle-filter-tutorial/content/particle_filter/particle_filter.m
% [References]
% Lennart Svensson, (2012), "Comments on the resampling step in particle filtering"
%
% Modified by Koiti Yano
function [ index ] = resamplingSystematic(index, weight)

Ns = length(weight); % Number of particle
edges = min([0 cumsum(weight)'],1); % protect against accumulated round-off
edges(end) = 1;                 % get the upper edge exact
u1 = rand/Ns;
% this works like the inverse of the empirical distribution and returns
% the interval where the sample is to be found
[~, index] = histc(u1:1/Ns:1, edges);

end