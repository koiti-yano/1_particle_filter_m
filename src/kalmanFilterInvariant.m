% kalmanFilterInvariant.m
% Copyright (c) 2016, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html
% References:
% Kitagawa, G., (2010), Introduction to Time Series Modeling, Chapman and Hall/CRC

function [ stateEst, covMatEst, logLikeli, statePred,  covMatPred] = ...
    kalmanFilterInvariant( observedValue, FF, HH, sigmaQ, sigmaR, ... 
    stateInit, covInit)


[numberOfObs , timeLength] = size(observedValue);
[numberOfState, ~] =size(stateInit);

statePred = zeros(numberOfState, timeLength);
covMatPred = zeros(numberOfState, numberOfState, timeLength);

stateEst = zeros(numberOfState, timeLength);
covMatEst = zeros(numberOfState, numberOfState, timeLength);


stateV = stateInit;
covMat = covInit;
logLikeli = 0;

for ii = 1:timeLength
    
    [ stateV, covMat ] = kalmanPrediction( stateV, covMat, FF, sigmaQ);
    statePred(:,ii) = stateV;
    covMatPred(:, :, ii) = covMat;
    
    [ stateV, covMat, predErr, covPredErr ] = kalmanUpdate(  ...
        observedValue(:, ii), stateV, covMat, HH, sigmaR);
    stateEst(:,ii) = stateV;
    covMatEst(:, :, ii) = covMat;
    
    % Log-likelihood, recursively calculated.
    logLikeli = logLikeli - (1/2) * ( numberOfObs * timeLength * log(2*pi) ...
        + log(det(covPredErr)) + predErr.' / (covPredErr) * predErr );
%    covFiltMar(:,:,i) = covMat;

end

end

