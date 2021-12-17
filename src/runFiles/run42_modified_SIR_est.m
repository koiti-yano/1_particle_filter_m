%% スプレッドシートからデータをインポート
%    ワークブック: C:\Users\koiti\Dropbox\program\matlab\1_particle_filter_m\data\covid-19\cov_jp_all_owid_2021_12_17.xlsx
%    ワークシート: Sheet1
% MATLAB からの自動生成日: 2021/12/17 13:30:10
%% インポート オプションの設定およびデータのインポート
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
sir_data = cov_jp_all_owid(:,{'date', 'susceptible_f', 'infectious_f',  'removed_f', 'aggregated_effectiveness'});

%% 
