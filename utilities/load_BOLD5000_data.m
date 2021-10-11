function [data, rescale_fig] = load_BOLD5000_data(datadir, sessionstorun)

tic 

addpath('GLMsingle/matlab')
addpath('GLMsingle/matlab/utilities')
addpath('nifti_tools')

%% load data from all sessions

disp(['loading data for sessions ' num2str(sessionstorun)])

data = [];
ses_IDs = [];
ses_meanvols = [];

% rescale if more than 1 session being processed
if length(sessionstorun) > 1
    rescale = 1;
else
    rescale = 0;
end

c = 1;
for ses = sessionstorun
    
    if ses < 10
        sesstr = ['0' num2str(ses)];
    else
        sesstr = num2str(ses);
    end
    
    disp(['loading session ' sesstr])
    
    subdatadir = fullfile(datadir,['ses-' sesstr],'func');
    
    % figure out runs
    files0 = matchfiles(fullfile(subdatadir,'*run*_preproc.nii.gz'));
    maskfiles0 = matchfiles(fullfile(subdatadir,'*_brainmask.nii.gz'));
    
    assert(~isempty(files0),'error: data files not found. check if path is correct.')
    
    % load data
    ses_data = {};
    for p=1:length(files0)
        disp(p)
        disp(files0{p}(1:end-7))
        a1 = load_nifti(files0{p}(1:end-7));
        img = single(a1.img);
        
        if sum(isnan(img(:))) > 0
            error('volume contains nans')
        end
        
        % load brain mask
        mask = load_nifti(maskfiles0{p}(1:end-7));
        for i=1:size(img,4)
            thisimg = squeeze(img(:,:,:,i));
            thisimg(mask.img==0) = 0;
            img(:,:,:,i) = thisimg;
        end
        ses_data{p} = img;
    end
    clear a1;
    
    if rescale == 1       
        ses_IDs = [ses_IDs ones(size(ses_data)).*c];
        c = c+1;
        meanvol = compute_meanvol(ses_data);
        ses_meanvols = [ses_meanvols {meanvol}];
    end
    
    data = [data ses_data];
    
end

if length(sessionstorun) > 1
    disp('more than one session being processed: rescaling data...')
    [data, rescale_fig] = rescale_data(data, ses_meanvols, ses_IDs);
else
    rescale_fig = [];
end
    
disp('done loading data')

toc

end

function [rescaled_data, rescale_fig] = rescale_data(data, ses_meanvols, ses_IDs)

assert(length(data) == length(ses_IDs))
n = length(ses_meanvols);
dims = size(data{1});

% reshape session meanvols to set up computation of scaling factor
mvs = zeros(dims(1)*dims(2)*dims(3),n);

for i = 1:n
    mvs(:,i) = reshape(ses_meanvols{i}, [dims(1)*dims(2)*dims(3), 1]);
end

% compute global mean volume
gmv = mean(mvs,2);

% perform regression to get scaling factor for each session
scs = [];
rescaled_mvs = zeros(size(mvs));
for p = 1:size(mvs,2)
   
   sc = mvs(:,p)\gmv;
   scs = [scs sc];
   rescaled_mvs(:,p) = sc*mvs(:,p);
   
end

% apply appropriate scaling factor to each run
for i = 1:length(data)
    
    rescaled_data{i} = scs(ses_IDs(i)) * data{i};
    disp(['rescaling absolute run ' num2str(i) ' from ses ' num2str(ses_IDs(i)) ' by scaling factor ' num2str(scs(ses_IDs(i)),4)])
    
end

% verify that rescaling worked properly
coefsA = zeros(n,n);
coefsB = zeros(n,n);

for i = 1:n
    for j = 1:n
        pA = polyfit(mvs(:,i), mvs(:,j), 1);
        pB = polyfit(rescaled_mvs(:,i), rescaled_mvs(:,j), 1);
        
        coefsA(i,j) = pA(1);
        coefsB(i,j) = pB(1);
        
    end
end

figure('Color',[1 1 1], 'Position',[0 0 2000 1200])
subplot(121)
imagesc(coefsA,[0.9 1.1])
colorbar
axis square
xlabel('session')
ylabel('session')
title(['LR slope relating voxel intensities' newline 'between sessions'])

subplot(122)
imagesc(coefsB,[0.9 1.1])
colorbar
axis square
xlabel('session')
ylabel('session')
title(['LR slope relating voxel intensities' newline 'between sessions (with rescaling)'])

rescale_fig = gcf;

%close

end

function [meanvol] = compute_meanvol(ses_data)

    dims = size(ses_data{1});
    meanvol = zeros(dims(1), dims(2), dims(3));
    
    for run = 1:length(ses_data)
        meanvol = meanvol + mean(ses_data{run},4);  
    end
     
    meanvol = meanvol ./ length(ses_data);

end





