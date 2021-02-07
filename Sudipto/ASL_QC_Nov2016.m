function M = ASL_QC_Nov2016(Y,c)

% Henk: Attached is the ASL-QC that I use currently. This one favours smooth CBF maps, and we are trying to modify it to account for that, but that is still work in progress. I normally smooth my 2D scans (3.4x3.4x6 mm3) with a 5mm FWHM smoothing kernel and then use it in the function and in that case the absolute QEI values make more sense. However even if you don't smooth it, or smooth it more, the relative ranking still works. The inputs of the function are Y = 3D matrix of the CBF map, c = 4D matrix with GM, WM and CSF tissue probability maps in order. Let me know if you have any question. I can work show you the QEI value for 1 subject if you need.


pcbf = 2.5*c(:,:,:,1)+c(:,:,:,2);
msk=(Y~=0)&(~isnan(Y))&(~isnan(pcbf));
r1=max(0,corr(pcbf(msk),Y(msk),'type','Pearson'));


gm = c(:,:,:,1)>0.9;
wm = c(:,:,:,2)>0.9;
csf=c(:,:,:,3)>0.9;

V=((sum(gm(:))-1)*var(Y(gm))+...
    (sum(wm(:))-1)*var(Y(wm))+...
    (sum(csf(:))-1)*var(Y(csf)))/(sum(gm(:))+sum(wm(:))+sum(csf(:))-3);

NegGM=sum(Y(gm)<0)/sum(gm(:));
GMCBF=mean(Y(gm));
CV=(V)./abs(GMCBF);

fun1 = @(x,xdata)exp(-x(1)*(xdata).^x(2));
fun2 = @(x,xdata)1-exp(-x(1)*(xdata).^x(2));


x1 = [0.0544    0.9272];
x2 = [2.8478    0.5196];
x4 = [3.0126    2.4419];

% x1 = lsqcurvefit(fun1,[0,0],CV,b);
% x2 = lsqcurvefit(fun1,[0,0],NegGM,b);
% x4 = lsqcurvefit(fun2,[0,0],r1,b);
Q = [fun1(x1,CV),fun1(x2,NegGM),fun2(x4,r1)];
M=geomean(Q);