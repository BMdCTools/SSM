function SSM_SliceView(BackGroundImg,OverlayImg,OverlayImgThre,...
                        BackgroungImgThre,FOrientation,OverlayColormap,...
                        slc_nmbr,AddtTitle,OutputName,OutputDir)
%
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
%
% uf2c_SliceView(BackGroundImg,OverlayImg,OverlayImgThre,...
%     BackgroungImgThre,FOrientation,OverlayColormap,slc_nmbr,AddtTitle,...
%     OutputName,OutputDir)
%
%   INPUTS: 
%       BackGroundImg: High Res T1 WI 
% 
%       OverlayImg: Image in the same matricial spatial of the 'BackGroundImg'
% 
%       OverlayImgThre: Threshold to be applied on the 'OverlayImg'
% 
%       BackgroungImgThre: Threshold to be applied on the 'BackgroungImgThre'
% 
%       FOrientation: slices orientation: 'Axial', 'Sagittal' or 'Coronal'
% 
%       OverlayColormap: overlay colormap e.g.: 'hot', 'winter'
% 
%       slc_nmbr: number of slices presented e.g.: 30 or a MNI range (e.g.:
%       [-50:2:80] or 'best' to best fit the clusters in the space.
% 
%       AddtTitle: Additional Figure Title
% 
%       OutputName: name of the output .png figure
% 
%       OutputDir: directory of the output .png figure
%
% Brunno Machado de Campos
% University of Campinas, 2026
%
% Copyright (c) 2026, Brunno Machado de Campos
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

if ~exist('BackGroundImg','var')
    warndlg('Background image not defined','Process aborted');
    return
end

if ~exist('OverlayImg','var')
    warndlg('Overlay image not defined','Process aborted');
    return
end

if ~exist('OverlayImgThre','var')
    OverlayImgThre = 0.00001;
    return
end

if ~exist('BackgroungImgThr','var')
    BackgroungImgThre = 0.1; % Para dar uma limpada na estrutural
end

if ~exist('OutputName','var')
    OutputName = 'SliceView.png';
end

if ~exist('OutputDir','var')
    [OutputDirTMP,bxx,cxx] = fileparts(OverlayImg);
    OutputDir = OutputDirTMP;
end

if ~exist('slc_nmbr','var')
    slc_nmbr   = 'best'; % numero de fatias
end

if ~exist('AddtTitle','var')
    AddtTitle = ''; 
end

if ~exist('OverlayColormap','var')
    OverlayColormap = hot; % Colomap: hot ou winter...
end

if ~exist('FOrientation','var')
    FOrientation = 'axial'; % 'axial', 'sagittal' or 'coronal'
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ScreSize = get(0,'screensize');
ScreSize = ScreSize(3:end);
threshStat = OverlayImgThre; % 

imgs       = {BackGroundImg,OverlayImg};
Sobj           = slover;
 % colorbar: vector with colobar of images index Ex: [1 2] --> background and overlay
Sobj.transform = FOrientation;

Sobj.img(1).vol   = spm_vol(imgs{1});

Sobj.img(1).prop  = 1;
Sobj.img(1).type  = 'truecolour';
Sobj.img(1).cmap  = gray(64);
Sobj.img(1).range = [BackgroungImgThre max(max(max(Sobj.img(1).vol.private.dat(:,:,:))))];

TMPstru = spm_vol(imgs{2});
matOV = TMPstru.private.dat(:,:,:);
matOV(isnan(matOV)) = 0;

if isequal(slc_nmbr,'best') % finding the best interval considering the overlay image
    T = TMPstru.mat(1:3,4);
    oMtx = TMPstru.mat(1:3,1:3);
    if isequal(FOrientation,'Axial') || isequal(FOrientation,'axial')
        Interval = [find(squeeze(sum(sum(matOV))),1,'first'),find(squeeze(sum(sum(matOV))),1,'last')];
        if ~isempty(Interval)
            MNIco1 = oMtx*[size(matOV,1)/2 size(matOV,2)/2 Interval(1)]'; % vox space to MNI
            MNIco2 = oMtx*[size(matOV,1)/2 size(matOV,2)/2 Interval(2)]';
            MNIco1 = MNIco1+T;% vox space to MNI
            MNIco2 = MNIco2+T;
            RangeV = sort([MNIco1(3),MNIco2(3)]);
            slc_nmbr = [RangeV(1):2:RangeV(2)];
        else
            RangeV = [-30 60];
            slc_nmbr = [RangeV(1):2:RangeV(2)];
        end
    end
    if isequal(FOrientation,'Sagittal') || isequal(FOrientation,'sagittal')
        Interval = [find(squeeze(sum(sum(matOV,2),3)),1,'first'),find(squeeze(sum(sum(matOV,2),3)),1,'last')];
        if ~isempty(Interval)
            MNIco1 = oMtx*[Interval(1) size(matOV,2)/2 size(matOV,3)/2]';% vox space to MNI
            MNIco1 = MNIco1+T;% vox space to MNI
            MNIco2 = oMtx*[Interval(2) size(matOV,2)/2 size(matOV,3)/2]';
            MNIco2 = MNIco2+T;
            RangeV = sort([MNIco1(1),MNIco2(1)]);
            slc_nmbr = [RangeV(1):2:RangeV(2)];
        else
            RangeV = [-30 60];
            slc_nmbr = [RangeV(1):2:RangeV(2)];
        end
    end
    if isequal(FOrientation,'Coronal') || isequal(FOrientation,'coronal')
        Interval = [find(squeeze(sum(sum(matOV,1),3)),1,'first'),find(squeeze(sum(sum(matOV,1),3)),1,'last')];
        if ~isempty(Interval)
            MNIco1 = oMtx*[size(matOV,1)/2 Interval(1) size(matOV,3)/2]';% vox space to MNI
            MNIco2 = oMtx*[size(matOV,1)/2 Interval(2) size(matOV,3)/2]';
            MNIco1 = MNIco1+T;% vox space to MNI
            MNIco2 = MNIco2+T;
            RangeV = sort([MNIco1(2),MNIco2(2)]);
            slc_nmbr = [RangeV(1):2:RangeV(2)];
        else
            RangeV = [-30 60];
            slc_nmbr = [RangeV(1):2:RangeV(2)];
        end
    end
    if numel(slc_nmbr) < 10
        slc_nmbr = [RangeV(1):1:RangeV(2)];
    end
    if numel(slc_nmbr) < 10
        slc_nmbr = [RangeV(1)-5:2:RangeV(2)+5];
    end
end

if ~isequal(sum(sum(sum(matOV))),0)
    Sobj.cbar      = 2;
    Sobj.img(2).vol.imgdata = abs(matOV);
    Sobj.img(2).vol.dim = TMPstru.dim;
    Sobj.img(2).vol.mat = TMPstru.mat;

    Sobj.img(2).prop  = 1;
    Sobj.img(2).type  = 'split';
%     Sobj.img(2).type  = 'truecolour';
    Sobj.img(2).cmap  = OverlayColormap; 
    Sobj.img(2).range = [threshStat max(Sobj.img(2).vol.imgdata(:))];
    Sobj.img(2).hold = 1;
end


if numel(slc_nmbr)>1
    Sobj.slices  = slc_nmbr;
else
    switch FOrientation
        case {'Axial','axial'}
            Sobj.slices  = round(linspace(-60,60,slc_nmbr));
        case {'Coronal','coronal'}
            Sobj.slices  = round(linspace(-60,60,slc_nmbr));
        case {'Sagittal','sagittal'}
            Sobj.slices  = round(linspace(-60,60,slc_nmbr));
    end
end

Sobj.figure = figure;

set(Sobj.figure,'Name','Slice View',...
    'Position', round([ScreSize(1)*.1 ScreSize(2)*.1 ScreSize(1).*0.6 ScreSize(1).*0.4]),...
                'Color',[0 0 0]);
            
Sobj = paint(Sobj);

set(Sobj.figure,'Position',...
    round([ScreSize(1)*.1 ScreSize(2)*.1 ScreSize(1).*0.6 ScreSize(1).*0.41]));

mTextBox = uicontrol('style','text','position',...
    round([(ScreSize(1).*0.5)/2.5 (ScreSize(1).*0.4) ScreSize(1)*.3 ScreSize(1)*.01]));
set(mTextBox,'String',['Overlay thres:' num2str(threshStat),'  ',AddtTitle],...
    'BackGroundColor',[0 0 0],'ForeGroundColor',[1 1 1],'FontSize',12);
set(Sobj.figure,'Name','Slice View');

drawnow
imgRR = getframe(Sobj.figure);
imwrite(imgRR.cdata, [OutputDir filesep OutputName]);
close('Slice View')

