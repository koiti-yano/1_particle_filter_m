% example1OneDimLinGausSmthRWMH.M
% Copyright (c) 2013, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html

%===========================================
%% Initialization
%===========================================
clear all;
close all;

% Parameters
modelFlag='oneDimLinearGaussian';
rwmhDebugFlag = 'normalRoute';
timeLength = 100;
numberOfState = 1;
numberOfObs = 1;
numberOfParticle = 20000;
paramSys = 1;
paramObs = 0.5;
initialDistr = 1;
fixedLag = 50;

paramMCMC.burnin = 1; % バーンイン
paramMCMC.numLoop = 1; % RW Metropilis-Hastings法の繰り返し回数
paramMCMC.scaleFactor = 0.1; % スケールファクター

%===========================================
%% Data Generation
%===========================================

% Create state vector
stateGen = zeros(timeLength, numberOfObs);
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
%subplot(2,1,1) ; plot(stateGen) ; title('状態'); xlabel('時間t')
%subplot(2,1,2) ; plot(observedValue) ; title('観測値'); xlabel('時間t')


%===========================================
%% Smoothing with saved particles
%===========================================

initialDistr = 0;

%  Smoothing with saved particles
tic
[stateSmoothed, logLikeli] = particleSmoother(observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr, fixedLag);
toc
%print -deps one_dim_lin_gaus_smth_hist

% Results
figure; plot(stateGen(:,1),'k-'); xlabel('Time'); %title('真の状態と推定値の比較'); 
hold on
plot(stateSmoothed(fixedLag:timeLength, 1), 'k--o'); legend('True state', 'Estimated state')
hold off
logLikeli
%print -deps one_dim_lin_gaus_smth

%===========================================
%% Smoothing with saved particles and RWMH
%===========================================

% Parallel toolbox is required
% Create parallel pool on cluster
parpool; 

initialDistr = 0;

% Smoothing with saved particles and RWMH
tic
[stateSmoothedRWMH, logLikeli, accepRateRec] = particleSmootherMetropolis(...
    observedValue, timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, paramMCMC, initialDistr, fixedLag, ...
    rwmhDebugFlag);
toc
%print -deps one_dim_lin_gaus_smth_rwmh_hist

% Results
figure; plot(stateGen(:,1),'k-'); xlabel('Time'); %title('真の状態と推定値の比較'); 
hold on
plot(stateSmoothedRWMH(fixedLag:timeLength, 1), 'k--o'); legend('True state', 'Estimated state')
hold off
logLikeli
%print -deps OneDimLinGausSmthRWMH

figure; plot(accepRateRec);
%print -deps one_dim_lin_gaus_smth_rwmh_accept

% Shut down parallel pool
delete(gcp); % gcp = get current parallel pool
%=========================================
