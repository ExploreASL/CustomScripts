Odir = '/mnt/s4e_data/home/l.mazzai/DIPG/DIPG_90_volumetric_study/T1_forSIENA';
Ddir = '/mnt/s4e_data/home/l.mazzai/DIPG/T1_xASL';

xASLdir = '/mnt/s4e_data/RAD/share/ExploreASL';
cd(xASLdir);
x = ExploreASL_Master('',0); % initiate

cd(Odir);
xASL_adm_CreateDir(Ddir);

TPdir = {'BSL' 'FollowUp'};

for TP=1:2 % TP = timepoint
    Odir2 = fullfile(Odir, TPdir{TP});
    Flist = xASL_adm_GetFileList(Odir2, '\d{6}_.*T(1|2).*\.nii\.gz$', 'FPList', [0 Inf]);
    for iL=1:length(Flist)
        xASL_TrackProgress(iL,length(Flist));
        [~, Ffile] = xASL_fileparts(Flist{iL});
        
        if TP==1
            Subj = [Ffile(1:6) '_1'];
        elseif TP==2
            Subj = [Ffile(1:6) '_2'];
        else
            warning(['StrangeTP ' Ffile ' is unknown']);
        end        
        
        nDir = fullfile(Ddir, Subj);
        xASL_adm_CreateDir(nDir);
        nFile = fullfile(nDir, 'T1.nii.gz');
        if ~xASL_exist(nFile)
            xASL_Copy(Flist{iL}, nFile);
        end
    end
end
    
iFile = '/mnt/s4e_data/RAD/share/ExploreASL/CustomScripts/DIPG/DATA_PAR.m';
oFile = fullfile(Ddir, 'DATA_PAR.m');

xASL_Copy(iFile, oFile);