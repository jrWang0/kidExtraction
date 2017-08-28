%%%%%%%%%%%%%%%%%%%%%%%%%%% Extrac MFCC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Input:  Wave files, 16kHz 1 channel
%Output: MFCC features and write the maplist into the 'feamap.lst' file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wavdir='D:/ab/downsample/'; %we use / instead of \ to avoid the misunderstanding of escape characters
codedir='D:/ab/code';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% output %%%%%%%%%%%%%%%%%%%%%%%%%%
feadir='D:/ab/feature/';  
txtfile = 'D:/ab/lists/feamap.txt';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fs=44100;
fs=16000;
fL = 100.0/fs; 
fH = 8000.0/fs;
fRate = 0.010 * fs; 
fSize = 0.025 * fs; 
nChan = 27; 
nCeps = 12; 
premcoef = 0.97;

fid=fopen(txtfile,'a'); %'a' means to append data for *.txt
tic
cd(wavdir);
f=dir(wavdir);
for k=3:size(f)
    wavfolder=[wavdir f(k).name '/'];
    cd(wavfolder);
    wavfiles=dir(wavfolder);
	featurefolder=[feadir f(k).name];
	if exist(featurefolder)==0
	    %system(['mkdir ' featurefolder]); %there is a space after mkdir
        mkdir(featurefolder);
	end
    for i=3:size(wavfiles,1)
        wavname=wavfiles(i).name;
	    [s, fs] = audioread(wavname);
		cd(codedir);
		
        s = rm_dc_n_dither(s, fs); 
        s = filter([1 -premcoef], 1, s); 
        mfc = melcepst(s, fs, '0dD', nCeps, nChan, fSize, fRate, fL, fH); %0dD means the MFCC is 39d including the energy, delta and delta delta
        mfc = cmvn(mfc', true);
	    
		featureFilename=[featurefolder '/' wavname(1:15) 'htk'];
        writehtk(featureFilename, mfc', 100000, 9);   %this is feature file
		cd(wavfolder);
		fprintf(fid, [featureFilename '\r\n']); %note: the escape character used to change the line is '\r\n' not the '\n'
	end
end
fclose(fid);
clear;
toc
