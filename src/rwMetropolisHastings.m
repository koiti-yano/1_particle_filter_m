% rwMetropolisHastings.m
% Random-walk Metropolis-Hastings alogorithm
% Copyright (c) Koiti Yano 2014
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html
% [References]
% Chib, S., and Greenberg, E., (1995), "Understanding the Metropolis-Hastings
% Algorithm," The American Statistician, Vol. 49, No. 4, pp. 327-335,
% http://streaming.stat.iastate.edu/~stat444x_B/Literature/ChibGreenberg.pdf
% This is a temporary code.

function [state, acceptedRateMat] = rwMetropolisHastings (likelihoodInBayes, ...
    observedValue, state, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, paramMCMC, timeIndex, mhDebugFlag)

% Parameters
numberOfSample = numberOfParticle; % The number of Monte Carlo trial
burnin = paramMCMC.burnin; % Burn-in
numLoop = paramMCMC.numLoop; % The loop of RW Metropilis-Hastings
scaleFactor = paramMCMC.scaleFactor; % The scale factor

time = burnin + numLoop;

% Matrix for the accepted rate
acceptedRateMat = zeros(1, time);
%disp(modelFlag);

% RW Metropilis-Hastings
for tt = 1:time
    acceptCount = 0;
    %    disp(['rwMetropolisHastings: ', num2str(tt)]);
    parfor ss = 1:numberOfSample % Parallel toolbox
        % Random-walk
        xStar = state(ss, :) + scaleFactor * randn(1, numberOfState);
        
        % Evaluate the probability of acceptance
        %
        if strcmp(mhDebugFlag, 'mhDebug'); % For debug. See example99RWMH.M
            lkStar = likelihoodInBayes(xStar, 0, 1);
            lk = likelihoodInBayes(state(ss, :), 0, 1);
            alpha = min( [ 1, lkStar / lk ] );
        else strcmp(mhDebugFlag, 'normalRoute');
            residual1 = observedValue - xStar;
            residual2 = observedValue - state(ss,:);

            if isstruct(paramObs);
                lkStar = mvnpdf(residual1, paramObs.mu , paramObs.sysSigma); %RBC
                lk = mvnpdf(residual2, paramObs.mu , paramObs.sysSigma); %RBC
            else 
                lkStar = normpdf(residual1, 0 , paramObs); %OneDim
                lk = normpdf(residual2, 0 , paramObs); %OneDim
            end
            
            % lkStar = likelihoodInBayes(observedValue, xStar, numberOfObs, ...
            %  numberOfParticle, modelFlag, paramObs, timeIndex);
            % lk = likelihoodInBayes(observedValue, state(ss,:), numberOfObs, ...
            %     numberOfParticle, modelFlag, paramObs, timeIndex);
            alpha = min( [ 1, lkStar/lk ] ); % The probability of acceptance

        end
        
        % Uniform distribution
        u = rand;
        
        % Accept or reject
        if u <= alpha
            state(ss, :) = xStar;
            acceptCount = acceptCount + 1;
        else
            % do nothing
        end
        
    end
    acceptedRateMat(tt) = acceptCount / numberOfSample;
    
end
%=========================================



