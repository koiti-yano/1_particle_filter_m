% systemEquation.m
% Copyright (c) 2013, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html

function state = systemEquation(state, systemNoise, ...
    numberOfState, numberOfParticle, modelFlag, paramSys, timeIndex)

[rr, ~] = size(state);
numLoop = min(numberOfParticle, rr);
%disp(rr);

switch modelFlag
    case 'oneDimLinearGaussian'
        state = state + systemNoise;
        
    case 'oneDimNonLinear'
        state = (1/2)*state + (25 * state)./(state.^2 + 1) + ...
            8 * cos(1.2 * timeIndex) + systemNoise;
    
    case 'stocVol'
        mu = paramSys.mu; phi = paramSys.phi;
        state = mu + phi * state + systemNoise;
        
    case 'twoDimLinearGaussian'
        state = state + systemNoise;
        
    case 'rbcSecondOrderItera'
        nx = paramSys.nx; ny = paramSys.ny;
        kx = paramSys.kx; pp = paramSys.pp; gg = paramSys.gg;
        ky = paramSys.ky; ff = paramSys.ff; ee = paramSys.ee;

        stCpy = repmat(state,1);
        for ii = 1:numLoop
            backlook = kx + pp * state(ii, 1:nx).' + ...
            (1/2) * kron(eye(nx), state(ii, 1:nx)) * gg * state(ii, 1:nx).' ...
            + systemNoise(ii, 1:nx).' ;
                
            nonbacklook = ky + ff * state(ii, 1:nx).' + ...
                (1/2) * kron(eye(ny), backlook.') * ee * backlook ;
            stCpy(ii, :) = [backlook.' nonbacklook.']; 
%            state(ii, :) = [backlook.' nonbacklook.'];
        end
        state = stCpy;
        
    case 'rbcSecondOrderIteraParallel'
        nx = paramSys.nx; ny = paramSys.ny;
        kx = paramSys.kx; pp = paramSys.pp; gg = paramSys.gg;
        ky = paramSys.ky; ff = paramSys.ff; ee = paramSys.ee;

        stCpy = repmat(state,1);
        parfor ii = 1:numLoop
            backlook = kx + pp * state(ii, 1:nx).' + ...
            (1/2) * kron(eye(nx), state(ii, 1:nx)) * gg * state(ii, 1:nx).' ...
            + systemNoise(ii, 1:nx).' ;
        
            nonbacklook = ky + ff * state(ii, 1:nx).' + ...
                (1/2) * kron(eye(ny), backlook.') * ee * backlook ;
            stCpy(ii, :) = [backlook.' nonbacklook.']; 
        end
        state = stCpy;
        
end
%=========================================

