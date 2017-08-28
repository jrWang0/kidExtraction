clear
format long
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wavdir='D:/ab/downsample/';           % wave files
trandir='D:/ab/transcription/';       % translation text files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
feadir='D:/ab/kidfeature/';           % MFCC feature .htk files
kwavdir='D:/ab/kidaudio/';            % kids' wave files(optional)
kidmap='D:/ab/lists/kidmap.txt';      % write the map of feature files to kidids to the kidmap.txt
%snrfile='D:/ab/lists/snr.txt';       % write snr of kid files to the snr.txt
%% 

fs=16000;
fL = 100.0/fs; 
fH = 8000.0/fs;
fRate = 0.010 * fs; 
fSize = 0.025 * fs; 
nChan = 27; 
nCeps = 12; 
premcoef = 0.97;

fkidmap=fopen(kidmap, 'a');
%fsnrfile=fopen(snrfile, 'a');
tic
f=dir(trandir);
fs=16000;
for k=3:size(f)
	tranfolder=[trandir f(k).name '/'];
	tranfiles=dir(tranfolder);
	featurefolder=[feadir f(k).name(2:16) '/'];
	if exist(featurefolder)==0
        mkdir(featurefolder);
	end


	for i=3:size(tranfiles)
		ftran=fopen([tranfolder tranfiles(i).name]);% open a transcription file
		C=textscan(ftran, '%f %f %s');
        fclose(ftran);
        

%% Extract all the children speech sample points according to the transcription

        [s, fs]=audioread([wavdir f(k).name(2:16) '/' tranfiles(i).name(1:15) 'wav']);
        %rb=snr(s);   %calculate the raw wave's snr
        ids=find(ismember(C{3},'c'));
        
        startpoint=floor(C{1}(ids)*fs);
        endpoint=floor(C{2}(ids)*fs);        
        res={};
        for j=1:length(endpoint)
        	res{j}=startpoint(j):endpoint(j);
        end
        ress=cell2mat(res);
        s=s(ress(2:end));
        
        
       %% %%%   !!!!!!!!!(optional) can be delete if we don't need the audio
        kwavfolder=[kwavdir f(k).name(2:16) '/'];
        kwavname=[kwavfolder 'c' tranfiles(i).name(1:15) 'wav'];
        if exist(kwavfolder)==0
            mkdir(kwavfolder);
        end
        audiowrite(kwavname,s,fs);
        %r=snr(s);    %calculate kid wave files' snr
        %fprintf(fsnrfile, [kwavname(16:50) ' ' num2str(r) '\r\n']); % e.g. LST__2017051101/c170511_1238S12.wav -21.7128 
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        s=rm_dc_n_dither(s,fs);
        s = filter([1 -premcoef], 1, s); 
        mfc = melcepst(s, fs, '0dD', nCeps, nChan, fSize, fRate, fL, fH); %0dD means the MFCC is 39d including the energy, delta and delta delta
        mfc = cmvn(mfc', true);
        featureFilename=[featurefolder 'c' tranfiles(i).name(1:15) 'htk'];
        writehtk(featureFilename, mfc', 100000, 9);
        fprintf(fkidmap, ['c ' featureFilename '\r\n']);   
	end

end
fclose all;
toc
