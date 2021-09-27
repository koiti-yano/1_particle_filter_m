% run51_Kalman_OneDimLinGausFilt.M
% Copyright (c) 2016, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html
%
% A state space model is defined by a system equation and an observation
% equation as follows.
%     state(t) = FF * state(t-1) + systemNoise
%     observaton(t) = HH * state(t) + observationNoise,
% where t is a time index. Given observations, we estimate state(t) 
% using the Kalman filter and Kalman smoother.
%
% References:
% Kitagawa, G., (2010), Introduction to Time Series Modeling, Chapman and Hall/CRC

%===========================================
%% Initialization
%===========================================
clear;

% Time length of observation
timeLength = 100;

% Define the numbers of states and observations
numberOfState = 1;
numberOfObs = 1;

% Parameters in a system equation for the Kalman filter
FF = 1;
sigmaQ = 1;
initialDistr = 0;

% Parameters in an observation equation
HH = 1;
sigmaR = 1;

%===========================================
%% Data Generation
%===========================================

% Create state vector
stateGen = zeros(numberOfState, timeLength);
stateGen(:, 1) = initialDistr;

% Observation vector
observedValue = zeros(numberOfObs, timeLength);

for ii = 1:(timeLength-1)
    
    systemNoise = sigmaQ*randn(numberOfState);
    stateGen(:, ii+1) = systemEquationKalman( stateGen(:, ii), systemNoise, ...
        FF );
    
    observationNoise = sigmaR*randn(numberOfObs);
    observedValue(:, ii+1) = observationEquationKalman( stateGen(:, ii+1), ...
        observationNoise, HH );
    
end

% plot generated data
if 0 % To plot, set 1.
figure;
subplot(2,1,1) ; plot(stateGen) ; title('State'); xlabel('Time t')
subplot(2,1,2) ; plot(observedValue) ; title('Observation'); xlabel('Time t')
end

%===========================================
%% Estimation (Kalman filter)
%===========================================

stateInit = 0;
covInit = 100;

% Estimation
tic
[ stateEst, covMatEst, logLikeli, statePred,  covMatPred ] =  ...
    kalmanFilterInvariant( observedValue, FF, HH, sigmaQ, sigmaR, ...
    stateInit, covInit);
toc

logLikeli

% Results
figure; 
plot(stateGen, 'k-'); xlabel('Time'); title('True state and estimated state')
hold on
plot(stateEst, 'r-o');
plot(statePred, 'b-*');
legend('True state', 'Estimated state', 'Predicted state');
hold off
%print -deps one_dim_lin_gauss_filt

%===========================================
%% Estimation (Kalman smoother)
%===========================================


[ stateSmooth, covMatSmooth ] = kalmanSmoothing( stateEst, ...
    covMatEst, statePred,  covMatPred , FF);

figure; 
plot(stateGen, 'k-'); xlabel('Time'); title('True state and smooted state')
hold on
plot(stateSmooth, 'r-o');
plot(stateEst, 'b-*');
legend('True state', 'Smoothed state', 'Filtered state');
hold off


figure;
plot(abs(stateGen - stateSmooth),  'k-')
hold on 
plot(abs(stateGen - stateEst), 'r-o')
hold off

diffDgpSmooth = mean(abs(stateGen - stateSmooth));
diffDgpFilt= mean(abs(stateGen - stateEst));
strng = ['Diff (smooth):', num2str(diffDgpSmooth), ', Diff (filter):', num2str(diffDgpFilt)];
disp(strng);
