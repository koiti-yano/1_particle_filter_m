% kalmanPrediction.m
% Copyright (c) 2016, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html
%
% Kalman Smoothing
% A(t) = V(t|t) F' V(t+1|t)^(-1),
% x(t|T) = x(t|t) + A(t) ( x(t+1|T) - x(t+1|t) ), 
% V(t|T) = V(t|t) + A(t) ( V(t+1|T) - V(t+1|t) ) A(t)',
% where x(t|t) = stateEst, F = FF, V(t|t) = covMatEst, x(t+1|t) =
% statePred, V(t+1|t) = covMatPred.
% 
% References:
% Kitagawa, G., (2010), Introduction to Time Series Modeling, Chapman and Hall/CRC

function [ stateSmooth, covMatSmooth ] = kalmanSmoothing( stateEst, ...
    covMatEst, statePred,  covMatPred, FF )

[numberOfState, timeLength] =size(stateEst);

stateSmooth = zeros(numberOfState, timeLength);
covMatSmooth = zeros(numberOfState, numberOfState, timeLength);

stateSmooth(:, timeLength) = stateEst(:, timeLength);
covMatSmooth(:, :, timeLength) = covMatEst(:, :, timeLength);

stSmth = stateEst(:, timeLength);
covSmth = covMatEst(:, :, timeLength);

for ii = (timeLength-1):-1:1
    %disp(ii)
    A = covMatEst(:,:,ii) * FF.' / covMatPred(:,:,ii+1);
    
    stSmth = stateEst(:,ii) + A * (stSmth - statePred(:, ii+1));
    stateSmooth(:, ii) = stSmth;
    
    covSmth = covMatEst(:, :, ii) + A * (covSmth - covMatPred(:, :, ii+1))* A.';
    covMatSmooth(:, :, ii) = covSmth;

end

end

