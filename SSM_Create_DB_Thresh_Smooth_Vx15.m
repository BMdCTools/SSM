% Brunno Machado de Campos
% University of Campinas, 2026
%
% Copyright (c) 2026, Brunno Machado de Campos
% All rights reserved.
% 
%      Redistribution and use in  source and  binary forms,  with  or without
%      modification, are permitted provided that the following conditions are
%      met:
%
%       * Redistributions  of  source  code  must retain  the above copyright
%         notice,  this list  of conditions  and  the  following  disclaimer.
%       * Redistributions in binary form must reproduce the  above  copyright
%         notice, this list of conditions and the following disclaimer in the 
%         documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR  IMPLIED WARRANTIES, INCLUDING, BUT  NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR  PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE  COPYRIGHT  OWNER OR CONTRIBUTORS  BE
% LIABLE   FOR  ANY   DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,  PROCUREMENT  OF
% SUBSTITUTE GOODS OR SERVICES;  LOSS OF  USE, DATA, OR PROFITS;  OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON  ANY THEORY  OF LIABILITY,  WHETHER  IN
% CONTRACT,  STRICT LIABILITY, OR  TORT  (INCLUDING NEGLIGENCE  OR  OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED  OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
%  Read the manual for instructions 
 
[filesub,pathsub] = uigetfile({'*.nii' ,'*.nii (NIfTI)'},...
    'Select all grey (or white) matter maps (e.g. m0wrp1)' ,'MultiSelect','on');
filesub = cell(sort(filesub));

fwhmUI = inputdlg('What is the desired smoothing kernel for the added files? (ex: 4x4x4)');

tissue = questdlg('What images type/tissue are you adding?','Map type',...
    'Grey Matter','White Matter','CSF','Grey Matter');

% After Smooth Thresholding:
% This value will be stored with your new Reference Dataset, and used
% further during SSM preprocessings, automatically
Thresh = 0.01;

fwhm = strsplit(char(fwhmUI{1}),'x');

fwhm1 = fwhm{1};
fwhm2 = fwhm{2};
fwhm3 = fwhm{3};

disp('Running....')

FWHM = [fwhm1 fwhm2 fwhm3];

Size1 = floor((size(filesub,2))/3);
Size2 = Size1;
Size3 = (size(filesub,2))-(Size1+Size2);

exSt = nifti([pathsub filesub{1}]);

FOV = exSt.dat.dim;

switch tissue
    case 'Grey Matter'
%%%%%%%%%%%%%%%%
%%% Grey Matter
%%%%%%%%%%%%%%%%
        SC_Tplate1 = zeros([FOV,Size1]);
        for i = 1:Size1
            
            clear matlabbatch
            matlabbatch{1}.spm.spatial.smooth.data = {[pathsub,filesub{i}]};
            matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm1) str2num(fwhm2) str2num(fwhm3)];
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.im = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = 's';
            spm_jobman('run',matlabbatch)
            
            stru = nifti([pathsub,'s',filesub{i}]);
            Mat = stru.dat(:,:,:);
            Mat(Mat < Thresh) = 0;
            SC_Tplate1(:,:,:,i) = Mat;
        end
        findSep = strfind(FWHM,'x');
        SC_Tplate1 = single(SC_Tplate1);
        save(['SC_Ctr_DB1_FWHM' fwhm1 '.mat'],'SC_Tplate1','Thresh','-v7.3')
        disp('Running....')
        clear SC_Tplate1
        
        SC_Tplate2 = zeros([FOV,Size2]);
        for i = Size1+1:(Size1+Size2)
            clear matlabbatch
            matlabbatch{1}.spm.spatial.smooth.data = {[pathsub,filesub{i}]};
            matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm1) str2num(fwhm2) str2num(fwhm3)];
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.im = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = 's';
            spm_jobman('run',matlabbatch)
            
            stru = nifti([pathsub,'s',filesub{i}]);
            Mat = stru.dat(:,:,:);
            Mat(Mat < Thresh) = 0;
            SC_Tplate2(:,:,:,i-Size1) = Mat;
        end
        SC_Tplate2 = single(SC_Tplate2);
        save(['SC_Ctr_DB2_FWHM' fwhm1 '.mat'],'SC_Tplate2','Thresh','-v7.3')
        disp('Running....')
        clear SC_Tplate2
        
        SC_Tplate3 = zeros([FOV,Size3]);
        for i = (Size1+Size2)+1:size(filesub,2)
            clear matlabbatch
            matlabbatch{1}.spm.spatial.smooth.data = {[pathsub,filesub{i}]};
            matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm1) str2num(fwhm2) str2num(fwhm3)];
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.im = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = 's';
            spm_jobman('run',matlabbatch)
            
            stru = nifti([pathsub,'s',filesub{i}]);
            Mat = stru.dat(:,:,:);
            Mat(Mat < Thresh) = 0;
            SC_Tplate3(:,:,:,i-(Size1+Size2)) = Mat;
        end
        SC_Tplate3 = single(SC_Tplate3);
        save(['SC_Ctr_DB3_FWHM' fwhm1 '.mat'],'SC_Tplate3','Thresh','-v7.3')
        disp('Done!')
        clear SC_Tplate3
        
    case 'White Matter'
