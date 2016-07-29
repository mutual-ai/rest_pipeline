function BATCH = initConnBatchCustom(Opts)
%% Initialize batch structure for Conn toolbox

% Version 1.1
% Nils Winter, Goethe University Frankfurt
% nils.r.winter@gmail.com

%% SETUP
BATCH.gui = 0;
Opts.filename = [Opts.projectFolderSubject filesep 'conn_' Opts.projectNameSubject '.mat'];
BATCH.filename = Opts.filename;
Opts.nSub = 1;  % stays 1 because of parallel programming
Opts.nSes = 1;
BATCH.Setup.analyses = 1;
if Opts.runSetup
    if ~exist(Opts.filename)
        BATCH.Setup.isnew = 1;
        if isfield(Opts, 'useStructurals') && Opts.useStructurals == 1
            [BATCH.Setup.functionals, BATCH.Setup.structurals] = connLoadImages(Opts);
        else
            functionals = connLoadImages(Opts);
            for indSub = 1:Opts.nSub
                for indSes = 1:Opts.nSes
                 BATCH.Setup.functionals{indSub}{indSes}{1} = functionals{indSub,indSes}; 
                end; 
            end
        end
        
    else
        BATCH.Setup.isnew = 0;
    end
    BATCH.Setup.done = 0;
    BATCH.Setup.overwrite = 0;
    BATCH.Setup.nsubjects = Opts.nSub;
    BATCH.Setup.nsessions = Opts.nSes;
    BATCH.Setup.RT = Opts.RT * ones(Opts.nSub,1); % 2 = repetition time
    BATCH.Setup.acquisitiontype = 1;
    BATCH.Setup.analysisunits = 1;
    BATCH.Setup.outputfiles = [0,1,0,0,0,0];
    % BATCH.Setup.voxelmask = 1;
    % BATCH.Setup.voxelmaskfile = fullfile(fileparts(which('spm')),'apriori','brainmask.nii');
    BATCH.Setup.voxelresolution = 1; % 1=Volume-based template
    BATCH.Setup.surfacesmoothing = 10;
    BATCH.Setup.roiextract = 2;
    % BATCH.Setup.roiextract_rule = [];
    % BATCH.Setup.roiextract_functionals = [];
    % BATCH.Setup.unwarp_functionals{nsub}{nses} = [];
    % BATCH.Setup.spmfiles{nsub} = [];
    % BATCH.Setup.masks.Grey{nsub}.files = [];
    % BATCH.Setup.masks.Grey{nsub}.dimensions = ones(nSub,1);
    % BATCH.Setup.masks.White{nsub}.files = [];
    % BATCH.Setup.masks.White{nsub}.dimensions = ones(nSub,1)*16;
    % BATCH.Setup.masks.CSF{nsub}.files = [];
    % BATCH.Setup.masks.CSF{nsub}.dimensions = ones(nSub,1)*16;
    
    BATCH.Setup.conditions.names{1} = 'Rest';
    for indCond = 1
        for indSub = 1:Opts.nSub
            for indSes = 1:Opts.nSes
                BATCH.Setup.conditions.onsets{indCond}{indSub}{indSes} = 0;
                BATCH.Setup.conditions.durations{indCond}{indSub}{indSes} = inf;
            end
        end
    end
    % BATCH.Setup.conditions.param{ncondition} = [];
    % BATCH.Setup.conditions.filter{ncondition} = [];
    % BATCH.Setup.conditions.missingdata = 0;
    % BATCH.Setup.conditions.add = 0;
    % BATCH.Setup.covariates.names{ncovariates} = [];
    % BATCH.Setup.covariates.files{ncovariates}{nsub}{nses} = [];
    % BATCH.Setup.covariates.add = 0;
    % BATCH.Setup.subjects.effect_names{neffect}
    % BATCH.Setup.subjects.effects{neffect}
    % BATCH.Setup.subjects.group_names{ngroup}
    % BATCH.Setup.subjects.groups
    % BATCH.Setup.rois.mask = rois.mask;
    % BATCH.Setup.rois.regresscovariates = rois.regresscovariates;
    % BATCH.Setup.rois.roiextract = rois.extract;
    BATCH.Setup.rois.add = 0;
    Rois = connLoadRois(Opts.roisFolder,Opts);
    BATCH.Setup.rois.names = Rois.names;
    BATCH.Setup.rois.files = Rois.files;
    BATCH.Setup.rois.dimensions = Rois.dimensions;
    BATCH.Setup.rois.multiplelabels = Opts.roisMultipleLabels;
end

