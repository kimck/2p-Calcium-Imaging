function regression_all(pathname,filedate,fn,filetype)

currpath=strcat(pathname,filedate);

% load lever, start_inds, dfof
load(strcat(currpath,'/results/',fn,'.mat'));
load(strcat(currpath,'/behavior/',fn,'.mat'));

if strmatch('shock',filetype)
    trial_type=dfof_trials_shock_press;
    display('Shock');
elseif strmatch('reward',filetype)
    trial_type=dfof_trials_reward_press;
    display('Reward');
else
    trial_type=cat(2,dfof_trials_reward_press,dfof_trials_shock_press);
    display('Lever');
end

numtrials=size(trial_type,2);
numtimepoints=length(time_trial);
numcells=size(trial_type,1);

t_0=find(time_trial>=0,1,'first');
t_1=find(time_trial>=1,1,'first');
t_2=find(time_trial>=2,1,'first');
t_3=find(time_trial>=3,1,'first');
behav=zeros(1,length(time_trial));
if strmatch('lever',filetype)
    behav(t_0:t_1)=5;
else
    behav(t_1:t_3)=5;
end

% convolve behavior regressor with exponential
tau=0.25;
cirf=exp(-time_trial/tau);
cirf=cirf/sum(cirf);
behav_conv=conv(behav,cirf);
behav_conv=behav_conv(1:length(cirf));
behav_regress=repmat(behav_conv,1,numtrials);

cells_type=[];
for a=1:numcells
    cells_type(a,:)=reshape(squeeze(trial_type(a,:,:))',1,numtimepoints*numtrials);
    mcells_type(a,:)=mean(squeeze(trial_type(a,:,:)));
    semcells_type(a,:)=std(squeeze(trial_type(a,:,:)))/sqrt(numtrials);
end

[rho,p]=corr(behav_regress',cells_type');

behav_cells=find(p<0.05);
pos=find(rho(behav_cells)>=0.2);
behav_cells=behav_cells(pos);
numcells_sig=length(behav_cells);
display(numcells_sig);
display(numcells);
percent_sig=length(behav_cells)/numcells;
display(percent_sig);

if ~exist(strcat(currpath,'/regression/'),'dir')
    mkdir(strcat(currpath,'/regression/'));
end

savename=strcat(currpath,'/regression/',fn,'_',filetype,'.mat');
save(savename,'behav_cells','rho','p');

end
