function [OutPut4D] = SSM_AnatDescrip_Vx15(fileR,OutDir,OutName,type,TempDim)
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
%  Read the manual for instructions 
%
% Anatomical Description Tool
% [OutPut4D] = SSM_AnatDescrip(fileR,OutDir,OutName,type,TempDim)
% Inputs:
% fileR: Cell of strings with ALL images or masks to perform the anatomical
%        e.g.: {'Image1.nii';'Image2.nii';'Image3.nii'}
%
% OutDir: String with an output directoty
%         e.g.: 'c:\MyFoldrr\'
%
% OutName: String with and output filename
%          e.g.: 'AnateDescrip.txt'
%
% type: define if the image is:
%       a mask/ROI with one connected component (one cluster): 'mask'
%       a map/image with several voxel values (intensities) and connected components
%       (clusters): 'map'
%
% TempDim (Template Dimnsion): 'AAL' --> Anatomic Automatic Labelling 1, 113x137x113, 1.5x1.5x1.5 mm³
%

if ~exist('OutDir','var')
    OutDir = uigetdir('','Define the output directory');
    if isequal(OutDir,0)
        OutDir = pwd;
    end
end
if ~exist('OutName','var')
    OutName = inputdlg('Define an output filename','Define an output filename',1,{'AnatResults.txt'});
    if isempty(OutName)
        OutName = 'AnatResults.txt';
    else
        OutName = OutName{1};
    end
end
if ~exist('fileR','var')
    [file,path] = uigetfile({'*.nii','NIfTI Files'},...
        'Add all images to analyze','MultiSelect','on');
    if isequal(file,0)
        warndlg('No Images added, process aborted')
        return
    else
        if ~iscell(file)   % CREATING A CELL VARIABLE FOR SINGULAR INPUTS
            file = {file};
        end
        for i = 1:numel(file)
            fileR{i,1} = fullfile(path,file{i});
        end
    end
end
if ~exist('type','var')
    type = questdlg('Define the input image(s) type and mask (a mask/ROI with one connected component (one cluster/blob)) or a map/image with several voxel intensities and connected components',...
        '','mask','map','mask');
        if isempty(type)
            type = 'map';
        end
end

if ~exist('TempDim','var')
    TempDim = 'uf2c';
