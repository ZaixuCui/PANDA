function g_DWI2LDH(inputDWIFileName, inputBVALFileName, NVoxel, prefix, SubjectID, type)


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

[ResultantFolder y z] = fileparts(inputDWIFileName);

theElapsedTime = cputime;
% check input
if NVoxel ~= 26 & NVoxel ~= 18 & NVoxel ~= 6 
    error('The NVoxel parameter should be 6, 18 or 26. Please re-exmamin it!');
end

fprintf('\n\t Read these 4D ADC images...\t\n');

DeleteDWI_Flag = 0;
if strcmp(inputDWIFileName(end-6:end), '.nii.gz')
   gunzip(inputDWIFileName);
   DeleteDWI_Flag = 1;
   inputDWIFileName = inputDWIFileName(1:end-3);
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
                        tmp = reshape(coef_result,a-2,b-2);
                        result_img_spearman(2:a-1,2:b-1,n+1) = result_img_spearman(2:a-1,2:b-1,n+1)+weight_spearman(i+2,j+2,k+2)*tmp;
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
            tmp = reshape(B,a-2,b-2);
            result_img_KCC(2:a-1,2:b-1,n+1) = tmp;

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
                        tmp = reshape(coef_result,a-2,b-2);
                        result_img_spearman(2:a-1,2:b-1,n+1) = result_img_spearman(2:a-1,2:b-1,n+1)+weight_spearman(i+2,j+2,k+2)*tmp;
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
            tmp = reshape(B,a-2,b-2);
            result_img_KCC(2:a-1,2:b-1,n+1) = tmp;

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





% the below subfunctions come from software FSL which is mentioned in the help information
% a subfunction called load_nii_hdr
%-----------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Load NIFTI dataset header. Support both *.nii and *.hdr/*.img file
%  extension. If file extension is not provided, *.hdr/*.img will be 
%  used as default.
%  
%  Usage: [hdr, filetype, fileprefix, machine] = load_nii_hdr(filename)
%  
%  filename - NIFTI file name.
%  
%  Returned values:
%  
%  hdr - struct with NIFTI header fields.
%  
%  filetype	- 0 for Analyze format (*.hdr/*.img);
%		  1 for NIFTI format in 2 files (*.hdr/*.img);
%		  2 for NIFTI format in 1 file (*.nii).
%  
%  fileprefix - NIFTI file name without extension.
%  
%  machine    - a string, see below for details. The default here is 'ieee-le'.
%
%    'native'      or 'n' - local machine format - the default
%    'ieee-le'     or 'l' - IEEE floating point with little-endian
%                           byte ordering
%    'ieee-be'     or 'b' - IEEE floating point with big-endian
%                           byte ordering
%    'vaxd'        or 'd' - VAX D floating point and VAX ordering
%    'vaxg'        or 'g' - VAX G floating point and VAX ordering
%    'cray'        or 'c' - Cray floating point with big-endian
%                           byte ordering
%    'ieee-le.l64' or 'a' - IEEE floating point with little-endian
%                           byte ordering and 64 bit long data type
%    'ieee-be.l64' or 's' - IEEE floating point with big-endian byte
%                           ordering and 64 bit long data type.
%  
%  Number of scanned images in the file can be obtained by:
%  num_scan = hdr.dime.dim(5)
%
%  Part of this file is copied and modified from:
%  http://www.mathworks.com/matlabcentral/fileexchange/1878-mri-analyze-tools
%
%  NIFTI data format can be found on: http://nifti.nimh.nih.gov
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function [hdr, filetype, fileprefix, machine] = load_nii_hdr(fileprefix)

   if ~exist('fileprefix','var'),
      error('Usage: [hdr, filetype, fileprefix, machine] = load_nii_hdr(filename)');
   end

   machine = 'ieee-le';
   new_ext = 0;

   if findstr('.nii',fileprefix)
      new_ext = 1;
      fileprefix = strrep(fileprefix,'.nii','');
   end

   if findstr('.hdr',fileprefix)
      fileprefix = strrep(fileprefix,'.hdr','');
   end

   if findstr('.img',fileprefix)
      fileprefix = strrep(fileprefix,'.img','');
   end

   if new_ext
      fn = sprintf('%s.nii',fileprefix);

      if ~exist(fn)
         msg = sprintf('Cannot find file "%s.nii".', fileprefix);
         error(msg);
      end
   else
      fn = sprintf('%s.hdr',fileprefix);

      if ~exist(fn)
         msg = sprintf('Cannot find file "%s.hdr".', fileprefix);
         error(msg);
      end
   end

   fid = fopen(fn,'r',machine);
    
   if fid < 0,
      msg = sprintf('Cannot open file %s.',fn);
      error(msg);
   else
      fseek(fid,0,'bof');

      if fread(fid,1,'int32') == 348
         hdr = read_header1(fid);
         fclose(fid);
      else
         fclose(fid);

         %  first try reading the opposite endian to 'machine'
         %
         switch machine,
         case 'ieee-le', machine = 'ieee-be';
         case 'ieee-be', machine = 'ieee-le';
         end

         fid = fopen(fn,'r',machine);

         if fid < 0,
            msg = sprintf('Cannot open file %s.',fn);
            error(msg);
         else
            fseek(fid,0,'bof');

            if fread(fid,1,'int32') ~= 348

               %  Now throw an error
               %
               msg = sprintf('File "%s" is corrupted.',fn);
               error(msg);
            end

            hdr = read_header1(fid);
            fclose(fid);
         end
      end
   end

   if strcmp(hdr.hist.magic, 'n+1')
      filetype = 2;
   elseif strcmp(hdr.hist.magic, 'ni1')
      filetype = 1;
   else
      filetype = 0;
   end

end					% load_nii_hdr
%---------------------------------------------------------------------
function [ dsr ] = read_header1(fid)

        %  Original header structures
	%  struct dsr
	%       { 
	%       struct header_key hk;            /*   0 +  40       */
	%       struct image_dimension dime;     /*  40 + 108       */
	%       struct data_history hist;        /* 148 + 200       */
	%       };                               /* total= 348 bytes*/

    dsr.hk   = header_key1(fid);
    dsr.dime = image_dimension1(fid);
    dsr.hist = data_history1(fid);

    %  For Analyze data format
    %
    if ~strcmp(dsr.hist.magic, 'n+1') & ~strcmp(dsr.hist.magic, 'ni1')
        dsr.hist.qform_code = 0;
        dsr.hist.sform_code = 0;
    end

