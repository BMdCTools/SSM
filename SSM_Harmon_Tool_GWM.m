function [gmmatPos,wmmatPos,SC_Cat_Tmp,SB_Cat_Tmp] = SSM_Harmon_Tool_GWM(gmmat,wmmat,SC_Cat_Tmp,SB_Cat_Tmp,AgeVet,GenVet,GTIV,Ida_Ctr,Gene_Ctr,DB_TIV,OutDir)
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

hObj = findobj('Type', 'figure', 'Name', 'Single-Subject Morphometry');
    handles = guidata(hObj);
    CovAgeBin = get(handles.covAge, 'Value');
    CovGenBin = get(handles.covAge, 'checkbox4');

    fprintf('-- Working with the encoded database\n\n');
    vetx = [84    53    15    80    63    68    71    64    48     1    29     5    21    87    62    73    39    76    69,...
           36    51    46   106   108    18    43    45   111    30    28   112    10    42    16    52    89   104    61,...
           107    90    77    32    14    78    47   109    95    91    37    99    83    85    65    19   103    13    22,...
           33   101   102    70    54    96     4    31     6    55    66    49    20   105    12     9    97    86    26,...
           8   110    67    98    81   100    24   113    17    88    57    92    75    93    74    27    94     7    41,...
           44    60    23    11    72    58    56     2     3    59    35    25    40    38    79    82    50    34];

    vety = [89   114     4   101    40    85    99    51   113   136    57    10    16    18    53    69     5   130    97,...
           131    49    14    48    26    52    17   135   111    27    65    56    83    13   117    12   129    82    23,...
           60    95    11   106     9   132    41    71    21    76    90    36    81    93   122    75    28   107    79,...
           50   125   108   127    67    70     6    38   105    77    80    33    78   104    73    32     8    61    94,...
           120    34    91    37   128    47    59    86    55     7    43    39    72    25    96    29   124   112    45,...
           98   103    44   115    20   100    30     2    24    62     1   102    35    88    54   133    15    19    42,...
           118   116    87   109   119   123    58    46   137    68    31    66   121    22   134   110    84   126    74,...
           64     3    63    92];

    vetz = [101    63    64    36    43   112    18    65    34    27    87     4    51    38    84     9    24    59    83,...
           3    48    88    53    46    54    11   100    40    25    39     7    94    95    20    67    22    57    85,...
           113    44     1    80    50    96   111    45    49    28    92    35    33    42    61    17    30    10   108,...
           76    58    12    98    77     6    26     2    89   107    41    82    75    99    74    91    97    60   110,...
           31    62    90   106   105    69    56   109    47    93    37    66    71    73    16    23    70    78   103,...
           19    79    14    29    86    32    21    81   104   102     5    72    55    15     8    68    52    13];

    [~,Svetx2] = sort(vetx);
    [~,Svety2] = sort(vety);
    [~,Svetz2] = sort(vetz);

    sizeTMP = size(SC_Cat_Tmp);
%     sizePatM = size(gmmat);
    
for i = 1:size(SC_Cat_Tmp,4)
    SC_Cat_Tmp(:,:,:,i) = SC_Cat_Tmp(Svetx2,Svety2,Svetz2,i);
    SB_Cat_Tmp(:,:,:,i) = SB_Cat_Tmp(Svetx2,Svety2,Svetz2,i);
end
    
SC_Cat_TmpResh = reshape(SC_Cat_Tmp,[sizeTMP(1)*sizeTMP(2)*sizeTMP(3),sizeTMP(4)])';
SB_Cat_TmpResh = reshape(SB_Cat_Tmp,[sizeTMP(1)*sizeTMP(2)*sizeTMP(3),sizeTMP(4)])';

vetBatch = [ones(size(SC_Cat_TmpResh,1),1);2 .* ones(size(gmmat,1),1)];

SC_Cat_TmpCat = [SC_Cat_TmpResh;gmmat];
SB_Cat_TmpCat = [SB_Cat_TmpResh;wmmat];
clear SC_Cat_TmpResh SB_Cat_TmpResh

testerMatx  = SC_Cat_TmpCat;
testerMatx2 = SB_Cat_TmpCat;
Size_testerMatx = size(testerMatx);

testerMatx(testerMatx ~= 0)   = 1;
testerMatx2(testerMatx2 ~= 0) = 1;

vetBin  = sum(testerMatx, 1);
vetBin2 = sum(testerMatx2, 1);

vetBin(vetBin > 0)   = 1;
vetBin2(vetBin2 > 0) = 1; 

