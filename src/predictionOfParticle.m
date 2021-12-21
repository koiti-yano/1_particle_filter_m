% predictionOfParticle.m
% Copyright (c) 2013, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html

function predictedState = predictionOfParticle(systemEquation, ...
    state, numberOfState, numberOfParticle, ...
    modelFlag, paramSys, timeIndex)

switch modelFlag
    case 'oneDimLinearGaussian'
        systemNoise = paramSys*randn(numberOfParticle, 1);
        predictedState = systemEquation(state, systemNoise, ...
            numberOfState, numberOfParticle, modelFlag, paramSys, timeIndex);

    case 'oneDimNonLinear'
        systemNoise = paramSys*randn(numberOfParticle, 1);
        predictedState = systemEquation(state, systemNoise, ...
            numberOfState, numberOfParticle, modelFlag, paramSys, timeIndex);

    case 'stocVol'
        systemNoise = paramSys.sigma*randn(numberOfParticle, 1);
        predictedState = systemEquation(state, systemNoise, ...
            numberOfState, numberOfParticle, modelFlag, paramSys, timeIndex);

    case 'twoDimLinearGaussian'
        systemNoise = mvnrnd(paramSys.mu, paramSys.sysSigma, ...
            numberOfParticle);
        predictedState = systemEquation(state, systemNoise, ...
            numberOfState, numberOfParticle, modelFlag, paramSys, timeIndex);

    case 'rbcSecondOrderItera'
        systemNoise = mvnrnd(paramSys.mu, paramSys.sysSigma, ...
            numberOfParticle);
        predictedState = systemEquation(state, systemNoise, ...
            numberOfState, numberOfParticle, modelFlag, paramSys, timeIndex);

    case 'rbcSecondOrderIteraParallel'
        systemNoise = mvnrnd(paramSys.mu, paramSys.sysSigma, ...
            numberOfParticle);
        predictedState = systemEquation(state, systemNoise, ...
            numberOfState, numberOfParticle, modelFlag, paramSys, timeIndex);

    case 'standardSIR'
        systemNoise = mvnrnd(paramSys.mean, paramSys.vcov, numberOfParticle);
        predictedState = systemEquation(state, systemNoise, ...
            numberOfState, numberOfParticle, modelFlag, paramSys, timeIndex);

    case 'modifiedSIRtvp'
        systemNoise = mvnrnd(paramSys.mean, paramSys.vcov, numberOfParticle);
        predictedState = systemEquation(state, systemNoise, ...
            numberOfState, numberOfParticle, modelFlag, paramSys, timeIndex);

end
%=========================================

