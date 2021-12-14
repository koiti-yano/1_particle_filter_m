% run41_SIR_sim.m
% Copyright (c) 2021, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html


%===========================================
%% Initialization
%===========================================
clear;
close all;

% Parameters
modelFlag='standardSIR';

timeLength = 100;
numberOfState = 3;
numberOfObs = 3;
numberOfParticle = 1000;

paramSys.mu = [0 0 0];
paramSys.vcov = 0.0 * eye(3);
paramSys.beta = 0.03;
paramSys.gamma = 0.1;

paramObs.mu = [0 0 0];
paramObs.vcov = 0.05 * eye(3);
% Initial Distribution: 
initialDistr = [0.9999 0.0001 0];


%===========================================
%% Data Generation
%===========================================

% Create state vector
stateGen = zeros(timeLength, numberOfState);
stateGen(1, :) = initialDistr;

% Observation vector
observedValue = zeros(timeLength, numberOfObs);

for ii = 1:(timeLength-1)
    
    systemNoise = mvnrnd(paramSys.mu, paramSys.vcov, 1);
    stateGen(ii+1, :) = systemEquation(stateGen(ii, :), systemNoise, ...
        numberOfState, numberOfParticle, modelFlag, paramSys, ii);
    
%    observationNoise = paramObs*randn(numberOfObs);
%    observedValue(ii+1, :) = observationEquation(stateGen(ii+1, :), ...
%        observationNoise, numberOfObs, modelFlag, paramObs, ii);
    
end

plot(stateGen(:, 1))
hold on
plot(stateGen(:, 2))
plot(stateGen(:, 3))
hold off
% plot generated data
%{
subplot(2,1,1) ; plot(stateGen) ; title('èÛë‘'); xlabel('éûä‘t')
subplot(2,1,2) ; plot(observedValue) ; title('äœë™íl'); xlabel('éûä‘t')
%}

%===========================================
%% Estimation (Particle filter)
%===========================================
%{
initialDistr = 0;

% Estimation
tic
[stateEstimated, logLikeli, lowerBound, upperBound] = ...
    particleFilter(observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr);
toc

logLikeli

% Results
figure; plot(stateGen(:,1), 'k-'); xlabel('Time');% title('ê^ÇÃèÛë‘Ç∆êÑíËílÇÃî‰är')
hold on
plot(stateEstimated(:, 1), 'k--o');
legend('True state', 'Estimated state');
plot(lowerBound(:, 1), 'k:');
plot(upperBound(:, 1), 'k:');
hold off
%print -deps one_dim_lin_gauss_filt

%figure; plot(stateEstimated(:, 1), 'k--o'); xlabel('Time');
%hold on
%legend('Estimated state', '95% credible interval');
%hold off
%print -deps one_dim_lin_gauss_filt_credible_intvl
%=========================================
%}
