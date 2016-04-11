function g_DWI2LDH(inputDWIFileName, inputBVALFileName, NVoxel, prefix, SubjectID, type, ResultantFolder)


% Calculate local diffusion homogeneity (Kendall) and local diffusion homogeneity (Spearman) from the 4D DWI images.
% FORMAT     function []   = (inputDWIFileName, inputBVALFileName, NVoxel, prefix, SubjectID, type)
% Input:
%   inputDWIFileName	input of all DWI images. Where the 3d+direction dataset stay. It must not contain / or \ at the end;
%   inputBVALFileName   bvalues of all input DWI images saved as a text;
%   NVoxel              The number of the voxel for a given cluster during calculating the LDH (e.g. 26, 18, or 6); 
%                       Recommand: NVoxel=26;
%   prefix              the desease type of the data put in; Recommand: prefix='aMCI';
%   SubjectID           the number of patients; Recommand: SubjectID='001';
%   type                the type of output result: Spearman or KCC or both of the two.Recommand: type='Spearman',the output 
%                       will only contain local diffusion homogeneity (Spearman) images.
%	
% Output:
%   outputFileName	    the filename of LDH(Kendall) and LDH(Spearman)result. The pattern of the output file name is like
%	                    'aMCI_001_26LDHs', when the input parameter prefix='aMCI', SubjectID='001', NVoxel=26, type='Spearman'. 
%
%
% COMMENTS:
% This work is based on the FMRIB Software Library v5.0 refered to http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/
% the reference about LDH is G Gong, Local Diffusion Homogeneity (LDH): An Inter-Voxel Diffusion MRI Metric for Assessing 
% Inter-Subject White Matter Variability[J]. PloS one. 2013.
%
% Copyright(C) Gaolang Gong, Yachao Xie, State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal 
% University, 2013-08-04
% Maintainer: gaolang.gong@gmail.com
%             yachaoxiexie@gmail.com
%
% Keywords: local diffusion homogeneity(LDH)
%

if nargin <= 6
    [ResultantFolder, ~, ~] = fileparts(inputDWIFileName);
end

theElapsedTime = cputime;
% check input
if NVoxel ~= 26 & NVoxel ~= 18 & NVoxel ~= 6 
    error('The NVoxel parameter should be 6, 18 or 26. Please re-exmamin it!');
end

fprintf('\n\t Read these 4D ADC images...\t\n');

DeleteDWI_Flag = 0;
if strcmp(inputDWIFileName(end-6:end), '.nii.gz')
   [FolderPath, ~, FilePrefix] = fileparts(inputDWIFileName);
   system(['fslchfiletype NIFTI ' inputDWIFileName ' ' FolderPath filesep 'InputDWIData.nii']);
   DeleteDWI_Flag = 1;
   inputDWIFileName = [FolderPath filesep 'InputDWIData.nii'];
elseif strcmp(inputDWIFileName(end-3:end), '.nii');
   inputDWIFileName = inputDWIFileName;
else
   error('not a NIFTI file')
end

% load first 3 slices data
bval = load(inputBVALFileName);
head_info = load_nii_hdr(inputDWIFileName);
a = head_info.dime.dim(2);
b = head_info.dime.dim(3);
c = head_info.dime.dim(4);
timepoint = head_info.dime.dim(5);
nii = load_untouch_nii(inputDWIFileName,[],[],[],[],[],1:3);
nii_data = nii.img;
index0 = find(bval==0);
index1 = find(bval~=0);
rank_3slices=zeros(a,b,3,timepoint-(size(index0,2)));
adj_3slices=zeros(a,b,3);
ADC_value = zeros(a,b,c,timepoint-(size(index0,2)));

% computing ADC values for the 3 slices
  for jj = 1:3
   b0 = nii_data(:,:,jj,index0);
   b0_ave = sum(b0,4)./(size(index0,2));
   DWI_data = nii_data(:,:,jj,index1);
    for ii = 1:size(index1,2)
        ADC_value_temp = DWI_data(:,:,:,ii);
        ADC_value_temp = squeeze(ADC_value_temp);
        ADC_value_temp = double(ADC_value_temp);
        ADC_value(1:a,1:b,jj,ii) = log(b0_ave./ADC_value_temp);
    end
  end