%%%%%%%%%%%%%%%%
%%% White Matter
%%%%%%%%%%%%%%%%
        SB_Tplate1 = zeros([FOV,Size1]);
        for i = 1:Size1
            clear matlabbatch
            matlabbatch{1}.spm.spatial.smooth.data = {[pathsub,filesub{i}]};
            matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm1) str2num(fwhm2) str2num(fwhm3)];
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.im = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = 's';
            spm_jobman('run',matlabbatch)
            
            stru = nifti([pathsub,'s',filesub{i}]);
            Mat = stru.dat(:,:,:);
            Mat(Mat < Thresh) = 0;
            SB_Tplate1(:,:,:,i) = Mat;
        end
        SB_Tplate1 = single(SB_Tplate1);
        save(['SB_Ctr_DB1_FWHM' fwhm1 '.mat'],'SB_Tplate1','Thresh','-v7.3')
        disp('Running....')

        SB_Tplate2 = zeros([FOV,Size2]);
        for i = Size1+1:(Size1+Size2)
            clear matlabbatch
            matlabbatch{1}.spm.spatial.smooth.data = {[pathsub,filesub{i}]};
            matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm1) str2num(fwhm2) str2num(fwhm3)];
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.im = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = 's';
            spm_jobman('run',matlabbatch)
            
            stru = nifti([pathsub,'s',filesub{i}]);
            Mat = stru.dat(:,:,:);
            Mat(Mat < Thresh) = 0;
            SB_Tplate2(:,:,:,i-Size1) = Mat;
        end
        SB_Tplate2 = single(SB_Tplate2);
        save(['SB_Ctr_DB2_FWHM' fwhm1 '.mat'],'SB_Tplate2','Thresh','-v7.3')
        disp('Running....')

        SB_Tplate3 = zeros([FOV,Size3]);
        for i = (Size1+Size2)+1:size(filesub,2)
            clear matlabbatch
            matlabbatch{1}.spm.spatial.smooth.data = {[pathsub,filesub{i}]};
            matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm1) str2num(fwhm2) str2num(fwhm3)];
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.im = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = 's';
            spm_jobman('run',matlabbatch)
            
            stru = nifti([pathsub,'s',filesub{i}]);
            Mat = stru.dat(:,:,:);
            Mat(Mat < Thresh) = 0;
            SB_Tplate3(:,:,:,i-(Size1+Size2)) = Mat;
        end
        SB_Tplate3 = single(SB_Tplate3);
        save(['SB_Ctr_DB3_FWHM' fwhm1 '.mat'],'SB_Tplate3','Thresh','-v7.3')
        disp('Done!')

    case 'CSF'
        %%%%%%%%%%%%%%%%
        %%% CSF
        %%%%%%%%%%%%%%%%
        CSF_Tplate1 = zeros([FOV,Size1]);
        for i = 1:Size1
            stru = nifti([pathsub,filesub{i}]);
            Mat = stru.dat(:,:,:);
            Mat(Mat<Thresh) = 0;
            stru.dat.fname = [pathsub,'TMPimg.nii'];
            stru.dat(:,:,:) = Mat;
            create(stru)
            
            clear matlabbatch
            matlabbatch{1}.spm.spatial.smooth.data = {[pathsub,'TMPimg.nii']};
            matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm1) str2num(fwhm2) str2num(fwhm3)];
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.im = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = 's';
            spm_jobman('run',matlabbatch)
            
            stru = nifti([pathsub,'sTMPimg.nii']);
            Mat = stru.dat(:,:,:);
            CSF_Tplate1(:,:,:,i) = Mat;
        end
        CSF_Tplate1 = single(CSF_Tplate1);
        save(['CSF_Ctr_DB1_FWHM' fwhm1 '.mat'],'CSF_Tplate1','Thresh','-v7.3')
        disp('Running....')

        CSF_Tplate2 = zeros([FOV,Size2]);
        for i = Size1+1:(Size1+Size2)
            stru = nifti([pathsub,filesub{i}]);
            Mat = stru.dat(:,:,:);
            Mat(Mat<Thresh) = 0;
            stru.dat.fname = [pathsub,'TMPimg.nii'];
            stru.dat(:,:,:) = Mat;
            create(stru)
            
            clear matlabbatch
            matlabbatch{1}.spm.spatial.smooth.data = {[pathsub,'TMPimg.nii']};
            matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm1) str2num(fwhm2) str2num(fwhm3)];
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.im = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = 's';
            spm_jobman('run',matlabbatch)
            
            stru = nifti([pathsub,'sTMPimg.nii']);
            Mat = stru.dat(:,:,:);
            CSF_Tplate2(:,:,:,i-Size1) = Mat;
        end
        CSF_Tplate2 = single(CSF_Tplate2);
        save(['CSF_Ctr_DB2_FWHM' fwhm1 '.mat'],'CSF_Tplate2','Thresh','-v7.3')
        disp('Running....')

        CSF_Tplate3 = zeros([FOV,Size3]);
        for i = (Size1+Size2)+1:size(filesub,2)
            stru = nifti([pathsub,filesub{i}]);
            Mat = stru.dat(:,:,:);
            Mat(Mat<Thresh) = 0;
            stru.dat.fname = [pathsub,'TMPimg.nii'];
            stru.dat(:,:,:) = Mat;
            create(stru)
            
            clear matlabbatch
            matlabbatch{1}.spm.spatial.smooth.data = {[pathsub,'TMPimg.nii']};
            matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm1) str2num(fwhm2) str2num(fwhm3)];
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.im = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = 's';
            spm_jobman('run',matlabbatch)
            
            stru = nifti([pathsub,'sTMPimg.nii']);
            Mat = stru.dat(:,:,:);
            CSF_Tplate3(:,:,:,i-(Size1+Size2)) = Mat;
        end
        CSF_Tplate3 = single(CSF_Tplate3);
        save(['CSF_Ctr_DB3_FWHM' fwhm1 '.mat'],'CSF_Tplate3','Thresh','-v7.3')
        disp('Done!')
end
clear all

