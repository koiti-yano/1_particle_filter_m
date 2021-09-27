% particleSmootherMetropolis.m
% Copyright (c) 2013, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html

function [stateSmoothedRWMH, logLikeli, accepRateRec] = particleSmootherMetropolis(...
    observedValue, timeLength, numberOfState, numberOfObs, ...
    numberOfParticle, modelFlag, paramSys, paramObs, paramMCMC, ...
    initialDistr, fixedLag, mhDebugFlag)

% Create initial particles and initial state.
initParticle = initialParticle(initialDistr, numberOfParticle, ...
    modelFlag);
state = initParticle;

% Matrix for saved particles
savedParticle = zeros(numberOfParticle, numberOfState, fixedLag);

% stateEstimatedAvrg
stateSmoothedRWMH = zeros(timeLength, numberOfState);
lowerBound = zeros(timeLength, numberOfState);
upperBound = zeros(timeLength, numberOfState);
logLikeli = 0;

accepRateRec = zeros(1, timeLength);

for ii = 1:(timeLength)
    tmpStr = ['Loop in particleSmootherMetropolis: ', num2str(ii)]; disp(tmpStr);
    % Predicting next states
    state = predictionOfParticle(@systemEquation, ...
        state, numberOfState, numberOfParticle, ...
        modelFlag, paramSys, ii);
    
    % Calculating weights of particles
    [state, weight, llk] = weightOfParticle(@likehoodInBayes, ...
        observedValue(ii, :), state, numberOfState,...
        numberOfObs, numberOfParticle, ...
        modelFlag, paramObs, ii);
    
    % Calculate likelihood of weight before resampling
    logLikeli = logLikeli + llk;
    
    % Calculate resampling index
    [state, rindex] = resamplingOfParticle(state, weight, ...
        numberOfParticle);
    
    [state, acceptedRateMat] = rwMetropolisHastings(@likehoodInBayes, ...
        observedValue(ii, :), state, numberOfState, numberOfObs,  ...
        numberOfParticle, modelFlag, paramSys, paramObs, paramMCMC, ...
        ii, mhDebugFlag);
    accepRateRec(1, ii) = acceptedRateMat(1,end);
    
    % push
    savedParticle = push(savedParticle, state);
    
    % Resample saved particles
    savedParticle = savedParticle(rindex, :, :);
    
    % Calculate representative values and related values
    if ii >= fixedLag
        for jj = 1:numberOfState
            stateSmoothedRWMH(ii, jj) = mean(savedParticle(:, jj, fixedLag));
            % stateSmoothedRWMH(ii, jj) = median(savedParticle(:, jj, fixedLag));
            lowerBound(ii, jj) = quantile(savedParticle(:, jj, fixedLag), 0.25);
            upperBound(ii, jj) = quantile(savedParticle(:, jj, fixedLag), 0.975);
            if mod(ii, 10)==1;
                hist(savedParticle(:, 1, fixedLag),10);
                % hist(savedParticle(:, jj, fixedLag),10);
            end
            
        end
    end
end
%=========================================