% computing ranks for the 3 slices
for i = 1:a
    for j = 1:b
        for k = 1:3
           [rank_3slices(i,j,k,:), adj_3slices(i,j,k)] = tiedrank(squeeze(ADC_value(i,j,k,:)), 0);
        end
    end
end


switch type 
    
% both Spearman and KCC will be calculated
%---------------------------------------------go----------------------------------------------------
    case 'both'

        NVoxel_Spearman = NVoxel;
        NVoxel_KCC = NVoxel+1;

        % choose the neighborhood number
        switch NVoxel_Spearman
            case 26
                weight_spearman = zeros(3,3,3);
                weight_spearman(:,:,1) = [sqrt(3),sqrt(2),sqrt(3);sqrt(2),1,sqrt(2);sqrt(3),sqrt(2),sqrt(3)];
                weight_spearman(:,:,2) = [sqrt(2),1,sqrt(2);1,0,1;sqrt(2),1,sqrt(2)];
                weight_spearman(:,:,3) = [sqrt(3),sqrt(2),sqrt(3);sqrt(2),1,sqrt(2);sqrt(3),sqrt(2),sqrt(3)];
            case 18
                weight_spearman = zeros(3,3,3);
                weight_spearman(:,:,1) = [0,sqrt(2),0;sqrt(2),1,sqrt(2);0,sqrt(2),0];
                weight_spearman(:,:,2) = [sqrt(2),1,sqrt(2);1,0,1;sqrt(2),1,sqrt(2)];
                weight_spearman(:,:,3) = [0,sqrt(2),0;sqrt(2),1,sqrt(2);0,sqrt(2),0];
            case 6
                weight_spearman = zeros(3,3,3);
                weight_spearman(2,2,1) = 1;weight_spearman(1,2,2) = 1;weight_spearman(2,1,2) = 1;
                weight_spearman(2,3,2) = 1;weight_spearman(3,2,2) = 1;weight_spearman(2,2,3) = 1;
        end

        switch NVoxel_KCC
            case 27
                weight_KCC = ones(3,3,3);
            case 19
                weight_KCC = zeros(3,3,3);
                weight_KCC(:,:,1) = [0,1,0;1,1,1;0,1,0];
                weight_KCC(:,:,2) = [1,1,1;1,1,1;1,1,1];
                weight_KCC(:,:,3) = [0,1,0;1,1,1;0,1,0];
            case 7
                weight_KCC = zeros(3,3,3);
                weight_KCC(2,2,1) = 1;weight_KCC(1,2,2) = 1;weight_KCC(2,1,2) = 1;weight_KCC(2,2,2) = 1;
                weight_KCC(2,3,2) = 1;weight_KCC(3,2,2) = 1;weight_KCC(2,2,3) = 1;
        end


        result_img_spearman = zeros(a,b,c);
        result_img_KCC = zeros(a,b,c);

        for n = 1:c-3

             tic

        % the process of calculating local diffusion homogeneity(Spearman) values
            rank_3slices_spearman = rank_3slices;
            target_rank = rank_3slices_spearman(2:a-1, 2:b-1, 2, :);
            target_rank_vector = reshape(target_rank, [(a-2)*(b-2), timepoint-(size(index0,2))]);
            target_adj = adj_3slices(2:a-1, 2:b-1, 2);
            target_adj_vector = reshape(target_adj, [(a-2)*(b-2), 1]);             
            for i = -1:1
                for j = -1:1
                    for k = -1:1           
                        neighbor_rank = rank_3slices_spearman(2+i:a-1+i, 2+j:b-1+j, 2+k, :);
                        neighbor_rank_vector = reshape(neighbor_rank, [(a-2)*(b-2), timepoint-(size(index0,2))]);
                        neighbor_adj = adj_3slices(2+i:a-1+i, 2+j:b-1+j, 2+k);
                        neighbor_adj_vector = reshape(neighbor_adj, [(a-2)*(b-2), 1]);
                        [coef_result] = gong_spearman(target_rank_vector', target_adj_vector', neighbor_rank_vector', neighbor_adj_vector');
                        tmp_LDH = reshape(coef_result,a-2,b-2);
                        result_img_spearman(2:a-1,2:b-1,n+1) = result_img_spearman(2:a-1,2:b-1,n+1)+weight_spearman(i+2,j+2,k+2)*tmp_LDH;
                    end
                end
            end

        % the process of calculating local diffusion homogeneity(Kendall) values    
            SR = zeros(a-2, b-2, timepoint-(size(index0,2)));
            SR_vector = reshape(SR, [(a-2)*(b-2), timepoint-(size(index0,2))]);
            rank_3slices_KCC = rank_3slices;
            for i = -1:1
                for j = -1:1
                    for k = -1:1           
                        neighbor_rank_KCC = rank_3slices_KCC(2+i:a-1+i, 2+j:b-1+j, 2+k, :);
                        neighbor_rank_vector_KCC = reshape(neighbor_rank_KCC, [(a-2)*(b-2), timepoint-(size(index0,2))]);
                        SR_vector = SR_vector+neighbor_rank_vector_KCC*weight_KCC(i+2,j+2,k+2);
                    end
                end
            end
            SRBAR = mean(SR_vector,2);
            S = sum(SR_vector.^2,2) - (timepoint-(size(index0,2)))*SRBAR.^2;
            B = 12*S./NVoxel_KCC^2/((timepoint-(size(index0,2)))^3-(timepoint-(size(index0,2))));
            tmp_LDH = reshape(B,a-2,b-2);
            result_img_KCC(2:a-1,2:b-1,n+1) = tmp_LDH;

        % refresh the 3 slices dataset
            rank_3slices(:,:,1:2,:) = rank_3slices(:,:,2:3,:);
            adj_3slices(:,:,1:2) = adj_3slices(:,:,2:3);
            nii = load_untouch_nii(inputDWIFileName,[],[],[],[],[],n+3);
            nii_data = nii.img;

        % calculating ADC values for the next slices  
            b0 = nii_data(:,:,1,index0);
            b0_ave = sum(b0,4)./(size(index0,2));
            DWI_data = nii_data(:,:,1,index1);
            for i = 1:size(index1,2)
                  ADC_value_temp = DWI_data(:,:,:,i);
                  ADC_value_temp = squeeze(ADC_value_temp);
                  ADC_value_temp = double(ADC_value_temp);
                  ADC_value(1:a,1:b,n+3,i) = log(b0_ave./ADC_value_temp);
            end

        % compute the ranks for the newly loaded slices
            for i = 1:a
                for j = 1:b
                    [rank_3slices(i,j,3,:), adj_3slices(i,j,3)] = tiedrank(squeeze(ADC_value(i,j,n+3,:)), 0);
                end
            end

            T = toc;
            slicenumber = n+1;
            disp(['the time of calculating the' ' ' num2str(slicenumber) ' ' 'slice is' ' ' num2str(T)]);

        end

        % compute average value of every voxel for the local diffusion homogeneity(Spearman)
        switch NVoxel_Spearman
            case 26
                result_img_spearman = result_img_spearman/(8*sqrt(3)+12*sqrt(2)+6);
            case 18
                result_img_spearman = result_img_spearman/(12*sqrt(2)+6);
            case 6
                result_img_spearman = result_img_spearman/6;
        end

        result_img_spearman(isnan(result_img_spearman)) = 0;
        result_img_KCC(isnan(result_img_KCC)) = 0;
        ADC_value(isnan(ADC_value)) = 0;
        ADC_value(isinf(ADC_value)) = 0;

        % save the nii file of local diffusion homogeneity(Spearman)
        nii.hdr.dime.datatype = 16;
        nii.hdr.dime.dim(1) = 3;
        nii.hdr.dime.dim(2) = a;
        nii.hdr.dime.dim(3) = b;
        nii.hdr.dime.dim(4) = c;
        nii.hdr.dime.dim(5) = 1;
        nii.img = result_img_spearman;

        if ~isempty(prefix)
            outputfile = [prefix,'_',SubjectID,'_' num2str(NVoxel_Spearman, '%02d') 'LDHs.nii']; 
        else
            outputfile = [SubjectID,'_' num2str(NVoxel_Spearman, '%02d') 'LDHs.nii']; 
        end

        save_untouch_nii(nii,[ResultantFolder filesep outputfile]);
        system(['fslchfiletype NIFTI_GZ ' ResultantFolder filesep outputfile]);

        % save the nii file of local diffusion homogeneity(Kendall)
        nii.hdr.dime.datatype = 16;
        nii.hdr.dime.dim(1) = 3;
        nii.hdr.dime.dim(2) = a;
        nii.hdr.dime.dim(3) = b;
        nii.hdr.dime.dim(4) = c;
        nii.hdr.dime.dim(5) = 1;
        nii.img = result_img_KCC;

        if ~isempty(prefix)
            outputfile = [prefix,'_',SubjectID,'_' num2str(NVoxel_KCC, '%02d') 'LDHk.nii']; 
        else
            outputfile = [SubjectID,'_' num2str(NVoxel_KCC, '%02d') 'LDHk.nii']; 
        end

        save_untouch_nii(nii,[ResultantFolder filesep outputfile]);
        system(['fslchfiletype NIFTI_GZ ' ResultantFolder filesep outputfile]);
