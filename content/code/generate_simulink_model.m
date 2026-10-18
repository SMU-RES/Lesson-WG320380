function out = generate_simulink_model(p, model, simulinkDir)
%GENERATE_SIMULINK_MODEL Build basic PID-Nomoto Simulink model if available.
ensure_dir(simulinkDir);
out = struct('created',false,'model_name','nomoto_pid_heading','slx_path','');

hasSimulink = license('test','Simulink') && (exist('new_system','builtin') > 0 || exist('new_system','file') > 0);
if ~hasSimulink
    return;
end

mdl = out.model_name;
if bdIsLoaded(mdl)
    close_system(mdl, 0);
end

new_system(mdl);
open_system(mdl);

add_block('simulink/Sources/Step', [mdl '/Step'], 'Position',[30 60 60 90], 'Time','0', 'Before','0', 'After','0.2618');
add_block('simulink/Math Operations/Sum', [mdl '/Sum'], 'Position',[110 60 130 90], 'Inputs','+-');
add_block('simulink/Continuous/PID Controller', [mdl '/PID'], 'Position',[170 50 250 100], ...
    'P','6','I','0.08','D','30');
add_block('simulink/Discontinuities/Saturation', [mdl '/Saturation'], 'Position',[290 55 330 95], ...
    'UpperLimit',num2str(p.delta_max), 'LowerLimit',num2str(-p.delta_max));
add_block('simulink/Continuous/Transfer Fcn', [mdl '/Nomoto'], 'Position',[370 50 470 100], ...
    'Numerator',mat2str([p.K]), 'Denominator',mat2str([p.T 1 0]));
add_block('simulink/Sinks/Scope', [mdl '/Scope'], 'Position',[520 45 550 75]);
add_block('simulink/Sinks/To Workspace', [mdl '/ToWorkspace'], 'Position',[520 90 620 120], ...
    'VariableName','psi_sim','SaveFormat','StructureWithTime');

add_line(mdl,'Step/1','Sum/1');
add_line(mdl,'Sum/1','PID/1');
add_line(mdl,'PID/1','Saturation/1');
add_line(mdl,'Saturation/1','Nomoto/1');
add_line(mdl,'Nomoto/1','Scope/1');
add_line(mdl,'Nomoto/1','ToWorkspace/1');
add_line(mdl,'Nomoto/1','Sum/2');

set_param(mdl, 'StopTime', '400');

slxPath = fullfile(simulinkDir, [mdl, '.slx']);
save_system(mdl, slxPath);
close_system(mdl, 0);

out.created = true;
out.slx_path = slxPath;
end
