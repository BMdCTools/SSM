function [BiasAddProce,SegProce] = SSM_Add_FLAIRbias(RawT1,RawFLAIR,SSVBM_AnaPath,SmoK,Thresh)
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
%
%  Read the manual for instructions 

NewSeg = 1;
if NewSeg
    SegProce = '-- Segmentation using five tissue template (new segment)';
else
    SegProce = '-- Segmentation using three tissue template (old segment)';
end

SSVBMpa = which('SSM');
SSVBMpa = SSVBMpa(1:end-5);

SPMP = which('spm');
SPMP = SPMP(1:end-5);

SSVBM_DefF = dir([SSVBM_AnaPath,filesep,'mri',filesep,'iy_*.nii.gz']);
SSVBM_DefF = gunzip([SSVBM_DefF.folder,filesep,SSVBM_DefF.name]);
SSVBM_DefF = SSVBM_DefF{1};
SSVBM_NormRef = dir([SSVBM_AnaPath,'mri',filesep,'s',num2str(SmoK(1)),'mwp1*.nii']);
SSVBM_NormRef = [SSVBM_NormRef.folder,filesep,SSVBM_NormRef.name];

clear matlabbatch
matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {RawT1};
matlabbatch{1}.spm.spatial.coreg.estwrite.source = {RawFLAIR};
matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
SSM_run_batch(matlabbatch);

[ax,bx,cx] = fileparts(RawFLAIR);

StruMat = nifti(RawT1);
PixDim = StruMat.hdr.pixdim(2:4);
    % checking if file has desired resolution (vox of 1x1x1)
    % case not, a spline interpolation will be performed

if any(PixDim ~= [1 1 1])
    clear matlabbatch
    matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {[SSVBMpa,'AuxFiles',filesep,'SSM_DimTmpl.nii']};
    matlabbatch{1}.spm.spatial.coreg.estwrite.source = {RawT1};
    matlabbatch{1}.spm.spatial.coreg.estwrite.other(1) = {[ax,filesep,'r',bx,cx]};
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
    SSM_run_batch(matlabbatch);
else
    movefile([ax,filesep,'r',bx,cx],[ax,filesep,'rr',bx,cx])

    [ax,bx,cx] = fileparts(RawT1);
    movefile([ax,filesep,bx,cx],[ax,filesep,'r',bx,cx])
end

[ax,bx,cx] = fileparts(RawT1);
clear matlabbatch
if NewSeg
    matlabbatch{1}.spm.spatial.preproc.channel.vols(1) = {[ax,filesep,'r',bx,cx]};
    matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.0001;
    matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[SPMP,filesep,'tpm',filesep,'TPM.nii,1']};
    matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[SPMP,filesep,'tpm',filesep,'TPM.nii,2']};
    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[SPMP,filesep,'tpm',filesep,'TPM.nii,3']};
    matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[SPMP,filesep,'tpm',filesep,'TPM.nii,4']};
    matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[SPMP,filesep,'tpm',filesep,'TPM.nii,5']};
    matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[SPMP,filesep,'tpm',filesep,'TPM.nii,6']};
    matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0 0.1 0.01 0.04];
    matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];
    matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
    matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                                  NaN NaN NaN];
else
    matlabbatch{1}.spm.tools.oldseg.data = {[ax,filesep,'r',bx,cx]};
    matlabbatch{1}.spm.tools.oldseg.output.GM = [0 0 1];
    matlabbatch{1}.spm.tools.oldseg.output.WM = [0 0 1];
    matlabbatch{1}.spm.tools.oldseg.output.CSF = [0 0 1];
    matlabbatch{1}.spm.tools.oldseg.output.biascor = 0;
    matlabbatch{1}.spm.tools.oldseg.output.cleanup = 1;
    matlabbatch{1}.spm.tools.oldseg.opts.tpm = {
                                                [SPMP,filesep,'toolbox',filesep,'OldSeg',filesep,'grey.nii']
                                                [SPMP,filesep,'toolbox',filesep,'OldSeg',filesep,'white.nii']
                                                [SPMP,filesep,'toolbox',filesep,'OldSeg',filesep,'csf.nii']
                                                };
    matlabbatch{1}.spm.tools.oldseg.opts.ngaus = [2
                                                  2
                                                  2
                                                  4];
    matlabbatch{1}.spm.tools.oldseg.opts.regtype = 'mni';
    matlabbatch{1}.spm.tools.oldseg.opts.warpreg = 1;
    matlabbatch{1}.spm.tools.oldseg.opts.warpco = 25;
    matlabbatch{1}.spm.tools.oldseg.opts.biasreg = 0.0001;
    matlabbatch{1}.spm.tools.oldseg.opts.biasfwhm = 60;
    matlabbatch{1}.spm.tools.oldseg.opts.samp = 3;
    matlabbatch{1}.spm.tools.oldseg.opts.msk = {''};    
