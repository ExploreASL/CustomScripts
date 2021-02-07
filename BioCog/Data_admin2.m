%% Data admin BioCog 2

ROOT{1}     = 'C:\Backup\ASL\BioCog\BERLIN_controls'; % wait for answer Ilse
ROOT{2}     = 'C:\Backup\ASL\BioCog\BERLIN_DF1';
ROOT{3}     = 'C:\Backup\ASL\BioCog\Utrecht_DF1_plusCo';
ROOT{4}     = 'C:\Backup\ASL\BioCog\Utrecht_DF2';


    iR=2

    Flist   = xASL_adm_GetFsList(ROOT{iR},'^(BIC|BICON|BIM|BCU|CCC)\d{3}_(1|2)$',1);
    for ii=1:length(Flist)
        Site{ii,1}  = Flist{ii};
        Site{ii,2}  = 'Berlin';
        DataFreeze{ii,1}  = Flist{ii};
        DataFreeze{ii,2}  = 1;
    end
    save(fullfile(ROOT{iR},'Site.mat'),'Site');
    save(fullfile(ROOT{iR},'DataFreeze.mat'),'DataFreeze');

    iR=3

    Flist   = xASL_adm_GetFsList(ROOT{iR},'^(BIC|BICON|BIM|BCU|CCC)\d{3}_(1|2)$',1);
    for ii=1:length(Flist)
        Site{ii,1}  = Flist{ii};
        Site{ii,2}  = 'UMCU';
        DataFreeze{ii,1}  = Flist{ii};
        DataFreeze{ii,2}  = 1;
    end
    save(fullfile(ROOT{iR},'Site.mat'),'Site');
    save(fullfile(ROOT{iR},'DataFreeze.mat'),'DataFreeze');

    iR=4

    Flist   = xASL_adm_GetFsList(ROOT{iR},'^(BIC|BICON|BIM|BCU|CCC)\d{3}_(1|2)$',1);
    for ii=1:length(Flist)
        Site{ii,1}  = Flist{ii};
        Site{ii,2}  = 'UMCU';
        DataFreeze{ii,1}  = Flist{ii};
        DataFreeze{ii,2}  = 2;
    end
    save(fullfile(ROOT{iR},'Site.mat'),'Site');
    save(fullfile(ROOT{iR},'DataFreeze.mat'),'DataFreeze');



%% Delete files

ROOT        = 'C:\Backup\ASL\BioCog';
RegExpL     = {'mwp1t1_mprage.*\.nii' 'mwp2t1_mprage.*\.nii' 'wmt1_mprage.*\.nii' 'catreport.*\.pdf' 'catROI_.*\.xml' 'catROI_.*\.mat' 'cat_.*\.xml' 'cat_.*\.mat' 'dicm2nii.*\.txt' 'DTI_30dir.*\.nii' 'HighResHippo.*\.nii' 't2_spc.*\.nii' 'filled_lpa.*\.nii' 'report_LST_.*\.html' 'fillingBioCog_.*\.mat' 'ep2d_bold.*\.nii' '3x3x7_MoCo\.nii' '^T1BOLD\.(nii|nii\.gz)$' '^log\.txt$' '^DTI\.bval$' '^DTI\.bvec$'};

RegExpL     = {'NONE\.mlimage$' 'NONE_\.mlimage$' 'UNKNOWN_\.mlimage$' 'UNKNOWN\.mlimage$' '^y_.*\.(nii|nii\.gz)$'};

RegExpL     = {'AutoAlign_.*\.nii'  '.*\.bval$' '.*\.bvec$' 'LST_filled.*' 'LST_lpa_mrt2_spc.*'};

RegExpL     = {'_ND\.nii' '_s003\.nii' '

'.*MoCo\.nii' keep 006



clear Flist
for iR=1:length(RegExpL)

    Flist{iR}   = xASL_adm_GetFileList(ROOT,RegExpL{iR},'FPListRec');

%         for iF=1:length(Flist{iR});delete(Flist{iR}{iF});end
end


%% First convert FileNames, to check whether all files are there

clear Flist
ROOT        = 'C:\Backup\ASL\BioCog\BERLIN_controls';
% RegExpL     = {'ep2d_pcasl_3x3x7\.nii'};

Dlist       = xASL_adm_GetFsList(ROOT,'^.*BICON.*$',1);
for iD=1:length(Dlist)
    clear Fname
    Fname   = fullfile(ROOT,Dlist{iD},'ep2d_pcasl_3x3x7.nii');
    Dir2    = fullfile(ROOT,Dlist{iD},'ASL_1');
    Fname2  = fullfile(Dir2 ,'ASL4D.nii');
    if  exist(Fname ,'file') && ~exist(Fname2,'file')
        xASL_adm_CreateDir(Dir2);
        xASL_Move(Fname, Fname2);
    else  error(Dlist{iD});
    end
end

for iD=1:length(Dlist)
    clear Fname
    Fname   = fullfile(ROOT,Dlist{iD},'ep2d_pcasl_3x3x7_M0_tra_Augen_offen.nii');
    Dir2    = fullfile(ROOT,Dlist{iD},'ASL_1');
    Fname2  = fullfile(Dir2 ,'M0.nii');
    if  exist(Fname ,'file') && ~exist(Fname2,'file')
        xASL_adm_CreateDir(Dir2);
        xASL_Move(Fname, Fname2);
    else  error(Dlist{iD});
    end
end

for iD=1:length(Dlist)
    clear Fname Fname2
    Fname   = xASL_adm_GetFileList(fullfile(ROOT,Dlist{iD}),'^t1_mprage_sag_1_0mm_opt_sag_s00(6|8|9)\.nii');
    Fname2  = fullfile(ROOT,Dlist{iD},'T1.nii');
    if  length(Fname)==1 && ~exist(Fname2,'file')
        xASL_Move(Fname{1}, Fname2);
    else  error(Dlist{iD});
    end
end


%% 2) DF1

