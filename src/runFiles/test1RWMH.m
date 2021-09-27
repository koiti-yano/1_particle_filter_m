% test rwMetropolisHastings.m
% Copyright (c) Koiti Yano 2014
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html
clear; close all;

% �p�����[�^�[�ݒ�
observedValue = 0 ; % Stub
numberOfState = 1;
numberOfObs = 1;
numberOfParticle = 1000;
paramSys.mu = 0;
paramSys.sigma = 1;
mhDebugFlag = 'mhDebug'; 
paramObs = 0; % stub
timeIndex = 0; % stub

paramMCMC.burnin = 20; % �o�[���C��
paramMCMC.numLoop =10; % RW Metropilis-Hastings�@�̌J��Ԃ���
paramMCMC.scaleFactor = 4; % �X�P�[���t�@�N�^�[

% RW Metropilis-Hastings�̌��ʂ�ۑ�����s����쐬
mhMat = zeros(numberOfParticle, numberOfState); % �S���[��
mhMat(:, 1) = rand(numberOfParticle, 1); % ��l���z�ŏ������z�𐶐�

% ���ʁi�������z��MH�@�Ő����������z�A�̑𗦁j���o�́i���̂P�j
subplot(3,1,1); hist(mhMat(:, 1)); title('�������z');

tic
[mhMat, acceptedRateMat] = rwMetropolisHastings (@normpdf, ...
    observedValue, mhMat, numberOfState, numberOfObs, numberOfParticle, ...
    'stub', paramSys, paramObs, paramMCMC, timeIndex, mhDebugFlag);
toc

% ���ʁi�������z��MH�@�Ő����������z�A�̑𗦁j���o�́i���̂Q�j
subplot(3,1,2); hist(mhMat(:, 1)); title('Random-walk Metropolis-Hastings�@�Ő����������z');
subplot(3,1,3); plot(acceptedRateMat); title('�̑𗦂̐���');

delete(gcp);