end

    %%%%%%%% aal
    SSdir2 = which('SSM');
    SSdir3 = [SSdir2(1:end-5) filesep];
    try
        LabelImgS = nifti([SSdir3 'AAL_SSM_vx15.nii']);
        load([SSdir3 'AAL_Labels_Vx15.mat']); 
    end
    LabelImgMAT = LabelImgS.dat(:,:,:);
    LabStruc = AAL;
    
    TEMPInpFV = single([LabelImgS.dat.dim, LabelImgS.hdr.pixdim(2:4)]);
    LabelImgMAT(LabelImgMAT(:,:,:)==0) = 666;
    fideGx = fopen([OutDir,filesep,OutName],'w+'); % CHARGE OUTPUT LOG FILE

    fprintf(fideGx,'SSM: ROIs Anatomical Labeling and Quantifications\r\n\r\n');
    
    fprintf('-- Performing Anatomical labeling\r\n');
    fprintf('\t * The term "image" will always refer to the input image(s) provided by the user\n');
    fprintf('\t ** The term "label" will always refer to the tool defined ROIs\n');
    fprintf('\t *** The term "region" will always refer to image(s) clusters (blobs) in the case of multi-blobs input image(s)\r\n');

    fprintf(fideGx,'    The resultant file is better visualized if imported into an MS Excel(R) type software\r\n\r\n');
    fprintf(fideGx,'*   The term "image" will always refer to the input image(s) provided by the user\n');
    fprintf(fideGx,'**  The term "label" will always refer to the tool pre-defined anatomical structures\n');
    fprintf(fideGx,'*** The term "region" will always be refer to image(s) clusters (blobs) in the case of mult blobs input image(s) --> ''map'' type\r\n\r\n');
    
    if ~exist('type','VAR')
        type = 'mask';
    end
    
    if isequal(type,'mask')
        for il = 1:numel(fileR)
            clear sFnl nOfvox Regions Posi roiFind centNs ncentr nOfvox LabelVol
            [~,bx,~] = fileparts(fileR{il});
            fprintf(fideGx,'Image %d:\t%s\r\n', il,bx);
            anatDO = 1;
            ncentr = 1;
            roi11_Stru = nifti(fileR{il});
            
            InpFV = single([roi11_Stru.dat.dim, roi11_Stru.hdr.pixdim(2:4)]);
            if ~isequal(InpFV,TEMPInpFV)
                fprintf(2,'The image %d FOV and resolution (%dx%dx%d %dx%dx%d)\n',...
                    il,InpFV(1),InpFV(2),InpFV(3),InpFV(4),InpFV(5),InpFV(6));
                fprintf(2,'does not match the chosen template: %s.\n',TempDim);
                fprintf(2,'Please, see the help to choose an appropriate template.\n');
                return
            end

            roi11 = roi11_Stru.dat(:,:,:);
            
            roi11(roi11>0) = 1;
            roi11(roi11<0) = 0;
            roi11(isnan(roi11)) = 0;
            roi11 = double(roi11);
            OutPut4D(:,:,:,il) = roi11;

            nofVoxTOT = nnz(roi11);
            RoiVol = nofVoxTOT.*prod(roi11_Stru.hdr.pixdim(2:4));
            fprintf(fideGx,'\tNumber of voxels (image):\t%d\r\n',nofVoxTOT);
            fprintf(fideGx,'\tTotal volume (image):\t%d\tmm²\r\n',RoiVol);
            
            sFnl = zeros(size(roi11,3),3);
            for yt = 1:size(roi11,3)
                clear Regions LabelVol
                roiFind = roi11(:,:,yt);
                roiFind = fliplr(roiFind);
                roiFind = permute(roiFind,[2,1]);
                roiFind = fliplr(roiFind);
                roiFind = flipud(roiFind);

                if ~isequal(sum(sum(roiFind)),0)
                    roiFind2 = logical(roiFind);
                    s = regionprops(roiFind2,'centroid');
                    if size(s,1)>1
                        for ytr = 1:size(s,1)
                            centNs(ytr,:) = s(ytr).Centroid;
                        end
                        sFnl(ncentr,1:2) = mean(centNs,1);
                        sFnl(ncentr,3) = yt;  
                    else
                        sFnl(ncentr,1:2) = s.Centroid(1,:);
                        sFnl(ncentr,3) = yt;  
                    end
                    ncentr = ncentr+1;
                end
            end
            
            sFnl(~any(sFnl,2), : ) = [];
            FinalCentrCoord(il,:) = round(median(sFnl,1));
            MultROILab = LabelImgMAT.*roi11;
            UniQ = unique(MultROILab);
            UniQ = UniQ(2:end);
            nofregions = numel(UniQ);
            
            if ~isequal(sum(FinalCentrCoord(il,:)),0)
                IDXcentroid = LabelImgMAT((size(roi11,1)-FinalCentrCoord(il,1)),FinalCentrCoord(il,2),FinalCentrCoord(il,3));
                if IDXcentroid == 666
                    CentroidRegions{il,1} = 'Unlabeled region';
                else
                    Posi = find(LabStruc.Index == IDXcentroid);
                    CentroidRegions{il,1} = LabStruc.Label{Posi};
                end
                fprintf(fideGx,'\tCentroid coordinate (voxel space):\t%dx%dx%d \r\n',FinalCentrCoord(il,1),FinalCentrCoord(il,2),FinalCentrCoord(il,3));
                fprintf(fideGx,'\tCentroid exact label:\t%s \r\n\r\n',CentroidRegions{il,1});
                fprintf(fideGx,'\tLabels included in the image:\r\n');
                fprintf(fideGx,'\tLabel name\t Intersection voxels (image/label)\t %% of the label in the image\t %% of the image in the label\r\n');

                for nr = 1:nofregions
                    Bint = double(MultROILab==UniQ(nr));
                    nOfvox(nr,1) = sum(sum(sum(Bint)));
                    Posi = find(LabStruc.Index == UniQ(nr));
                    Regions{nr,1} = LabStruc.Label{Posi};
                    LabelVol{nr,1} = LabStruc.Nvox(Posi);
                end
                
                [nOfvox,www] = sort(nOfvox,'descend');
                Regions = Regions(www);
                LabelVol = LabelVol(www);
                
                for nr = 1:nofregions
                    fprintf(fideGx,'\t%s\t%d\t%.2f\t%.2f\r\n',Regions{nr,1},nOfvox(nr,1),(100*(nOfvox(nr,1)/nofVoxTOT)),(100*(nOfvox(nr,1)/LabelVol{nr,1})));
                end
            else
                fprintf(fideGx,'\tCentroid coordinate (voxel space): No regions found');
            end

            fprintf(fideGx,'\r\n\r\n');
        end
    else
        for il = 1:numel(fileR)
            clear sFnl nOfvox Regions Posi roiFind centNs ncentr
            
            [~,bx,~] = fileparts(fileR{il});
            fprintf(fideGx,'Image %d:\t%s\r\n', il,bx);
            anatDO = 1;
            roi11_Stru = nifti(fileR{il});

            InpFV = [roi11_Stru.dat.dim, roi11_Stru.hdr.pixdim(2:4)];
            if ~isequal(InpFV,TEMPInpFV)
                fprintf(2,'The image %d FOV and resolution (%dx%dx%d %dx%dx%d)\n',...
                    il,InpFV(1),InpFV(2),InpFV(3),InpFV(4),InpFV(5),InpFV(6));
                fprintf(2,'does not match the chosen template (%s) dimensions.\n',TempDim);
                fprintf(2,'Please, see the help to choose an appropriate template.\n');
                return
            end

            roi11 = roi11_Stru.dat(:,:,:);
            roi11ori = roi11;
            
            roi11(roi11>0) = 1;
            roi11(roi11<0) = 0;
            roi11(isnan(roi11)) = 0;
            roi11 = double(roi11);
            OutPut4D(:,:,:,il) = roi11;
            
            if ~isequal(max(roi11ori(:)),0)
                [xGlo,yGlo,zGlo] = ind2sub(size(roi11ori),find(roi11ori == max(roi11ori(:))));
                GlobMap = zeros(size(roi11ori));
                
                if numel(zGlo) > 1
                    zGlo = round(mean(zGlo));
                    xGlo = round(mean(xGlo));
                    yGlo = round(mean(yGlo));
                end
                
                GlobMap(xGlo,yGlo,zGlo) = 1;

                GlobFind = GlobMap(:,:,zGlo);
                GlobFind = fliplr(GlobFind);
                GlobFind = permute(GlobFind,[2,1]);
                GlobFind = fliplr(GlobFind);
                GlobFind = flipud(GlobFind);

                GlobFind2 = logical(GlobFind);
                sg = regionprops(GlobFind2,'centroid');
                sFnlg(1,1:2) = sg.Centroid;
                sFnlg(1,3) = zGlo;  
                
                MultROILabG = LabelImgMAT .* GlobMap;
                UniQG = unique(MultROILabG);
                UniQG = UniQG(2:end);
                
                if isequal(UniQG,0) || isempty(UniQG)
                    CentroidRegionsG = 'Unlabeled region';
                else
                    PosiG = find(LabStruc.Index == UniQG);
                    CentroidRegionsG = LabStruc.Label{PosiG};
                end

                nofVoxTOT = nnz(roi11);
                RoiVol = nofVoxTOT.*prod(roi11_Stru.hdr.pixdim(2:4));
                fprintf(fideGx,'\tNumber of voxels (image):\t%d\r\n',nofVoxTOT);
                fprintf(fideGx,'\tImage total volume:\t%d\tmm³\r\n',RoiVol);
                fprintf(fideGx,'\tImage global maximum intensity:\t%.2f\r\n',max(roi11ori(:)));
                fprintf(fideGx,'\tImage global maximum label:\t%s\r\n\r\n',CentroidRegionsG);

                L = bwlabeln(roi11);
                vet = unique(L);
                vet = vet(2:end);
                iidx = 0;

                for i = 1:size(vet,1)
                    clear CentroidRegions IDXcentroid UniQ nofregions FinalCentrCoord sFnl nOfvox Regions LabelVol MultROILab roiFind centNs ncentr sFnl UniQ nofregions
                    
                    TempRoiM = double(L == vet(i));
                    fprintf(fideGx,'\tSub region %d:\t\r\n',i);
                    sFnl = zeros(size(roi11,3),3);
                    TempRoi = TempRoiM .* roi11ori;
                    TempRoi(isnan(TempRoi)) = 0;
                    SubRoiNvox = nnz(TempRoi);
                    MeanValue = sum(sum(sum(TempRoi)))/SubRoiNvox;
                    MaxValue = max(TempRoi(:));
                    SubRoiVol = nnz(TempRoi) .* prod(roi11_Stru.hdr.pixdim(2:4));

                    ncentr = 1;
                    for yt = 1:size(TempRoiM,3)
                        roiFind = TempRoiM(:,:,yt);
                        roiFind = fliplr(roiFind);
                        roiFind = permute(roiFind,[2,1]);
                        roiFind = fliplr(roiFind);
                        roiFind = flipud(roiFind);

                        if ~isequal(sum(sum(roiFind)),0)
                            roiFind2 = logical(roiFind);
                            s = regionprops(roiFind2,'centroid');
                            if size(s,1)>1
                                for ytr = 1:size(s,1)
                                    centNs(ytr,:) = s(ytr).Centroid;
                                end
                                sFnl(ncentr,1:2) = mean(centNs,1);
                                sFnl(ncentr,3) = yt;  
                            else
                                sFnl(ncentr,1:2) = s.Centroid(1,:);
                                sFnl(ncentr,3) = yt;  
                            end
                            ncentr = ncentr + 1;
                        end
                    end

                    sFnl(~any(sFnl,2), : ) = [];
                    FinalCentrCoord(il,:) = round(median(sFnl,1));
                    
                    MultROILab = LabelImgMAT .* TempRoiM;

                    UniQ = unique(MultROILab);
                    UniQ = UniQ(2:end);
                    nofregions = numel(UniQ);
                    
                    if ~isequal(sum(FinalCentrCoord(il,:)),0) && ~isequal(nofregions,0)
                        
                        IDXcentroid = LabelImgMAT((size(TempRoiM,1)-FinalCentrCoord(il,1)),FinalCentrCoord(il,2),FinalCentrCoord(il,3));
                        if IDXcentroid == 0
                            CentroidRegions{il,1} = 'Unlabeled region';
                        else
                            Posi = find(LabStruc.Index == IDXcentroid);
                            CentroidRegions{il,1} = LabStruc.Label{Posi};
                        end
                        fprintf(fideGx,'\t\tCentroid coordinate (voxel space):\t%dx%dx%d \r\n',FinalCentrCoord(il,1),FinalCentrCoord(il,2),FinalCentrCoord(il,3));
                        fprintf(fideGx,'\t\tCentroid exact label:\t%s \r\n',CentroidRegions{il,1});
                        fprintf(fideGx,'\t\tSub region mean value:\t%.2f \r\n',MeanValue);
                        fprintf(fideGx,'\t\tSub region max value:\t%.2f \r\n',MaxValue);
                        fprintf(fideGx,'\t\tSub region volume:\t%.2fmm³ \r\n\r\n',SubRoiVol);
                        fprintf(fideGx,'\t\tLabels included in the sub region:\r\n');
                        fprintf(fideGx,'\t\tLabel name\t Intersection voxels (region/label)\t %% of the label in the region\t %% of the region in the label\r\n');
                        clear Posi
                        
                        clear Bint
                        for nr = 1:nofregions
                            Bint = single(MultROILab == UniQ(nr));
                            nOfvox(nr,1) = sum(Bint(:));
                            Posi = find(LabStruc.Index == UniQ(nr));
                            Regions{nr,1} = LabStruc.Label{Posi};
                            LabelVol{nr,1} = LabStruc.Nvox(Posi);
                        end
                        
                        [nOfvox,www] = sort(nOfvox,'descend');
                        Regions = Regions(www);
                        LabelVol = LabelVol(www);
                        
                        for nr = 1:nofregions
                            fprintf(fideGx,'\t\t%s\t%d\t%.2f\t%.2f\r\n',Regions{nr,1},nOfvox(nr,1),(100*(nOfvox(nr,1)/SubRoiNvox)),(100*(nOfvox(nr,1)/LabelVol{nr,1})));
                        end
                    else
                        fprintf(fideGx,'\t\tCentroid coordinate (voxel space): No regions found');
                    end
                    fprintf(fideGx,'\r\n\r\n');
                end
            else
                fprintf(fideGx,'\t\t Empty Mask');
            end
        end
    end
    
    switch TempDim
        case {'uf2c','original'}
            fprintf(fideGx,'Maximum probability tissue labels derived from:\r\n');
            fprintf(fideGx,'''MICCAI 2012 Grand Challenge and Workshop on Multi-Atlas Labeling''\r\n');
            fprintf(fideGx,'These data were released under the Creative Commons Attribution-NonCommercial\r\n');
            fprintf(fideGx,'(CC BY-NC) with no end date. Labeled template provided by Neuromorphometrics, Inc.\r\n');
            fprintf(fideGx,'(http://Neuromorphometrics.com/) under academic subscription".\r\n\r\n\r\n');
        case 'Desikan'
            fprintf(fideGx,'Anatomical parcellation derived from:\r\n');
            fprintf(fideGx,'''Desikan-Killiany'' cortical atlas. It is a gyral based atlas:\r\n');
            fprintf(fideGx,'A gyrus was defined as running between the bottoms of two adjacent sulci.\r\n');
            fprintf(fideGx,'That is, a gyrus includes the part visible on the pial view + adjacent banks of the\r\n');
            fprintf(fideGx,'sulci limiting this gyrus. See Desikan et al., (2006).\r\n\r\n\r\n');
        case 'Destrieux'
            fprintf(fideGx,'Anatomical parcellation derived from:\r\n');
            fprintf(fideGx,'''Destrieux'' cortical atlas. It is based on a parcellation scheme that first\r\n');
            fprintf(fideGx,'divided the cortex into gyral and sulcal regions, the limit between both being\r\n');
            fprintf(fideGx,'given by the curvature value of the surface. A gyrus only includes the cortex\r\n');
            fprintf(fideGx,'visible on the pial view, the hidden cortex (banks of sulci) are marked sulcus.\r\n');
            fprintf(fideGx,'see Fischl et al., (2004), Destrieux et al. (2010) and changes described at:\r\n');
            fprintf(fideGx,'https://surfer.nmr.mgh.harvard.edu/fswiki/DestrieuxAtlasChanges\r\n\r\n\r\n');
    end

    if anatDO
        fprintf('-- Anatomical labeling file saved on: %s%s\n',OutDir,OutName);
    else
        fprintf('Attention! Your images resolutions do not enable anatomical descriptions.\r\n');
        fprintf(fideGx,'Attention! Your images resolutions do not enable anatomical descriptions.');
    end
    fclose(fideGx);
end
