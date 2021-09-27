% kalmanUpdate.m
% Copyright (c) 2016, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html
%
% Kalman update
% d(t|t-1)     = H V(t|t-1) H' + R % Covariance matrix of prediction error
% K(t)         = V(t|t-1) H' d(t|t-1)^(-1) % Kalman gain
% \tilde{y}(t) = y(t) - H x(t|t-1) % Prediction Error
% x(t|t)       = x(t|t-1) + K(t) \tilde(y}(t) % Filtered state
% V(t|t)       = V(t|t-1) - K(t) H V(t|t-1), % Filtered covariance of state
%
% References:
% Kitagawa, G., (2010), Introduction to Time Series Modeling, Chapman and Hall/CRC


function [ stateV, covMat, predErr, covPredErr ] = kalmanUpdate( observation, ...
    stateV, covMat, HH, sigmaR)

covPredErr = HH * covMat * HH.' + sigmaR;
kalmanGain = covMat * HH.' / covPredErr; % Kalman gain
% kalmanGain = covMat * HH.' * inv( covPredErr); % Kalman gain (test code)
predErr     = observation - HH * stateV;
stateV     = stateV + kalmanGain * predErr;
covMat     = covMat - kalmanGain * HH * covMat;

end

