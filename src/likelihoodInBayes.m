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

end


%=========================================