%-------------------------------------------over----------------------------------------------------


% only Spearman will be calculated
%--------------------------------------------go------------------------------------------------------
    case 'Spearman'
        
        NVoxel_Spearman = NVoxel;

        % choose the neighborhood number
        switch NVoxel_Spearman
            case 26
                weight_spearman = zeros(3,3,3);
                weight_spearman(:,:,1) = [sqrt(3),sqrt(2),sqrt(3);sqrt(2),1,sqrt(2);sqrt(3),sqrt(2),sqrt(3)];
                weight_spearman(:,:,2) = [sqrt(2),1,sqrt(2);1,0,1;sqrt(2),1,sqrt(2)];
                weight_spearman(:,:,3) = [sqrt(3),sqrt(2),sqrt(3);sqrt(2),1,sqrt(2);sqrt(3),sqrt(2),sqrt(3)];
            case 18
                weight_spearman = zeros(3,3,3);
                weight_spearman(:,:,1) = [0,sqrt(2),0;sqrt(2),1,sqrt(2);0,sqrt(2),0];
                weight_spearman(:,:,2) = [sqrt(2),1,sqrt(2);1,0,1;sqrt(2),1,sqrt(2)];
                weight_spearman(:,:,3) = [0,sqrt(2),0;sqrt(2),1,sqrt(2);0,sqrt(2),0];
            case 6
                weight_spearman = zeros(3,3,3);
                weight_spearman(2,2,1) = 1;weight_spearman(1,2,2) = 1;weight_spearman(2,1,2) = 1;
                weight_spearman(2,3,2) = 1;weight_spearman(3,2,2) = 1;weight_spearman(2,2,3) = 1;
        end

        result_img_spearman = zeros(a,b,c);

        for n = 1:c-3

             tic

        % the process of calculating local diffusion homogeneity(Spearman) values
            rank_3slices_spearman = rank_3slices;
            target_rank = rank_3slices_spearman(2:a-1, 2:b-1, 2, :);
            target_rank_vector = reshape(target_rank, [(a-2)*(b-2), timepoint-(size(index0,2))]);
            target_adj = adj_3slices(2:a-1, 2:b-1, 2);
            target_adj_vector = reshape(target_adj, [(a-2)*(b-2), 1]);             
            for i = -1:1
                for j = -1:1
                    for k = -1:1           
                        neighbor_rank = rank_3slices_spearman(2+i:a-1+i, 2+j:b-1+j, 2+k, :);
                        neighbor_rank_vector = reshape(neighbor_rank, [(a-2)*(b-2), timepoint-(size(index0,2))]);
                        neighbor_adj = adj_3slices(2+i:a-1+i, 2+j:b-1+j, 2+k);
                        neighbor_adj_vector = reshape(neighbor_adj, [(a-2)*(b-2), 1]);
                        [coef_result] = gong_spearman(target_rank_vector', target_adj_vector', neighbor_rank_vector', neighbor_adj_vector');
                        tmp_PANDA = reshape(coef_result,a-2,b-2);
                        result_img_spearman(2:a-1,2:b-1,n+1) = result_img_spearman(2:a-1,2:b-1,n+1)+weight_spearman(i+2,j+2,k+2)*tmp_PANDA;
                    end
                end
            end

        % refresh the 3 slices dataset
            rank_3slices(:,:,1:2,:) = rank_3slices(:,:,2:3,:);
            adj_3slices(:,:,1:2) = adj_3slices(:,:,2:3);
            nii = load_untouch_nii(inputDWIFileName,[],[],[],[],[],n+3);
            nii_data = nii.img;

        % calculating ADC values for the next slices  
            b0 = nii_data(:,:,1,index0);
            b0_ave = sum(b0,4)./(size(index0,2));
            DWI_data = nii_data(:,:,1,index1);
            for i = 1:size(index1,2)
                  ADC_value_temp = DWI_data(:,:,:,i);
                  ADC_value_temp = squeeze(ADC_value_temp);
                  ADC_value_temp = double(ADC_value_temp);
                  ADC_value(1:a,1:b,n+3,i) = log(b0_ave./ADC_value_temp);
            end

        % compute the ranks for the newly loaded slices
            for i = 1:a
                for j = 1:b
                    [rank_3slices(i,j,3,:), adj_3slices(i,j,3)] = tiedrank(squeeze(ADC_value(i,j,n+3,:)), 0);
                end
            end

            T = toc;
            slicenumber = n+1;
            disp(['the time of calculating the' ' ' num2str(slicenumber) ' ' 'slice is' ' ' num2str(T)]);    

        end

        % compute average value of every voxel for the local diffusion homogeneity(Spearman)
        switch NVoxel_Spearman
            case 26
                result_img_spearman = result_img_spearman/(8*sqrt(3)+12*sqrt(2)+6);
            case 18
                result_img_spearman = result_img_spearman/(12*sqrt(2)+6);
            case 6
                result_img_spearman = result_img_spearman/6;
        end

        result_img_spearman(isnan(result_img_spearman)) = 0;

        % save the nii file of local diffusion homogeneity(Spearman)
        nii.hdr.dime.datatype = 16;
        nii.hdr.dime.dim(1) = 3;
        nii.hdr.dime.dim(2) = a;
        nii.hdr.dime.dim(3) = b;
        nii.hdr.dime.dim(4) = c;
        nii.hdr.dime.dim(5) = 1;
        nii.img = result_img_spearman;

        if ~isempty(prefix)
            outputfile = [prefix,'_',SubjectID,'_' num2str(NVoxel_Spearman, '%02d') 'LDHs.nii']; 
        else
            outputfile = [SubjectID,'_' num2str(NVoxel_Spearman, '%02d') 'LDHs.nii']; 
        end

        save_untouch_nii(nii,[ResultantFolder filesep outputfile]);
        system(['fslchfiletype NIFTI_GZ ' ResultantFolder filesep outputfile]);