vetBinMat  = bsxfun(@and,vetBin, ones(1,size(testerMatx,1))');
vetBinMat2 = bsxfun(@and,vetBin2,ones(1,size(testerMatx2,1))');

TtmptResh  = SC_Cat_TmpCat .* vetBinMat;
TtmptResh2 = SB_Cat_TmpCat .* vetBinMat2;

fprintf('-- Removing zeros from the reshaped maps\n\n')
TtmptResh(:, ~any(TtmptResh,1))   = [];
TtmptResh2(:,~any(TtmptResh2,1))  = [];

fprintf('-- Creating Covariates\n\n')
if size(Gene_Ctr,2) > 1
    Gene_Ctr = Gene_Ctr';
end

if CovAgeBin && CovGenBin
    Covar2Ctr = horzcat(Ida_Ctr,Gene_Ctr,DB_TIV,ones(size(Ida_Ctr,1),1));
    Covar2Pac = [AgeVet,GenVet,GTIV',ones(size(AgeVet,1),1)];
    MCov = mean(Covar2Ctr(:,1:end - 1));
    Covar2Ctr(:,1:end - 1) = Covar2Ctr(:,1:end - 1) - MCov;
    
elseif CovAgeBin
    Covar2Ctr = horzcat(Ida_Ctr,DB_TIV,ones(size(Ida_Ctr,1),1));
    Covar2Pac = [agePat,SubjTIV,1];
    MCov = mean(Covar2Ctr(:,1:end-1));
    Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
elseif CovGenBin
    Covar2Ctr = horzcat(Gene_Ctr,DB_TIV,ones(size(Gene_Ctr,1),1));
    Covar2Pac = [GenPat,SubjTIV,1];
    MCov = mean(Covar2Ctr(:,1:end-1));
    Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
else
    Covar2Ctr = horzcat(DB_TIV,ones(size(DB_TIV,1),1));
    Covar2Pac = [SubjTIV,1];
    MCov = mean(Covar2Ctr(:,1:end-1));
    Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
end

%%% ---------------- Regression ----------------
fprintf('-- Regressing confounders\n');
betas1c = Covar2Ctr \ TtmptResh(1:size(Covar2Ctr,1),:);
TtmptReshTMP = TtmptResh(1:size(Covar2Ctr,1),:) - (Covar2Ctr * betas1c) + betas1c(end,:);

betas2c = Covar2Ctr \ TtmptResh2(1:size(Covar2Ctr,1),:);
TtmptReshTMP2 = TtmptResh2(1:size(Covar2Ctr,1),:) - (Covar2Ctr * betas2c) + betas2c(end,:);

fkeepResh = TtmptResh(size(Covar2Ctr,1) + 1:end,:) - ((Covar2Pac - [MCov,0]) * betas1c) + betas1c(end, :);
fkeepResh2 = TtmptResh2(size(Covar2Ctr,1) + 1:end,:) - ((Covar2Pac - [MCov,0]) * betas2c) + betas2c(end, :);

TtmptResh = [TtmptReshTMP;fkeepResh];
TtmptResh2 = [TtmptReshTMP2;fkeepResh2];

% HARMONIZING
TtmptResh = combat(double(TtmptResh'),vetBatch,[],1);
TtmptResh2 = combat(double(TtmptResh2'),vetBatch,[],1);

TtmptResh = single(TtmptResh');
TtmptResh2 = single(TtmptResh2');

TtmptReshFF  = single(bsxfun(@and,vetBin, ones(1,Size_testerMatx(1))'));
TtmptReshFF2 = single(bsxfun(@and,vetBin2, ones(1,Size_testerMatx(1))'));

TtmptReshFF(TtmptReshFF ~= 0)   = TtmptResh;
TtmptReshFF2(TtmptReshFF2 ~= 0) = TtmptResh2;

gmmatPos = TtmptReshFF(sizeTMP(4)+1:end,:);
wmmatPos = TtmptReshFF2(sizeTMP(4)+1:end,:);

SC_Cat_Tmp = TtmptReshFF(1:sizeTMP(4),:);
SB_Cat_Tmp = TtmptReshFF2(1:sizeTMP(4),:);

SC_Cat_Tmp = reshape(SC_Cat_Tmp',sizeTMP);
SB_Cat_Tmp = reshape(SB_Cat_Tmp',sizeTMP);

fprintf('-- Encoding database\n\n')
for k = 1:size(SC_Cat_Tmp,4)
    SC_Cat_Tmp(:,:,:,k) = SC_Cat_Tmp(vetx,vety,vetz,k);
    SB_Cat_Tmp(:,:,:,k) = SB_Cat_Tmp(vetx,vety,vetz,k);
end

fprintf('-- Generating resultant harm. plots: GM\n\n')
HarmPlots(SC_Cat_TmpCat,TtmptReshFF,vetBatch,'GM',OutDir)
fprintf('-- Generating resultant harm. plots: WM\n\n')
HarmPlots(SB_Cat_TmpCat,TtmptReshFF2,vetBatch,'WM',OutDir)


end