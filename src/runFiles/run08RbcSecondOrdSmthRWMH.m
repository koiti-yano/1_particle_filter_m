% solab2GommeKlein2011Rbc.m
% Copyright (c) 2013, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html


%===========================================
%% Initialization
%===========================================
clear all;
% The matrices of second-order approximation of of a RBC model
% based on Gomme and Klein (2011).
% [ff,pp,ee,gg,kx,ky]
load('solab2GommeKlein2011Rbc')

% Parameters
modelFlag = 'rbcSecondOrderItera';
%modelFlag = 'rbcSecondOrderMat';


timeLength = 50;

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
fixedLag = 10;


%===========================================
%% Data Generation
%===========================================

% Parallel toolbox is required
% Create parallel pool on cluster
numCore = feature('numCores');
parpool('local', numCore);

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
figure; subplot(3,1,1); plot(stateGen(:,1)); title('���1'); xlabel('����t')
subplot(3,1,2); plot(stateGen(:,2)); title('���2'); xlabel('����t')
subplot(3,1,3); plot(stateGen(:,3)); title('���3'); xlabel('����t')

figure; subplot(3,1,1); plot(observedValue(:,1)); title('�ϑ��l1'); xlabel('����t')
subplot(3,1,2); plot(observedValue(:,2)); title('�ϑ��l2'); xlabel('����t')
subplot(3,1,3); plot(observedValue(:,3)); title('�ϑ��l3'); xlabel('����t')
%}

%===========================================
%% Smoothing with saved particle
%===========================================

% Smoothing with saved particle
tic
[stateSmoothed, logLikeli, lowerBound, upperBound] = ...
    particleSmoother(observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr, fixedLag);
toc

logLikeli

% Results
figure; subplot(3,1,1)
plot(stateGen(:,1), 'k-'); xlabel('Time'); %title('�^�̏��1�Ɛ���l�̔�r')
hold on
plot(stateSmoothed((fixedLag:timeLength), 1), 'k--o')
legend('True state 1', 'Smoothed state 1')
hold off

subplot(3,1,2)
plot(stateGen(:,2), 'k-'); xlabel('Time'); %title('�^�̏��2�Ɛ���l�̔�r'); 
hold on
plot(stateSmoothed((fixedLag:timeLength), 2), 'k--o')
legend('True state 2', 'Smoothed state 2')
hold off

subplot(3,1,3)
plot(stateGen(:,3), 'k-'); xlabel('Time'); %title('�^�̏��3�Ɛ���l�̔�r');
hold on
plot(stateSmoothed((fixedLag:timeLength), 3), 'k--o')
legend('True state 3', 'Smoothed state 3')
hold off
print -deps RbcSecondOrdSmth

%===========================================
%% Smoothing with saved particles and RWMH
%===========================================

rwmhDebugFlag = 'normalRoute';

paramMCMC.burnin = 1; % �o�[���C��
paramMCMC.numLoop = 1; % RW Metropilis-Hastings�@�̌J��Ԃ���
paramMCMC.scaleFactor = 0.1; % �X�P�[���t�@�N�^�[

initialDistr = [0.0 0.0 0.0];

% Smoothing with saved particles and RWMH
figure;
tic
[stateSmoothedRWMH, logLikeli, accepRateRec] = particleSmootherMetropolis(...
    observedValue, timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, paramMCMC, initialDistr, fixedLag, ...
    rwmhDebugFlag);
toc

logLikeli

% Results
figure; 
subplot(3,1,1); plot(stateGen(:,1),'k-'); xlabel('Time'); %title('�^�̏�ԂƐ���l�̔�r'); 
hold on
plot(stateSmoothedRWMH(fixedLag:timeLength, 1), 'k--o'); legend('True state', 'Estimated state')
hold off
subplot(3,1,2); plot(stateGen(:,2),'k-'); xlabel('Time'); %title('�^�̏�ԂƐ���l�̔�r'); 
hold on
plot(stateSmoothedRWMH(fixedLag:timeLength, 2), 'k--o'); legend('True state', 'Estimated state')
hold off
subplot(3,1,3); plot(stateGen(:,3),'k-'); xlabel('Time'); %title('�^�̏�ԂƐ���l�̔�r'); 
hold on
plot(stateSmoothedRWMH(fixedLag:timeLength, 3), 'k--o'); legend('True state', 'Estimated state')
hold off
%print -deps rbs_second_ord_smth_rwmh

figure; plot(accepRateRec);
%print -deps rbs_second_ord_smth_rwmh_accept

delete(gcp);
%=========================================

