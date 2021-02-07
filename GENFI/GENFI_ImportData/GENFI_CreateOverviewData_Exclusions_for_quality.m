%% GENFI get first volumes, and follow-ups

BaselineSubjects    = '';
FollowUpSubjects    = '';

for iS=1:x.nSubjects
    [ DoLongReg IsSubject VolumeN ] = LongRegInit( x, x.SUBJECTS{iS} );
    if      DoLongReg==0 || DoLongReg==1
            BaselineSubjects{end+1,1}     = x.SUBJECTS{iS};
    else    FollowUpSubjects{end+1,1}     = x.SUBJECTS{iS};
    end
end

load('C:\Backup\ASL\GENFI\GENFI_DF2\QC3_SpatialCoV&visualQC.mat');

LessThan10Subjects   = {'SI_Allegra_C9ORF022_1'  ;'SI_Allegra_C9ORF024_1';'SI_Skyra_MAPT047_1';'SI_Skyra_MAPT050_1'};

BaselineExcl_Bad            = ''; length(BaselineExcl_Bad)
BaselineExcl_Unusable       = ''; length(BaselineExcl_Unusable)
BaselineExcl_Lessthan10     = ''; length(BaselineExcl_Lessthan10)

FU_Excl_Bad                 = ''; length(FU_Excl_Bad)
FU_Excl_Unusable            = ''; length(FU_Excl_Unusable)
FU_Excl_Lessthan10          = ''; length(FU_Excl_Lessthan10)

for iS=1:length(BaselineSubjects)
    for iQ=1:length(QualityBad2)
        if      strcmp( BaselineSubjects{iS,1}, QualityBad2{iQ} )
                BaselineExcl_Bad{end+1,1}       = BaselineSubjects{iS,1};
        end
    end
    
    for iQ=1:length(QualityUnusable2)
        if      strcmp( BaselineSubjects{iS,1}, QualityUnusable2{iQ} )
                BaselineExcl_Unusable{end+1,1}  = BaselineSubjects{iS,1};
        end
    end

    for iQ=1:length(LessThan10Subjects)
        if      strcmp( BaselineSubjects{iS,1}, LessThan10Subjects{iQ} )
                BaselineExcl_Lessthan10{end+1,1}  = BaselineSubjects{iS,1};
        end
    end
end

for iS=1:length(FollowUpSubjects)
    for iQ=1:length(QualityBad2)
        if      strcmp( FollowUpSubjects{iS,1}, QualityBad2{iQ} )
                FU_Excl_Bad{end+1,1}       = FollowUpSubjects{iS,1};
        end
    end
    
    for iQ=1:length(QualityUnusable2)
        if      strcmp( FollowUpSubjects{iS,1}, QualityUnusable2{iQ} )
                FU_Excl_Unusable{end+1,1}  = FollowUpSubjects{iS,1};
        end
    end

    for iQ=1:length(LessThan10Subjects)
        if      strcmp( FollowUpSubjects{iS,1}, LessThan10Subjects{iQ} )
                FU_Excl_Lessthan10{end+1,1}  = FollowUpSubjects{iS,1};
        end
    end
end

FU_Excl_Bad_by_Baseline                 = ''; length(FU_Excl_Bad_by_Baseline)
FU_Excl_Unusable_by_Baseline            = ''; length(FU_Excl_Unusable_by_Baseline)
FU_Excl_Lessthan10_by_Baseline          = ''; length(FU_Excl_Lessthan10_by_Baseline)

for iS=1:length(FollowUpSubjects)
    for iQ=1:length(BaselineExcl_Bad)
        if  strcmp(BaselineExcl_Bad{iQ}(1:end-2),FollowUpSubjects{iS}(1:end-2))
            FU_Excl_Bad_by_Baseline{end+1,1}    = FollowUpSubjects{iS};
        end
    end
       
    for iQ=1:length(BaselineExcl_Unusable)
        if  strcmp(BaselineExcl_Unusable{iQ}(1:end-2),FollowUpSubjects{iS}(1:end-2))
            FU_Excl_Unusable_by_Baseline{end+1,1}    = FollowUpSubjects{iS};
        end      
    end

    for iQ=1:length(BaselineExcl_Lessthan10)
        if  strcmp(BaselineExcl_Lessthan10{iQ}(1:end-2),FollowUpSubjects{iS}(1:end-2))
            FU_Excl_LessThan10_by_Baseline{end+1,1}    = FollowUpSubjects{iS};
        end                
    end
end
        
        