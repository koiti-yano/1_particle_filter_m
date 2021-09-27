% solab2GommeKlein2011Rbc.m
% Copyright (c) 2013, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html

%===========================================
%% Initialization
%===========================================
%clear; 
close all;

% The matrices of second-order approximation of of a RBC model
% based on Gomme and Klein (2011).
% [ff,pp,ee,gg,kx,ky]
load('solab2GommeKlein2011Rbc')

% Parameters
modelFlag = 'rbcSecondOrderItera';
%modelFlag = 'rbcSecondOrderMat';

timeLength = 100;

numberOfState = 3;
numberOfObs = 3;
numberOfParticle = 10000;

paramSys.mu = [0.0 0.0];
paramSys.sysSigma = [0.02 0; 0 0.02];
paramSys.nx = 2;
paramSys.ny = 1;

paramSys.kx = kx;
paramSys.pp = pp;
paramSys.gg = gg;

paramSys.ff = ff;
paramSys.ee = ee;
paramSys.ky = ky;

paramObs.mu = [0.0 0.0 0.0];
paramObs.sysSigma = [0.01 0 0; 0 0.01 0; 0 0 0.01];

initialDistr = [0.0 0.0 0.0];

%===========================================
%% Data Generation
%===========================================

% Create state vector
stateGen = zeros(timeLength, numberOfObs);
stateGen(1, :) = initialDistr;

% Observation vector
observedValue = zeros(timeLength, numberOfObs);

for ii = 1:(timeLength-1)
    
    systemNoise = mvnrnd(paramSys.mu, paramSys.sysSigma);
    stateGen(ii+1, :) = systemEquation(stateGen(ii, :), systemNoise, ...
        numberOfState, numberOfParticle, modelFlag, paramSys, ii);
    
    observationNoise = mvnrnd(paramObs.mu, paramObs.sysSigma);
    observedValue(ii+1, :) = observationEquation(stateGen(ii+1, :), ...
        observationNoise, numberOfObs, modelFlag, paramObs, ii);
    
end

% plot generated data
%{
figure; subplot(3,1,1); plot(stateGen(:,1)); title('状態1'); xlabel('時間t')
subplot(3,1,2); plot(stateGen(:,2)); title('状態2'); xlabel('時間t')
subplot(3,1,3); plot(stateGen(:,3)); title('状態3'); xlabel('時間t')

figure; subplot(3,1,1); plot(observedValue(:,1)); title('観測値1'); xlabel('時間t')
subplot(3,1,2); plot(observedValue(:,2)); title('観測値2'); xlabel('時間t')
subplot(3,1,3); plot(observedValue(:,3)); title('観測値3'); xlabel('時間t')
%}

%===========================================
%% Estimation
%===========================================

% Estimation
tic
[stateEstimated, logLikeli, lowerBound, upperBound] = ...
    particleFilter(observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr);
toc

logLikeli


% Results
figure; subplot(3,1,1)
plot(stateGen(:,1), 'k-'); xlabel('Time'); %title('真の状態1と推定値の比較')
hold on
%title('Consumption: C')
title('Technology Level: A')
plot(stateEstimated(:, 1), 'k--o')
legend('True state 1', 'Estimated state 1')
hold off

subplot(3,1,2)
plot(stateGen(:,2), 'k-'); xlabel('Time'); %title('真の状態2と推定値の比較'); 
hold on
title('Capital: K')
plot(stateEstimated(:, 2), 'k--o')
legend('True state 2', 'Estimated state 2')
hold off

subplot(3,1,3)
plot(stateGen(:,3), 'k-'); xlabel('Time'); %title('真の状態3と推定値の比較');
hold on
%title('Technology Level: A')
title('Consumption: C')
plot(stateEstimated(:, 3), 'k--o')
legend('True state 3', 'Estimated state 3')
hold off
%print -deps RbcSecondOrdFilt

%=========================================
