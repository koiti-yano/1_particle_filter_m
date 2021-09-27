% test rwMetropolisHastings.m
% Copyright (c) Koiti Yano 2014
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html
clear; close all;

% パラメーター設定
observedValue = 0 ; % Stub
numberOfState = 1;
numberOfObs = 1;
numberOfParticle = 1000;
paramSys.mu = 0;
paramSys.sigma = 1;
mhDebugFlag = 'mhDebug'; 
paramObs = 0; % stub
timeIndex = 0; % stub

paramMCMC.burnin = 20; % バーンイン
paramMCMC.numLoop =10; % RW Metropilis-Hastings法の繰り返し回数
paramMCMC.scaleFactor = 4; % スケールファクター

% RW Metropilis-Hastingsの結果を保存する行列を作成
mhMat = zeros(numberOfParticle, numberOfState); % 全部ゼロ
mhMat(:, 1) = rand(numberOfParticle, 1); % 一様分布で初期分布を生成

% 結果（初期分布とMH法で生成した分布、採択率）を出力（その１）
subplot(3,1,1); hist(mhMat(:, 1)); title('初期分布');

tic
[mhMat, acceptedRateMat] = rwMetropolisHastings (@normpdf, ...
    observedValue, mhMat, numberOfState, numberOfObs, numberOfParticle, ...
    'stub', paramSys, paramObs, paramMCMC, timeIndex, mhDebugFlag);
toc

% 結果（初期分布とMH法で生成した分布、採択率）を出力（その２）
subplot(3,1,2); hist(mhMat(:, 1)); title('Random-walk Metropolis-Hastings法で生成した分布');
subplot(3,1,3); plot(acceptedRateMat); title('採択率の推移');

delete(gcp);