clear Flist
ROOT        = 'C:\Backup\ASL\BioCog\BERLIN_DF1';
% RegExpL     = {'ep2d_pcasl_3x3x7\.nii'};

Dlist       = xASL_adm_GetFsList(ROOT,'^.*(BICON|BIC|BIM).*$',1);

% ASL
clear NotPresent NN
NN=1;
for iD=1:length(Dlist)
    clear Fname
    Fname   = fullfile(ROOT,Dlist{iD},'ep2d_pcasl_3x3x7.nii');
    Dir2    = fullfile(ROOT,Dlist{iD},'ASL_1');
    Fname2  = fullfile(Dir2 ,'ASL4D.nii');
    if  exist(Fname ,'file') || exist(Fname2,'file')
        if  exist(Fname ,'file') && ~exist(Fname2,'file')
            xASL_adm_CreateDir(Dir2);
            xASL_Move(Fname, Fname2);
        end
    else  NotPresent{NN,1}  = Dlist{iD};
          NN    = NN+1;
    end
end

% M0
clear NotPresent NN
NN=1;
for iD=1:length(Dlist)
    clear Fname Fname2 Fname3
    Fname   = fullfile(ROOT,Dlist{iD},'ep2d_pcasl_3x3x7_M0_tra_Augen_offen.nii');
    Fname3  = fullfile(ROOT,Dlist{iD},'ep2d_pcasl_3x3x7_M0_tra.nii');
    Dir2    = fullfile(ROOT,Dlist{iD},'ASL_1');
    Fname2  = fullfile(Dir2 ,'M0.nii');
    if  exist(Fname ,'file') || exist(Fname2,'file') || exist(Fname3,'file')
        if      exist(Fname ,'file') && ~exist(Fname2,'file')
                xASL_adm_CreateDir(Dir2);
                xASL_Move(Fname, Fname2);
        elseif  exist(Fname3 ,'file') && ~exist(Fname2,'file')
                xASL_adm_CreateDir(Dir2);
                xASL_Move(Fname3, Fname2);
        end
    else  NotPresent{NN,1}  = Dlist{iD};
          NN    = NN+1;
    end
end

% T1w
clear NotPresent NN
NN=1;
for iD=1:length(Dlist)
    clear Fname Fname2
    Fname   = xASL_adm_GetFileList(fullfile(ROOT,Dlist{iD}),'^t1_mprage_sag_1_0mm_opt_sag_s0\d{2}\.nii','FPList',[0 Inf]);
    Fname2  = fullfile(ROOT,Dlist{iD},'T1.nii');
    if  length(Fname)==1 || exist(Fname2,'file')
        if  length(Fname)==1 && ~exist(Fname2,'file')
            xASL_Move(Fname{1}, Fname2);
        end
    else  NotPresent{NN,1}  = Dlist{iD};
          NN    = NN+1;
    end
end


% FLAIR
clear NotPresent NN
NN=1;
for iD=1:length(Dlist)
    clear Fname Fname2
    Fname   = xASL_adm_GetFileList(fullfile(ROOT,Dlist{iD}),'^t1_mprage_sag_1_0mm_opt_sag_s0\d{2}\.nii','FPList',[0 Inf]);
    Fname2  = fullfile(ROOT,Dlist{iD},'T1.nii');
    if  length(Fname)==1 || exist(Fname2,'file')
        if  length(Fname)==1 && ~exist(Fname2,'file')
            xASL_Move(Fname{1}, Fname2);
        end
    else  NotPresent{NN,1}  = Dlist{iD};
          NN    = NN+1;
    end
end






