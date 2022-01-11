% run01OneDimLinGaus.M
% Copyright (c) 2013, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html


%===========================================
%% Initialization
%===========================================
%clear;
%close all;

% Parameters
modelFlag='oneDimLinearGaussian';

timeLength = 100;
numberOfState = 1;
numberOfObs = 1;
numberOfParticle = 10000;
paramSys = 1;
paramObs = 0.8;
initialDistr = 1;

%===========================================
%% Data Generation
%===========================================

% Create state vector
stateGen = zeros(timeLength, numberOfState);
stateGen(1, :) = initialDistr;

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
subplot(2,1,1) ; plot(stateGen) ; title('状態'); xlabel('時間t')
subplot(2,1,2) ; plot(observedValue) ; title('観測値'); xlabel('時間t')
%}

%===========================================
%% State estimation (Particle filter)
%===========================================

initialDistr = 0;

% State estimation
tic
[stateEstimated, logLikeli, lowerBound, upperBound] = ...
    particleFilter(observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr);
toc

disp("Log-likelihood: " + logLikeli);

% Results
figure; plot(stateGen(:,1), 'k-'); xlabel('Time');% title('真の状態と推定値の比較')
hold on
plot(stateEstimated(:, 1),  'k--o');
plot(lowerBound(:, 1), 'k:');
plot(upperBound(:, 1), 'k:');
legend('True state', 'Estimated state', 'Lower bound', 'Upper bound');
hold off
%print -deps one_dim_lin_gauss_filt

%figure; plot(stateEstimated(:, 1), 'k--o'); xlabel('Time');
%hold on
%legend('Estimated state', '95% credible interval');
%hold off
%print -deps one_dim_lin_gauss_filt_credible_intvl
%=========================================

%===========================================
%% State estimation (Particle filter), parameter miscalibrated 
%===========================================

initialDistr = 0;
paramObs = 0.8; % paramObs = 0.8 is correct.

% State estimation
tic
[stateEstimatedMis, logLikeliMis, lowerBoundMis, upperBoundMis] = ...
    particleFilter(observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr);
toc

disp("Log-likelihood: " + logLikeliMis);

% Results
figure; plot(stateGen(:,1), 'k-'); xlabel('Time');% title('真の状態と推定値の比較')
hold on
plot(stateEstimatedMis(:, 1), 'k--o');
plot(lowerBoundMis(:, 1), 'k:');
plot(upperBoundMis(:, 1), 'k:');
legend('True state', 'Estimated state (miscalibrated parameter)', 'Lower bound', 'Upper bound');
hold off
%print -deps one_dim_lin_gauss_filt

%figure; plot(stateEstimated(:, 1), 'k--o'); xlabel('Time');
%hold on
%legend('Estimated state', '95% credible interval');
%hold off
%print -deps one_dim_lin_gauss_filt_credible_intvl
%=========================================



