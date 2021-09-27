% example1OneDimLinGaus.M
% Copyright (c) 2013, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html

%===========================================
%% Initialization
%===========================================
clear; close all; 

% Parameters
modelFlag='oneDimLinearGaussian';

timeLength = 100;
numberOfState = 1;
numberOfObs = 1;
numberOfParticle = 5000;
paramSys = 1;
paramObs = 0.5;
initialDistr = 1;
fixedLag = 40;

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
%subplot(2,1,1) ; plot(stateGen) ; title('���'); xlabel('����t')
%subplot(2,1,2) ; plot(observedValue) ; title('�ϑ��l'); xlabel('����t')


%===========================================
%% Smoothing with saved particles
%===========================================

initialDistr = 0;

% Estimation
tic
[stateSmoothedEst, logLikeli, lowerBound, upperBound] =  ...
    particleSmoother(observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr, fixedLag);
toc

% Results
figure; plot(stateGen(:,1),'k-'); xlabel('Time'); %title('�^�̏�ԂƐ���l�̔�r'); 
hold on
plot(stateSmoothedEst(fixedLag:timeLength, 1), 'k--o'); legend('True state', 'Estimated state')
hold off
logLikeli

%=========================================
