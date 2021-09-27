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

timeLength = 200;
numberOfState = 1;
numberOfObs = 1;
numberOfParticle = 100000;
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
%% Parameter estimation
%===========================================

numOfVertices=3; %value of N+1 (the number of vetrices) 

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

