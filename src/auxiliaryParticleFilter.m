% auxiliaryParticleFilter.m
% Copyright (c) 2013, Koiti Yano
% [References]
% Pitt and Shephard (1999). "Filtering Via Simulation: Auxiliary Particle Filters".
% Journal of the American Statistical Association 94 (446): 590?591.
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html

function [auxStateEstimated, auxLogLikeli, auxLowerBound, auxUpperBound] = ...
    auxiliaryParticleFilter(observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, modelFlag, ...
    paramSys, paramObs, initialDistr)

% Create initial particles and initial state.
initParticle = initialParticle(initialDistr, numberOfParticle, ...
    modelFlag);
state = initParticle;

% stateEstimatedAvrg
auxStateEstimated = zeros(timeLength, numberOfState);
auxLowerBound = zeros(timeLength, numberOfState);
auxUpperBound = zeros(timeLength, numberOfState);
auxLogLikeli = 0;

for ii = 1:(timeLength)
%    tmpStr = ['Loop in auxiliaryParticleFilter: ', num2str(ii)]; disp(tmpStr);

    % Predicting next states (1st prediction)
    predictedState = predictionOfParticle(@systemEquation, ...
        state, numberOfState, numberOfParticle, ...
        modelFlag, paramSys, ii);
    
    % Calculating weights of particles
    [~, weight, llk1] = weightOfParticle(@likehoodInBayes, ...
        observedValue(ii, :), predictedState, numberOfState, ...
        numberOfObs, numberOfParticle, ...
        modelFlag, paramObs, ii);

    % Resampling particles (1st resampling)
    [~, resampledIndex] = resamplingOfParticle(predictedState, ...
        weight, ...
        numberOfParticle);
    
    % Calculate auxiliary variables
    auxiliaryIndex = resampledIndex; % resampledIndices are auxiliary indices.
    auxiliaryState = state(auxiliaryIndex,:);
    auxiliaryWeight = weight(auxiliaryIndex);
    
    % Predicting next states (2nd prediction)
    auxiliaryState = predictionOfParticle(@systemEquation, ...
        auxiliaryState, numberOfState, numberOfParticle, ...
        modelFlag, paramSys, ii);

    % Calculating weights of particles (2nd weights)
    [~, weightBeforeAdjust, llk2] = weightOfParticle(@likehoodInBayes, ...
        observedValue(ii, :), auxiliaryState, numberOfState, ...
        numberOfObs, numberOfParticle, ...
        modelFlag, paramObs, ii);
    
    % Calcute adjusted weights
    adjustedWeight = weightBeforeAdjust./auxiliaryWeight;
    
    % Resampling particles (2nd resampling)
    [secondResampledState, ~] = resamplingOfParticle(auxiliaryState, ...
        adjustedWeight, ...
        numberOfParticle);

    % Calculate likelihood of weight before resampling
    llk = llk1 + llk2;
    auxLogLikeli = auxLogLikeli + (llk);

    state = secondResampledState;
    
    % Calculate representative values
    for jj = 1:numberOfState
        auxStateEstimated(ii, jj) = mean(state(:, jj));
        % stateEstimated(ii, jj) = median(state(:, jj));
        auxLowerBound(ii, jj) = quantile(state(:, jj), 0.25);
        auxUpperBound(ii, jj) = quantile(state(:, jj), 0.975);
    end
end
%=========================================


