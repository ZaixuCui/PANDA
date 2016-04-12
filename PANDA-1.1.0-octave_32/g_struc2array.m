function field_array  = g_struc2array( Graph_struc, field_cell )

[subject_num,threhold_interval] = size(Graph_struc);

field_num = length(field_cell);

if subject_num >= 1 && threhold_interval >= 1
    for i = 1:subject_num
        for j = 1:threhold_interval
            if field_num == 1
                field_array(i,j,:) = Graph_struc(i,j).(field_cell{1});
            end
            if field_num == 2
                field_array(i,j,:) = Graph_struc(i,j).(field_cell{1}).(field_cell{2});
            end
            if field_num == 3
                field_array(i,j,:) = Graph_struc(i,j).(field_cell{1}).(field_cell{2}).(field_cell{3});
            end  
        end
    end
else
    field_array = '';
end