end					% read_header
%---------------------------------------------------------------------
function [ hk ] = header_key1(fid)

    fseek(fid,0,'bof');
    
	%  Original header structures	
	%  struct header_key                     /* header key      */ 
	%       {                                /* off + size      */
	%       int sizeof_hdr                   /*  0 +  4         */
	%       char data_type[10];              /*  4 + 10         */
	%       char db_name[18];                /* 14 + 18         */
	%       int extents;                     /* 32 +  4         */
	%       short int session_error;         /* 36 +  2         */
	%       char regular;                    /* 38 +  1         */
	%       char dim_info;   % char hkey_un0;        /* 39 +  1 */
	%       };                               /* total=40 bytes  */
	%
	% int sizeof_header   Should be 348.
	% char regular        Must be 'r' to indicate that all images and 
	%                     volumes are the same size. 

    v6 = version;
    if str2num(v6(1))<6
       directchar = '*char';
    else
       directchar = 'uchar=>char';
    end

    hk.sizeof_hdr    = fread(fid, 1,'int32')';	% should be 348!
    hk.data_type     = deblank(fread(fid,10,directchar)');
    hk.db_name       = deblank(fread(fid,18,directchar)');
    hk.extents       = fread(fid, 1,'int32')';
    hk.session_error = fread(fid, 1,'int16')';
    hk.regular       = fread(fid, 1,directchar)';
    hk.dim_info      = fread(fid, 1,'uchar')';
    
end					% header_key
%---------------------------------------------------------------------
function [ dime ] = image_dimension1(fid)

	%  Original header structures    
	%  struct image_dimension
	%       {                                /* off + size      */
	%       short int dim[8];                /* 0 + 16          */
        %       /*
        %           dim[0]      Number of dimensions in database; usually 4. 
        %           dim[1]      Image X dimension;  number of *pixels* in an image row. 
        %           dim[2]      Image Y dimension;  number of *pixel rows* in slice. 
        %           dim[3]      Volume Z dimension; number of *slices* in a volume. 
        %           dim[4]      Time points; number of volumes in database
        %       */
	%       float intent_p1;   % char vox_units[4];   /* 16 + 4       */
	%       float intent_p2;   % char cal_units[8];   /* 20 + 4       */
	%       float intent_p3;   % char cal_units[8];   /* 24 + 4       */
	%       short int intent_code;   % short int unused1;   /* 28 + 2 */
	%       short int datatype;              /* 30 + 2          */
	%       short int bitpix;                /* 32 + 2          */
	%       short int slice_start;   % short int dim_un0;   /* 34 + 2 */
	%       float pixdim[8];                 /* 36 + 32         */
	%	/*
	%		pixdim[] specifies the voxel dimensions:
	%		pixdim[1] - voxel width, mm
	%		pixdim[2] - voxel height, mm
	%		pixdim[3] - slice thickness, mm
	%		pixdim[4] - volume timing, in msec
	%					..etc
	%	*/
	%       float vox_offset;                /* 68 + 4          */
	%       float scl_slope;   % float roi_scale;     /* 72 + 4 */
	%       float scl_inter;   % float funused1;      /* 76 + 4 */
	%       short slice_end;   % float funused2;      /* 80 + 2 */
	%       char slice_code;   % float funused2;      /* 82 + 1 */
	%       char xyzt_units;   % float funused2;      /* 83 + 1 */
	%       float cal_max;                   /* 84 + 4          */
	%       float cal_min;                   /* 88 + 4          */
	%       float slice_duration;   % int compressed; /* 92 + 4 */
	%       float toffset;   % int verified;          /* 96 + 4 */
	%       int glmax;                       /* 100 + 4         */
	%       int glmin;                       /* 104 + 4         */
	%       };                               /* total=108 bytes */
	
    dime.dim        = fread(fid,8,'int16')';
    dime.intent_p1  = fread(fid,1,'float32')';
    dime.intent_p2  = fread(fid,1,'float32')';
    dime.intent_p3  = fread(fid,1,'float32')';
    dime.intent_code = fread(fid,1,'int16')';
    dime.datatype   = fread(fid,1,'int16')';
    dime.bitpix     = fread(fid,1,'int16')';
    dime.slice_start = fread(fid,1,'int16')';
    dime.pixdim     = abs(fread(fid,8,'float32')');
    dime.vox_offset = fread(fid,1,'float32')';
    dime.scl_slope  = fread(fid,1,'float32')';
    dime.scl_inter  = fread(fid,1,'float32')';
    dime.slice_end  = fread(fid,1,'int16')';
    dime.slice_code = fread(fid,1,'uchar')';
    dime.xyzt_units = fread(fid,1,'uchar')';
    dime.cal_max    = fread(fid,1,'float32')';
    dime.cal_min    = fread(fid,1,'float32')';
    dime.slice_duration = fread(fid,1,'float32')';
    dime.toffset    = fread(fid,1,'float32')';
    dime.glmax      = fread(fid,1,'int32')';
    dime.glmin      = fread(fid,1,'int32')';
        
end					% image_dimension
%---------------------------------------------------------------------
function [ hist ] = data_history1(fid)
        
	%  Original header structures
	%  struct data_history       
	%       {                                /* off + size      */
	%       char descrip[80];                /* 0 + 80          */
	%       char aux_file[24];               /* 80 + 24         */
	%       short int qform_code;            /* 104 + 2         */
	%       short int sform_code;            /* 106 + 2         */
	%       float quatern_b;                 /* 108 + 4         */
	%       float quatern_c;                 /* 112 + 4         */
	%       float quatern_d;                 /* 116 + 4         */
	%       float qoffset_x;                 /* 120 + 4         */
	%       float qoffset_y;                 /* 124 + 4         */
	%       float qoffset_z;                 /* 128 + 4         */
	%       float srow_x[4];                 /* 132 + 16        */
	%       float srow_y[4];                 /* 148 + 16        */
	%       float srow_z[4];                 /* 164 + 16        */
	%       char intent_name[16];            /* 180 + 16        */
	%       char magic[4];   % int smin;     /* 196 + 4         */
	%       };                               /* total=200 bytes */

    v6 = version;
    if str2num(v6(1))<6
       directchar = '*char';
    else
       directchar = 'uchar=>char';
    end

    hist.descrip     = deblank(fread(fid,80,directchar)');
    hist.aux_file    = deblank(fread(fid,24,directchar)');
    hist.qform_code  = fread(fid,1,'int16')';
    hist.sform_code  = fread(fid,1,'int16')';
    hist.quatern_b   = fread(fid,1,'float32')';
    hist.quatern_c   = fread(fid,1,'float32')';
    hist.quatern_d   = fread(fid,1,'float32')';
    hist.qoffset_x   = fread(fid,1,'float32')';
    hist.qoffset_y   = fread(fid,1,'float32')';
    hist.qoffset_z   = fread(fid,1,'float32')';
    hist.srow_x      = fread(fid,4,'float32')';
    hist.srow_y      = fread(fid,4,'float32')';
    hist.srow_z      = fread(fid,4,'float32')';
    hist.intent_name = deblank(fread(fid,16,directchar)');
    hist.magic       = deblank(fread(fid,4,directchar)');

    fseek(fid,253,'bof');
    hist.originator  = fread(fid, 5,'int16')';
    
end					% data_history
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------------------------------------------------


% a subfunction called load_untouch_nii
%-----------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Load NIFTI or ANALYZE dataset, but not applying any appropriate affine
%  geometric transform or voxel intensity scaling.
%
%  Although according to NIFTI website, all those header information are
%  supposed to be applied to the loaded NIFTI image, there are some
%  situations that people do want to leave the original NIFTI header and
%  data untouched. They will probably just use MATLAB to do certain image
%  processing regardless of image orientation, and to save data back with
%  the same NIfTI header.
%
%  Since this program is only served for those situations, please use it
%  together with "save_untouch_nii.m", and do not use "save_nii.m" or
%  "view_nii.m" for the data that is loaded by "load_untouch_nii.m". For
%  normal situation, you should use "load_nii.m" instead.
%  
%  Usage: nii = load_untouch_nii(filename, [img_idx], [dim5_idx], [dim6_idx], ...
%			[dim7_idx], [old_RGB], [slice_idx])
%  
%  filename  - 	NIFTI or ANALYZE file name.
%  
%  img_idx (optional)  -  a numerical array of image volume indices.
%	Only the specified volumes will be loaded. All available image
%	volumes will be loaded, if it is default or empty.
%
%	The number of images scans can be obtained from get_nii_frame.m,
%	or simply: hdr.dime.dim(5).
%
%  dim5_idx (optional)  -  a numerical array of 5th dimension indices.
%	Only the specified range will be loaded. All available range
%	will be loaded, if it is default or empty.
%
%  dim6_idx (optional)  -  a numerical array of 6th dimension indices.
%	Only the specified range will be loaded. All available range
%	will be loaded, if it is default or empty.
%
%  dim7_idx (optional)  -  a numerical array of 7th dimension indices.
%	Only the specified range will be loaded. All available range
%	will be loaded, if it is default or empty.
%
%  old_RGB (optional)  -  a scale number to tell difference of new RGB24
%	from old RGB24. New RGB24 uses RGB triple sequentially for each
%	voxel, like [R1 G1 B1 R2 G2 B2 ...]. Analyze 6.0 from AnalyzeDirect
%	uses old RGB24, in a way like [R1 R2 ... G1 G2 ... B1 B2 ...] for
%	each slices. If the image that you view is garbled, try to set 
%	old_RGB variable to 1 and try again, because it could be in
%	old RGB24. It will be set to 0, if it is default or empty.
%
%  slice_idx (optional)  -  a numerical array of image slice indices.
%	Only the specified volumes will be loaded. All available image
%	slices will be loaded, if it is default or empty.
%
%  Returned values:
%  
%  nii structure:
%
%	hdr -		struct with NIFTI header fields.
%
%	filetype -	Analyze format .hdr/.img (0); 
%			NIFTI .hdr/.img (1);
%			NIFTI .nii (2)
%
%	fileprefix - 	NIFTI filename without extension.
%
%	machine - 	machine string variable.
%
%	img - 		3D (or 4D) matrix of NIFTI data.
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function nii = load_untouch_nii(filename, img_idx, dim5_idx, dim6_idx, dim7_idx, ...
			old_RGB, slice_idx)

   if ~exist('filename','var')
      error('Usage: nii = load_untouch_nii(filename, [img_idx], [dim5_idx], [dim6_idx], [dim7_idx], [old_RGB], [slice_idx])');
   end

   if ~exist('img_idx','var') | isempty(img_idx)
      img_idx = [];
   end

   if ~exist('dim5_idx','var') | isempty(dim5_idx)
      dim5_idx = [];
   end

   if ~exist('dim6_idx','var') | isempty(dim6_idx)
      dim6_idx = [];
   end

   if ~exist('dim7_idx','var') | isempty(dim7_idx)
      dim7_idx = [];
   end

   if ~exist('old_RGB','var') | isempty(old_RGB)
      old_RGB = 0;
   end

   if ~exist('slice_idx','var') | isempty(slice_idx)
      slice_idx = [];
   end

   %  Read the dataset header
   %
   [nii.hdr,nii.filetype,nii.fileprefix,nii.machine] = load_nii_hdr(filename);

   if nii.filetype == 0
      nii.hdr = load_untouch0_nii_hdr(nii.fileprefix,nii.machine);
      nii.ext = [];
   else
      nii.hdr = load_untouch_nii_hdr(nii.fileprefix,nii.machine,nii.filetype);

      %  Read the header extension
      %
      nii.ext = load_nii_ext(filename);
   end

   %  Read the dataset body
   %
   [nii.img,nii.hdr] = load_untouch_nii_img(nii.hdr,nii.filetype,nii.fileprefix, ...
		nii.machine,img_idx,dim5_idx,dim6_idx,dim7_idx,old_RGB,slice_idx);

   %  Perform some of sform/qform transform
   %
%   nii = xform_nii(nii, tolerance, preferredForm);

   nii.untouch = 1;

end					% load_untouch_nii
%---------------------------------------------------------------------
function hdr = load_untouch0_nii_hdr(fileprefix, machine)

   fn = sprintf('%s.hdr',fileprefix);
   fid = fopen(fn,'r',machine);
    
   if fid < 0,
      msg = sprintf('Cannot open file %s.',fn);
      error(msg);
   else
      fseek(fid,0,'bof');
      hdr = read_header2(fid);
      fclose(fid);
   end

end					% load_nii_hdr
%---------------------------------------------------------------------
function [ dsr ] = read_header2(fid)

        %  Original header structures
	%  struct dsr
	%       { 
	%       struct header_key hk;            /*   0 +  40       */
	%       struct image_dimension dime;     /*  40 + 108       */
	%       struct data_history hist;        /* 148 + 200       */
	%       };                               /* total= 348 bytes*/

    dsr.hk   = header_key2(fid);
    dsr.dime = image_dimension2(fid);
    dsr.hist = data_history2(fid);

end					% read_header
%---------------------------------------------------------------------
function [ hk ] = header_key2(fid)

    fseek(fid,0,'bof');
    
	%  Original header structures	
	%  struct header_key                     /* header key      */ 
	%       {                                /* off + size      */
	%       int sizeof_hdr                   /*  0 +  4         */
	%       char data_type[10];              /*  4 + 10         */
	%       char db_name[18];                /* 14 + 18         */
	%       int extents;                     /* 32 +  4         */
	%       short int session_error;         /* 36 +  2         */
	%       char regular;                    /* 38 +  1         */
	%       char hkey_un0;                   /* 39 +  1 */
	%       };                               /* total=40 bytes  */
	%
	% int sizeof_header   Should be 348.
	% char regular        Must be 'r' to indicate that all images and 
	%                     volumes are the same size. 

    v6 = version;
    if str2num(v6(1))<6
       directchar = '*char';
    else
       directchar = 'uchar=>char';
    end
	
    hk.sizeof_hdr    = fread(fid, 1,'int32')';	% should be 348!
    hk.data_type     = deblank(fread(fid,10,directchar)');
    hk.db_name       = deblank(fread(fid,18,directchar)');
    hk.extents       = fread(fid, 1,'int32')';
    hk.session_error = fread(fid, 1,'int16')';
    hk.regular       = fread(fid, 1,directchar)';
    hk.hkey_un0      = fread(fid, 1,directchar)';
    
end					% header_key
%---------------------------------------------------------------------
function [ dime ] = image_dimension2(fid)

	%struct image_dimension
	%       {                                /* off + size      */
	%       short int dim[8];                /* 0 + 16          */
    %           /*
    %           dim[0]      Number of dimensions in database; usually 4. 
    %           dim[1]      Image X dimension;  number of *pixels* in an image row. 
    %           dim[2]      Image Y dimension;  number of *pixel rows* in slice. 
    %           dim[3]      Volume Z dimension; number of *slices* in a volume. 
    %           dim[4]      Time points; number of volumes in database
    %           */
	%       char vox_units[4];               /* 16 + 4          */
	%       char cal_units[8];               /* 20 + 8          */
	%       short int unused1;               /* 28 + 2          */
	%       short int datatype;              /* 30 + 2          */
	%       short int bitpix;                /* 32 + 2          */
	%       short int dim_un0;               /* 34 + 2          */
	%       float pixdim[8];                 /* 36 + 32         */
	%			/*
	%				pixdim[] specifies the voxel dimensions:
	%				pixdim[1] - voxel width, mm
	%				pixdim[2] - voxel height, mm
	%				pixdim[3] - slice thickness, mm
    %               pixdim[4] - volume timing, in msec
	%					..etc
	%			*/
	%       float vox_offset;                /* 68 + 4          */
	%       float roi_scale;                 /* 72 + 4          */
	%       float funused1;                  /* 76 + 4          */
	%       float funused2;                  /* 80 + 4          */
	%       float cal_max;                   /* 84 + 4          */
	%       float cal_min;                   /* 88 + 4          */
	%       int compressed;                  /* 92 + 4          */
	%       int verified;                    /* 96 + 4          */
	%       int glmax;                       /* 100 + 4         */
	%       int glmin;                       /* 104 + 4         */
	%       };                               /* total=108 bytes */

    v6 = version;
    if str2num(v6(1))<6
       directchar = '*char';
    else
       directchar = 'uchar=>char';
    end
	
    dime.dim        = fread(fid,8,'int16')';
    dime.vox_units  = deblank(fread(fid,4,directchar)');
    dime.cal_units  = deblank(fread(fid,8,directchar)');
    dime.unused1    = fread(fid,1,'int16')';
    dime.datatype   = fread(fid,1,'int16')';
    dime.bitpix     = fread(fid,1,'int16')';
    dime.dim_un0    = fread(fid,1,'int16')';
    dime.pixdim     = fread(fid,8,'float32')';
    dime.vox_offset = fread(fid,1,'float32')';
    dime.roi_scale  = fread(fid,1,'float32')';
    dime.funused1   = fread(fid,1,'float32')';
    dime.funused2   = fread(fid,1,'float32')';
    dime.cal_max    = fread(fid,1,'float32')';
    dime.cal_min    = fread(fid,1,'float32')';
    dime.compressed = fread(fid,1,'int32')';
    dime.verified   = fread(fid,1,'int32')';
    dime.glmax      = fread(fid,1,'int32')';
    dime.glmin      = fread(fid,1,'int32')';
        
end					% image_dimension
%---------------------------------------------------------------------
function [ hist ] = data_history2(fid)
        
	%struct data_history       
	%       {                                /* off + size      */
	%       char descrip[80];                /* 0 + 80          */
	%       char aux_file[24];               /* 80 + 24         */
	%       char orient;                     /* 104 + 1         */
	%       char originator[10];             /* 105 + 10        */
	%       char generated[10];              /* 115 + 10        */
	%       char scannum[10];                /* 125 + 10        */
	%       char patient_id[10];             /* 135 + 10        */
	%       char exp_date[10];               /* 145 + 10        */
	%       char exp_time[10];               /* 155 + 10        */
	%       char hist_un0[3];                /* 165 + 3         */
	%       int views                        /* 168 + 4         */
	%       int vols_added;                  /* 172 + 4         */
	%       int start_field;                 /* 176 + 4         */
	%       int field_skip;                  /* 180 + 4         */
	%       int omax;                        /* 184 + 4         */
	%       int omin;                        /* 188 + 4         */
	%       int smax;                        /* 192 + 4         */
	%       int smin;                        /* 196 + 4         */
	%       };                               /* total=200 bytes */

    v6 = version;
    if str2num(v6(1))<6
       directchar = '*char';
    else
       directchar = 'uchar=>char';
    end

    hist.descrip     = deblank(fread(fid,80,directchar)');
    hist.aux_file    = deblank(fread(fid,24,directchar)');
    hist.orient      = fread(fid, 1,'char')';
    hist.originator  = fread(fid, 5,'int16')';
    hist.generated   = deblank(fread(fid,10,directchar)');
    hist.scannum     = deblank(fread(fid,10,directchar)');
    hist.patient_id  = deblank(fread(fid,10,directchar)');
    hist.exp_date    = deblank(fread(fid,10,directchar)');
    hist.exp_time    = deblank(fread(fid,10,directchar)');
    hist.hist_un0    = deblank(fread(fid, 3,directchar)');
    hist.views       = fread(fid, 1,'int32')';
    hist.vols_added  = fread(fid, 1,'int32')';
    hist.start_field = fread(fid, 1,'int32')';
    hist.field_skip  = fread(fid, 1,'int32')';
    hist.omax        = fread(fid, 1,'int32')';
    hist.omin        = fread(fid, 1,'int32')';
    hist.smax        = fread(fid, 1,'int32')';
    hist.smin        = fread(fid, 1,'int32')';
    
end					% data_history
%---------------------------------------------------------------------
function hdr = load_untouch_nii_hdr(fileprefix, machine, filetype)

   if filetype == 2
      fn = sprintf('%s.nii',fileprefix);

      if ~exist(fn)
         msg = sprintf('Cannot find file "%s.nii".', fileprefix);
         error(msg);
      end
   else
      fn = sprintf('%s.hdr',fileprefix);

      if ~exist(fn)
         msg = sprintf('Cannot find file "%s.hdr".', fileprefix);
         error(msg);
      end
   end

   fid = fopen(fn,'r',machine);
    
   if fid < 0,
      msg = sprintf('Cannot open file %s.',fn);
      error(msg);
   else
      fseek(fid,0,'bof');
      hdr = read_header3(fid);
      fclose(fid);
   end

end					% load_nii_hdr
%---------------------------------------------------------------------
function [ dsr ] = read_header3(fid)

        %  Original header structures
	%  struct dsr
	%       { 
	%       struct header_key hk;            /*   0 +  40       */
	%       struct image_dimension dime;     /*  40 + 108       */
	%       struct data_history hist;        /* 148 + 200       */
	%       };                               /* total= 348 bytes*/

    dsr.hk   = header_key3(fid);
    dsr.dime = image_dimension3(fid);
    dsr.hist = data_history3(fid);

    %  For Analyze data format
    %
    if ~strcmp(dsr.hist.magic, 'n+1') & ~strcmp(dsr.hist.magic, 'ni1')
        dsr.hist.qform_code = 0;
        dsr.hist.sform_code = 0;
    end

end					% read_header
%---------------------------------------------------------------------
function [ hk ] = header_key3(fid)

    fseek(fid,0,'bof');
    
	%  Original header structures	
	%  struct header_key                     /* header key      */ 
	%       {                                /* off + size      */
	%       int sizeof_hdr                   /*  0 +  4         */
	%       char data_type[10];              /*  4 + 10         */
	%       char db_name[18];                /* 14 + 18         */
	%       int extents;                     /* 32 +  4         */
	%       short int session_error;         /* 36 +  2         */
	%       char regular;                    /* 38 +  1         */
	%       char dim_info;   % char hkey_un0;        /* 39 +  1 */
	%       };                               /* total=40 bytes  */
	%
	% int sizeof_header   Should be 348.
	% char regular        Must be 'r' to indicate that all images and 
	%                     volumes are the same size. 

    v6 = version;
    if str2num(v6(1))<6
       directchar = '*char';
    else
       directchar = 'uchar=>char';
    end
	
    hk.sizeof_hdr    = fread(fid, 1,'int32')';	% should be 348!
    hk.data_type     = deblank(fread(fid,10,directchar)');
    hk.db_name       = deblank(fread(fid,18,directchar)');
    hk.extents       = fread(fid, 1,'int32')';
    hk.session_error = fread(fid, 1,'int16')';
    hk.regular       = fread(fid, 1,directchar)';
    hk.dim_info      = fread(fid, 1,'uchar')';
    
end					% header_key
%---------------------------------------------------------------------
function [ dime ] = image_dimension3(fid)

	%  Original header structures    
	%  struct image_dimension
	%       {                                /* off + size      */
	%       short int dim[8];                /* 0 + 16          */
        %       /*
        %           dim[0]      Number of dimensions in database; usually 4. 
        %           dim[1]      Image X dimension;  number of *pixels* in an image row. 
        %           dim[2]      Image Y dimension;  number of *pixel rows* in slice. 
        %           dim[3]      Volume Z dimension; number of *slices* in a volume. 
        %           dim[4]      Time points; number of volumes in database
        %       */
	%       float intent_p1;   % char vox_units[4];   /* 16 + 4       */
	%       float intent_p2;   % char cal_units[8];   /* 20 + 4       */
	%       float intent_p3;   % char cal_units[8];   /* 24 + 4       */
	%       short int intent_code;   % short int unused1;   /* 28 + 2 */
	%       short int datatype;              /* 30 + 2          */
	%       short int bitpix;                /* 32 + 2          */
	%       short int slice_start;   % short int dim_un0;   /* 34 + 2 */
	%       float pixdim[8];                 /* 36 + 32         */
	%	/*
	%		pixdim[] specifies the voxel dimensions:
	%		pixdim[1] - voxel width, mm
	%		pixdim[2] - voxel height, mm
	%		pixdim[3] - slice thickness, mm
	%		pixdim[4] - volume timing, in msec
	%					..etc
	%	*/
	%       float vox_offset;                /* 68 + 4          */
	%       float scl_slope;   % float roi_scale;     /* 72 + 4 */
	%       float scl_inter;   % float funused1;      /* 76 + 4 */
	%       short slice_end;   % float funused2;      /* 80 + 2 */
	%       char slice_code;   % float funused2;      /* 82 + 1 */
	%       char xyzt_units;   % float funused2;      /* 83 + 1 */
	%       float cal_max;                   /* 84 + 4          */
	%       float cal_min;                   /* 88 + 4          */
	%       float slice_duration;   % int compressed; /* 92 + 4 */
	%       float toffset;   % int verified;          /* 96 + 4 */
	%       int glmax;                       /* 100 + 4         */
	%       int glmin;                       /* 104 + 4         */
	%       };                               /* total=108 bytes */
	
    dime.dim        = fread(fid,8,'int16')';
    dime.intent_p1  = fread(fid,1,'float32')';
    dime.intent_p2  = fread(fid,1,'float32')';
    dime.intent_p3  = fread(fid,1,'float32')';
    dime.intent_code = fread(fid,1,'int16')';
    dime.datatype   = fread(fid,1,'int16')';
    dime.bitpix     = fread(fid,1,'int16')';
    dime.slice_start = fread(fid,1,'int16')';
    dime.pixdim     = fread(fid,8,'float32')';
    dime.vox_offset = fread(fid,1,'float32')';
    dime.scl_slope  = fread(fid,1,'float32')';
    dime.scl_inter  = fread(fid,1,'float32')';
    dime.slice_end  = fread(fid,1,'int16')';
    dime.slice_code = fread(fid,1,'uchar')';
    dime.xyzt_units = fread(fid,1,'uchar')';
    dime.cal_max    = fread(fid,1,'float32')';
    dime.cal_min    = fread(fid,1,'float32')';
    dime.slice_duration = fread(fid,1,'float32')';
    dime.toffset    = fread(fid,1,'float32')';
    dime.glmax      = fread(fid,1,'int32')';
    dime.glmin      = fread(fid,1,'int32')';
        
end					% image_dimension
%---------------------------------------------------------------------
function [ hist ] = data_history3(fid)
        
	%  Original header structures
	%  struct data_history       
	%       {                                /* off + size      */
	%       char descrip[80];                /* 0 + 80          */
	%       char aux_file[24];               /* 80 + 24         */
	%       short int qform_code;            /* 104 + 2         */
	%       short int sform_code;            /* 106 + 2         */
	%       float quatern_b;                 /* 108 + 4         */
	%       float quatern_c;                 /* 112 + 4         */
	%       float quatern_d;                 /* 116 + 4         */
	%       float qoffset_x;                 /* 120 + 4         */
	%       float qoffset_y;                 /* 124 + 4         */
	%       float qoffset_z;                 /* 128 + 4         */
	%       float srow_x[4];                 /* 132 + 16        */
	%       float srow_y[4];                 /* 148 + 16        */
	%       float srow_z[4];                 /* 164 + 16        */
	%       char intent_name[16];            /* 180 + 16        */
	%       char magic[4];   % int smin;     /* 196 + 4         */
	%       };                               /* total=200 bytes */

    v6 = version;
    if str2num(v6(1))<6
       directchar = '*char';
    else
       directchar = 'uchar=>char';
    end
    
    hist.descrip     = deblank(fread(fid,80,directchar)');
    hist.aux_file    = deblank(fread(fid,24,directchar)');
    hist.qform_code  = fread(fid,1,'int16')';
    hist.sform_code  = fread(fid,1,'int16')';
    hist.quatern_b   = fread(fid,1,'float32')';
    hist.quatern_c   = fread(fid,1,'float32')';
    hist.quatern_d   = fread(fid,1,'float32')';
    hist.qoffset_x   = fread(fid,1,'float32')';
    hist.qoffset_y   = fread(fid,1,'float32')';
    hist.qoffset_z   = fread(fid,1,'float32')';
    hist.srow_x      = fread(fid,4,'float32')';
    hist.srow_y      = fread(fid,4,'float32')';
    hist.srow_z      = fread(fid,4,'float32')';
    hist.intent_name = deblank(fread(fid,16,directchar)');
    hist.magic       = deblank(fread(fid,4,directchar)');
    
end					% data_history
%---------------------------------------------------------------------
%  Load NIFTI header extension after its header is loaded using load_nii_hdr.
%
%  Usage: ext = load_nii_ext(filename)
%
%  filename - NIFTI file name.
%
%  Returned values:
%
%  ext - Structure of NIFTI header extension, which includes num_ext,
%       and all the extended header sections in the header extension.
%       Each extended header section will have its esize, ecode, and
%       edata, where edata can be plain text, xml, or any raw data
%       that was saved in the extended header section.
%
%  NIFTI data format can be found on: http://nifti.nimh.nih.gov
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function ext = load_nii_ext(fileprefix)

   if ~exist('fileprefix','var'),
      error('Usage: ext = load_nii_ext(filename)');
   end

   machine = 'ieee-le';
   new_ext = 0;

   if findstr('.nii',fileprefix)
      new_ext = 1;
      fileprefix = strrep(fileprefix,'.nii','');
   end

   if findstr('.hdr',fileprefix)
      fileprefix = strrep(fileprefix,'.hdr','');
   end

   if findstr('.img',fileprefix)
      fileprefix = strrep(fileprefix,'.img','');
   end

   if new_ext
      fn = sprintf('%s.nii',fileprefix);

      if ~exist(fn)
         msg = sprintf('Cannot find file "%s.nii".', fileprefix);
         error(msg);
      end
   else
      fn = sprintf('%s.hdr',fileprefix);

      if ~exist(fn)
         msg = sprintf('Cannot find file "%s.hdr".', fileprefix);
         error(msg);
      end
   end

   fid = fopen(fn,'r',machine);
   vox_offset = 0;
    
   if fid < 0,
      msg = sprintf('Cannot open file %s.',fn);
      error(msg);
   else
      fseek(fid,0,'bof');

      if fread(fid,1,'int32') == 348
         if new_ext
            fseek(fid,108,'bof');
            vox_offset = fread(fid,1,'float32');
         end

         ext = read_extension1(fid, vox_offset);
         fclose(fid);
      else
         fclose(fid);

         %  first try reading the opposite endian to 'machine'
         %
         switch machine,
         case 'ieee-le', machine = 'ieee-be';
         case 'ieee-be', machine = 'ieee-le';
         end

         fid = fopen(fn,'r',machine);

         if fid < 0,
            msg = sprintf('Cannot open file %s.',fn);
            error(msg);
         else
            fseek(fid,0,'bof');

            if fread(fid,1,'int32') ~= 348

               %  Now throw an error
               %
               msg = sprintf('File "%s" is corrupted.',fn);
               error(msg);
            end

            if new_ext
               fseek(fid,108,'bof');
               vox_offset = fread(fid,1,'float32');
            end

            ext = read_extension1(fid, vox_offset);
            fclose(fid);
         end
      end
   end

end                                       % load_nii_ext
%---------------------------------------------------------------------
function ext = read_extension1(fid, vox_offset)

   ext = [];

   if vox_offset
      end_of_ext = vox_offset;
   else
      fseek(fid, 0, 'eof');
      end_of_ext = ftell(fid);
   end

   if end_of_ext > 352
      fseek(fid, 348, 'bof');
      ext.extension = fread(fid,4)';
   end

   if isempty(ext) | ext.extension(1) == 0
      ext = [];
      return;
   end

   i = 1;

   while(ftell(fid) < end_of_ext)
      ext.section(i).esize = fread(fid,1,'int32');
      ext.section(i).ecode = fread(fid,1,'int32');
      ext.section(i).edata = char(fread(fid,ext.section(i).esize-8)');
      i = i + 1;
   end

   ext.num_ext = length(ext.section);

end                                               % read_extension
%---------------------------------------------------------------------
function [img,hdr] = load_untouch_nii_img(hdr,filetype,fileprefix,machine,img_idx,dim5_idx,dim6_idx,dim7_idx,old_RGB,slice_idx)

   if ~exist('hdr','var') | ~exist('filetype','var') | ~exist('fileprefix','var') | ~exist('machine','var')
      error('Usage: [img,hdr] = load_nii_img(hdr,filetype,fileprefix,machine,[img_idx],[dim5_idx],[dim6_idx],[dim7_idx],[old_RGB],[slice_idx]);');
   end

   if ~exist('img_idx','var') | isempty(img_idx) | hdr.dime.dim(5)<1
      img_idx = [];
   end

   if ~exist('dim5_idx','var') | isempty(dim5_idx) | hdr.dime.dim(6)<1
      dim5_idx = [];
   end

   if ~exist('dim6_idx','var') | isempty(dim6_idx) | hdr.dime.dim(7)<1
      dim6_idx = [];
   end

   if ~exist('dim7_idx','var') | isempty(dim7_idx) | hdr.dime.dim(8)<1
      dim7_idx = [];
   end

   if ~exist('old_RGB','var') | isempty(old_RGB)
      old_RGB = 0;
   end

   if ~exist('slice_idx','var') | isempty(slice_idx) | hdr.dime.dim(4)<1
      slice_idx = [];
   end

   %  check img_idx
   %
   if ~isempty(img_idx) & ~isnumeric(img_idx)
      error('"img_idx" should be a numerical array.');
   end

   if length(unique(img_idx)) ~= length(img_idx)
      error('Duplicate image index in "img_idx"');
   end

   if ~isempty(img_idx) & (min(img_idx) < 1 | max(img_idx) > hdr.dime.dim(5))
      max_range = hdr.dime.dim(5);

      if max_range == 1
         error(['"img_idx" should be 1.']);
      else
         range = ['1 ' num2str(max_range)];
         error(['"img_idx" should be an integer within the range of [' range '].']);
      end
   end

   %  check dim5_idx
   %
   if ~isempty(dim5_idx) & ~isnumeric(dim5_idx)
      error('"dim5_idx" should be a numerical array.');
   end

   if length(unique(dim5_idx)) ~= length(dim5_idx)
      error('Duplicate index in "dim5_idx"');
   end

   if ~isempty(dim5_idx) & (min(dim5_idx) < 1 | max(dim5_idx) > hdr.dime.dim(6))
      max_range = hdr.dime.dim(6);

      if max_range == 1
         error(['"dim5_idx" should be 1.']);
      else
         range = ['1 ' num2str(max_range)];
         error(['"dim5_idx" should be an integer within the range of [' range '].']);
      end
   end

   %  check dim6_idx
   %
   if ~isempty(dim6_idx) & ~isnumeric(dim6_idx)
      error('"dim6_idx" should be a numerical array.');
   end

   if length(unique(dim6_idx)) ~= length(dim6_idx)
      error('Duplicate index in "dim6_idx"');
   end

   if ~isempty(dim6_idx) & (min(dim6_idx) < 1 | max(dim6_idx) > hdr.dime.dim(7))
      max_range = hdr.dime.dim(7);

      if max_range == 1
         error(['"dim6_idx" should be 1.']);
      else
         range = ['1 ' num2str(max_range)];
         error(['"dim6_idx" should be an integer within the range of [' range '].']);
      end
   end

   %  check dim7_idx
   %
   if ~isempty(dim7_idx) & ~isnumeric(dim7_idx)
      error('"dim7_idx" should be a numerical array.');
   end

   if length(unique(dim7_idx)) ~= length(dim7_idx)
      error('Duplicate index in "dim7_idx"');
   end

   if ~isempty(dim7_idx) & (min(dim7_idx) < 1 | max(dim7_idx) > hdr.dime.dim(8))
      max_range = hdr.dime.dim(8);

      if max_range == 1
         error(['"dim7_idx" should be 1.']);
      else
         range = ['1 ' num2str(max_range)];
         error(['"dim7_idx" should be an integer within the range of [' range '].']);
      end
   end

   %  check slice_idx
   %
   if ~isempty(slice_idx) & ~isnumeric(slice_idx)
      error('"slice_idx" should be a numerical array.');
   end

   if length(unique(slice_idx)) ~= length(slice_idx)
      error('Duplicate index in "slice_idx"');
   end

   if ~isempty(slice_idx) & (min(slice_idx) < 1 | max(slice_idx) > hdr.dime.dim(4))
      max_range = hdr.dime.dim(4);

      if max_range == 1
         error(['"slice_idx" should be 1.']);
      else
         range = ['1 ' num2str(max_range)];
         error(['"slice_idx" should be an integer within the range of [' range '].']);
      end
   end

   [img,hdr] = read_image1(hdr,filetype,fileprefix,machine,img_idx,dim5_idx,dim6_idx,dim7_idx,old_RGB,slice_idx);

end					% load_nii_img
%---------------------------------------------------------------------
function [img,hdr] = read_image1(hdr,filetype,fileprefix,machine,img_idx,dim5_idx,dim6_idx,dim7_idx,old_RGB,slice_idx)

   switch filetype
   case {0, 1}
      fn = [fileprefix '.img'];
   case 2
      fn = [fileprefix '.nii'];
   end

   fid = fopen(fn,'r',machine);

   if fid < 0,
      msg = sprintf('Cannot open file %s.',fn);
      error(msg);
   end

   %  Set bitpix according to datatype
   %
   %  /*Acceptable values for datatype are*/ 
   %
   %     0 None                     (Unknown bit per voxel) % DT_NONE, DT_UNKNOWN 
   %     1 Binary                         (ubit1, bitpix=1) % DT_BINARY 
   %     2 Unsigned char         (uchar or uint8, bitpix=8) % DT_UINT8, NIFTI_TYPE_UINT8 
   %     4 Signed short                  (int16, bitpix=16) % DT_INT16, NIFTI_TYPE_INT16 
   %     8 Signed integer                (int32, bitpix=32) % DT_INT32, NIFTI_TYPE_INT32 
   %    16 Floating point    (single or float32, bitpix=32) % DT_FLOAT32, NIFTI_TYPE_FLOAT32 
   %    32 Complex, 2 float32      (Use float32, bitpix=64) % DT_COMPLEX64, NIFTI_TYPE_COMPLEX64
   %    64 Double precision  (double or float64, bitpix=64) % DT_FLOAT64, NIFTI_TYPE_FLOAT64 
   %   128 uint8 RGB                 (Use uint8, bitpix=24) % DT_RGB24, NIFTI_TYPE_RGB24 
   %   256 Signed char            (schar or int8, bitpix=8) % DT_INT8, NIFTI_TYPE_INT8 
   %   511 Single RGB              (Use float32, bitpix=96) % DT_RGB96, NIFTI_TYPE_RGB96
   %   512 Unsigned short               (uint16, bitpix=16) % DT_UNINT16, NIFTI_TYPE_UNINT16 
   %   768 Unsigned integer             (uint32, bitpix=32) % DT_UNINT32, NIFTI_TYPE_UNINT32 
   %  1024 Signed long long              (int64, bitpix=64) % DT_INT64, NIFTI_TYPE_INT64
   %  1280 Unsigned long long           (uint64, bitpix=64) % DT_UINT64, NIFTI_TYPE_UINT64 
   %  1536 Long double, float128  (Unsupported, bitpix=128) % DT_FLOAT128, NIFTI_TYPE_FLOAT128 
   %  1792 Complex128, 2 float64  (Use float64, bitpix=128) % DT_COMPLEX128, NIFTI_TYPE_COMPLEX128 
   %  2048 Complex256, 2 float128 (Unsupported, bitpix=256) % DT_COMPLEX128, NIFTI_TYPE_COMPLEX128 
   %
   switch hdr.dime.datatype
   case   1,
      hdr.dime.bitpix = 1;  precision = 'ubit1';
   case   2,
      hdr.dime.bitpix = 8;  precision = 'uint8';
   case   4,
      hdr.dime.bitpix = 16; precision = 'int16';
   case   8,
      hdr.dime.bitpix = 32; precision = 'int32';
   case  16,
      hdr.dime.bitpix = 32; precision = 'float32';
   case  32,
      hdr.dime.bitpix = 64; precision = 'float32';
   case  64,
      hdr.dime.bitpix = 64; precision = 'float64';
   case 128,
      hdr.dime.bitpix = 24; precision = 'uint8';
   case 256 
      hdr.dime.bitpix = 8;  precision = 'int8';
   case 511 
      hdr.dime.bitpix = 96; precision = 'float32';
   case 512 
      hdr.dime.bitpix = 16; precision = 'uint16';
   case 768 
      hdr.dime.bitpix = 32; precision = 'uint32';
   case 1024
      hdr.dime.bitpix = 64; precision = 'int64';
   case 1280
      hdr.dime.bitpix = 64; precision = 'uint64';
   case 1792,
      hdr.dime.bitpix = 128; precision = 'float64';
   otherwise
      error('This datatype is not supported'); 
   end

   hdr.dime.dim(find(hdr.dime.dim < 1)) = 1;

   %  move pointer to the start of image block
   %
   switch filetype
   case {0, 1}
      fseek(fid, 0, 'bof');
   case 2
      fseek(fid, hdr.dime.vox_offset, 'bof');
   end

   %  Load whole image block for old Analyze format or binary image;
   %  otherwise, load images that are specified in img_idx, dim5_idx,
   %  dim6_idx, and dim7_idx
   %
   %  For binary image, we have to read all because pos can not be
   %  seeked in bit and can not be calculated the way below.
   %
   if hdr.dime.datatype == 1 | isequal(hdr.dime.dim(4:8),ones(1,5)) | ...
	(isempty(img_idx) & isempty(dim5_idx) & isempty(dim6_idx) & isempty(dim7_idx) & isempty(slice_idx))

      %  For each frame, precision of value will be read 
      %  in img_siz times, where img_siz is only the 
      %  dimension size of an image, not the byte storage
      %  size of an image.
      %
      img_siz = prod(hdr.dime.dim(2:8));

      %  For complex float32 or complex float64, voxel values
      %  include [real, imag]
      %
      if hdr.dime.datatype == 32 | hdr.dime.datatype == 1792
         img_siz = img_siz * 2;
      end
	 
      %MPH: For RGB24, voxel values include 3 separate color planes
      %
      if hdr.dime.datatype == 128 | hdr.dime.datatype == 511
	 img_siz = img_siz * 3;
      end

      img = fread(fid, img_siz, sprintf('*%s',precision));

      d1 = hdr.dime.dim(2);
      d2 = hdr.dime.dim(3);
      d3 = hdr.dime.dim(4);
      d4 = hdr.dime.dim(5);
      d5 = hdr.dime.dim(6);
      d6 = hdr.dime.dim(7);
      d7 = hdr.dime.dim(8);

      if isempty(slice_idx)
         slice_idx = 1:d3;
      end

      if isempty(img_idx)
         img_idx = 1:d4;
      end

      if isempty(dim5_idx)
         dim5_idx = 1:d5;
      end

      if isempty(dim6_idx)
         dim6_idx = 1:d6;
      end

      if isempty(dim7_idx)
         dim7_idx = 1:d7;
      end
   else

      img = [];

      d1 = hdr.dime.dim(2);
      d2 = hdr.dime.dim(3);
      d3 = hdr.dime.dim(4);
      d4 = hdr.dime.dim(5);
      d5 = hdr.dime.dim(6);
      d6 = hdr.dime.dim(7);
      d7 = hdr.dime.dim(8);

      if isempty(slice_idx)
         slice_idx = 1:d3;
      end

      if isempty(img_idx)
         img_idx = 1:d4;
      end

      if isempty(dim5_idx)
         dim5_idx = 1:d5;
      end

      if isempty(dim6_idx)
         dim6_idx = 1:d6;
      end

      if isempty(dim7_idx)
         dim7_idx = 1:d7;
      end

      for i7=1:length(dim7_idx)
         for i6=1:length(dim6_idx)
            for i5=1:length(dim5_idx)
               for t=1:length(img_idx)
               for s=1:length(slice_idx)

                  %  Position is seeked in bytes. To convert dimension size
                  %  to byte storage size, hdr.dime.bitpix/8 will be
                  %  applied.
                  %
                  pos = sub2ind([d1 d2 d3 d4 d5 d6 d7], 1, 1, slice_idx(s), ...
			img_idx(t), dim5_idx(i5),dim6_idx(i6),dim7_idx(i7)) -1;
                  pos = pos * hdr.dime.bitpix/8;

                  img_siz = prod(hdr.dime.dim(2:3));

                  %  For complex float32 or complex float64, voxel values
                  %  include [real, imag]
                  %
                  if hdr.dime.datatype == 32 | hdr.dime.datatype == 1792
                     img_siz = img_siz * 2;
                  end

                  %MPH: For RGB24, voxel values include 3 separate color planes
                  %
                  if hdr.dime.datatype == 128 | hdr.dime.datatype == 511
	             img_siz = img_siz * 3;
                  end
         
                  if filetype == 2
                     fseek(fid, pos + hdr.dime.vox_offset, 'bof');
                  else
                     fseek(fid, pos, 'bof');
                  end

                  %  For each frame, fread will read precision of value
                  %  in img_siz times
                  %
                  img = [img fread(fid, img_siz, sprintf('*%s',precision))];
               end
               end
            end
         end
      end
   end

   %  For complex float32 or complex float64, voxel values
   %  include [real, imag]
   %
   if hdr.dime.datatype == 32 | hdr.dime.datatype == 1792
      img = reshape(img, [2, length(img)/2]);
      img = complex(img(1,:)', img(2,:)');
   end

   fclose(fid);

   %  Update the global min and max values 
   %
   hdr.dime.glmax = max(double(img(:)));
   hdr.dime.glmin = min(double(img(:)));

   %  old_RGB treat RGB slice by slice, now it is treated voxel by voxel
   %
   if old_RGB & hdr.dime.datatype == 128 & hdr.dime.bitpix == 24
      % remove squeeze
      img = (reshape(img, [hdr.dime.dim(2:3) 3 length(slice_idx) length(img_idx) length(dim5_idx) length(dim6_idx) length(dim7_idx)]));
      img = permute(img, [1 2 4 3 5 6 7 8]);
   elseif hdr.dime.datatype == 128 & hdr.dime.bitpix == 24
      % remove squeeze
      img = (reshape(img, [3 hdr.dime.dim(2:3) length(slice_idx) length(img_idx) length(dim5_idx) length(dim6_idx) length(dim7_idx)]));
      img = permute(img, [2 3 4 1 5 6 7 8]);
   elseif hdr.dime.datatype == 511 & hdr.dime.bitpix == 96
      img = double(img(:));
      img = (img - min(img))/(max(img) - min(img));
      % remove squeeze
      img = (reshape(img, [3 hdr.dime.dim(2:3) length(slice_idx) length(img_idx) length(dim5_idx) length(dim6_idx) length(dim7_idx)]));
      img = permute(img, [2 3 4 1 5 6 7 8]);
   else
      % remove squeeze
      img = (reshape(img, [hdr.dime.dim(2:3) length(slice_idx) length(img_idx) length(dim5_idx) length(dim6_idx) length(dim7_idx)]));
   end

   if ~isempty(slice_idx)
      hdr.dime.dim(4) = length(slice_idx);
   end

   if ~isempty(img_idx)
      hdr.dime.dim(5) = length(img_idx);
   end

   if ~isempty(dim5_idx)
      hdr.dime.dim(6) = length(dim5_idx);
   end

   if ~isempty(dim6_idx)
      hdr.dime.dim(7) = length(dim6_idx);
   end

   if ~isempty(dim7_idx)
      hdr.dime.dim(8) = length(dim7_idx);
   end

end						% read_image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------------------------------------------------


% a subfunction called save_untouch_nii
%-----------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Save NIFTI or ANALYZE dataset that is loaded by "load_untouch_nii.m".
%  The output image format and file extension will be the same as the
%  input one (NIFTI.nii, NIFTI.img or ANALYZE.img). Therefore, any file
%  extension that you specified will be ignored.
%
%  Usage: save_untouch_nii(nii, filename)
%  
%  nii - nii structure that is loaded by "load_untouch_nii.m"
%
%  filename  - 	NIFTI or ANALYZE file name.
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function save_untouch_nii(nii, filename)
   
   if ~exist('nii','var') | isempty(nii) | ~isfield(nii,'hdr') | ...
	~isfield(nii,'img') | ~exist('filename','var') | isempty(filename)

      error('Usage: save_untouch_nii(nii, filename)');
   end

   if ~isfield(nii,'untouch') | nii.untouch == 0
      error('Usage: please use ''save_nii.m'' for the modified structure.');
   end

   if isfield(nii.hdr.hist,'magic') & strcmp(nii.hdr.hist.magic(1:3),'ni1')
      filetype = 1;
   elseif isfield(nii.hdr.hist,'magic') & strcmp(nii.hdr.hist.magic(1:3),'n+1')
      filetype = 2;
   else
      filetype = 0;
   end

   [p,f] = fileparts(filename);
   fileprefix = fullfile(p, f);

   write_nii1(nii, filetype, fileprefix);

%   %  So earlier versions of SPM can also open it with correct originator
 %  %
  % if filetype == 0
   %   M=[[diag(nii.hdr.dime.pixdim(2:4)) -[nii.hdr.hist.originator(1:3).*nii.hdr.dime.pixdim(2:4)]'];[0 0 0 1]];
    %  save(fileprefix, 'M');
%   elseif filetype == 1
 %     M=[];
  %    save(fileprefix, 'M');
   %end
   
end					% save_untouch_nii
%---------------------------------------------------------------------
function write_nii1(nii, filetype, fileprefix)

   hdr = nii.hdr;

   if isfield(nii,'ext') & ~isempty(nii.ext)
      ext = nii.ext;
      [ext, esize_total] = verify_nii_ext(ext);
   else
      ext = [];
   end

   switch double(hdr.dime.datatype),
   case   1,
      hdr.dime.bitpix = int16(1 ); precision = 'ubit1';
   case   2,
      hdr.dime.bitpix = int16(8 ); precision = 'uint8';
   case   4,
      hdr.dime.bitpix = int16(16); precision = 'int16';
   case   8,
      hdr.dime.bitpix = int16(32); precision = 'int32';
   case  16,
      hdr.dime.bitpix = int16(32); precision = 'float32';
   case  32,
      hdr.dime.bitpix = int16(64); precision = 'float32';
   case  64,
      hdr.dime.bitpix = int16(64); precision = 'float64';
   case 128,
      hdr.dime.bitpix = int16(24); precision = 'uint8';
   case 256 
      hdr.dime.bitpix = int16(8 ); precision = 'int8';
   case 512 
      hdr.dime.bitpix = int16(16); precision = 'uint16';
   case 768 
      hdr.dime.bitpix = int16(32); precision = 'uint32';
   case 1024
      hdr.dime.bitpix = int16(64); precision = 'int64';
   case 1280
      hdr.dime.bitpix = int16(64); precision = 'uint64';
   case 1792,
      hdr.dime.bitpix = int16(128); precision = 'float64';
   otherwise
      error('This datatype is not supported');
   end
   
%   hdr.dime.glmax = round(double(max(nii.img(:))));
 %  hdr.dime.glmin = round(double(min(nii.img(:))));
   
   if filetype == 2
      fid = fopen(sprintf('%s.nii',fileprefix),'w');
      
      if fid < 0,
         msg = sprintf('Cannot open file %s.nii.',fileprefix);
         error(msg);
      end
      
      hdr.dime.vox_offset = 352;

      if ~isempty(ext)
         hdr.dime.vox_offset = hdr.dime.vox_offset + esize_total;
      end

      hdr.hist.magic = 'n+1';
      save_untouch_nii_hdr(hdr, fid);

      if ~isempty(ext)
         save_nii_ext(ext, fid);
      end
   elseif filetype == 1
      fid = fopen(sprintf('%s.hdr',fileprefix),'w');
      
      if fid < 0,
         msg = sprintf('Cannot open file %s.hdr.',fileprefix);
         error(msg);
      end
      
      hdr.dime.vox_offset = 0;
      hdr.hist.magic = 'ni1';
      save_untouch_nii_hdr(hdr, fid);

      if ~isempty(ext)
         save_nii_ext(ext, fid);
      end
      
      fclose(fid);
      fid = fopen(sprintf('%s.img',fileprefix),'w');
   else
      fid = fopen(sprintf('%s.hdr',fileprefix),'w');
      
      if fid < 0,
         msg = sprintf('Cannot open file %s.hdr.',fileprefix);
         error(msg);
      end
      
      save_untouch0_nii_hdr(hdr, fid);
      
      fclose(fid);
      fid = fopen(sprintf('%s.img',fileprefix),'w');
   end

   ScanDim = double(hdr.dime.dim(5));		% t
   SliceDim = double(hdr.dime.dim(4));		% z
   RowDim   = double(hdr.dime.dim(3));		% y
   PixelDim = double(hdr.dime.dim(2));		% x
   SliceSz  = double(hdr.dime.pixdim(4));
   RowSz    = double(hdr.dime.pixdim(3));
   PixelSz  = double(hdr.dime.pixdim(2));
   
   x = 1:PixelDim;
   
   if filetype == 2 & isempty(ext)
      skip_bytes = double(hdr.dime.vox_offset) - 348;
   else
      skip_bytes = 0;
   end

   if double(hdr.dime.datatype) == 128

      %  RGB planes are expected to be in the 4th dimension of nii.img
      %
      if(size(nii.img,4)~=3)
         error(['The NII structure does not appear to have 3 RGB color planes in the 4th dimension']);
      end

      nii.img = permute(nii.img, [4 1 2 3 5 6 7 8]);
   end

   %  For complex float32 or complex float64, voxel values
   %  include [real, imag]
   %
   if hdr.dime.datatype == 32 | hdr.dime.datatype == 1792
      real_img = real(nii.img(:))';
      nii.img = imag(nii.img(:))';
      nii.img = [real_img; nii.img];
   end

   if skip_bytes
      fwrite(fid, ones(1,skip_bytes), 'uint8');
   end

   fwrite(fid, nii.img, precision);
%   fwrite(fid, nii.img, precision, skip_bytes);        % error using skip
   fclose(fid);

end					% write_nii
%---------------------------------------------------------------------
%  Verify NIFTI header extension to make sure that each extension section
%  must be an integer multiple of 16 byte long that includes the first 8
%  bytes of esize and ecode. If the length of extension section is not the
%  above mentioned case, edata should be padded with all 0.
%
%  Usage: [ext, esize_total] = verify_nii_ext(ext)
%
%  ext - Structure of NIFTI header extension, which includes num_ext,
%       and all the extended header sections in the header extension.
%       Each extended header section will have its esize, ecode, and
%       edata, where edata can be plain text, xml, or any raw data
%       that was saved in the extended header section.
%
%  esize_total - Sum of all esize variable in all header sections.
%
%  NIFTI data format can be found on: http://nifti.nimh.nih.gov
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function [ext, esize_total] = verify_nii_ext(ext)

   if ~isfield(ext, 'section')
      error('Incorrect NIFTI header extension structure.');
   elseif ~isfield(ext, 'num_ext')
      ext.num_ext = length(ext.section);
   elseif ~isfield(ext, 'extension')
      ext.extension = [1 0 0 0];
   end

   esize_total = 0;

   for i=1:ext.num_ext
      if ~isfield(ext.section(i), 'ecode') | ~isfield(ext.section(i), 'edata')
         error('Incorrect NIFTI header extension structure.');
      end

      ext.section(i).esize = ceil((length(ext.section(i).edata)+8)/16)*16;
      ext.section(i).edata = ...
	[ext.section(i).edata ...
	 zeros(1,ext.section(i).esize-length(ext.section(i).edata)-8)];
      esize_total = esize_total + ext.section(i).esize;
   end

end                                       % verify_nii_ext
%---------------------------------------------------------------------
function save_untouch_nii_hdr(hdr, fid)

   if ~isequal(hdr.hk.sizeof_hdr,348),
      error('hdr.hk.sizeof_hdr must be 348.');
   end

   write_header6(hdr, fid);

end					% save_nii_hdr
%---------------------------------------------------------------------
function write_header6(hdr, fid)

        %  Original header structures
	%  struct dsr				/* dsr = hdr */
	%       { 
	%       struct header_key hk;            /*   0 +  40       */
	%       struct image_dimension dime;     /*  40 + 108       */
	%       struct data_history hist;        /* 148 + 200       */
	%       };                               /* total= 348 bytes*/
   
   header_key6(fid, hdr.hk);
   image_dimension6(fid, hdr.dime);
   data_history6(fid, hdr.hist);
   
   %  check the file size is 348 bytes
   %
   fbytes = ftell(fid);
   
   if ~isequal(fbytes,348),
      msg = sprintf('Header size is not 348 bytes.');
      warning(msg);
   end
    
end					% write_header
%---------------------------------------------------------------------
function header_key6(fid, hk)
   
   fseek(fid,0,'bof');

	%  Original header structures    
	%  struct header_key                      /* header key      */ 
	%       {                                /* off + size      */
	%       int sizeof_hdr                   /*  0 +  4         */
	%       char data_type[10];              /*  4 + 10         */
	%       char db_name[18];                /* 14 + 18         */
	%       int extents;                     /* 32 +  4         */
	%       short int session_error;         /* 36 +  2         */
	%       char regular;                    /* 38 +  1         */
	%       char dim_info;   % char hkey_un0;        /* 39 +  1 */
	%       };                               /* total=40 bytes  */
        
   fwrite(fid, hk.sizeof_hdr(1),    'int32');	% must be 348.
    
   % data_type = sprintf('%-10s',hk.data_type);	% ensure it is 10 chars from left
   % fwrite(fid, data_type(1:10), 'uchar');
   pad = zeros(1, 10-length(hk.data_type));
   hk.data_type = [hk.data_type  char(pad)];
   fwrite(fid, hk.data_type(1:10), 'uchar');
    
   % db_name   = sprintf('%-18s', hk.db_name);	% ensure it is 18 chars from left
   % fwrite(fid, db_name(1:18), 'uchar');
   pad = zeros(1, 18-length(hk.db_name));
   hk.db_name = [hk.db_name  char(pad)];
   fwrite(fid, hk.db_name(1:18), 'uchar');
    
   fwrite(fid, hk.extents(1),       'int32');
   fwrite(fid, hk.session_error(1), 'int16');
   fwrite(fid, hk.regular(1),       'uchar');	% might be uint8
    
   % fwrite(fid, hk.hkey_un0(1),    'uchar');
   % fwrite(fid, hk.hkey_un0(1),    'uint8');
   fwrite(fid, hk.dim_info(1),      'uchar');
    
end					% header_key
%---------------------------------------------------------------------
function image_dimension6(fid, dime)

	%  Original header structures        
	%  struct image_dimension
	%       {                                /* off + size      */
	%       short int dim[8];                /* 0 + 16          */
	%       float intent_p1;   % char vox_units[4];   /* 16 + 4       */
	%       float intent_p2;   % char cal_units[8];   /* 20 + 4       */
	%       float intent_p3;   % char cal_units[8];   /* 24 + 4       */
	%       short int intent_code;   % short int unused1;   /* 28 + 2 */
	%       short int datatype;              /* 30 + 2          */
	%       short int bitpix;                /* 32 + 2          */
	%       short int slice_start;   % short int dim_un0;   /* 34 + 2 */
	%       float pixdim[8];                 /* 36 + 32         */
	%			/*
	%				pixdim[] specifies the voxel dimensions:
	%				pixdim[1] - voxel width
	%				pixdim[2] - voxel height
	%				pixdim[3] - interslice distance
	%				pixdim[4] - volume timing, in msec
	%					..etc
	%			*/
	%       float vox_offset;                /* 68 + 4          */
	%       float scl_slope;   % float roi_scale;     /* 72 + 4 */
	%       float scl_inter;   % float funused1;      /* 76 + 4 */
	%       short slice_end;   % float funused2;      /* 80 + 2 */
	%       char slice_code;   % float funused2;      /* 82 + 1 */
	%       char xyzt_units;   % float funused2;      /* 83 + 1 */
	%       float cal_max;                   /* 84 + 4          */
	%       float cal_min;                   /* 88 + 4          */
	%       float slice_duration;   % int compressed; /* 92 + 4 */
	%       float toffset;   % int verified;          /* 96 + 4 */
	%       int glmax;                       /* 100 + 4         */
	%       int glmin;                       /* 104 + 4         */
	%       };                               /* total=108 bytes */
	
   fwrite(fid, dime.dim(1:8),        'int16');
   fwrite(fid, dime.intent_p1(1),  'float32');
   fwrite(fid, dime.intent_p2(1),  'float32');
   fwrite(fid, dime.intent_p3(1),  'float32');
   fwrite(fid, dime.intent_code(1),  'int16');
   fwrite(fid, dime.datatype(1),     'int16');
   fwrite(fid, dime.bitpix(1),       'int16');
   fwrite(fid, dime.slice_start(1),  'int16');
   fwrite(fid, dime.pixdim(1:8),   'float32');
   fwrite(fid, dime.vox_offset(1), 'float32');
   fwrite(fid, dime.scl_slope(1),  'float32');
   fwrite(fid, dime.scl_inter(1),  'float32');
   fwrite(fid, dime.slice_end(1),    'int16');
   fwrite(fid, dime.slice_code(1),   'uchar');
   fwrite(fid, dime.xyzt_units(1),   'uchar');
   fwrite(fid, dime.cal_max(1),    'float32');
   fwrite(fid, dime.cal_min(1),    'float32');
   fwrite(fid, dime.slice_duration(1), 'float32');
   fwrite(fid, dime.toffset(1),    'float32');
   fwrite(fid, dime.glmax(1),        'int32');
   fwrite(fid, dime.glmin(1),        'int32');
   
end					% image_dimension
%---------------------------------------------------------------------
function data_history6(fid, hist)
    
	% Original header structures
	%struct data_history       
	%       {                                /* off + size      */
	%       char descrip[80];                /* 0 + 80          */
	%       char aux_file[24];               /* 80 + 24         */
	%       short int qform_code;            /* 104 + 2         */
	%       short int sform_code;            /* 106 + 2         */
	%       float quatern_b;                 /* 108 + 4         */
	%       float quatern_c;                 /* 112 + 4         */
	%       float quatern_d;                 /* 116 + 4         */
	%       float qoffset_x;                 /* 120 + 4         */
	%       float qoffset_y;                 /* 124 + 4         */
	%       float qoffset_z;                 /* 128 + 4         */
	%       float srow_x[4];                 /* 132 + 16        */
	%       float srow_y[4];                 /* 148 + 16        */
	%       float srow_z[4];                 /* 164 + 16        */
	%       char intent_name[16];            /* 180 + 16        */
	%       char magic[4];   % int smin;     /* 196 + 4         */
	%       };                               /* total=200 bytes */
	
   % descrip     = sprintf('%-80s', hist.descrip);     % 80 chars from left
   % fwrite(fid, descrip(1:80),    'uchar');
   pad = zeros(1, 80-length(hist.descrip));
   hist.descrip = [hist.descrip  char(pad)];
   fwrite(fid, hist.descrip(1:80), 'uchar');
    
   % aux_file    = sprintf('%-24s', hist.aux_file);    % 24 chars from left
   % fwrite(fid, aux_file(1:24),   'uchar');
   pad = zeros(1, 24-length(hist.aux_file));
   hist.aux_file = [hist.aux_file  char(pad)];
   fwrite(fid, hist.aux_file(1:24), 'uchar');
    
   fwrite(fid, hist.qform_code,    'int16');
   fwrite(fid, hist.sform_code,    'int16');
   fwrite(fid, hist.quatern_b,   'float32');
   fwrite(fid, hist.quatern_c,   'float32');
   fwrite(fid, hist.quatern_d,   'float32');
   fwrite(fid, hist.qoffset_x,   'float32');
   fwrite(fid, hist.qoffset_y,   'float32');
   fwrite(fid, hist.qoffset_z,   'float32');
   fwrite(fid, hist.srow_x(1:4), 'float32');
   fwrite(fid, hist.srow_y(1:4), 'float32');
   fwrite(fid, hist.srow_z(1:4), 'float32');

   % intent_name = sprintf('%-16s', hist.intent_name);	% 16 chars from left
   % fwrite(fid, intent_name(1:16),    'uchar');
   pad = zeros(1, 16-length(hist.intent_name));
   hist.intent_name = [hist.intent_name  char(pad)];
   fwrite(fid, hist.intent_name(1:16), 'uchar');
    
   % magic	= sprintf('%-4s', hist.magic);		% 4 chars from left
   % fwrite(fid, magic(1:4),           'uchar');
   pad = zeros(1, 4-length(hist.magic));
   hist.magic = [hist.magic  char(pad)];
   fwrite(fid, hist.magic(1:4),        'uchar');
    
end					% data_history
%---------------------------------------------------------------------
%  Save NIFTI header extension.
%
%  Usage: save_nii_ext(ext, fid)
%
%  ext - struct with NIFTI header extension fields.
%
%  NIFTI data format can be found on: http://nifti.nimh.nih.gov
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function save_nii_ext(ext, fid)

   if ~exist('ext','var') | ~exist('fid','var')
      error('Usage: save_nii_ext(ext, fid)');
   end

   if ~isfield(ext,'extension') | ~isfield(ext,'section') | ~isfield(ext,'num_ext')
      error('Wrong header extension');
   end

   write_ext6(ext, fid);

end                                      % save_nii_ext
%---------------------------------------------------------------------
function write_ext6(ext, fid)

   fwrite(fid, ext.extension, 'uchar');

   for i=1:ext.num_ext
      fwrite(fid, ext.section(i).esize, 'int32');
      fwrite(fid, ext.section(i).ecode, 'int32');
      fwrite(fid, ext.section(i).edata, 'uchar');
   end

end                                      % write_ext
%---------------------------------------------------------------------
function save_untouch0_nii_hdr(hdr, fid)

   if ~isequal(hdr.hk.sizeof_hdr,348),
      error('hdr.hk.sizeof_hdr must be 348.');
   end

   write_header7(hdr, fid);

end					% save_nii_hdr
%---------------------------------------------------------------------
function write_header7(hdr, fid)

        %  Original header structures
	%  struct dsr				/* dsr = hdr */
	%       { 
	%       struct header_key hk;            /*   0 +  40       */
	%       struct image_dimension dime;     /*  40 + 108       */
	%       struct data_history hist;        /* 148 + 200       */
	%       };                               /* total= 348 bytes*/
   
   header_key7(fid, hdr.hk);
   image_dimension7(fid, hdr.dime);
   data_history7(fid, hdr.hist);
   
   %  check the file size is 348 bytes
   %
   fbytes = ftell(fid);
   
   if ~isequal(fbytes,348),
      msg = sprintf('Header size is not 348 bytes.');
      warning(msg);
   end
    
end					% write_header
%---------------------------------------------------------------------
function header_key7(fid, hk)
   
   fseek(fid,0,'bof');

	%  Original header structures    
	%  struct header_key                      /* header key      */ 
	%       {                                /* off + size      */
	%       int sizeof_hdr                   /*  0 +  4         */
	%       char data_type[10];              /*  4 + 10         */
	%       char db_name[18];                /* 14 + 18         */
	%       int extents;                     /* 32 +  4         */
	%       short int session_error;         /* 36 +  2         */
	%       char regular;                    /* 38 +  1         */
	%       char hkey_un0;                   /* 39 +  1 */
	%       };                               /* total=40 bytes  */
        
   fwrite(fid, hk.sizeof_hdr(1),    'int32');	% must be 348.
    
   % data_type = sprintf('%-10s',hk.data_type);	% ensure it is 10 chars from left
   % fwrite(fid, data_type(1:10), 'uchar');
   pad = zeros(1, 10-length(hk.data_type));
   hk.data_type = [hk.data_type  char(pad)];
   fwrite(fid, hk.data_type(1:10), 'uchar');
    
   % db_name   = sprintf('%-18s', hk.db_name);	% ensure it is 18 chars from left
   % fwrite(fid, db_name(1:18), 'uchar');
   pad = zeros(1, 18-length(hk.db_name));
   hk.db_name = [hk.db_name  char(pad)];
   fwrite(fid, hk.db_name(1:18), 'uchar');

   fwrite(fid, hk.extents(1),       'int32');
   fwrite(fid, hk.session_error(1), 'int16');
   fwrite(fid, hk.regular(1),       'uchar');

   fwrite(fid, hk.hkey_un0(1),    'uchar');
    
end					% header_key
%---------------------------------------------------------------------
function image_dimension7(fid, dime)

	%struct image_dimension
	%       {                                /* off + size      */
	%       short int dim[8];                /* 0 + 16          */
	%       char vox_units[4];               /* 16 + 4          */
	%       char cal_units[8];               /* 20 + 8          */
	%       short int unused1;               /* 28 + 2          */
	%       short int datatype;              /* 30 + 2          */
	%       short int bitpix;                /* 32 + 2          */
	%       short int dim_un0;               /* 34 + 2          */
	%       float pixdim[8];                 /* 36 + 32         */
	%			/*
	%				pixdim[] specifies the voxel dimensions:
	%				pixdim[1] - voxel width
	%				pixdim[2] - voxel height
	%				pixdim[3] - interslice distance
	%					..etc
	%			*/
	%       float vox_offset;                /* 68 + 4          */
	%       float roi_scale;                 /* 72 + 4          */
	%       float funused1;                  /* 76 + 4          */
	%       float funused2;                  /* 80 + 4          */
	%       float cal_max;                   /* 84 + 4          */
	%       float cal_min;                   /* 88 + 4          */
	%       int compressed;                  /* 92 + 4          */
	%       int verified;                    /* 96 + 4          */
	%       int glmax;                       /* 100 + 4         */
	%       int glmin;                       /* 104 + 4         */
	%       };                               /* total=108 bytes */
	
   fwrite(fid, dime.dim(1:8),      'int16');

   pad = zeros(1, 4-length(dime.vox_units));
   dime.vox_units = [dime.vox_units  char(pad)];
   fwrite(fid, dime.vox_units(1:4),  'uchar');

   pad = zeros(1, 8-length(dime.cal_units));
   dime.cal_units = [dime.cal_units  char(pad)];
   fwrite(fid, dime.cal_units(1:8),  'uchar');

   fwrite(fid, dime.unused1(1),    'int16');
   fwrite(fid, dime.datatype(1),   'int16');
   fwrite(fid, dime.bitpix(1),     'int16');
   fwrite(fid, dime.dim_un0(1),    'int16');
   fwrite(fid, dime.pixdim(1:8),   'float32');
   fwrite(fid, dime.vox_offset(1), 'float32');
   fwrite(fid, dime.roi_scale(1),  'float32');
   fwrite(fid, dime.funused1(1),   'float32');
   fwrite(fid, dime.funused2(1),   'float32');
   fwrite(fid, dime.cal_max(1),    'float32');
   fwrite(fid, dime.cal_min(1),    'float32');
   fwrite(fid, dime.compressed(1), 'int32');
   fwrite(fid, dime.verified(1),   'int32');
   fwrite(fid, dime.glmax(1),      'int32');
   fwrite(fid, dime.glmin(1),      'int32');
   
end					% image_dimension
%---------------------------------------------------------------------
function data_history7(fid, hist)
    
	% Original header structures - ANALYZE 7.5
	%struct data_history       
	%       {                                /* off + size      */
	%       char descrip[80];                /* 0 + 80          */
	%       char aux_file[24];               /* 80 + 24         */
	%       char orient;                     /* 104 + 1         */
	%       char originator[10];             /* 105 + 10        */
	%       char generated[10];              /* 115 + 10        */
	%       char scannum[10];                /* 125 + 10        */
	%       char patient_id[10];             /* 135 + 10        */
	%       char exp_date[10];               /* 145 + 10        */
	%       char exp_time[10];               /* 155 + 10        */
	%       char hist_un0[3];                /* 165 + 3         */
	%       int views                        /* 168 + 4         */
	%       int vols_added;                  /* 172 + 4         */
	%       int start_field;                 /* 176 + 4         */
	%       int field_skip;                  /* 180 + 4         */
	%       int omax;                        /* 184 + 4         */
	%       int omin;                        /* 188 + 4         */
	%       int smax;                        /* 192 + 4         */
	%       int smin;                        /* 196 + 4         */
	%       };                               /* total=200 bytes */
	
   % descrip     = sprintf('%-80s', hist.descrip);     % 80 chars from left
   % fwrite(fid, descrip(1:80),    'uchar');
   pad = zeros(1, 80-length(hist.descrip));
   hist.descrip = [hist.descrip  char(pad)];
   fwrite(fid, hist.descrip(1:80), 'uchar');
    
   % aux_file    = sprintf('%-24s', hist.aux_file);    % 24 chars from left
   % fwrite(fid, aux_file(1:24),   'uchar');
   pad = zeros(1, 24-length(hist.aux_file));
   hist.aux_file = [hist.aux_file  char(pad)];
   fwrite(fid, hist.aux_file(1:24), 'uchar');

   fwrite(fid, hist.orient(1),      'uchar');
   fwrite(fid, hist.originator(1:5), 'int16');

   pad = zeros(1, 10-length(hist.generated));
   hist.generated = [hist.generated  char(pad)];
   fwrite(fid, hist.generated(1:10),  'uchar');

   pad = zeros(1, 10-length(hist.scannum));
   hist.scannum = [hist.scannum  char(pad)];
   fwrite(fid, hist.scannum(1:10),  'uchar');

   pad = zeros(1, 10-length(hist.patient_id));
   hist.patient_id = [hist.patient_id  char(pad)];
   fwrite(fid, hist.patient_id(1:10),  'uchar');

   pad = zeros(1, 10-length(hist.exp_date));
   hist.exp_date = [hist.exp_date  char(pad)];
   fwrite(fid, hist.exp_date(1:10),  'uchar');

   pad = zeros(1, 10-length(hist.exp_time));
   hist.exp_time = [hist.exp_time  char(pad)];
   fwrite(fid, hist.exp_time(1:10),  'uchar');

   pad = zeros(1, 3-length(hist.hist_un0));
   hist.hist_un0 = [hist.hist_un0  char(pad)];
   fwrite(fid, hist.hist_un0(1:3),  'uchar');

   fwrite(fid, hist.views(1),      'int32');
   fwrite(fid, hist.vols_added(1), 'int32');
   fwrite(fid, hist.start_field(1),'int32');
   fwrite(fid, hist.field_skip(1), 'int32');
   fwrite(fid, hist.omax(1),       'int32');
   fwrite(fid, hist.omin(1),       'int32');
   fwrite(fid, hist.smax(1),       'int32');
   fwrite(fid, hist.smin(1),       'int32');
    
end					% data_history
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------------------------------------------------


