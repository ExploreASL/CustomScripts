%% Get QC list >HD302

ODIR    = 'C:\Backup\ASL\Harmy\analysis_Harmy\dartel\ASL_Check\Visual_QC_HigherThan302';

DIR{1}  = fullfile(ODIR,'1 Good CBF contrast');
DIR{2}  = fullfile(ODIR,'2 Acceptable');
DIR{3}  = fullfile(ODIR,'3 Angiogram');
DIR{4}  = fullfile(ODIR,'4 Unusable');

Tlist   = [];

for iD=1:4
    fList{iD}   = xASL_adm_GetFileList(DIR{iD},'^qCBF_untreated_HD\d{3}_(1|2)_ASL_1\.jpg$');
    for iL=1:length(fList{iD})
        [Fpath Ffile Fext]  = fileparts(fList{iD}{iL});
        fList{iD}{iL}       = Ffile(16:end-6);
        Tlist{end+1,1}      = fList{iD}{iL};
        Tlist{end  ,2}      = iD;
    end
end

