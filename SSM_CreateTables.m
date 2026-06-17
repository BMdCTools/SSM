[fileStru,pathStru] = uigetfile({'*.nii;*.nii.gz','GunZip/NIfTI files'},'Select all the Structural images','MultiSelect','on');
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
 
if ~iscell(fileStru)   % CREATING A CELL VARIABLE FOR SINGULAR INPUTS
    fileStru = {fileStru};
end

GMtable = table;
GM_Thick_table = table;
WMtable = table;

for i = 1:size(fileStru,2)

    [~,bName,ext] = fileparts(fileStru{i});

    load([pathStru,'report',filesep,'cat_',bName,'.mat']);

    GMtable{i,1} = {S.filedata.file};
    GMtable{i,2} = S.subjectmeasures.vol_TIV;
    GMtable{i,3} = S.subjectmeasures.vol_abs_CGW(2); % Gray matter
    GMtable{i,4} = S.subjectmeasures.vol_abs_CGW(1); % CSF
    GMtable{i,5} = S.subjectmeasures.surf_TSA; %total surface area
    GMtable{i,6} = S.qualitymeasures.NCR; %noise to contrast ratio
    GMtable{i,7} = S.qualitymeasures.contrastr; %tissue contrast raio

    GM_Thick_table{i,1} = {S.filedata.file};
    GM_Thick_table{i,2} = S.subjectmeasures.vol_TIV;
    GM_Thick_table{i,3} = S.subjectmeasures.vol_abs_CGW(2); % Gray matter
    GM_Thick_table{i,4} = S.subjectmeasures.vol_abs_CGW(1); % CSF
    GM_Thick_table{i,5} = S.subjectmeasures.surf_TSA; %total surface area
    GM_Thick_table{i,6} = S.qualitymeasures.NCR; %noise to contrast ratio
    GM_Thick_table{i,7} = S.qualitymeasures.contrastr; %tissue contrast raio

    WMtable{i,1} = {S.filedata.file};
    WMtable{i,2} = S.subjectmeasures.vol_TIV;
    WMtable{i,3} = S.subjectmeasures.vol_abs_CGW(3);
    WMtable{i,4} = S.subjectmeasures.vol_abs_CGW(1); % CSF
    WMtable{i,5} = S.subjectmeasures.surf_TSA; %total surface area
    WMtable{i,6} = S.qualitymeasures.NCR; %noise to contrast ratio
    WMtable{i,7} = S.qualitymeasures.contrastr; %tissue contrast raio

    if isequal(i,1)
        GMtable.Properties.VariableNames(1:7) = {'SubName','TIV','GM vol','CSF vol','Tot Surf area','Noise/Contr Ratio','Tissues Contra Ratio'};
        GM_Thick_table.Properties.VariableNames(1:7) = {'SubName','TIV','GM vol','CSF vol','Tot Surf area','Noise/Contr Ratio','Tissues Contra Ratio'};
        WMtable.Properties.VariableNames(1:7) = {'SubName','TIV','WM vol','CSF vol','Tot Surf area','Noise/Contr Ratio','Tissues Contra Ratio'};
    end

    load([pathStru,'label',filesep,'catROI_',bName,'.mat']);
    GMtable{i,8:8+size(S.neuromorphometrics.data.Vgm,1)-1} = S.neuromorphometrics.data.Vgm';
    WMtable{i,8:8+size(S.neuromorphometrics.data.Vwm,1)-1} = S.neuromorphometrics.data.Vwm';
    if isequal(i,1)
        GMtable.Properties.VariableNames(8:8+size(S.neuromorphometrics.data.Vgm,1)-1) = S.neuromorphometrics.names';
        WMtable.Properties.VariableNames(8:8+size(S.neuromorphometrics.data.Vwm,1)-1) = S.neuromorphometrics.names';
    end

    load([pathStru,'label',filesep,'catROIs_',bName,'.mat']);
    GM_Thick_table{i,8:8+size(S.aparc_a2009s.data.thickness,1)-1} = S.aparc_a2009s.data.thickness';

    if isequal(i,1)
        GM_Thick_table.Properties.VariableNames(8:8+size(S.aparc_a2009s.data.thickness,1)-1) = S.aparc_a2009s.names';
    end
end

save('GM_Table','GMtable');


