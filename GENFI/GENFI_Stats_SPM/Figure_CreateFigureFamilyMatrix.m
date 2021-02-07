%% Create Figure Family matrix

%% Find sets indices
clear nFamily nSite

for iS=1:length(x.S.SetsName)
    if      strcmp(x.S.SetsName{iS},'Family') && ~exist('nFamily','var')
            nFamily         = iS;
    elseif  strcmp(x.S.SetsName{iS},'Family') &&  exist('nFamily','var')
            error('Multiple sets Family found');
    end
end    
if ~exist('nFamily','var')
    error('Set Family was not found');
end    
   
for iS=1:length(x.S.SetsName)
    if      strcmp(x.S.SetsName{iS},'Site') && ~exist('nSite','var')
            nSite         = iS;
    elseif  strcmp(x.S.SetsName{iS},'Site') &&  exist('nSite','var')
            error('Multiple sets Site found');
    end
end    
if ~exist('nSite','var')
    error('Set Site was not found');
end    

SiteData    = x.S.SetsID(:,nSite);
% Set sites 5&6 to 5, site 6 == site 5 but Prisma
SiteData(SiteData==6)   = 5;
FamilyData  = x.S.SetsID(:,nFamily);

%% Resort family for sites
clear NewFamily
UniqueSite      = unique(SiteData);
l_Fam           = 0;
for iSite=1:length(unique(SiteData))
    FamilySite      = FamilyData(SiteData==UniqueSite(iSite));
    NewFamily(l_Fam+1:l_Fam+length(FamilySite),1)   = FamilySite;
    NewFamily(l_Fam+1:l_Fam+length(FamilySite),2)   = iSite;
    l_Fam       = length(NewFamily);
    clear FamilySite
end

%% Create random factor Subject
IndexN              = 1;
SubjectList         = zeros(length(x.SUBJECTS),1);
for iS=1:x.nSubjects
    clear IsVolume VolumeList VolumeN IndicesAre
    [ IsVolume VolumeList VolumeN ] = LongRegInit( x, x.SUBJECTS{iS} );
    IndicesAre                  = find(VolumeList(:,2)~=0);
    if  sum(SubjectList(IndicesAre,1))==0 % skips processed subjects
        SubjectList(IndicesAre,1)   = IndexN;
        IndexN                      = IndexN+1;
    end
end

SubjectData     = SubjectList;
    
%% Resort subject for sites
clear NewSubject
UniqueSite      = unique(SiteData);
l_Sub           = 0;
for iSite=1:length(unique(SiteData))
    SubjectSite      = SubjectData(SiteData==UniqueSite(iSite));
    NewSubject(l_Sub+1:l_Sub+length(SubjectSite),1)   = SubjectSite;
    NewSubject(l_Sub+1:l_Sub+length(SubjectSite),2)   = iSite;
    l_Sub       = length(NewSubject);
    clear FamilySite
end

% %% Create covariance matrix, assign color per family
% U   =   unique(NewFamily(:,1));
% clear Xfam
% for iI=1:length(U)
%     Xfam(:,iI)     = (NewFamily(:,1)==U(iI)).*iI;
% end
% Vfam=double(Xfam)*double(Xfam)';


%% Create covariance matrix Subject, assign color per subject
U   =   unique(NewSubject);
clear Xsub
for iI=1:length(U)
    Xsub(:,iI)     = (NewSubject(:,1)==U(iI)).*iI;
end
Vsub=double(Xsub)*double(Xsub)';

%% Create covariance matrix family , assign color per site
U   =   unique(NewFamily(:,1));
FamilySite  = NewFamily(:,2);
clear Xfam
for iI=1:length(U)
    clear TempDim
    TempDim                     = double((NewFamily(:,1)==U(iI)));
    TempDim(logical(TempDim))   = TempDim(logical(TempDim)).*FamilySite(logical(TempDim));
    Xfam(:,iI)                  = TempDim;
end
VfamSite=double(Xfam)*double(Xfam)';

%% Create covariance matrix, assign color per subject
U   =   unique(NewSubject(:,1));
SubjectSite  = NewSubject(:,2);
clear Xfam
for iI=1:length(U)
    clear TempDim
    TempDim                     = double((NewFamily(:,1)==U(iI)));
    TempDim(logical(TempDim))   = TempDim(logical(TempDim)).*FamilySite(logical(TempDim));
    Xfam(:,iI)                  = TempDim;
end
VfamSite=double(Xfam)*double(Xfam)';

%% Convert image to colors
Vfam_clr = LabelColors( Vfam, x);
Vfam_clrSite = LabelColors( VfamSite, x);
Vsub_clr = LabelColors( Vsub, x);


figure(1);imshow(Vsub_clr)


%% Same for subject
