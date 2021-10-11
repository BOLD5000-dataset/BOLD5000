function [design, allses_design, cond_labels, session_indicator] = load_BOLD5000_design(eventdir, sessionstorun)

addpath('GLMsingle/matlab')
addpath('GLMsingle/matlab/utilities')
addpath('nifti_tools')

if contains(eventdir,'CSI4')
    nses = 9;
else
    nses = 15;
end

runtrs = 194;

tr = 2;

assert(isfolder(eventdir))

%% step 1: get mapping from image name to condition number

disp('accumulating event info...')

allses_events = cell(1,nses);
allses_design = cell(1,nses);

stim_names = [];

for ses = 1:nses
        
    if ses < 10
        sesstr = ['0' num2str(ses)];
    else
        sesstr = num2str(ses);
    end
    
    disp(['loading design matrix for session ' sesstr])
    
    subeventdir = fullfile(eventdir,['ses-' sesstr],'func');
    
    eventfiles = struct2table(dir(subeventdir));
    eventfiles = eventfiles(~eventfiles.isdir,:).name;
    eventfiles = eventfiles(contains(eventfiles,'events.tsv') & ~contains(eventfiles,'localizer'));
            
    for run = 1:length(eventfiles)   
       temp = tdfread(fullfile(subeventdir,eventfiles{run}));    
       allses_events{ses}{run} = temp;
       stim_names = [stim_names; cellstr(temp.ImgName)];
    end
    
end

%%  

[unique_names,~,cond_labels] = unique(stim_names,'stable');
mapping = [stim_names num2cell(cond_labels)];

%%

for ses = 1:nses
    
    for run = 1:length(allses_events{ses})
        
        events0 = allses_events{ses}{run};
        design0 = sparse(runtrs, length(unique_names));

        onsetTRs = round(events0.onset./tr)+1;
        
        % img names presented this run
        runimgs = cellstr(allses_events{ses}{run}.ImgName);
        
        % for each name 
        for img = 1:length(runimgs)
            
            % use the mapping table to look up the img condition label
            cond = cond_labels(strcmp(mapping(:,1),runimgs{img}));
            
            % assert that repeats (if exist) all have the same label
            assert(all(cond == cond(1)))
            
            % insert label into design matrix at correct TR
            design0(onsetTRs(img), cond(1)) = 1;
            
            %disp(['ses ' num2str(ses) ' run ' num2str(run) ': cond ' num2str(cond(1)) ' inserted at tr ' num2str(onsetTRs(img)) ': ' runimgs{img} '  (' unique_names{cond(1)} ')'])
                
        end
        
        allses_design{ses}{run} = design0;
        
    end
        
end

%%

for ses = 1:nses
    for run = 1:length(allses_events{ses})
        
        % lookup img names using cond labels from design matrix 
        [runconds, ~] = find(allses_design{ses}{run}');
        
        namesA = unique_names(runconds);
        namesB = cellstr(allses_events{ses}{run}.ImgName);
        
        assert(all(strcmp(namesA,namesB)))
   
    end
end

%%

design = [];
session_indicator = [];
ct = 1; 
for ses = sessionstorun
    
    ses_design = allses_design{ses};
    design = [design ses_design];
    session_indicator = [session_indicator ones(1,length(ses_design)).*ct];
    ct = ct + 1;

end

end