%% Concatenate multiple M0
clear IM IM1 IM2 Fname1 Fname2
Fname1  = 'C:\Backup\ASL\BioCog\BERLIN_DF1\BIC033_2\ASL_1\M0.nii';
Fname2  = 'C:\Backup\ASL\BioCog\BERLIN_DF1\BIC033_2\ASL_1\M01.nii';

IM1         = xASL_io_ReadNifti(Fname1);
IM          = IM1.dat(:,:,:);
IM2         = xASL_io_ReadNifti(Fname2);
IM(:,:,:,2) = IM2.dat(:,:,:);
xASL_io_SaveNifti(Fname1,Fname1,IM);

%% Convert dcm2nii
dcm2nii( 'C:\Backup\ASL\BioCog\BERLIN_DF1\BIC140_2\009_t2_spc_da-fl_irprep_sag_p2_iso_TR4800_PF68','C:\Backup\ASL\BioCog\BERLIN_DF1\BIC140_2', 'FLAIR');



%% UTRECHT DATA







%% 2) DF1

Dlist1       = xASL_adm_GetFsList(ROOT,'^(BICON|BIC|BIM|BCU|CCC)\d{3}_(1|2)$',1);
Dlist2       = xASL_adm_GetFsList('C:\Backup\ASL\BioCog_OLD','^(BICON|BIC|BIM|BCU|CCC)\d{3}_(1|2)$',1);


clear Flist
ROOT        = 'C:\Backup\ASL\BioCog\Utrecht_DF1_plusCo';
Dlist       = xASL_adm_GetFsList(ROOT,'^(BICON|BIC|BIM|BCU|CCC)\d{3}_(1|2)$',1);

% ASL
clear NotPresent NN
NN=1;
for iD=1:length(Dlist)
    clear Fname
    Fname   = fullfile(ROOT,Dlist{iD},'ep2d_pcasl_3x3x7.nii');
    Dir2    = fullfile(ROOT,Dlist{iD},'ASL_1');
    Fname2  = fullfile(Dir2 ,'ASL4D.nii');
    if  exist(Fname ,'file') || exist(Fname2,'file')
        if  exist(Fname ,'file') && ~exist(Fname2,'file')
            xASL_adm_CreateDir(Dir2);
            xASL_Move(Fname, Fname2);
        end
    else  NotPresent{NN,1}  = Dlist{iD};
          NN    = NN+1;
    end
end

% M0
clear NotPresent NN
NN=1;
for iD=1:length(Dlist)
    clear Fname Fname2 Fname3
    Fname   = fullfile(ROOT,Dlist{iD},'ep2d_pcasl_3x3x7_M0_tra_Augen_offen.nii');
    Fname3  = fullfile(ROOT,Dlist{iD},'ep2d_pcasl_3x3x7_M0_tra.nii');
    Dir2    = fullfile(ROOT,Dlist{iD},'ASL_1');
    Fname2  = fullfile(Dir2 ,'M0.nii');
    if  exist(Fname ,'file') || exist(Fname2,'file') || exist(Fname3,'file')
        if      exist(Fname ,'file') && ~exist(Fname2,'file')
                xASL_adm_CreateDir(Dir2);
                xASL_Move(Fname, Fname2);
        elseif  exist(Fname3 ,'file') && ~exist(Fname2,'file')
                xASL_adm_CreateDir(Dir2);
                xASL_Move(Fname3, Fname2);
        end
    else  NotPresent{NN,1}  = Dlist{iD};
          NN    = NN+1;
    end
end

% T1w
clear NotPresent NN
NN=1;
for iD=1:length(Dlist)
    clear Fname Fname2
    Fname   = xASL_adm_GetFileList(fullfile(ROOT,Dlist{iD}),'^t1_mprage_sag_1_0mm_opt_sag_s0\d{2}\.nii','FPList',[0 Inf]);
    Fname2  = fullfile(ROOT,Dlist{iD},'T1.nii');
    if  length(Fname)==1 || exist(Fname2,'file')
        if  length(Fname)==1 && ~exist(Fname2,'file')
            xASL_Move(Fname{1}, Fname2);
        end
    else  NotPresent{NN,1}  = Dlist{iD};
          NN    = NN+1;
    end
end


% FLAIR
clear NotPresent NN
NN=1;
for iD=1:length(Dlist)
    clear Fname Fname2
    Fname   = xASL_adm_GetFileList(fullfile(ROOT,Dlist{iD}),'^t1_mprage_sag_1_0mm_opt_sag_s0\d{2}\.nii','FPList',[0 Inf]);
    Fname2  = fullfile(ROOT,Dlist{iD},'T1.nii');
    if  length(Fname)==1 || exist(Fname2,'file')
        if  length(Fname)==1 && ~exist(Fname2,'file')
            xASL_Move(Fname{1}, Fname2);
        end
    else  NotPresent{NN,1}  = Dlist{iD};
          NN    = NN+1;
    end
end
