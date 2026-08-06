function handles = SSM_harmGUI(handles)
% Copyright (c) 2026, Brunno Machado de Campos
% All rights reserved.
% 
% Redistribution  and  use  in  source  and  binary  forms, with  or  without
% modification, are permitted provided that the following conditions are met:
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
% CONTRACT,  STRICT LIABILITY, OR  TORT (INCLUDING NEGLIGENCE  OR  OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED  OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Brunno Machado de Campos
% brunno AT unicamp DOT br
% University of Campinas, 2026

ScreSize = get(0,'screensize');
ScreSize = ScreSize(3:end);

SSfactorX = 0.35;
SSfactorY = 0.35;

InipositX = (1-SSfactorX)/2;
InipositY = (1-SSfactorY)/2;

MainFig2 = figure('Name','Single-Subject Morphometry: harmonization options','NumberTitle','off','Color',[0.9 0.9 0.9],...
            'Position',[ScreSize(1)*InipositX ScreSize(2)*InipositY ScreSize(1)*SSfactorX ScreSize(2)*SSfactorY],...
            'MenuBar','none','Tag','SSM_Main');

set(0, 'CurrentFigure', MainFig2);

handles.HEstim = uicontrol('Parent',MainFig2,'Style','checkbox','Units',...
    'normalized','Position',[0.01 0.84 0.3 0.06],'FontUnits',...
    'normalized','FontSize',0.58,'String','Estimate using loaded cases','BackgroundColor',[0.9 0.9 0.9],...
    'tooltip',{'requires at least 10 cases eligible loaded cases'},...
    'Visible','on','Enable','off','Callback',@HEstimf);

handles.HAdd = uicontrol('Parent',MainFig2,'Style','checkbox','Units',...
    'normalized','Position',[0.32 0.84 0.35 0.06],'FontUnits',...
    'normalized','FontSize',0.58,'String','Add previuosly estimated param...','BackgroundColor',[0.9 0.9 0.9],...
    'tooltip',{'Select the HarmomParam_***.mat file containing the harmonization parameters for the current cases'},...
    'Visible','on','Enable','on','Callback',@HAddf);

handles.HFlairOnly = uicontrol('Parent',MainFig2,'Style','checkbox','Units',...
    'normalized','Position',[0.67 0.84 0.33 0.06],'FontUnits',...
    'normalized','FontSize',0.58,'String','Use SSM FLAIR bias harmon...','BackgroundColor',[0.9 0.9 0.9],...
    'tooltip',{'Enable data harmonization for undesired FLAIR images bias using SSM integrated parameters'},...
    'Visible','on','Enable','off','Callback',@HFlairOnlyf);

if handles.nsubje < 10
    set(handles.HEstim,'Enable','off')
end

if get(handles.AddFlair,'Value')
    set(handles.HFlairOnly,'Enable','on')
end


handles.output = MainFig2;
guidata(MainFig2, handles);
end

function HEstimf(hObject, eventdata)
handles = guidata(hObject);

    handles.HarmParaAdded = 0;
    HarAns = questdlg({'Are the loaded cases composed exclusively of reference subjects used for harmonization parameter estimation?';...
                       ' ';...
                       ' - If YES, SSM will estimate the harmonization parameters using all loaded images and apply them to all images.';...
                       ' ';...
                       ' - If NO, SSM will prompt you to provide a binary vector identifying the loaded cases to be used for harmonization parameter estimation (e.g., control subjects). The estimated harmonization parameters will then be applied to all loaded images.';
                       ' '},...
                       'User dataset harmonization definitions','Yes','No','Yes');
    switch HarAns
        case 'Yes'
        	handles.HarmRef = ones(size(handles.filesub,2),1);
        case 'No'
            [HarmFile,HarmPath] = uigetfile({'*.txt;*.xlsx;*.xls;*.csv','Tab Files'},'Select the file with a binary vector (column) indicating the reference subjects within the loaded cases.','MultiSelect','off',handles.pathsub);

            RAW2 = readmatrix([HarmPath,HarmFile]);
            for xi = 1:size(RAW2,1)
                if ~isnan(RAW2(xi,1))
                    handles.HarmRef(xi,1) = RAW2(xi,1);
                else
                    handles.HarmRef(xi,1) = [];
                end
            end
%             [NUM2,TXT2,RAW2] = xlsread([HarmPath,HarmFile]);
%             RAW2(cellfun(@isempty,RAW2)) = [];
%             for xi = 1:size(RAW2,1)
%                 if ~isnan(RAW2{xi,1})
%                     handles.HarmRef(xi,1) = RAW2{xi,1};
%                 else
%                     handles.HarmRef(xi,1) = [];
%                 end
%             end
            if sum(handles.HarmRef) < 10
                warndlg(['Its recquired more 10 or more reference subjects for harmonization parameter estimation, and your files indicated you have only ',num2str(sum(handles.HarmRef))],'Cancelling harmonization')
                set(handles.HarmCBf,'Value',0)
            end
    end
    
handles.output = hObject;
guidata(hObject, handles);
end

function HAddf(hObject, eventdata)
handles = guidata(hObject);

    handles.HarmParaAdded = 1;
    [handles.HarmVarsF,handles.HarmVarsFp] = uigetfile({'*.mat','MATLAB VAR files'},'Select the HarmomParam.mat file containing the harmonization parameters for the current cases','MultiSelect','off',handles.pathsub);
    
handles.output = hObject;
guidata(hObject, handles);
end