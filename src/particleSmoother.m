% particleSmoother.m
% Copyright (c) 2013, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html

function [stateSmoothed, logLikeli, lowerBound, upperBound] = ...
    particleSmoother(observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, modelFlag, ...
    paramSys, paramObs, initialDistr, fixedLag)

% Debug flag
debugF = 1; % Debug mode
%debugF = 0; % No debug mode

% Create initial particles and initial state.
initParticle = initialParticle(initialDistr, numberOfParticle, ...
    modelFlag);
state = initParticle;

% Matrix for saved particles
savedParticle = zeros(numberOfParticle, numberOfState, fixedLag);

% stateEstimatedAvrg
stateSmoothed = zeros(timeLength, numberOfState);
lowerBound = zeros(timeLength, numberOfState);
upperBound = zeros(timeLength, numberOfState);
logLikeli = 0;

% Create waitbar.
wb = waitbar(0,'Particle smoother is running');

for ii = 1:(timeLength)
    if debugF == 1 && rem(ii,50)==0
        tmpStr = ['Loop in particleSmoother: ', num2str(ii)]; disp(tmpStr);
    end
    
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
    
    % push
    savedParticle = push(savedParticle, state);
    
    % Resample saved particles
    savedParticle = savedParticle(rindex, :, :);
    
    % Calculate representative values and related values
    if ii >= fixedLag
        for jj = 1:numberOfState
            stateSmoothed(ii, jj) = mean(savedParticle(:, jj, fixedLag));
            %stateSmoothed(ii, jj) = median(savedParticle(:, jj, fixedLag));
            lowerBound(ii, jj) = quantile(savedParticle(:, jj, fixedLag), 0.25);
            upperBound(ii, jj) = quantile(savedParticle(:, jj, fixedLag), 0.975);
            if mod(ii, 10)==1;
                hist(savedParticle(:, 1, fixedLag),10);
                % hist(savedParticle(:, jj, fixedLag),10);
                
            end
        end
    end
    
    % Update waitbar.
    waitbar(ii/timeLength);
    
end
%=========================================


