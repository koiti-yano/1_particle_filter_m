% example3TwoDimLinGaus.m
% Copyright (c) 2013, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html

%===========================================
%% Initialization
%===========================================
clear; close all;

% Parameters
modelFlag = 'twoDimLinearGaussian';

timeLength = 100;

numberOfState = 2;
numberOfObs = 2;
numberOfParticle = 10000;

paramSys.mu = [0. 0.];
paramSys.sysSigma = [1 0.5; 0.5 1.];

paramObs.mu = [0.0 0.0];
paramObs.sysSigma = [1 0; 0 1.];

initialDistr = [0.1 0.2];

%===========================================
%% Data Generation
%===========================================

% Create state vector
stateGen = zeros(timeLength, numberOfState);
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
figure; subplot(2,1,1); plot(stateGen(:,1)); title('���1'); xlabel('����t')
subplot(2,1,2); plot(stateGen(:,2)); title('���2'); xlabel('����t')

figure; subplot(2,1,1); plot(observedValue(:,1)); title('�ϑ��l1'); xlabel('����t')
subplot(2,1,2); plot(observedValue(:,2)); title('�ϑ��l2'); xlabel('����t')

%===========================================
%% State estimation
%===========================================

% State estimation
tic
[stateEstimated, logLikeli, lowerBound, upperBound] = ...
    particleFilter(observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr);
toc

disp("Log-likelihood: " + logLikeli);

% Results
figure; subplot(2,1,1)
plot(stateGen(:,1)); title('�^�̏��1�Ɛ���l�̔�r'); xlabel('����t')
hold on
plot(stateEstimated(:, 1), 'r-o')
legend('�^�̏��1', '���肳�ꂽ���1')
hold off

subplot(2,1,2)
plot(stateGen(:,2)); title('�^�̏��2�Ɛ���l�̔�r'); xlabel('����t')
hold on
plot(stateEstimated(:, 2), 'r-o')
legend('�^�̏��2', '���肳�ꂽ���2')
hold off

%=========================================

%===========================================
%% State estimation with parameter misclibrated
%===========================================
paramObs.sysSigma = [3 0; 0 3];

% State estimation
tic
[stateEstimatedMis, logLikeliMis, lowerBoundMis, upperBoundMis] = ...
    particleFilter(observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr);
toc

disp("Log-likelihood: " + logLikeliMis);


% Results
figure; subplot(2,1,1)
plot(stateGen(:,1)); title('�^�̏��1�Ɛ���l�̔�r'); xlabel('����t')
hold on
plot(stateEstimatedMis(:, 1), 'r-o')
legend('�^�̏��1', '���肳�ꂽ���1')
hold off

subplot(2,1,2)
plot(stateGen(:,2)); title('�^�̏��2�Ɛ���l�̔�r'); xlabel('����t')
hold on
plot(stateEstimatedMis(:, 2), 'r-o')
legend('�^�̏��2', '���肳�ꂽ���2')
hold off

%=========================================