end

SSM_run_batch(matlabbatch);

[ax,bx,cx] = fileparts(RawFLAIR);
if NewSeg
    clear matlabbatch
    matlabbatch{1}.spm.spatial.preproc.channel.vols(1) = {[ax,filesep,'rr',bx,cx]};
    matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.0001;
    matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];

    [ax,bx,cx] = fileparts(RawT1);
    matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm(1) = {[ax,filesep,'c1r',bx,cx]};
    matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 1];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm(1) = {[ax,filesep,'c2r',bx,cx]};
    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 1];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm(1) = {[ax,filesep,'c3r',bx,cx]};
    matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm(1) = {[ax,filesep,'c4r',bx,cx]};
    matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm(1) = {[ax,filesep,'c5r',bx,cx]};
    matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm(1) = {[ax,filesep,'c6r',bx,cx]};
    matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0 0.1 0.01 0.04];
    matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];
    matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
    matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                                  NaN NaN NaN];
else
    clear matlabbatch
    matlabbatch{1}.spm.tools.oldseg.data = {[ax,filesep,'rr',bx,cx]};
    matlabbatch{1}.spm.tools.oldseg.output.GM = [1 0 0];
    matlabbatch{1}.spm.tools.oldseg.output.WM = [1 0 0];
    matlabbatch{1}.spm.tools.oldseg.output.CSF = [0 0 0];
    matlabbatch{1}.spm.tools.oldseg.output.biascor = 0;
    matlabbatch{1}.spm.tools.oldseg.output.cleanup = 1;
    
    [ax,bx,cx] = fileparts(RawT1);
    matlabbatch{1}.spm.tools.oldseg.opts.tpm = {
                                                [ax,filesep,'c1r',bx,cx]
                                                [ax,filesep,'c2r',bx,cx]
                                                [ax,filesep,'c3r',bx,cx]
                                                };
    matlabbatch{1}.spm.tools.oldseg.opts.ngaus = [2
                                                  2
                                                  2
                                                  4];
    matlabbatch{1}.spm.tools.oldseg.opts.regtype = 'mni';
    matlabbatch{1}.spm.tools.oldseg.opts.warpreg = 1;
    matlabbatch{1}.spm.tools.oldseg.opts.warpco = 25;
    matlabbatch{1}.spm.tools.oldseg.opts.biasreg = 0.0001;
    matlabbatch{1}.spm.tools.oldseg.opts.biasfwhm = 60;
    matlabbatch{1}.spm.tools.oldseg.opts.samp = 3;
    matlabbatch{1}.spm.tools.oldseg.opts.msk = {''};    
end

SSM_run_batch(matlabbatch);

[ax,bx,cx] = fileparts(RawFLAIR);

clear matlabbatch
matlabbatch{1}.spm.util.defs.comp{1}.def = {SSVBM_DefF};
matlabbatch{1}.spm.util.defs.out{1}.push.fnames = {
                                                   [ax,filesep,'mwc1rr',bx,cx]
                                                   [ax,filesep,'mwc2rr',bx,cx]
                                                   };
matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
matlabbatch{1}.spm.util.defs.out{1}.push.savedir.saveusr = {ax};
matlabbatch{1}.spm.util.defs.out{1}.push.fov.file = {SSVBM_NormRef};
matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 1;
matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [0 0 0];
matlabbatch{1}.spm.util.defs.out{1}.push.prefix = 'w';
SSM_run_batch(matlabbatch);

