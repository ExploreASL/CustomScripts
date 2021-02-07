function [prefix,R,Score]= SCRUBdenoising(filename,tpmimgs,maskimg,prefix)
%,wfun,flagprior,flagmodrobust,flagstd,prefix,savefile)

% RobustBayesianASLdenoising: performs ASL denoising using a Robust
% Bayesian approach
% Input:
%   filename: File name of 4D CBF time series
%   tpmimgs: file names of GM, WM and CSF tissue probability maps in order
%   maskimg: file name of brain mask
%   wfun: robust function used in robust regression
%   flagprior: 1 implies use prior, 0 no prior
%   flagmodrobust: Use modified robust method
%   flagstd: 1 implies std in robust regression computed using regular std,
%   0 implies robust estimate
%   prefix: prefix to be added to the name of the saved file: Use SCRUB
%
% Output:
%   prefix: prefix added to the name of the file
%   R: Estimated mean CBF map
%   Score: Score output
% Report any bug to Sudipto Dolui: sudiptod@mail.med.upenn.edu

% Default Use: SCRUBdenoising(filename,tpmimgs,maskimg,'huber',1,1,1,'SCRUB',1);    %%% OLD version of the code with more user input
% Default Use:SCRUBdenoising(filename,tpmimgs,maskimg,'SCRUB');

wfun = 'huber';
flagprior = 1;
flagmodrobust=1;
flagstd=1;
% prefix='SCRUB';
savefile=1;


% if ~ismember(flagstd,[0,1])
%     flagstd=1;       % flagstd = 1 implies std, 0 implies robust method
% end
% if ~ismember(flagprior,[0,1])
%     flagprior=1;       % flagprior = 1 implies global prior, 0 implies no prior
% end
% if ~ismember(flagmodrobust,[0,1])
%     flagmodrobust=1;       % flagprior = 1 implies global prior, 0 implies no prior
% end
% 
% if ~exist('savefile','var')||isempty(savefile)
%     savefile = 1;
% end


v=spm_vol(filename);
dat=spm_read_vols(v);
[x,y,z,~]=size(dat);

roidat=spm_read_vols(spm_vol(tpmimgs));
gm=roidat(:,:,:,1);
wm=roidat(:,:,:,2);
csf=roidat(:,:,:,3);

mask=spm_read_vols(spm_vol(maskimg))>0;
mask=mask & (max(abs(dat),[],4)>0) & any(~isnan(dat),4);
gm=gm.*mask;
wm=wm.*mask;
csf=csf.*mask;


