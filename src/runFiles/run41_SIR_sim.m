% run41_SIR_sim.m
% Copyright (c) 2021, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html


%===========================================
%% Initialization
%===========================================
clear all;
close all;

% Parameters
modelFlag='standardSIR';

timeLength = 100;
numberOfState = 3;
numberOfObs = 3;
numberOfParticle = 1; % シミュレーションの場合

paramSys.mean = [0 0 0];
paramSys.vcov = 0.000001 * eye(3);
paramSys.betaAncestral = 0.279;
paramSys.betaDelta = 0.508;
paramSys.gamma = 0.1;
paramSys.mu = 1;
paramSys.aggEff = zeros(timeLength,1); % An aggregate effectiveness of vaccination = 0

% A paarmeter shitf
paramSys.paramShift = 50;

paramObs.mean = [0 0 0];
paramObs.vcov = 0.000001 * eye(3);
% Initial Distribution: 
initialDistr = [0.999 0.001 0];


%===========================================
%% Data Generation
%===========================================

% Create state vector
stateGen = zeros(timeLength, numberOfState);
stateGen(1, :) = initialDistr;

% Observation vector
observedValue = zeros(timeLength, numberOfObs);
observedValue(1,1) = 1;

for ii = 1:(timeLength-1)
    
    systemNoise = mvnrnd(paramSys.mean, paramSys.vcov, 1);
    stateGen(ii+1, :) = systemEquation(stateGen(ii, :), systemNoise, ...
        numberOfState, numberOfParticle, modelFlag, paramSys, ii);
    
    observationNoise = mvnrnd(paramObs.mean, paramObs.vcov, 1);
    observedValue(ii+1, :) = observationEquation(stateGen(ii+1, :), ...
        observationNoise, numberOfObs, modelFlag, paramObs, ii);
    
end


% plot observed values
plot(observedValue(:, 1), 'LineWidth',1.5) ; 
title("The standard SIR model (\beta=0.508, \gamma=0.1, \mu_t=1)");
xlabel("Time")
hold on
plot(observedValue(:, 2), 'LineWidth',1.5)
plot(observedValue(:, 3), 'LineWidth',1.5)
legend('Susceptible fraction', 'Infectious fraction', 'Removed fraction')
hold off


%===========================================
%% Estimation (Particle filter)
%===========================================
close;
numberOfParticle = 10000; % 1万 
%numberOfParticle = 1000000; % 100万

initialDistr = [1 0 0];

% Estimation
tic
[stateEstimated, logLikeli, lowerBound, upperBound] = ...
    particleFilter(observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr);
toc

logLikeli

% Plots

% Plot simulated data
subplot(2,2,1);
plot(stateGen(:, 1), 'LineWidth',1.5) ; 
title("Simulation: the standard SIR model (\gamma=0.1, \mu_t=1)");
%title("Simulation: the standard SIR model (\beta=0.508, \gamma=0.1, \mu_t=1)");
xlabel("Time")
hold on
plot(stateGen(:, 2), 'LineWidth',1.5)
plot(stateGen(:, 3), 'LineWidth',1.5)
legend('Susceptible fraction', 'Infectious fraction', 'Removed fraction')
hold off

% Susceptible fraction
subplot(2,2,2);
plot(stateGen(:,1), 'k-'); xlabel('Time');
title('Real data and estimation: susceptible fraction ')
hold on
plot(stateEstimated(:, 1), 'k--o');
legend('True state', 'Estimated state');
plot(lowerBound(:, 1), 'k:');
plot(upperBound(:, 1), 'k:');
hold off
%print -deps one_dim_lin_gauss_filt

% Infectious fraction
subplot(2,2,3);
plot(stateGen(:,2), 'k-'); xlabel('Time');
title('Simultion and estimation: infectious fraction ')
hold on
plot(stateEstimated(:, 2), 'k--o');
legend('True state', 'Estimated state');
plot(lowerBound(:, 2), 'k:');
plot(upperBound(:, 2), 'k:');
hold off

% Removed fraction
subplot(2,2,4);
plot(stateGen(:,3), 'k-'); xlabel('Time');
title('Simultion and estimation: removed fraction ')
hold on
plot(stateEstimated(:, 3), 'k--o');
legend('True state', 'Estimated state');
plot(lowerBound(:, 3), 'k:');
plot(upperBound(:, 3), 'k:');
hold off
