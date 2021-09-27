% particleFilter.m
% Copyright (c) 2013, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html

function [stateEstimated, logLikeli, lowerBound, upperBound] = ...
    particleFilter(observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, modelFlag, ...
    paramSys, paramObs, initialDistr)
% Debug flag
%debugF = 1; % Debug mode
debugF = 0; % No debug mode

% Create initial particles and initial state.
initParticle = initialParticle(initialDistr, numberOfParticle, ...
    modelFlag);
state = initParticle;

% stateEstimatedAvrg
stateEstimated = zeros(timeLength, numberOfState);
lowerBound = zeros(timeLength, numberOfState);
upperBound = zeros(timeLength, numberOfState);
logLikeli = 0;

% Create waitbar.
wb = waitbar(0,'Particle filter is running');

for ii = 1:(timeLength)
    if debugF == 1 && rem(ii,50)==0 
        tmpStr = ['Loop in particleFilter: ', num2str(ii)]; disp(tmpStr);
    end
    % Predicting next states
    state = predictionOfParticle(@systemEquation, ...
        state, numberOfState, numberOfParticle, ...
        modelFlag, paramSys, ii);
    
    % Calculating weights of particles
    [~, weight, llk] = weightOfParticle(@likehoodInBayes, ...
        observedValue(ii, :), state, numberOfState, ...
        numberOfObs, numberOfParticle, ...
        modelFlag, paramObs, ii);
    
    % Calculate likelihood of weight before resampling
    logLikeli = logLikeli + llk;
    
    % Resampling particles
    [state, ~] = resamplingOfParticle(state, weight, ...
        numberOfParticle);
    
    % Calculate representative values
    for jj = 1:numberOfState
        stateEstimated(ii, jj) = mean(state(:, jj));
        % stateEstimated(ii, jj) = median(state(:, jj));
        lowerBound(ii, jj) = quantile(state(:, jj), 0.25);
        upperBound(ii, jj) = quantile(state(:, jj), 0.975);
    end
    
    % Update waitbar.
    waitbar(ii/timeLength);
    
end
close(wb);
%=========================================


