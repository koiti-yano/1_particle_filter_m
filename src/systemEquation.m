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

    case 'standardSIR'
        % Note: state(:,1) is s(t), state(:,2) is i(t), state(:,3) is r(t)
        paramShift = paramSys.paramShift; % A parameter shift
        if timeIndex <= paramShift
            beta = paramSys.betaAncestral;
        elseif timeIndex > paramShift
            beta = paramSys.betaDelta;
        end
        
        gamma = paramSys.gamma;
        mu = paramSys.mu;
        state(: , 1) = state(: , 1) - beta * mu * state(: , 1) .* state(: , 2) + systemNoise(:,1);
        state(: , 2) = (1 - gamma) .* state(: , 2) + beta * mu * state(: , 1) .* state(: , 2) + systemNoise(:,2);
        % state(: , 3) = state(: , 3) + gamma * state(: , 2)  + systemNoise(:,3);
        state(: , 3) = 1 - (state(:,1) + state(:,2));

        % [Ugly test code] Replace some values (> 1 and < 0);
        % It does not work well. A similar code move to likelihoodInBayes.
        %{
            state = [-1 0.5, 1.1 ; 0.4 0.3 -0.2 ; 0.2 -0.45 0.77];
            stmp = state(:,1); stmp(stmp < 0 | stmp >1) = NaN;
            mm = mean(stmp, 'omitnan'); stmp(isnan(stmp)) = mm; state(:,1) = stmp;
            stmp = state(:,2); stmp(stmp < 0 | stmp >1) = NaN;
            mm = mean(stmp, 'omitnan'); stmp(isnan(stmp)) = mm; state(:,2) = stmp;
            stmp = state(:,3); stmp(stmp < 0 | stmp >1) = NaN;
            mm = mean(stmp, 'omitnan'); stmp(isnan(stmp)) = mm; state(:,3) = stmp;
            disp(state);[-1 0.5, 1.1 ; 0.4 0.3 -0.2 ; 0.2 -0.45 0.77]
        %}

end
%=========================================