%% Preprocessing
if isfield(Opts,'initPreprocessing')
    if isfield(Opts, 'useStructurals') && Opts.useStructurals == 1
        [BATCH.Setup.functionals, BATCH.Setup.structurals] = connLoadImages(Opts);
    else
         functionals = connLoadImages(Opts);
            for indSub=1:Opts.nSub
                for indSes=1:Opts.nSes
                 BATCH.Setup.functionals{indSub}{indSes}{1} = functionals{indSub,indSes}; 
                end; 
            end
    end
    
    % BATCH.Setup.preprocessing.subjects = [];
    BATCH.Setup.preprocessing.voxelsize = 2;
    BATCH.Setup.preprocessing.boundingbox = [-90,-126,-72;90,90,108];
    BATCH.Setup.preprocessing.fwhm = 6;
    if Opts.useStructurals
        BATCH.Setup.preprocessing.coregtomean = 0;
        BATCH.Setup.preprocessing.steps = 'default_mni';
    else
        BATCH.Setup.preprocessing.coregtomean = 1;
%         BATCH.Setup.preprocessing.steps = {'functional_slicetime','functional_realign',...
%             'functional_coregister', 'functional_normalize',...
%             'functional_segment', 'functional_smooth'};
        BATCH.Setup.preprocessing.steps = {'functional_realign&unwarp',...
            'functional_center', 'functional_slicetime',...
            'functional_normalize', 'functional_segment','functional_art',...
            'functional_smooth'};
    end
    BATCH.Setup.preprocessing.applytofunctional = 0;
    BATCH.Setup.preprocessing.sliceorder = Opts.sliceOrder;
    % BATCH.Setup.preprocessing.unwarp = [];
    BATCH.Setup.preprocessing.art_thresholds = [9 2];
    BATCH.Setup.preprocessing.removescans = 0;
    %     BATCH.Setup.preprocessing.reorient = [];
    %     BATCH.Setup.preprocessing.template_structural = 'spm/template/T1.nii';
    %     BATCH.Setup.preprocessing.template_functional = 'spm/template/EPI.nii';
    %     BATCH.Setup.preprocessing.tpm_template = 'spm/tpm/TPM.nii';
    %     BATCH.Setup.preprocessing.tpm_ngaus = [];
end
%% Denoising
if Opts.runDenoising
    BATCH.Denoising.done = 0;
    BATCH.Denoising.overwrite = 1;
    BATCH.Denoising.filter = [0.01 0.08];
    %     BATCH.Denoising.detrending = 1;
    %     BATCH.Denoising.despiking = 0;
    %     BATCH.Denoising.regbp = 1;
        BATCH.Denoising.confounds.names = {'White Matter';'CSF';'realignment';'scrubbing';'Effect of Rest'};
        BATCH.Denoising.confounds.dimensions = {5;5;inf;inf;inf};
        BATCH.Denoising.confounds.deriv ={0;0;0;0;1};
end
%% First-Level Analysis
if Opts.runFirstLevel
    if max(BATCH.Setup.analyses) <= 2
        BATCH.Analysis.done	= 0;
        BATCH.Analysis.overwrite = 0;
        BATCH.Analysis.analysis_number = 1;
        BATCH.Analysis.measure = 1;
        BATCH.Analysis.weight = 2;
        BATCH.Analysis.modulation = 0;
        %     BATCH.Analysis.conditions = ;
        BATCH.Analysis.type = 3;
        %     BATCH.Analysis.sources.names
        %     BATCH.Analysis.sources.dimensions
        %     BATCH.Analysis.sources.deriv
        %     BATCH.Analysis.sources.fbands
    else
        BATCH.Analysis.done = 0;
        BATCH.Analysis.overwrite = 0;
        %     BATCH.Analysis.measures.names = ;
        %     BATCH.Analysis.measures.type = ;
        %     BATCH.Analysis.measures.kernelsupport = ;
        %     BATCH.Analysis.measures.type.kernelshape = ;
        %     BATCH.Analysis.measures.type.dimensions = ;
    end
end
%% Second-Level Analysis
if Opts.runSecondLevel
    if max(BATCH.Setup.analyses) <= 2
        BATCH.Results.done = 0;
        BATCH.Results.overwrite = 0;
        BATCH.Results.analysis_number = 1;
        %     BATCH.Results.foldername = ;
        %     BATCH.Results.between_subjects.effect_names
        %     BATCH.Results.between_subjects.effects
        %     BATCH.Results.between_conditions.effect_names
        %     BATCH.Results.between_conditions.effects
        %     BATCH.Results.between_sources.effect_names
        %     BATCH.Results.between_sources.contrast
        
    else
        BATCH.Results.done = 0;
        BATCH.Results.overwrite = 0;
        %     BATCH.Results.foldername = ;
        %     BATCH.Results.between_subjects.effect_names
        %     BATCH.Results.between_subjects.contrast
        %     BATCH.Results.between_conditions.effect_names
        %     BATCH.Results.between_conditions.contrast
        %     BATCH.Results.between_measures.effect_names
        %     BATCH.Results.between_measures.contrast
        
    end
end
end


