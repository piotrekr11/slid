function plotSkyPlot(AZ_cell, EL_cell, SVID_cell, times, labels, colors, elevMask, t_query)

    %% --- Resolve epoch index ---
    if ischar(t_query) || isstring(t_query)
        t_query = datetime(t_query, 'InputFormat', 'dd.MM.yyyy HH:mm');
    end
    [~, t_idx] = min(abs(times - t_query));
    t_ep = times(t_idx);
    fprintf('plotSkyPlot: epoch %d/%d  ->  %s\n', t_idx, numel(times), datestr(t_ep));

    %% --- Figure and axes ---
    figure('Name', 'GNSS Sky Plot', 'Color', 'w', 'Position', [100 100 620 680]);
    axes; hold on; axis equal off;
    title(sprintf('Sky plot - %s   (elevation mask: %d°)', ...
          datestr(t_ep, 'yyyy-mm-dd HH:MM:SS'), elevMask), 'FontSize', 11);

    %% --- Background grid ---
    th = linspace(0, 2*pi, 361);

    % Elevation rings at 0°, 30°, 60°
    for el_ring = [0 30 60]
        r = 1 - el_ring / 90;
        plot(r*sin(th), r*cos(th), 'Color', [0.75 0.75 0.75], 'LineWidth', 0.5, ...
             'HandleVisibility', 'off');
        text(0.03, r + 0.03, sprintf('%d°', el_ring), ...
             'FontSize', 7, 'Color', [0.55 0.55 0.55], 'HandleVisibility', 'off');
    end

    % Azimuth spokes every 45°
    for az_spoke = 0:45:315
        plot([0 sind(az_spoke)], [0 cosd(az_spoke)], ...
             'Color', [0.88 0.88 0.88], 'LineWidth', 0.4, 'HandleVisibility', 'off');
    end

    % Elevation mask ring
    r_mask = 1 - elevMask / 90;
    plot(r_mask*sin(th), r_mask*cos(th), '--', ...
         'Color', [0.85 0.65 0.1], 'LineWidth', 1.4, ...
         'DisplayName', sprintf('%d° mask', elevMask));

    % Cardinal labels
    cardinals = {'N', 'E', 'S', 'W'};
    card_az   = [0, 90, 180, 270];
    for i = 1:4
        text(1.12 * sind(card_az(i)), 1.12 * cosd(card_az(i)), cardinals{i}, ...
             'HorizontalAlignment', 'center', 'FontSize', 9, ...
             'FontWeight', 'bold', 'Color', [0.2 0.2 0.2], ...
             'HandleVisibility', 'off');
    end

    % Zenith marker
    plot(0, 0, 'k+', 'MarkerSize', 9, 'LineWidth', 1.8, 'HandleVisibility', 'off');

    %% --- Plot satellites ---
    for c = 1:numel(AZ_cell)
        az_vec  = AZ_cell{c}{t_idx};
        el_vec  = EL_cell{c}{t_idx};
        sv_vec  = SVID_cell{c}{t_idx};
        clr     = colors{c};

        if isempty(az_vec)
            % Still add a legend entry even if no sats this epoch
            plot(nan, nan, 'o', 'Color', clr, 'MarkerSize', 8, ...
                 'MarkerFaceColor', clr, 'MarkerEdgeColor', 'w', ...
                 'LineWidth', 0.8, 'DisplayName', labels{c});
            continue;
        end

        legend_added = false;

        for s = 1:numel(az_vec)
            az_s = az_vec(s);
            el_s = el_vec(s);
            r    = 1 - el_s / 90;
            xp   =  r * sind(az_s);
            yp   =  r * cosd(az_s);

            if el_s >= elevMask
                % Above mask — filled marker
                if ~legend_added
                    plot(xp, yp, 'o', 'Color', clr, 'MarkerSize', 9, ...
                         'MarkerFaceColor', clr, 'MarkerEdgeColor', 'w', ...
                         'LineWidth', 0.8, 'DisplayName', labels{c});
                    legend_added = true;
                else
                    plot(xp, yp, 'o', 'Color', clr, 'MarkerSize', 9, ...
                         'MarkerFaceColor', clr, 'MarkerEdgeColor', 'w', ...
                         'LineWidth', 0.8, 'HandleVisibility', 'off');
                end
                text(xp + 0.05, yp + 0.03, sprintf('%d', sv_vec(s)), ...
                     'FontSize', 7, 'Color', clr, 'FontWeight', 'bold', ...
                     'HandleVisibility', 'off');
            else

            end
        end

        % Legend entry if all sats were below mask
        if ~legend_added
            plot(nan, nan, 'o', 'Color', clr, 'MarkerSize', 9, ...
                 'MarkerFaceColor', clr, 'MarkerEdgeColor', 'w', ...
                 'LineWidth', 0.8, 'DisplayName', labels{c});
        end
    end

    %% --- Legend and axes limits ---
    legend('Location', 'southoutside', 'Orientation', 'horizontal', ...
           'FontSize', 8, 'Box', 'off');
    xlim([-1.3 1.3]);
    ylim([-1.3 1.3]);
end