%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function loads BIDS-formatted BOLD5000 time-series data and computes 
% single-trial GLM beta estimates using the GLMsingle toolbox. 
%
% GLMsingle is new tool that provides efficient, scalable, and accurate
% single-trial fMRI response estimates. By default, the tool implements a
% set of optimizations that improve upon generic GLM approaches by: (1)
% identifying an optimal hemodynamic response function (HRF) at each voxel,
% (2) deriving a set of useful GLM nuisance regressors via "GLMdenoise" and
% picking an optimal number to include in the final GLM, and (3) applying a
% custom amount of ridge regularization at each voxel using an efficient
% technique called "fracridge". The output of GLMsingle are GLM betas
% reflecting the estimated percent signal change in each voxel in response
% to each experimental stimulus or condition being modeled.
% 
% Input arguments:
%
% <subj> is the string identifier for a BOLD5000 subject (CSI1, CSI2, CSI3, or
%       CSI4) determining which subject's data will be processed.
%
% <sess> is a string defining which sessions of data will be processed. subjects
%        1-3 completed all 15 sessions, while subject 4 completed 9 sessions. 
%        because GLMsingle relies on the existence of repeated stimuli within each group
%        of data being processed, it is likely best to process several sessions of data
%        simultaneously to maximize the available image repetitions. 
%        inputs should be formatted as numbers separated by underscores - for example, 
%        to process data from sessions 1, 4, 9, and 13, <sess> would be "1_4_9_13". 
%
% <GLM_method> describes which combination of GLMsingle hyperparameters should be 
%        applied for this run. "assume" fits the GLM using the canonical HRF, with 
%        no denoising or ridge regression. "optimize" (recommended) performs a complete 
%        run of GLMsingle incorporating HRF fitting, GLMdenoise, and ridge regression. 
%
% <bidsdir> is a filepath pointing to the location of BOLD5000 fMRI time-series data
%        in BIDS format. 
%        these data are available here: 
%        https://openneuro.org/datasets/ds001499/versions/1.3.1
%
% <outputdir> is a user-provided string that will name the folder into which outputs
%        will be saved. 
%
% example usage: 
%        run_GLMsingle_pipeline_BOLD5000('CSI1','1_6_12','optimize',...
%                                 '/media/tarrlab/scenedata2/5000_BIDS','output_betas')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = run_GLMsingle_pipeline_BOLD5000(subj, sess, GLM_method, bidsdir, outputdir)

dbstop if error

disp(['running for subject: ' subj])
disp(['running for session: ' sess])
disp(['running for method: ' GLM_method])
disp('begin setup...')
tic

addpath('utilities')
addpath('fracridge/matlab')
addpath('GLMsingle/matlab')
addpath('GLMsingle/matlab/utilities')
addpath('nifti_tools')

debug_mode = 1; % runs GLMsingle on only one slice of data

%%%%%%%%% OPTS HANDLING %%%%%%%%%%%%%%%%

opt = struct();

% adjust hyperparameters based on GLM method
if strcmp(GLM_method,'assume') % uses the canonical HRF, no denoising/ridge regression
    opt.wantlibrary=0;
    opt.wantfileoutputs = [1 1 0 0];
    opt.wantglmdenoise=0;
    opt.wantlss=0;
    opt.wantfracridge=0;
    opt.wantmemoryoutputs=[0 0 0 0];
    opt.method = [outputdir '_assume'];
elseif strcmp(GLM_method, 'optimize') % uses HRF fitting, GLMdenoise, and ridge regression
    opt.wantlibrary=1;
    opt.wantfileoutputs = [1 1 1 1];
    opt.wantglmdenoise=1;
    opt.wantlss=0;
    opt.wantfracridge=1;
    opt.wantmemoryoutputs=[0 0 0 0];
    opt.method = outputdir;
elseif strcmp(GLM_method,'fit_lss') % uses HRF fitting, and fits the GLM using the least-squares-single method
    opt.wantlibrary=1;
    opt.wantfileoutputs = [1 1 0 0];
    opt.wantglmdenoise=0;
    opt.wantlss=1;
    opt.wantfracridge=0;
    opt.wantmemoryoutputs=[0 0 0 0];
    opt.method = [outputdir '_fit_lss'];
elseif strcmp(GLM_method,'assume_lss') % no HRF fitting, uses LSS method
    opt.wantlibrary=0;
    opt.wantfileoutputs = [1 1 0 0];
    opt.wantglmdenoise=0;
    opt.wantlss=1;
    opt.wantfracridge=0;
    opt.wantmemoryoutputs=[0 0 0 0];
    opt.method = [outputdir '_assume_lss']; 
end

opt.subj = subj;
opt.sessionstorun = cellfun(@str2num,(strsplit(sess,'_')));
opt.loocv = 1;
opt.k = 2;

opt.chunknum = 125000; % number of voxels processed simultaneously; decrease if low RAM
opt.numpcstotry = 12; % number of GLMdenoise noise regressors to test 

disp('chunknum:')
disp(opt.chunknum)

% if not leave-one-run-out cross validation, adjust the CV scheme
if opt.loocv == 0
    
    opt.xvalscheme = [];
    
    k = opt.k;
    for x = 1:k
        opt.xvalscheme = [opt.xvalscheme {[x:k:length(design_scheme)]}];
    end
    
    disp('xvalscheme:')
    disp(opt.xvalscheme)
else
    disp('using leave-one-run-out cv')
end

%%%%%%%% DIRECTORY MANAGEMENT %%%%%%%%%%%

if debug_mode == 1
    outputdir = [outputdir '_debug'];
end

homedir = pwd;

eventdir = fullfile(bidsdir,['sub-' subj]); % directory containing event files - for constructing design matrix

datadir = fullfile(bidsdir,'derivatives','fmriprep',['sub-' subj]); % directory containing time-series data

savedir = fullfile(homedir,'betas',outputdir, subj,['sessions_' strrep(strrep(strrep(num2str(opt.sessionstorun),' ','_'),'__','_'),'__','_')]); % output directory

disp(['savedir: ' savedir])

assert(isdir(bidsdir))
assert(isdir(eventdir))
assert(isdir(datadir))

% define
stimdur = 1;
tr = 2;

%% load design matrices for the sessions being processed
[design, ~, ~, session_indicator] = load_BOLD5000_design(eventdir, opt.sessionstorun);

if length(opt.sessionstorun) > 1
    opt.sessionindicator = session_indicator;
end

%% load data for the session(s) being processed

[data, rescale_fig] = load_BOLD5000_data(datadir, opt.sessionstorun);

% if debug mode, limit data to one slice
if debug_mode == 1
    for i = 1:length(data)
        dims = size(data{i});
        subslices = 25;
        data{i} = data{i}(:,:,subslices,:);
    end
end

% check sanity
assert(length(data) == length(design))

disp('finished setup')
toc

%% run GLMs

disp(['running GLM for sessions ' num2str(opt.sessionstorun)])

tic;

% run GLMsingle
results = GLMestimatesingletrial(design,data,stimdur,tr,savedir,opt);

disp('done with call to GLMestimatesingletrial')

% if multiple sessions, data was rescaled. save the output figure showing results of rescaling
if length(data) > 10
    saveas(rescale_fig, fullfile(savedir,'rescaleOutcome.png'), 'png')
    close
end

toc;

end