[Score,dat]=SCORE_den(dat,gm,wm,csf,0.95);
vo=v(1);
vo.fname=fullfile(spm_str_manip(vo.fname,'H'),['SCORE'_' spm_str_manip(vo.fname,'t')]);
spm_write_vol(vo,Score);

clear T

Y=zeros(sum(mask(:)),size(dat,4));

for k=1:size(dat,4)
    tmp=dat(:,:,:,k);
    Y(:,k)=tmp(mask);
end

R=Score;

for iter=1
    if flagprior==0
        mu=0;
        GlobalPrior=0;
        modrobprior = 0;
    else
        %         GMCBF=median(R(gm>0.9));
        %         WMCBF=median(R(wm>0.9));
        
        
        
        
        % CSFCBF=median(R(csf>0.9));
        
        VV=var(Y,[],2);%
        [mnmu1,sd3mu1,meanmedianratio] = getchisquarevals(size(Y,2));
        mu1 = VV'/(median(VV(gm(mask)>0.95))*meanmedianratio);
        mu = ((mu1>mnmu1)&(mu1<sd3mu1)).*(mu1-mnmu1) + (mu1>=sd3mu1).*(1/(2*sd3mu1)*(mu1.^2) + (sd3mu1/2-mnmu1));
        
        M=zeros(x,y,z);
        M(mask)=mu;
        
        modrobprior = mu/10;

        gmidx = (gm>0.9)&(M==0)&(wm>csf);
        wmidx = (wm>0.9)&(M==0)&(gm>csf);
        if (sum(gmidx(:)==0))||(sum(wmidx(:))==0)
            gmidx=(gm>0.9);
            wmidx=(wm>0.9);
        end
        idxx = gmidx|wmidx;
        X=[gm(idxx),wm(idxx)];
        A=R(idxx);
        c=X\A;
        GMCBF=c(1);
        WMCBF=c(2);
        GlobalPriorfull=GMCBF*gm+WMCBF*wm;%+CSFCBF*csf;
        GlobalPrior=GlobalPriorfull(mask);
       

        
    end
    localprior=0;
    lmd=0;
    
    
    b1=myrobustfit(Y',[],mu,GlobalPrior',lmd,localprior,wfun,flagstd,flagmodrobust,modrobprior);
    
    
    R=zeros(x,y,z);
    R(mask)=b1;
end

if ~exist('prefix','var')||isempty(prefix)
    prefix = [];
    if flagprior==1
        prefix = strcat(prefix,'prior_');
    else
        prefix = strcat(prefix,'noprior_');
    end
    
    if flagmodrobust==1
        prefix = strcat(prefix,'modrob_');
    else
        prefix = strcat(prefix,'rob_');
    end
    
    prefix = strcat(prefix,wfun,'_');
    
    if flagstd==1
        prefix = strcat(prefix,'std');
    else
        prefix = strcat(prefix,'rstd');
    end
end

if savefile==1
    vo=v(1);
    vo.fname=fullfile(spm_str_manip(vo.fname,'H'),[prefix '_' spm_str_manip(vo.fname,'t')]);
    spm_write_vol(vo,R);
end




function b = myrobustfit(y,priorw,mu,bprior,lmd,localprior,wfun,flagstd,flagmodrobust,modrobprior)


if ~exist('wfun','var')||isempty(wfun)
    wfun = 'huber';
end


if ischar(wfun)
    switch(wfun)
        case 'andrews'
            wfun = @andrews;
            t = 1.339;
        case 'bisquare'
            wfun = @bisquare;
            t = 4.685;
        case 'cauchy'
            wfun = @cauchy;
            t= 2.385;
        case 'fair'
            wfun = @fair;
            t = 1.400;
        case 'huber'
            wfun = @huber;
            t = 1.345;
        case 'logistic'
            wfun = @logistic;
            t = 1.205;
        case 'ols'
            wfun = @ols;
            t = 1;
        case 'talwar'
            wfun = @talwar;
            t = 2.795;
        case 'welsch'
            wfun = @welsch;
            t = 2.985;
    end
end
tune = t;



if ~exist('lmd','var')||isempty(lmd)
    lmd=0;
    bprior=1;
end

% if (nargin<3 || isempty(wfun)), wfun = 'bisquare'; end


[n,p]=size(y);

if ~exist('priorw','var')||isempty(priorw)
    priorw=ones(size(y));
else
    priorw=priorw./repmat(max(priorw),n,1);
end



X=ones(n,p);

if ~all(priorw==1)
    sw = sqrt(priorw);
    X = bsxfun(@times,X,sw);
    y = y.*sw;
else
    sw = 1;
end

b=(sum(X.*y)+mu.*bprior+lmd.*localprior)./(sum(X.*X)+mu+lmd);

b0 = zeros(size(b));
h = min(.9999, (X./  repmat(sqrt(sum(X.^2)),n,1)     ).^2);
adjfactor = 1 ./ sqrt(1-h./priorw);
% dfe = n-xrank;




% If we get a perfect or near perfect fit, the whole idea of finding
% outliers by comparing them to the residual standard deviation becomes
% difficult.  We'll deal with that by never allowing our estimate of the
% standard deviation of the error term to get below a value that is a small
% fraction of the standard deviation of the raw response values.
tiny_s = 1e-6 * std(y);
tiny_s(tiny_s==0)=1;

D = sqrt(eps(class(X)));
iter = 0;
iterlim = 50;
while((iter==0) || any(abs(b-b0) > D*max(abs(b),abs(b0))))
    iter = iter+1;
    if (iter>iterlim)
        %       warning(message('stats:statrobustfit:IterationLimit'));
        break;
    end
    
    % Compute residuals from previous fit, then compute scale estimate
    r = y - X.*repmat(b,n,1);
    radj = r .* adjfactor ./ sw;
    
    if flagstd==1
        s = sqrt(mean(radj.^2));
    elseif flagstd==0
        rs=sort(abs(radj));
        s = median(rs)/0.6745;
    else
        error('Unknown flagstd')
    end
    
    % Compute new weights from these residuals, then re-fit
    w = wfun(radj.*(1-flagmodrobust*exp(-repmat(modrobprior,n,1)))./ repmat((max(s,tiny_s)*tune),n,1)   );
    b0 = b;
    %    [b,wxrank] = wfit(y,X,w);
    z=sqrt(w);
    x=X.*z;
    yz=y.*z;
    b=(sum(x.*yz)+mu.*bprior+lmd.*localprior)./(sum(x.*x)+mu+lmd);
end



% function w = bisquare(r)
% w = (abs(r)<1) .* (1 - r.^2).^2;

% function w = huber(r)
% w = 1 ./ max(1, abs(r));

% function w = talwar(r)
% w = 1*(abs(r)<1);

function w = andrews(r)
r = max(sqrt(eps(class(r))), abs(r));
w = (abs(r)<pi) .* sin(r) ./ r;

function w = bisquare(r)
w = (abs(r)<1) .* (1 - r.^2).^2;

function w = cauchy(r)
w = 1 ./ (1 + r.^2);

function w = fair(r)
w = 1 ./ (1 + abs(r));

function w = huber(r)
w = 1 ./ max(1, abs(r));

function w = logistic(r)
r = max(sqrt(eps(class(r))), abs(r));
w = tanh(r) ./ r;

function w = ols(r)
w = ones(size(r));

function w = talwar(r)
w = 1 * (abs(r)<1);

function w = welsch(r)
w = exp(-(r.^2));


function s = madsigma(r)
%MADSIGMA    Compute sigma estimate using MAD of residuals from 0
rs = sort(abs(r));
s = median(rs) / 0.6745;


function [recon,dat]=SCORE_den(dat,gmtpm,wmtpm,csftpm,thresh)

% SCORE: performs Structural Correlation based Outlier REjection
% Input:
%   dat: CBF time series (4D)
%   gmtpm: Grey matter tissue probability map
%   wmtpm: White matter tissue probability map
%   csftpm: CSF tissue probability map
%   thresh: Threshold to create gm, wm and csf mask
%
% Output:
%   recon: Estimated mean CBF map
%   noimg: Number of volumes retained
%   indx: Index file;  0: volumes retained for the mean CBF computation
%                      1: volumes rejected based on GM threshold
%                      2: volumes rejected based on structural correlation
% Report any bug to Sudipto Dolui: sudiptod@mail.med.upenn.edu
% Copyright Sudipto Dolui



gm=gmtpm>thresh;
wm=wmtpm>thresh;
csf=csftpm>thresh;
msk=(gm+wm+csf)>0;

nogm=sum(gm(:)>0)-1;
nowm=sum(wm(:)>0)-1;
nocsf=sum(csf(:)>0)-1;


TD=size(dat,4);
MnGM=zeros(TD,1);



for tdim=1:TD
    tmp=dat(:,:,:,tdim);
    MnGM(tdim)=mean(tmp(gm));
end
MedMnGM=median(MnGM);           % Robust estimation of mean
SDMnGM=mad(MnGM,1)/0.675;       % Robust estimation of standard deviation
indx=double(abs(MnGM-MedMnGM)>2.5*SDMnGM);    % Volumes outside 2.5 SD of Mean are discarded

R=mean(dat(:,:,:,indx==0),4);
V=nogm*var(R(gm))+nowm*var(R(wm))+nocsf*var(R(csf));
V_prev=V+1;

while V<V_prev
    V_prev=V;
    R_prev=R;
    indx_prev=indx;
    CC=-2*ones(TD,1);
    for tdim=1:TD
        if(indx(tdim)~=0)
            continue;
        end
        tmp=dat(:,:,:,tdim);
        CC(tdim)=corr(R(msk),tmp(msk));
    end
    [~,inx]=max(CC);
    indx(inx)=2;
    R=mean(dat(:,:,:,indx==0),4);
    V=nogm*var(R(gm))+nowm*var(R(wm))+nocsf*var(R(csf));
end


% indx=indx_prev;
% noimg=sum(ismember(indx_prev,[0]))
dat=dat(:,:,:,ismember(indx_prev,[0]));
recon=mean(dat,4);

function [thresh1,thresh2,meanmedianratio] = getchisquarevals(n)

%%%% 99.99 percentile value
a=[0.000000, 15.484663, 8.886835, 7.224733, 5.901333, 5.126189, 4.683238, 4.272937, 4.079918, 3.731612, 3.515615, 3.459711, 3.280471, 3.078046, 3.037280, 2.990761, 2.837119, 2.795526, 2.785189, 2.649955, 2.637642, 2.532700, 2.505253, 2.469810, 2.496135, 2.342210, 2.384975, 2.275019, 2.244482, 2.249109, 2.271968, 2.210340, 2.179537, 2.133762, 2.174928, 2.150072, 2.142526, 2.071512, 2.091061, 2.039329, 2.053183, 2.066396, 1.998564, 1.993568, 1.991905, 1.981837, 1.950225, 1.938580, 1.937753, 1.882911, 1.892665, 1.960767, 1.915530, 1.847124, 1.947374, 1.872383, 1.852023, 1.861169, 1.843109, 1.823870, 1.809643, 1.815038, 1.848064, 1.791687, 1.768343, 1.778231, 1.779046, 1.759597, 1.774383, 1.774876, 1.751232, 1.755293, 1.757028, 1.751388, 1.739384, 1.716395, 1.730631, 1.718389, 1.693839, 1.696862, 1.691245, 1.682541, 1.702515, 1.700991, 1.674607, 1.669986, 1.688864, 1.653713, 1.641309, 1.648462, 1.630380, 1.634156, 1.660821, 1.625298, 1.643779, 1.631554, 1.643987, 1.624604, 1.606314, 1.609462];
b=[NaN, 2.177715, 1.446966, 1.272340, 1.190646, 1.151953, 1.122953, 1.103451, 1.089395, 1.079783, 1.071751, 1.063096, 1.058524, 1.054137, 1.049783, 1.046265, 1.043192, 1.039536, 1.038500, 1.037296, 1.033765, 1.032317, 1.031334, 1.029551, 1.028829, 1.027734, 1.024896, 1.024860, 1.025207, 1.024154, 1.022032, 1.021962, 1.021514, 1.020388, 1.019238, 1.020381, 1.019068, 1.018729, 1.018395, 1.017134, 1.016539, 1.015676, 1.015641, 1.015398, 1.015481, 1.015566, 1.014620, 1.014342, 1.013901, 1.013867, 1.013838, 1.013602, 1.013322, 1.012083, 1.013168, 1.012667, 1.011087, 1.011959, 1.011670, 1.011494, 1.010463, 1.010269, 1.010393, 1.010004, 1.010775, 1.009399, 1.011000, 1.010364, 1.009831, 1.009563, 1.010085, 1.009149, 1.008444, 1.009455, 1.009705, 1.008597, 1.008644, 1.008051, 1.008085, 1.008550, 1.008265, 1.009141, 1.008235, 1.008002, 1.008007, 1.007660, 1.007993, 1.007184, 1.008093, 1.007816, 1.007770, 1.007932, 1.007819, 1.007063, 1.006712, 1.006752, 1.006703, 1.006650, 1.006743, 1.007087];
thresh1 = a(n);
thresh2 = 10*a(n);
meanmedianratio = b(n);
% 
% v=zeros(1e5,1);
% for k=1:1e5
%     v(k) = var(randn(n,1));
% end
% thresh1=prctile(v,p1);
% thresh2=prctile(v,p2);
% rat = mean(v)/median(v);



