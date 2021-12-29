% run42_modified_SIR_est.m
% Copyright (c) 2021, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html

%% スプレッドシートからデータをインポート
%    ワークブック: C:\Users\koiti\Dropbox\program\matlab\1_particle_filter_m\data\covid-19\cov_jp_all_owid_2021_12_17.xlsx
%    ワークシート: Sheet1
% MATLAB からの自動生成日: 2021/12/17 13:30:10
% インポート オプションの設定およびデータのインポート
close all;
clear;
opts = spreadsheetImportOptions("NumVariables", 23);

% シートと範囲の指定
opts.Sheet = "Sheet1";
opts.DataRange = "A2:W700";

% 列名と型の指定
opts.VariableNames = ["date", "tests", "newCases", "activeCases", "severeCases", "recovered", "deaths", "rt", "people_fully_vaccinated", "people_fully_vaccinated_intp", "people_fully_vaccinated_diff", "ratio_full_v_diff", "ratio_full_v", "aggregated_effectiveness", "population_final_estimate", "population_temporary_estimate", "newCasesCumsum", "susceptible", "infectious", "removed", "susceptible_f", "infectious_f", "removed_f"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "string", "string", "string", "double", "string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% 変数プロパティを指定
opts = setvaropts(opts, ["people_fully_vaccinated", "people_fully_vaccinated_intp", "people_fully_vaccinated_diff", "ratio_full_v"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["people_fully_vaccinated", "people_fully_vaccinated_intp", "people_fully_vaccinated_diff", "ratio_full_v"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "date", "InputFormat", "");

% データのインポート
cov_jp_all_owid = readtable("C:\Users\koiti\Dropbox\program\matlab\1_particle_filter_m\data\covid-19\cov_jp_all_owid_2021_12_17.xlsx", opts, "UseExcel", false);

% 一時変数のクリア
clear opts

% SIRモデルで使用するデータのみ抽出
% https://jp.mathworks.com/help/matlab/matlab_prog/create-a-table.html
observedValue = table2array(cov_jp_all_owid(:,{'susceptible_f', 'infectious_f',  'removed_f'}));
aggEff = table2array(cov_jp_all_owid(:,{'aggregated_effectiveness'}));
%sirData = cov_jp_all_owid(:,{'date', 'susceptible_f', 'infectious_f',  'removed_f', 'aggregated_effectiveness'});

% Parameters
modelFlag='modifiedSIRtvp';

%timeLength = 100;
[timeLength, ~] = size(observedValue);
numberOfState = 4;
numberOfObs = 3;
numberOfParticle = 10000; % 1万 
%numberOfParticle = 1000000; % 100万

paramSys.mean = [0 0 0 0];
paramSys.vcov = 0.000001 * eye(4);
paramSys.betaAncestral = 0.279;
paramSys.betaDelta = 0.508;
paramSys.gamma = 0.1;
paramSys.mu = 0.3;

% A paarmeter shitf 
% In Japan, a dominant variant changed from Alpha to Delta in July 2021.
paramSys.paramShift = 532; % At the end of June 2021.

paramObs.mean = [0 0 0];
paramObs.vcov = 0.0000001 * eye(3);

%===========================================
%% State estimation (Particle filter)
%===========================================
close;
initialDistr = [1 0 0 0.3];

% State estimation
tic
[stateEstimated, logLikeli, lowerBound, upperBound] = ...
    particleFilter(observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr);
toc

disp("Log-likelihood: " + logLikeli);

%% Plots
subplot(1,3,1);
plot(observedValue(:,1), 'k-'); xlabel('Time');
title('Real data and estimation: susceptible fraction ')
hold on
plot(stateEstimated(:, 1), 'k--o');
legend('Real data', 'Estimated state');
plot(lowerBound(:, 1), 'k:');
plot(upperBound(:, 1), 'k:');
hold off
%print -deps one_dim_lin_gauss_filt

subplot(1,3,2);
plot(observedValue(:,2), 'k-'); xlabel('Time');
title('Real data and estimation: susceptible fraction ')
hold on
plot(stateEstimated(:, 2), 'k--o');
legend('Real data', 'Estimated state');
plot(lowerBound(:, 2), 'k:');
plot(upperBound(:, 2), 'k:');
hold off

subplot(1,3,3);
plot(observedValue(:,3), 'k-'); xlabel('Time');
title('Real data and estimation: susceptible fraction ')
hold on
plot(stateEstimated(:, 3), 'k--o');
legend('Real data', 'Estimated state');
plot(lowerBound(:, 3), 'k:');
plot(upperBound(:, 3), 'k:');
hold off

figure;
plot(stateEstimated(:,4))
