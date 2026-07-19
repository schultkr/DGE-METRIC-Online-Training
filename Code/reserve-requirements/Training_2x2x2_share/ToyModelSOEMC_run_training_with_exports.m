% ToyModelSOEMC_run_training_with_exports.m
% Run training configuration, capture console log, and export all figures.

clc; close all;

this_folder = fileparts(mfilename('fullpath'));
addpath(this_folder);
cd(this_folder);

% Create timestamped output directory for reproducible artifacts.
ts = datestr(now, 'yyyymmdd_HHMMSS');
out_dir = fullfile(this_folder, 'Presentation', 'run_outputs', ts);
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

log_file = fullfile(out_dir, 'matlab_console.log');
diary(log_file);
diary_cleanup = onCleanup(@() diary('off')); %#ok<NASGU>

fprintf('\n=== ToyModelSOEMC training run with exports ===\n');
fprintf('Output folder: %s\n', out_dir);

run_ok = true;
try
    ToyModelSOEMC_run_training_2x2x2;
catch ME
    run_ok = false;
    fprintf('\nRun failed: %s\n', ME.message);
    fprintf('%s\n', getReport(ME, 'extended', 'hyperlinks', 'off'));
end

% Export every open figure after the run completes.
figs = findall(0, 'Type', 'figure');
fig_count = numel(figs);
fprintf('\nExporting %d figure(s)...\n', fig_count);

manifest = fullfile(out_dir, 'export_manifest.txt');
fid = fopen(manifest, 'w');
fprintf(fid, 'ToyModelSOEMC training export manifest\n');
fprintf(fid, 'Timestamp: %s\n', datestr(now, 31));
fprintf(fid, 'Run successful: %d\n\n', run_ok);

if fig_count > 0
    % Sort by figure number for stable output naming.
    fig_nums = zeros(fig_count, 1);
    for ii = 1:fig_count
        fig_nums(ii) = figs(ii).Number;
    end
    [~, order] = sort(fig_nums);
    figs = figs(order);

    for ii = 1:fig_count
        f = figs(ii);
        name = get(f, 'Name');
        if isempty(name)
            name = sprintf('Figure_%02d', ii);
        end

        % Keep filenames portable and readable.
        safe = regexprep(name, '[^a-zA-Z0-9_\- ]', '');
        safe = strtrim(regexprep(safe, '\s+', '_'));
        if isempty(safe)
            safe = sprintf('Figure_%02d', ii);
        end

        base = sprintf('%02d_%s', ii, safe);
        png_path = fullfile(out_dir, [base '.png']);
        pdf_path = fullfile(out_dir, [base '.pdf']);
        fig_path = fullfile(out_dir, [base '.fig']);

        try
            exportgraphics(f, png_path, 'Resolution', 200);
        catch
            saveas(f, png_path);
        end

        try
            exportgraphics(f, pdf_path, 'ContentType', 'vector');
        catch
            saveas(f, pdf_path);
        end

        try
            savefig(f, fig_path);
        catch
            % Ignore if savefig is unavailable in older MATLAB versions.
        end

        fprintf('  Exported: %s\n', base);
        fprintf(fid, '%02d | %s\n', ii, name);
        fprintf(fid, '    PNG: %s\n', png_path);
        fprintf(fid, '    PDF: %s\n', pdf_path);
        fprintf(fid, '    FIG: %s\n\n', fig_path);
    end
else
    fprintf(fid, 'No figures were open at export time.\n');
end

fclose(fid);

% Save workspace snapshot for reproducibility/debugging.
try
    save(fullfile(out_dir, 'workspace_snapshot.mat'));
catch
    fprintf('Warning: Could not save workspace snapshot.\n');
end

if run_ok
    fprintf('\nRun complete. Artifacts saved to: %s\n', out_dir);
else
    fprintf('\nRun ended with errors. Partial artifacts saved to: %s\n', out_dir);
end
