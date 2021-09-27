% kalmanPrediction.m
% Copyright (c) 2016, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html
%
% Kalman Update
% x(t|t-1) = F x(t-1|t-1),
% V(t|t-1) = F V(t-1|t-1) F' + Q, 
% where x = statev, F = FF, V = covMat, and Q = sigmaQ. 
% 
% References:
% Kitagawa, G., (2010), Introduction to Time Series Modeling, Chapman and Hall/CRC

function [ stateV, covMat ] = kalmanPrediction( stateV, covMat, FF, sigmaQ )

stateV = FF * stateV;

covMat = FF * covMat * FF.' + sigmaQ;

end