clear matlabbatch
matlabbatch{1}.spm.spatial.smooth.data = {[ax,filesep,'wmwc1rr',bx,cx]};
matlabbatch{1}.spm.spatial.smooth.fwhm = SmoK;
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';

matlabbatch{2}.spm.spatial.smooth.data = {[ax,filesep,'wmwc2rr',bx,cx]};
matlabbatch{2}.spm.spatial.smooth.fwhm = SmoK;
matlabbatch{2}.spm.spatial.smooth.dtype = 0;
matlabbatch{2}.spm.spatial.smooth.im = 0;
matlabbatch{2}.spm.spatial.smooth.prefix = 's';
SSM_run_batch(matlabbatch);


[a2x,b2x,c2x] = fileparts(SSVBM_NormRef);
% mkdir([a2x,filesep,'OrigSeg']);
% movefile(SSVBM_NormRef,[a2x,filesep,'OrigSeg',filesep,b2x,c2x]);
b2x2 = b2x;
b2x2(6) = '2';
% movefile([a2x,filesep,b2x2,c2x],[a2x,filesep,'OrigSeg',filesep,b2x2,c2x]);

SSdir3 = which('SSM');
SSdir3 = SSdir3(1:end-5);
ExclMask = nifti([SSdir3,'AuxFiles',filesep,'SSM_Mean_WpMd_Mask.nii']);
MaskMat = ExclMask.dat(:,:,:);

average = 0;
if average
    BiasAddProce = '-- FLAIR bias added using the average';
else
    BiasAddProce = '-- FLAIR bias added using extreme value';
end

if average
    %%% GM
    OriS = nifti([a2x,filesep,filesep,b2x,c2x]);
    OriMat = OriS.dat(:,:,:);

    NewS = nifti([ax,filesep,'swmwc1rr',bx,cx]);
    NewMat = NewS.dat(:,:,:);
    NewMat(NewMat < Thresh) = 0;
    NewMat = NewMat .* MaskMat;

    OriMatMax = max(OriMat(:));
    OriMat = OriMat ./ OriMatMax;

    NewMat = NewMat ./ max(NewMat(:));

    MergeMat1 = (OriMat + NewMat) ./2;
    MergeMat1 = MergeMat1 .* OriMatMax;
    MergeMat1(MergeMat1 < Thresh) = 0;
    MergeMat1 = MergeMat1 .* MaskMat;

    MergeS = OriS;
    MergeS.dat.fname = [a2x,filesep,'f',b2x,c2x];
    MergeS.dat(:,:,:) = MergeMat1;
    create(MergeS)

    %%% WM
    OriS = nifti([a2x,filesep,filesep,b2x2,c2x]);
    OriMat = OriS.dat(:,:,:);

    NewS = nifti([ax,filesep,'swmwc2rr',bx,cx]);
    NewMat = NewS.dat(:,:,:);
    NewMat(NewMat < Thresh) = 0;
    NewMat = NewMat .* MaskMat;

    OriMatMax = max(OriMat(:));
    OriMat = OriMat ./ OriMatMax;

    NewMat = NewMat ./ max(NewMat(:));

    MergeMat2 = (OriMat + NewMat) ./2;
    MergeMat2 = MergeMat2 .* OriMatMax;
    MergeMat2(MergeMat2 < Thresh) = 0;
    MergeMat2 = MergeMat2 .* MaskMat;
    
    MergeS = OriS;
    MergeS.dat.fname = [a2x,filesep,'f',b2x2,c2x];
    MergeS.dat(:,:,:) = MergeMat2;
    create(MergeS)
