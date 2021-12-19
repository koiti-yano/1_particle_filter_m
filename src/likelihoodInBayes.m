% likelihoodInBayes.m
% Copyright (c) 2013, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html

function likelihood = likelihoodInBayes(observedValue, state, ...
    numberOfObs, numberOfParticle, ...
    modelFlag, paramObs, timeIndex)

switch modelFlag
    case 'oneDimLinearGaussian'
        % Statistics toolbox is required.
        residual = observedValue - state;
        likelihood = normpdf(residual, 0 , paramObs);

    case 'oneDimNonLinear'
        % Statistics toolbox is required.
        residual = observedValue - (state.^2)/10;
        likelihood = normpdf(residual, 0 , paramObs);

    case 'stocVol'
        % Statistics toolbox is required.
        %OLD        residual = observedValue * exp(-state/2);
        sigma = paramObs.sigma;
        likelihood = normpdf(observedValue, 0 , sigma*exp(state/2));

    case 'twoDimLinearGaussian'
        % Statistics toolbox is required.
        %OLD residual = repmat(observedValue, [numberOfParticle, 1])  - state;
        residual = observedValue  - state;
        likelihood = mvnpdf(residual, paramObs.mu, paramObs.sysSigma);

    case 'rbcSecondOrderItera'
        % Statistics toolbox is required.
        %OLD residual = repmat(observedValue, [numberOfParticle, 1])  - state;
        residual = observedValue  - state;
        likelihood = mvnpdf(residual, paramObs.mu, paramObs.sysSigma);
        %        if sum(likelihood) == 0
        %            disp(residual);disp(likelihood);
        %        end

    case 'rbcSecondOrderIteraParallel'
        % Statistics toolbox is required.
        %residual = repmat(observedValue, [numberOfParticle, 1])  - state;
        residual = observedValue  - state;
        likelihood = mvnpdf(residual, paramObs.mu, paramObs.sysSigma);

    case 'standardSIR'
        % Statistics toolbox is required.
        %residual = repmat(observedValue, [numberOfParticle, 1])  - state;
        residual = observedValue  - state;
        likelihood = mvnpdf(residual, paramObs.mean, paramObs.vcov);

        doflag = 1;
        if doflag == 1
            % If a state is outside [0, 1], a weight is set to zero for stable estimation. 
            ff = state < 0 | state >1 ;
            indx = (sum(ff, 2) ~= 0);
            likelihood(indx, 1) = 0;
        end
        %{
        % Example code
        likelihood = [1; 2; 3; 4]
        state = [-1 0.5, 1.1 ; 0.4 0.3 -0.2 ; 0.2 -0.45 0.77 ; 0.3 0.55 0.78]
        ff = state < 0 | state >1 ; 
        indx = (sum(ff, 2) ~= 0);
        likelihood(indx, 1) = 0
        %}
end


%=========================================

