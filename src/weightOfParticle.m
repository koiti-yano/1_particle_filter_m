% weightOfParticle.m
% Copyright (c) 2013, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html

function [state, weight, llk] = weightOfParticle(likehoodInBayes, ...
    observedValue, state, numberOfState, ...
    numberOfObs, numberOfParticle, ...
    modelFlag, paramObs, timeIndex)

likelihood = likelihoodInBayes(observedValue, ...
    state, numberOfObs, numberOfParticle, modelFlag, paramObs, timeIndex);

%===== Caluclating the log-liklehood before normalization ===
% Note: (1) removing zero, (2) normilizing weights, (3) log-likelihood.
% The order of (1), (2) and, (3) is important to run run5RbcSecondOrdFilt.
%
% (1) To avoid -Inf in log-likelihood, remove zero.
likelihood(likelihood==0, :) = 1/1.0e20; % Logical indexing

% (2) Normalizing weights
weight = likelihood/sum(likelihood);

% (3) Calculate log-likelihood
likeli = sum(likelihood)/numberOfParticle;
llk = log(likeli);

%=========================================