else
    %%% GM
    OriS = nifti([a2x,filesep,b2x,c2x]);
    OriMat = OriS.dat(:,:,:);
    OriMatResh = reshape(OriMat,[1,prod(OriS.dat.dim(1:3))]);
    OriMatReshMax = max(OriMatResh);
    OriMatResh = OriMatResh ./ OriMatReshMax;

    NewS = nifti([ax,filesep,'swmwc1rr',bx,cx]);
    NewMat = NewS.dat(:,:,:);
    NewMat(NewMat < Thresh) = 0;
    NewMat = NewMat .* MaskMat;
    NewMatResh = reshape(NewMat,[1,prod(OriS.dat.dim(1:3))]);
    NewMatResh = NewMatResh ./ max(NewMatResh);

    CatMat = [OriMatResh;NewMatResh];
    MergeMatResh = max(CatMat,[],1);
    MergeMat = reshape(MergeMatResh,OriS.dat.dim(1:3));
    MergeMat = MergeMat .* OriMatReshMax;

    MergeS = OriS;
    MergeS.dat.fname = [a2x,filesep,'f',b2x,c2x];
    MergeS.dat(:,:,:) = MergeMat;
    create(MergeS)
    clear OriS OriMat OriMatResh OriMatReshMax CatMat NewMat MergeS MergeMat
    %%% WM
    OriS = nifti([a2x,filesep,b2x2,c2x]);
    OriMat = OriS.dat(:,:,:);
    OriMatResh = reshape(OriMat,[1,prod(OriS.dat.dim(1:3))]);
    OriMatReshMax = max(OriMatResh);
    OriMatResh = OriMatResh ./ OriMatReshMax;

    NewS = nifti([ax,filesep,'swmwc2rr',bx,cx]);
    NewMat = NewS.dat(:,:,:);
    NewMat(NewMat < Thresh) = 0;
    NewMat = NewMat .* MaskMat;
    NewMatResh = reshape(NewMat,[1,prod(OriS.dat.dim(1:3))]);
    NewMatResh = NewMatResh ./ max(NewMatResh);

    CatMat = [OriMatResh;NewMatResh];
    CatMat(CatMat == 0) = NaN;
    MergeMatResh = min(CatMat,[],1);
    MergeMatResh(isnan(MergeMatResh)) = 0;
    MergeMat = reshape(MergeMatResh,OriS.dat.dim(1:3));
    MergeMat = MergeMat .* OriMatReshMax;

    MergeS = OriS;
    MergeS.dat.fname = [a2x,filesep,'f',b2x2,c2x];
    MergeS.dat(:,:,:) = MergeMat;
    create(MergeS)
end

% fprintf('-- Saving FLAIR biased segmented image\n');

[ax,bx,cx] = fileparts(RawFLAIR);
delete([ax,filesep,'swmwc1rr',bx,cx]);
delete([ax,filesep,'swmwc2rr',bx,cx]);
delete([ax,filesep,'wmwc2rr',bx,cx]);
delete([ax,filesep,'wmwc1rr',bx,cx]);
delete([ax,filesep,'mwc2rr',bx,cx]);
delete([ax,filesep,'mwc1rr',bx,cx]);

if NewSeg
    delete([ax,filesep,'rr',bx,'_seg8.mat']);
else
    delete([ax,filesep,'rr',bx,'_seg_inv_sn.mat']);
    delete([ax,filesep,'rr',bx,'_seg_sn.mat']);
end

delete([ax,filesep,'rr',bx,cx]);

% try
%     delete([ax,filesep,'r',bx,cx]);
% end

try
    delete(RawFLAIR);
end

[ax,bx,cx] = fileparts(RawT1);
delete([ax,filesep,'c1r',bx,cx]);
delete([ax,filesep,'c2r',bx,cx]);
delete([ax,filesep,'c3r',bx,cx]);

if NewSeg
    delete([ax,filesep,'c4r',bx,cx]);
    delete([ax,filesep,'c5r',bx,cx]);
    delete([ax,filesep,'c6r',bx,cx]);
    delete([ax,filesep,'r',bx,'_seg8.mat']);
else
    delete([ax,filesep,'r',bx,'_seg_inv_sn.mat']);
    delete([ax,filesep,'r',bx,'_seg_sn.mat']);
end
try
    delete([ax,filesep,'r',bx,cx]);
end
% try
%     delete(RawT1);
% end

delete(SSVBM_DefF);
    
% end

