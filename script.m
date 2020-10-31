%   Parker Johnson
%   Jonathan Roth
%   2020-08-11

% a useful script for running the project on all of the source images

function script()
var = ls('images/SCAN*');

for index = 1:length(var)
    path = var(index,:);
    input_path = append('images/',path);
    output_path = append('images_rectangle/',path);
    project(input_path, output_path);
end
