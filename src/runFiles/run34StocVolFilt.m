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
modelFlag='stocVol';

timeLength = 200;
numberOfState = 1;
numberOfObs = 1;
numberOfParticle = 100000;

paramSys.mu = 0;
paramSys.phi = 0.98;
paramSys.sigma = 0.5;

paramObs.sigma = 1;
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
    
    systemNoise = paramSys.sigma * randn(numberOfState);
    stateGen(ii+1, :) = systemEquation(stateGen(ii, :), systemNoise, ...
        numberOfState, numberOfParticle, modelFlag, paramSys, ii);
    
    observationNoise = paramObs.sigma*randn(numberOfObs);
    observedValue(ii+1, :) = observationEquation(stateGen(ii+1, :), ...
        observationNoise, numberOfObs, modelFlag, paramObs, ii);
    
end
% plot generated data
%{
subplot(2,1,1) ; plot(stateGen) ; title('���'); xlabel('����t')
subplot(2,1,2) ; plot(observedValue) ; title('�ϑ��l'); xlabel('����t')
%}

%===========================================
%% Parameter estimation
%===========================================

numOfVertices=5; %value of N+1 (the number of vetrices) 

tic
[minima, minmas, numOfIter] = nelderMead(@wrapFunc, ...
    numOfVertices, observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr);
toc
% Check results
minima.coord
minima.value

minmas;
numOfIter;

%=========================================

