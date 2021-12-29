% run51_Kalman_TwoDimLinGausFilt.M
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
numberOfState = 2;
numberOfObs = 2;

% Parameters in a system equation for the Kalman filter
FF = [1. 0. ; 0. 1.0];
sigmaQ = [1.0 0.5 ; 0.5 1.0];
initialDistr = [0; 0];
muSys = zeros(numberOfState, 1);

% Parameters in an observation equation
HH = [1 0 ; 0 1];
sigmaR = [0.5 0.2 ; 0.2 0.5];
muObs = zeros(numberOfObs, 1);

%===========================================
%% Data Generation
%===========================================

% Create state vector
stateGen = zeros(numberOfState, timeLength);
stateGen(:, 1) = initialDistr;

% Observation vector
observedValue = zeros(numberOfObs, timeLength);

for ii = 1:(timeLength-1)
    
    systemNoise = mvnrndWrapper(muSys, sigmaQ, 1);
    
    stateGen(:, ii+1) = systemEquationKalman( stateGen(:, ii), systemNoise, ...
        FF );
    
    observationNoise = mvnrndWrapper(muObs,sigmaR, 1);
    %disp(observationNoise);
    observedValue(:, ii+1) = observationEquationKalman( stateGen(:, ii+1), ...
        observationNoise, HH );
    
end

% plot generated data

if 0 % To plot, set 1.
figure; 
subplot(2,1,1); 
plot(stateGen(1, :)); title('State 1'); xlabel('Time t')
subplot(2,1,2); 
plot(stateGen(2, :)); title('State 2'); xlabel('Time t')

figure; 
subplot(2,1,1); 
plot(observedValue(1, :)); title('State 1'); xlabel('Time t')
subplot(2,1,2); 
plot(observedValue(2, :)); title('State 2'); xlabel('Time t')
end

%===========================================
%% State estimation (Kalman filter)
%===========================================
stateInit = [0; 0];
covInit = [100 100; 100 100];

% State estimation
tic
[ stateEst, covMatEst, logLikeli, statePred,  covMatPred ] =  ...
    kalmanFilterInvariant( observedValue, FF, HH, sigmaQ, sigmaR, ...
    stateInit, covInit);
toc

logLikeli

figure; 
subplot(2,1,1)
plot(stateGen(1,:), 'k'); title('True state and filtered state 1'); xlabel('Time t')
hold on
plot(stateEst(1, :), 'r-o')
legend('True state 1', 'Filtered state1')
hold off

subplot(2,1,2)
plot(stateGen(2,:), 'k'); title('True state 2‚Æfiltered state 2'); xlabel('Time t')
hold on
plot(stateEst(2, :), 'r-o')
legend('True state2', 'Filtered state 2')
hold off

%===========================================
%% Estimation (Kalman smoother)
%===========================================


[ stateSmooth, covMatSmooth ] = kalmanSmoothing( stateEst, ...
    covMatEst, statePred,  covMatPred , FF);

figure; 
subplot(2,1,1)
plot(stateGen(1,:), 'k'); title('True state 1 and Filtered state 1'); xlabel('Time t')
hold on
plot(stateSmooth(1, :), 'r-o')
plot(stateEst(1, :), 'b-*')
legend('True state 1', 'Smoothed state 1', 'Filtered state 1')
hold off

subplot(2,1,2)
plot(stateGen(2,:), 'k'); title('True state 2 and Filtered state 1'); xlabel('Time t')
hold on
plot(stateSmooth(2, :), 'r-o')
plot(stateEst(2, :), 'b-*')
legend('True state 2', 'Smoothed state 2', 'Filtered state 2')
hold off

figure;
subplot(2,1,1)
plot(abs(stateGen(1,:) - stateSmooth(1,:)), 'k')
hold on 
plot(abs(stateGen(1,:) - stateEst(1,:)), 'r-o')
hold off
subplot(2,1,2)
plot(abs(stateGen(2,:) - stateSmooth(2,:)), 'k')
hold on 
plot(abs(stateGen(2,:) - stateEst(2,:)), 'r-o')
hold off

%mean(abs(stateGen(1,:) - stateSmooth(1,:)))
%mean(abs(stateGen(1,:) - stateEst(1,:)))
%mean(abs(stateGen(2,:) - stateSmooth(2,:)))
%mean(abs(stateGen(2,:) - stateEst(2,:)))
