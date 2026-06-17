function SSM_HarmPlots(PreHarm,PostHarm,vetBatch,Prefx,OutDir)
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

%% ============= ORIGINAL PIPELINE  =============
    prehist = PreHarm;
    poshist = PostHarm;
    Thresh = 0.05;

    prehist(prehist < Thresh) = NaN;
    poshist(poshist < Thresh) = NaN;

    BatchVarUni = vetBatch;

    ScreSize = get(0,'screensize');
    ScreSize = ScreSize(3:end);

    PrehistCentres_1 = prehist(vetBatch == 1,:);
    PoshistCentres_1 = poshist(vetBatch == 1,:);

    PrehistCentres_2 = prehist(vetBatch == 2,:);
    PoshistCentres_2 = poshist(vetBatch == 2,:);


    % Defining color for each batch. Assuming a max number of 16 different
    % baches (limit)
    Colors = [0 0 1;1 0 0;0 1 0;1 1 0;0 1 1;1 0 1;0 0 0;0.5 0.5 0.5;...
        1 0.5 0.5;0.5 1 0.5;0.5 0.5 1;1 0.5 1;1 0.5 0;0 0.5 1;0.5 0 1;...
        0.5 1 0];

    % Creating Histogram plot.
    FigAll = figure;
    set(FigAll,'Name','Distributions Comparisons',...
                    'Position', round([ScreSize(1)*.1 ScreSize(2)*.1 ScreSize(1)*.8 ScreSize(2)*.8]),...
                    'Color',[1 1 1]);

    subplot(2,2,1),
    title(['Pre harmonization batches: all subjects (values higher than ',num2str(Thresh),')'])
    xlabel('Data values')
    ylabel('Value Frequency')
    hold on

    if size(PoshistCentres_1,2) > 500
        Nbin = 150;
    else
        Nbin = 20;
    end

    SiLoop = size(PrehistCentres_1,1); % get the size of this specif batch
    for j = 1:SiLoop % for the size of this specif batch
        [atmp,btmp] = hist(PrehistCentres_1(j,:),Nbin); % Plot a histogram for each case of this batch
        if j==1 % to store the first plot of each batch and create properly color legends.
            Pleg(1) = plot(btmp,atmp,'Color',Colors(1,:));
        else
            plot(btmp,atmp,'Color',Colors(1,:));
        end
    end
    LegendVar{1,1} = ['Img. Batch ' num2str(1)];

    SiLoop = size(PrehistCentres_2,1); % get the size of this specif batch
    for j = 1:SiLoop % for the size of this specif batch
        [atmp,btmp] = hist(PrehistCentres_2(j,:),Nbin); % Plot a histogram for each case of this batch
        if j==1 % to store the first plot of each batch and create properly color legends.
            Pleg(2) = plot(btmp,atmp,'Color',Colors(2,:));
        else
            plot(btmp,atmp,'Color',Colors(2,:));
        end
    end
    LegendVar{2,1} = ['Img. Batch ' num2str(2)];

    legend(Pleg,LegendVar);

    hold off
    clear SiLoop

    subplot(2,2,2),
    title(['Post harmonization batches: all subjects (values higher than ',num2str(Thresh),')'])
    xlabel('Data values')
    ylabel('Value Frequency')

    hold on
    SiLoop = size(PoshistCentres_1,1); % get the size of this specif batch
    for j = 1:SiLoop
        [atmp,btmp] = hist(PoshistCentres_1(j,:),Nbin);
        if j==1
            Pleg(1) = plot(btmp,atmp,'Color',Colors(1,:));
        else
            plot(btmp,atmp,'Color',Colors(1,:));
        end
    end
    LegendVar{1,1} = ['Img. Batch ' num2str(1)];

    SiLoop = size(PoshistCentres_2,1); % get the size of this specif batch
    for j = 1:SiLoop
        [atmp,btmp] = hist(PoshistCentres_2(j,:),Nbin);
        if j==1
            Pleg(2) = plot(btmp,atmp,'Color',Colors(2,:));
        else
            plot(btmp,atmp,'Color',Colors(2,:));
        end
    end
    LegendVar{2,1} = ['Img. Batch ' num2str(2)];

    legend(Pleg,LegendVar);
    hold off
    clear SiLoop

    ylym1(1,:) = get(subplot(2,2,1),'ylim');
    ylym1(2,:) = get(subplot(2,2,2),'ylim');
    ylym12(1) = min(ylym1(:,1));
    ylym12(2) = max(ylym1(:,2));
    set(subplot(2,2,1),'ylim',ylym12);
    set(subplot(2,2,2),'ylim',ylym12);

    %%%%%%%%%%%%%%%%%%
    % Now similar plots but instead to plot each batch case, we will plot
    % only the median of the cases for each batch
    subplot(2,2,3),
    title(['Pre harmonization batches: subjects median histogram  (values higher than ',num2str(Thresh),')'])
    xlabel('Data values')
    ylabel('Value Frequency')
    hold on

    SiLoop = nanmean(PrehistCentres_1,1); %get the median (among batch cases) for the specific batch
    [atmp,btmp] = hist(SiLoop,Nbin); % Plot the histogram of this median
    area(btmp,atmp);
    LegendVar{1,1} = ['Img. Batch ' num2str(1)];

    SiLoop = nanmean(PrehistCentres_2,1); %get the median (among batch cases) for the specific batch
    [atmp,btmp] = hist(SiLoop,Nbin); % Plot the histogram of this median
    area(btmp,atmp,'FaceAlpha',0.6);
    LegendVar{2,1} = ['Img. Batch ' num2str(2)];

    legend(LegendVar);

    clear SiLoop

    subplot(2,2,4),
    title(['Post harmonization batches: subjects median histogram (values higher than ',num2str(Thresh),')'])
    xlabel('Data values')
    ylabel('Value Frequency')
    hold on

    SiLoop = nanmean(PoshistCentres_1,1);
    [atmp,btmp] = hist(SiLoop,Nbin);
    area(btmp,atmp);
    LegendVar{1,1} = ['Img. Batch ' num2str(1)];

    SiLoop = nanmean(PoshistCentres_2,1);
    [atmp,btmp] = hist(SiLoop,Nbin);
    area(btmp,atmp,'FaceAlpha',0.6);
    LegendVar{2,1} = ['Img. Batch ' num2str(2)];

    legend(LegendVar);

    ylym1(1,:) = get(subplot(2,2,3),'ylim');
    ylym1(2,:) = get(subplot(2,2,4),'ylim');
    ylym12(1) = min(ylym1(:,1));
    ylym12(2) = max(ylym1(:,2));
    xlym1(1,:) = get(subplot(2,2,3),'xlim');
    xlym1(2,:) = get(subplot(2,2,4),'xlim');
    xlym12(1) = min(xlym1(:,1));
    xlym12(2) = max(xlym1(:,2));
    set(subplot(2,2,3),'xlim',xlym12);
    set(subplot(2,2,4),'xlim',xlym12);
    set(subplot(2,2,3),'ylim',ylym12);
    set(subplot(2,2,4),'ylim',ylym12);

    imgRR = getframe(FigAll);
    imwrite(imgRR.cdata, [OutDir filesep  Prefx '_1_Pre-Post_Histograms.png']);
    close(FigAll)

    ValBoxPlot = [];
    GroupBoxPlot = [];
    tmp = [];
    tmp = nanmedian(PrehistCentres_1,2)';
    ValBoxPlot = [ValBoxPlot;tmp'];
    GroupBoxPlot = [GroupBoxPlot;1*ones(numel(tmp),1)];
    NameBoxPlot{1,1} = ['Batch ' num2str(1)];
    tmp = [];
    tmp = nanmedian(PrehistCentres_2,2)';
    ValBoxPlot = [ValBoxPlot;tmp'];
    GroupBoxPlot = [GroupBoxPlot;2*ones(numel(tmp),1)];
    NameBoxPlot{1,2} = ['Batch ' num2str(2)];

    BPfig = SSM_BoxPlotCloud(ValBoxPlot,GroupBoxPlot,['Pre homogenization baches (individual median values >  ',num2str(Thresh),')'],NameBoxPlot,'Individual Median Values',0.7);
    set(BPfig,'Name','Distributions Coparisons',...
                'Position', round([ScreSize(1)*.1 ScreSize(2)*.1 ScreSize(1)*.5 ScreSize(2)*.8]),...
                'Color',[1 1 1]);

    imgRR = getframe(BPfig);
    imwrite(imgRR.cdata, [OutDir filesep Prefx '_2a_Pre-Harm_BoxPlots.png']);
    close(BPfig)

    tmp = [];
    ValBoxPlot = [];
    GroupBoxPlot = [];
    tmp = nanmedian(PoshistCentres_1,2)';
    ValBoxPlot = [ValBoxPlot;tmp'];
    GroupBoxPlot = [GroupBoxPlot;1*ones(numel(tmp),1)];
    NameBoxPlot{1,1} = ['Batch ' num2str(1)];

    tmp = [];
    tmp = nanmedian(PoshistCentres_2,2)';
    ValBoxPlot = [ValBoxPlot;tmp'];
    GroupBoxPlot = [GroupBoxPlot;2*ones(numel(tmp),1)];
    NameBoxPlot{1,2} = ['Batch ' num2str(2)];

    BPfig2 = SSM_BoxPlotCloud(ValBoxPlot,GroupBoxPlot,['Pos homogenization baches (individual median values > ',num2str(Thresh),')'],NameBoxPlot,'Individual Median Values',0.7);
    set(BPfig2,'Name','Distributions Coparisons',...
                'Position', round([ScreSize(1)*.1 ScreSize(2)*.1 ScreSize(1)*.5 ScreSize(2)*.8]),...
                'Color',[1 1 1]);

    imgRR = getframe(BPfig2);
    imwrite(imgRR.cdata, [OutDir filesep Prefx '_2b_Post-Harm_BoxPlots.png']);
    close(BPfig2)

    %%%%%%
    FigAl2 = figure;
    set(FigAl2,'Name','Pre Harm. Bland-Altman Plots',...
                    'Position', round([ScreSize(1)*.05 ScreSize(2)*.1 ScreSize(1)*.9 ScreSize(2)*.8]),...
                    'Color',[1 1 1]);
    sgtitle(['Bland-Altman Plots: Pre harmonization batches: Batches 1 Vs. 2 (values higher than  ',num2str(Thresh),')'])
    clear ylym1

    Vet1 = mean(PrehistCentres_1,1);
    Vet2 = mean(PrehistCentres_2,1);
    DifVet = Vet1-Vet2;
    Xaxis = (Vet1+Vet2)/2;
    [xx,yy] = sort(DifVet);
    Xaxis = (Vet1+Vet2)/2;
    Xaxis = Xaxis(yy);
    scatter(Xaxis,DifVet,6,'.');
    xlabel('Both batches average')
    ylabel('Between batches Delta')

    Prelim = ylim;

    FigAl3 = figure;
    set(FigAl3,'Name','Post Harm. Bland-Altman Plots',...
                    'Position', round([ScreSize(1)*.05 ScreSize(2)*.1 ScreSize(1)*.9 ScreSize(2)*.8]),...
                    'Color',[1 1 1]);

    sgtitle(['Bland-Altman Plots: Post harmonization batches: Batches 1 Vs. 2 (values higher than  ',num2str(Thresh),')'])

    Vet1 = mean(PoshistCentres_1,1);
    Vet2 = mean(PoshistCentres_2,1);
    DifVet = Vet1-Vet2;
    [xx,yy] = sort(DifVet);
    Xaxis = (Vet1+Vet2)/2;
    Xaxis = Xaxis(yy);
    scatter(Xaxis,DifVet,8,'.');
    xlabel('Both batches average')
    ylabel('Between batches Delta')
    ylim(Prelim);

    imgRR = getframe(FigAl2);
    imwrite(imgRR.cdata, [OutDir filesep Prefx '_3a_Pre_Harm._Bland-Altman.png']);
    close(FigAl2)

    imgRR = getframe(FigAl3);
    imwrite(imgRR.cdata, [OutDir filesep Prefx '_3b_Post_Harm._Bland-Altman.png']);
    close(FigAl3)
end
