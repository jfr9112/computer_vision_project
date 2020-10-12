function script()
var = ls('images/SCAN*');

for index = 1:length(var)
    path = var(index,:);
    input_path = append('images/',path);
    output_path = append('images_rectangle/',path);
    project(input_path, output_path);
end
