function w = GaussWinImage(L, a)
% GaussWinImage Returns a N-point Gaussian window,
% with alpha being the reciprocal of SD,
% a determinant of the width of the Fourier transform
    
%   According to 
%   Fredric j. Harris, On the Use of Windows for Harmonic
%   Analysis with the Discrete Fourier Transform, IEEE, 
%   66-1, 1978    
    
    if ~exist('a','var') || isempty(a)
        a   = 2.5; % alpha is 2.5 by default
    end

    N = L-1;
    n = (0:N)'-N/2;
    w = exp(-(1/2)*(a*n/(N/2)).^2);
    
end