%-------------------------------------------over-----------------------------------------------------


% only Kendall will be calculated
%--------------------------------------------go------------------------------------------------------
    case 'Kendall'

        NVoxel_KCC = NVoxel+1;

        % choose the neighborhood number
        switch NVoxel_KCC
            case 27
                weight_KCC = ones(3,3,3);
            case 19
                weight_KCC = zeros(3,3,3);
                weight_KCC(:,:,1) = [0,1,0;1,1,1;0,1,0];
                weight_KCC(:,:,2) = [1,1,1;1,1,1;1,1,1];
                weight_KCC(:,:,3) = [0,1,0;1,1,1;0,1,0];
            case 7
                weight_KCC = zeros(3,3,3);
                weight_KCC(2,2,1) = 1;weight_KCC(1,2,2) = 1;weight_KCC(2,1,2) = 1;weight_KCC(2,2,2) = 1;
                weight_KCC(2,3,2) = 1;weight_KCC(3,2,2) = 1;weight_KCC(2,2,3) = 1;
        end

        result_img_KCC = zeros(a,b,c);

        for n = 1:c-3

             tic

        % the process of calculating local diffusion homogeneity(Kendall) values    
            SR = zeros(a-2, b-2, timepoint-(size(index0,2)));
            SR_vector = reshape(SR, [(a-2)*(b-2), timepoint-(size(index0,2))]);
            rank_3slices_KCC = rank_3slices;
            for i = -1:1
                for j = -1:1
                    for k = -1:1           
                        neighbor_rank_KCC = rank_3slices_KCC(2+i:a-1+i, 2+j:b-1+j, 2+k, :);
                        neighbor_rank_vector_KCC = reshape(neighbor_rank_KCC, [(a-2)*(b-2), timepoint-(size(index0,2))]);
                        SR_vector = SR_vector+neighbor_rank_vector_KCC*weight_KCC(i+2,j+2,k+2);
                    end
                end
            end
            SRBAR = mean(SR_vector,2);
            S = sum(SR_vector.^2,2) - (timepoint-(size(index0,2)))*SRBAR.^2;
            B = 12*S./NVoxel_KCC^2/((timepoint-(size(index0,2)))^3-(timepoint-(size(index0,2))));
            tmp_LDH = reshape(B,a-2,b-2);
            result_img_KCC(2:a-1,2:b-1,n+1) = tmp_LDH;

        % refresh the 3 slices dataset
            rank_3slices(:,:,1:2,:) = rank_3slices(:,:,2:3,:);
            adj_3slices(:,:,1:2) = adj_3slices(:,:,2:3);
            nii = load_untouch_nii(inputDWIFileName,[],[],[],[],[],n+3);
            nii_data = nii.img;

        % calculating ADC values for the next slices  
            b0 = nii_data(:,:,1,index0);
            b0_ave = sum(b0,4)./(size(index0,2));
            DWI_data = nii_data(:,:,1,index1);
            for i = 1:size(index1,2)
                  ADC_value_temp = DWI_data(:,:,:,i);
                  ADC_value_temp = squeeze(ADC_value_temp);
                  ADC_value_temp = double(ADC_value_temp);
                  ADC_value(1:a,1:b,n+3,i) = log(b0_ave./ADC_value_temp);
            end

        % compute the ranks for the newly loaded slices
            for i = 1:a
                for j = 1:b
                    [rank_3slices(i,j,3,:), adj_3slices(i,j,3)] = tiedrank(squeeze(ADC_value(i,j,n+3,:)), 0);
                end
            end

            T = toc;
            slicenumber = n+1;
            disp(['the time of calculating the' ' ' num2str(slicenumber) ' ' 'slice is' ' ' num2str(T)]);    

        end

        result_img_KCC(isnan(result_img_KCC)) = 0;

        % save the nii file of local diffusion homogeneity(Kendall)
        nii.hdr.dime.datatype = 16;
        nii.hdr.dime.dim(1) = 3;
        nii.hdr.dime.dim(2) = a;
        nii.hdr.dime.dim(3) = b;
        nii.hdr.dime.dim(4) = c;
        nii.hdr.dime.dim(5) = 1;
        nii.img = result_img_KCC;

        if ~isempty(prefix)
            outputfile = [prefix,'_',SubjectID,'_' num2str(NVoxel_KCC, '%02d') 'LDHk.nii']; 
        else
            outputfile = [SubjectID,'_' num2str(NVoxel_KCC, '%02d') 'LDHk.nii']; 
        end

        save_untouch_nii(nii,[ResultantFolder filesep outputfile]);
        system(['fslchfiletype NIFTI_GZ ' ResultantFolder filesep outputfile]);
%------------------------------------------over------------------------------------------------------

end

if DeleteDWI_Flag
    delete(inputDWIFileName);
end
theElapsedTime = cputime-theElapsedTime;
fprintf('\n\t   total time: %g seconds\t\n', theElapsedTime);

end


% a subfunction that can calculate Spearman coefficient
%-----------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [coef_result] = gong_spearman(xrank, xadj, yrank, yadj)

   [a,b] = size(xrank);
   n = a;
   n3const = (n+1)*n*(n-1) ./ 3;                 
   D = sum((xrank - yrank).^2);
   meanD = (n3const - (xadj+yadj)./3) ./ 2;
   stdD = sqrt((n3const./2 - xadj./3).*(n3const./2 - yadj./3)./(n-1));
   coef_result = (meanD - D) ./ (sqrt(n-1)*stdD);  
   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------------------------------------------------

