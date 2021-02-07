% simple script to rename dicom files according to relevant information in the header 
% 2010-03-10, Paul Groot

dcminpath='D:\Scratch\raphael\DICOM\10020517\06360000';
dcmoutpath='D:\scratch\raphael\';
filepattern='*';

files = dir(fullfile(dcminpath,filepattern));
N = size(files,1);
Nok = 0;
Nerr = 0;
for f=1:N
    if ~files(f).isdir
        try
            src = fullfile(dcminpath, files(f).name);
            I = dicominfo(src);
            
            outpath = fullfile(dcmoutpath, [I.StudyDate '_' I.StudyTime]);
            if ~exist(outpath,'dir')
                [status message ] = mkdir(outpath);
                if status==1
                    fprintf('Created %s\n', outpath);
                else
                    error([ message ': ' outpath ]);
                end
            end
            
            outpath = fullfile(outpath, sprintf('%04d_%s',I.SeriesNumber,I.SeriesDescription));
            outpath = strrep(outpath,'<','');
            outpath = strrep(outpath,'>','');
            if ~exist(outpath,'dir')
                [status message ] = mkdir(outpath);
                if status==1
                    fprintf('Created %s\n', outpath);
                else
                    error([ message ': ' outpath ]);
                end
            end
            
%             if isfield(I,'AcquisitionTime')
%                 dest = fullfile(outpath, sprintf('%04d-%s.dcm',I.InstanceNumber,I.AcquisitionTime));
%             else
%                 dest = fullfile(outpath, sprintf('%04d-%s.dcm',I.InstanceNumber,I.ContentTime));
%             end
            dest = fullfile(outpath, sprintf('%04d.dcm',I.InstanceNumber));
            fprintf('copy %s to %s\n',src,dest);
            copyfile(src,dest);
            Nok = Nok + 1;
        catch ME
            disp(ME.message)
            Nerr = Nerr + 1;
        end
    end
end

fprintf('copied %d dicom files; %d errors',Nok,Nerr);
