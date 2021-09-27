% example2NonLin.M
% Copyright (c) 2013, Koiti Yano
% This script generate observed value.
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html

%===========================================
%% Initialization
%===========================================
clear; close all;

% Parameters
modelFlag='oneDimNonLinear';

timeLength = 100;
numberOfState = 1;
numberOfObs = 1;
numberOfParticle = 1000;
paramSys = 1;
paramObs = 3;
initialDistr = 0.;

%===========================================
%% Data Generation
%===========================================

% Create state vector
stateGen = zeros(timeLength, numberOfObs);
stateGen(1, :) = initialDistr + 5*randn(1);

% Observation vector
observedValue = zeros(timeLength, numberOfObs);

for ii = 1:(timeLength-1)
    
    systemNoise = paramSys*randn(numberOfState);
    stateGen(ii+1, :) = systemEquation(stateGen(ii, :), systemNoise, ...
        numberOfState, numberOfParticle, modelFlag, paramSys, ii);
    
    observationNoise = paramObs*randn(numberOfObs);
    observedValue(ii+1, :) = observationEquation(stateGen(ii+1, :), ...
        observationNoise, numberOfObs, modelFlag, paramObs, ii);
    
end
% plot generated data
%{
subplot(2,1,1) ; plot(stateGen) ; title('èÛë‘'); xlabel('éûä‘t')
subplot(2,1,2) ; plot(observedValue) ; title('äœë™íl'); xlabel('éûä‘t')
%}

%===========================================
%% Estimation (Auxiliary particle filter)
%===========================================

initialDistr = 0;

% Estimation
tic
[auxStateEstimated, auxLogLikeli, auxLowerBound, auxUpperBound] = ...
    auxiliaryParticleFilter(observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr);
toc

auxLogLikeli

subplot(2,1,1); 
plot(stateGen(:,1), 'k-'); xlabel('Time'); ylim([-20 20]);% True state
title('Auxiliary particle filter');
hold on
plot(auxStateEstimated(:, 1), 'k--o'); xlabel('Time');
plot(auxLowerBound(:, 1), 'k:');
plot(auxUpperBound(:, 1), 'k:');
legend('True state', 'Estimated state (APF)', '95% credible interval');
hold off


%===========================================
%% Estimation (Particle filter)
%===========================================

% Estimation
tic
[stateEstimated, logLikeli, lowerBound, upperBound] = ...
    particleFilter(observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr);
toc

logLikeli

subplot(2,1,2); 
plot(stateGen(:,1), 'k-'); xlabel('Time'); ylim([-20 20]);% True state
title('Particle filter');
hold on
plot(stateEstimated(:, 1), 'k--o'); xlabel('Time');
plot(lowerBound(:, 1), 'k:');
plot(upperBound(:, 1), 'k:');
legend('True state','Estimated state (PF)', '95% credible interval');
hold off
%print -deps NonLinFilt

figure; plot(stateEstimated - auxStateEstimated);
%=========================================

