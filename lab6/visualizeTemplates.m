function visualizeTemplates(templates)

keys = templates.keys;

figure('Name','All Templates');
tiledlayout(length(keys), 9, 'Padding','compact');

for i = 1:length(keys)
    
    key = keys{i};
    templateList = templates(key);
    
    for j = 1:length(templateList)
        
        idx = (i-1)*9 + j;
        
        nexttile(idx);
        imshow(templateList{j});
        
        if j == 1
            title(key);
        end
        
    end
end

end