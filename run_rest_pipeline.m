%% ------------------------------------------------------------------------
% Resting-State fMRI - Pipeline
% -------------------------------------------------------------------------
% This script runs a whole resting-state connectivity analysis; including
% preprocessing of fMRI data using CONN and compCor-strategy, different ROI
% masks, time-series extraction for ROIs, computing of connectivity
% matrices, uni-variate first and second-level analysis and/or multi-variate pattern
% analysis.
%
% For a complete decription of changeable parameters in CONN, see
% 'CONN_batch_overview.xlsx'.
%
% Overview:
%       1. Specification of project - change for every project
%       2. Specification of analysis - change for every project
%       3. Run Conn for preprocessing, denoising, first-level and
%           second-level (don't change)
%       4. Run MVPA (don't change; to be implemented)

% Version 1.1
% Nils Winter, Goethe University Frankfurt
% nils.r.winter@gmail.com

clear;clc;
addpath([fileparts(mfilename('fullpath')) filesep 'conn15h' filesep 'conn']);
addpath([fileparts(mfilename('fullpath')) filesep 'scripts']);
addpath([fileparts(mfilename('fullpath')) filesep 'spm12']);

%% ------------------------------------------------------------------------
% 1. Specification of project - Change for every project
% -------------------------------------------------------------------------
Opts.projectFolder = 'C:\Users\Allgem. Psych. II\Documents\Rest Databases\ABIDE'; % where project is stored
Opts.dataPath = 'C:\Users\Allgem. Psych. II\Documents\Rest Databases\ABIDE\data';
Opts.projectName = 'abide_rest_200716';
Opts.nameFunctionals = 'ABIDE*'; % define typical part of name of functionals; make smart use of * (wild cards)

% Want to use a subset of subjects? Store the name of the subject folders
% in an Excel sheet. To use all subjects, just comment out the next line or
% leave Opts.useSpecificSubjects empty
Opts.useSpecificSubjects = num2cell(xlsread(...
    'C:\Users\Allgem. Psych. II\Desktop\ABIDE_results\abide_rest_over_18.xlsx')); % cell array with subject codes for all subjects that need to be analyzed (must correspond to folder names)

Opts.useStructurals = 0;
Opts.nameStructurals = 't1'; % define typical part of name of structurals
Opts.imgExt = '.nii'; % define image extension ('.nii' or '.img')
Opts.analysesTypes = [1]; % 1=ROI-to-ROI;2=Seed-to-Voxel;3=Voxel-to-Voxel;4=Dynamic-FC;
Opts.sliceOrder = 'ascending';
Opts.RT = 1.5; % Repetition Time
Opts.saveMemory = 2; % 0=don't delete data; 1=delete all but for CONN important data; 2=delete all but results

% Define ROIs - One folder for one atlas - Specify directories
Opts.roisFolder = {'C:\Users\Allgem. Psych. II\Desktop\Rest Pipeline Nils v1.1\rois\aal2';...
    'C:\Users\Allgem. Psych. II\Desktop\Rest Pipeline Nils v1.1\rois\dosenbach'};  % separate with semicolon
Opts.roisMultipleLabels = [1 0]; % vector with ones and zeros; one indicates a ROI with multiple labels

% Want to change any other parameters of CONN? Make these changes in
% 'initConnBatchCustom.m' and set Opts.customInit to 1
Opts.customInit = 0;

%% ------------------------------------------------------------------------
% 2. Specification of analysis - Change for every project
% -------------------------------------------------------------------------
% Specify which analyses are to be conducted

% INITIALIZE BATCH STRUCTURE AND CONN PROJECT
Opts.runInit = 1;

% PREPROCESSING
Opts.runPreprocessing = 1;

% SETUP
Opts.runSetup = 1;

% DENOISING
Opts.runDenoising = 1;

% FIRST LEVEL
Opts.runFirstLevel = 1;
Opts.firstLevelMeasures = [1 2 3 4]; % 1=bivarCorr;2=semiCorr;3=biReg;4=multiReg;
Opts.roisSources = {'C:\Users\Allgem. Psych. II\Desktop\Rest Pipeline Nils v1.1\rois\aal2';
    'C:\Users\Allgem. Psych. II\Desktop\Rest Pipeline Nils v1.1\rois\dosenbach'};
% leave empty to analyze all atlases; or specify one specific atlas --> specify directory to atlas folder

% SECOND LEVEL
Opts.runSecondLevel = 0;

% MVPA
Opts.runMVPA = 1;


%% ------------------------------------------------------------------------
% No changes necessary from this point onwards
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% 3. Run Conn for preprocessing, denoising, first-level and second-level
% -------------------------------------------------------------------------
%Prepare subject loop
if isfield(Opts, 'useSpecificSubjects')
    if ~isempty(Opts.useSpecificSubjects)
        subCode = cellfun(@num2str, Opts.useSpecificSubjects, 'UniformOutput', false);
    end
else
    subCodeTmp = dir(Opts.dataPath);
    for ind = 3:size(subCodeTmp,1)
        subCode{ind-2,1} = subCodeTmp(ind,1).name;
    end
end
for indSub = 1:size(subCode,1)
    fprintf('\nProcessing subject: %d\n\n',indSub);
    Opts.dataPathSubject = [Opts.projectFolder filesep Opts.projectName filesep subCode{indSub,1}];
    Opts.projectFolderSubject = Opts.dataPathSubject;
    Opts.projectNameSubject = [Opts.projectName '_' subCode{indSub,1}];
    cd(Opts.projectFolder);
    
    % Initialize conn
    if Opts.runInit
        copyfile([Opts.dataPath filesep subCode{indSub,1}],Opts.dataPathSubject,'f');
        if Opts.customInit == 0
            ConnBatch = initConnBatch(Opts);
        elseif Opts.customInit == 1
            ConnBatch = initConnBatchCustom(Opts);
        else
            error('Error: Please define Opts.customInit.')
        end
        conn_batch(ConnBatch);
    end
    
    % Run preprocessing
    if Opts.runPreprocessing
        Opts.initPreprocessing = 1;
        ConnBatch = initConnBatch(Opts);
        conn_batch(ConnBatch);
        ConnBatch = rmfield(ConnBatch,'Setup');
        delete(findall(0,'Type','figure'))
        Opts = rmfield(Opts,'initPreprocessing');
    end
    
    % Run setup
    if Opts.runSetup
        ConnBatch.Setup.done = 1;
        conn_batch(ConnBatch);
        ConnBatch.Setup.done = 0;
    end
    
    % Run denoising
    if Opts.runDenoising
        ConnBatch.Denoising.done = 1;
        conn_batch(ConnBatch);
        ConnBatch.Denoising.done = 0;
    end
    
    % Run first level
    if Opts.runFirstLevel
        ConnBatch.Analysis.done = 1;
        ConnBatch.Analysis.overwrite = 1;
        % check which sources have been defined for the analyses
        if isempty(Opts.roisSources); sourcesFolder = Opts.roisFolder;
        else sourcesFolder = Opts.roisSources; end;
        
        for indAtlas = 1:size(sourcesFolder,1)
            % Define ROI sources
            Sources = connLoadRois({sourcesFolder{indAtlas,1}},Opts.roisMultipleLabels(indAtlas),'Sources');
            ConnBatch.Analysis.sources.names = Sources.names;
            ConnBatch.Analysis.sources.dimensions = Sources.dimensions;
            ConnBatch.Analysis.sources.deriv = num2cell(zeros(size(Sources.names,2),1));
            % Define analysis name (probably one analysis for every atlas)
            for indMeas = Opts.firstLevelMeasures
                [~,atlasName,~] = fileparts(Opts.roisFolder{indAtlas,1});
                ConnBatch.Analysis.analysis_number = ...
                    [atlasName '_' num2str(indMeas)];
                ConnBatch.Analysis.measure = indMeas;
                conn_batch(ConnBatch);
            end
        end
        ConnBatch.Analysis.done = 0;
    end
    
    % Run second level
    if Opts.runSecondLevel;
        ConnBatch.Results.done = 1;
        conn_batch(ConnBatch);
        ConnBatch.Results.done = 0;
    end
    
    % Delete data if specified
    if Opts.saveMemory == 1
        % take all files in subject folder
        uselessData = dir(Opts.projectFolderSubject);
        uselessData = {uselessData.name};
        % search for files that shouldn't be deleted
        volumes = dir([Opts.projectFolderSubject filesep '*wau*.nii']);
        realignPar = dir([Opts.projectFolderSubject filesep 'rp*.txt']);
        connProject = dir([Opts.projectFolderSubject filesep '*.mat']);
        usefullData = [volumes;realignPar;connProject];
        for ind = 1:size(usefullData,1)
            n = find(strcmp(uselessData,cellstr(usefullData(ind,1).name)));
            uselessData{n}=[];
        end
        % delete files
        for k = 1:numel(uselessData);
            delete([Opts.projectFolderSubject filesep uselessData{k}])
        end
    elseif Opts.saveMemory == 2
        copyfile([Opts.projectFolderSubject filesep 'conn_' Opts.projectNameSubject...
            filesep 'results' filesep 'firstlevel'],[Opts.projectFolder...
            filesep 'results' filesep subCode{indSub,1}],'f');
        rmdir(Opts.projectFolderSubject,'s');
    end
end
%% ------------------------------------------------------------------------
% 4. MVPA
% -------------------------------------------------------------------------
if Opts.runMVPA
    % Create feature vectors (connectivities) for every subject
    measure = {'bivarCorr','semivarCorr','bivarReg','multivarReg'};
    % check which sources have been defined for the analyses
    if isempty(Opts.roisSources); sourcesFolder = Opts.roisFolder;
    else sourcesFolder = Opts.roisSources; end;
    
    % for every atlas and for all specified first level measures
    for indAtlas = 1:size(sourcesFolder,1)
        for indMeas = Opts.firstLevelMeasures
            for indSub = 1:size(subCode,1)
                [~,atlasName,~] = fileparts(sourcesFolder{indAtlas,1});
                if Opts.saveMemory == 2
                    load([Opts.projectFolder filesep 'results' filesep...
                        subCode{indSub,1} filesep...
                        atlasName '_' num2str(indMeas) '\resultsROI_Condition001.mat']);
                else
                    load([Opts.projectFolder filesep Opts.projectName filesep...
                        subCode{indSub,1} filesep 'conn_'...
                        Opts.projectName '_' subCode{indSub,1}...
                        filesep 'results' filesep 'firstlevel' filesep...
                        atlasName '_' num2str(indMeas) '\resultsROI_Condition001.mat']);
                end
                Z(:,size(Z,1)+1:end,:) = [];  %get rid of other stuff we don't need
                vectors(indSub,:) = mat2vecs(Z);
            end
            eval(['connectivities.' atlasName '.' measure{1,indMeas} ' = vectors;']);
            clear vectors;
        end
    end
    save(['results_conn_' Opts.projectName '_' date], 'connectivities');
end







