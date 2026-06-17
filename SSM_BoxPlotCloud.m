function Fig = SSM_BoxPlotCloud(Data,GroupVar,Title,VarLabels,YaxisLabel,CloudAlpha)
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
% INPUT:
%       Data -->MxN double matrix where M is the number of observations and N
%           the number of variables (distinct boxes). Or Mx1 vector
%           containing concatenated variables. In this case, a GroupVar is
%           recquired to separate the groups/variables with distinct sizes.
%           This is useful when the variables have disting numbers of
%           observations.
%       GroupVar --> Vector indicating the number of observation in each
%           group (separated boxplost). This variable is only defined in the
%           case the Data Variable is also a vector concatenating several 
%           variables with distinct number of observationswith variables from
%           variables of distinct
%       Title --> String defining the plot Title
%       VarLabels --> 1xN cell of strings defining the names of each
%           variable included in Data
%       YaxisLabel --> String defining the Y axis name (observations
%           nature)
%       CloudAlpha --> Number between 0 and 1 defining the Cloud (scatter)
%       transparency. 1 is visible, 0 is unvisible.
%
% EXAMPLES:
%       1)
%       Data = rand(30,3);
%       SSM_BoxPlotCloud(Data,[],Group,{'Rand 1','Rand 2','Rand 3'},'Random Values',0.9);
%
%       2)
%       Data = rand(80,1);
%       Group = [ones(50,1); 2*ones(30,1)];
%       SSM_BoxPlotCloud(Data,Group,'Controls Vs Patients',{'Controls (n=50)','Patients (n=30)'},'Random Observations',0.7);
%
%       3)
%       Data = rand(30,3);
%       SSM_BoxPlotCloud(Data,[],[],[],[],0.5);
%
%       4)
%       Data = rand(30,3);
%       SSM_BoxPlotCloud(Data,[],[],[],'Random Values',0.8);
%
%       5)
%       Data = rand(50,25);
%       SSM_BoxPlotCloud(Data,[],'Compact Style',[],'Random Values');

    if ~exist('Data','var') || isempty(Data)
        return;
    end
    if ~exist('Title','var') || isempty(Title)
        Title = 'Box Plot';
    end
    if ~exist('VarLabels','var') || isempty(VarLabels)
        for i = 1:size(Data,2)
            VarLabels{i} = ['Var ' num2str(i)];
        end
    end
    if ~exist('YaxisLabel','var') || isempty(YaxisLabel)
        YaxisLabel = 'Values';
    end
    
    if ~exist('CloudAlpha','var') || isempty(CloudAlpha)
        CloudAlpha = 0.5;
    end
    
    if size(Data,2)>20
        Fig = figure('Position',[2123,52,719,926],'Color',[1 1 1]);
        hold on;
        if isempty(GroupVar)
            boxplot(Data,'PlotStyle','compact','Symbol','r+','LabelOrientation','inline','LabelVerbosity','all');
            xticklabels(VarLabels);
            ylabel(YaxisLabel);
            title(Title);

            XPosi = 0;
            for i = 1:size(Data,2)
                p = randperm(numel(Data(:,i)));
                X1e = XPosi + [0.8+(0.4/numel(Data(:,i))):0.4/numel(Data(:,i)):1.2];
                X1e = X1e(p);
                scatter(X1e,Data(:,i),'MarkerEdgeAlpha',CloudAlpha)
                XPosi = XPosi +1;
            end
        else
            boxplot(Data,GroupVar,'PlotStyle','compact','Symbol','r+','LabelOrientation','inline','LabelVerbosity','all');
            xticklabels(VarLabels);
            ylabel(YaxisLabel);
            title(Title);

            XPosi = 0;
            for i = 1:numel(unique(GroupVar))
                p = randperm(sum(GroupVar == i));
                X1e = XPosi + [0.8+(0.4/sum(GroupVar==i)):0.4/sum(GroupVar==i):1.2];
                X1e = X1e(p);
                scatter(X1e,Data(find(GroupVar==i),1),'MarkerEdgeAlpha',CloudAlpha)
                XPosi = XPosi +1;
            end
        end
        
    else
        Fig = figure('Position',[2123,52,719,926],'Color',[1 1 1]);
        hold on;
        if isempty(GroupVar)
            XPosi = 0;
            for i = 1:size(Data,2)
                p = randperm(numel(Data(:,i)));
                X1e = XPosi + [0.8+(0.4/numel(Data(:,i))):0.4/numel(Data(:,i)):1.2];
                X1e = X1e(p);
                scatter(X1e,Data(:,i),'MarkerEdgeAlpha',CloudAlpha)
                XPosi = XPosi +1;
            end
            boxplot(Data,'LabelVerbosity','all');
        else
            XPosi = 0;
            for i = 1:numel(unique(GroupVar))
                p = randperm(sum(GroupVar == i));
                X1e = XPosi + [0.8+(0.4/sum(GroupVar==i)):0.4/sum(GroupVar==i):1.2];
                X1e = X1e(p);
                scatter(X1e,Data(find(GroupVar==i),1),'MarkerEdgeAlpha',CloudAlpha)
                XPosi = XPosi +1;
            end
            boxplot(Data,GroupVar,'LabelVerbosity','all');
        end
        
        xticklabels(VarLabels);
        xtickangle(45)
        ylabel(YaxisLabel);
        title(Title);
        
    end
    
    hold off
end