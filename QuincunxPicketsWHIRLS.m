% make a drifter deployment pattern for WHIRLS
% that is comparable to QUICCHE and hopefully a bit better.
% It maintains high-density of pairs across the submesoscale
% It maintains simplicity of operational navigation and deployment
% It extends measurements in the eddies to capture leaking/trapping
% It extends the spatial footprint to be less sensitive to exact center of
% dipole.
% Use target_lat and lon as the center of the dipole
% Use rotation_deg to align the core array rows with the wind or swell for
% a safe ride.
% If you modify the script, please send me a copy
% gnovelli@miami.edu June 11, 2026
%% --- MASTER PARAMETERS ---
target_lat = -37.; % The center of the dipole
target_lon = 15.0;
rotation_deg = -20;


L_y = 5; % Vertical spacing (2 gaps = 20km total height)
L_x = 5;  % Horizontal spacing
X_dist = 11; % Distance of pickets from center
% L_y = 6; % Vertical spacing (2 gaps = 20km total height)
% L_x = 4;  % Horizontal spacing
% X_dist = 14; %
% Drifter Types
triplet_x = [0, 0.1, 0.5]; 
bridge_x  = [-0.5, 0.5]; % 1km pair
quad_y    = [0, 0.1, 0.5, 1.0]; % For pickets

local_x = []; local_y = [];

% % 1. WEST PICKET (South to North)
% % 4 nodes along the western flank
% for y_picket = linspace(-L_y, L_y, 4)
%     for dx = quad_x
%         local_x(end+1) = -X_dist + dx;
%         local_y(end+1) = y_picket;
%     end
% end
% 1. WEST PICKET (South to North)
% 4 picket nodes spaced vertically across the domain footprint
y_picket_nodes = linspace(-L_y, L_y, 4);
for y_node = y_picket_nodes
    for dy = quad_y
        local_x(end+1) = -X_dist;
        local_y(end+1) = y_node + dy; % Quadruplet is aligned vertically along the line
    end
end

% 2. INNER CORE: 3-ROW RADIATOR (North to South order for the S-walk)
% Row 2 (North Row) -> Row 1 (Center) -> Row 0 (South Row)
for row = [2, 1, 0]
    y_km = (row - 1) * L_y;
    
    if mod(row, 2) == 0 % Rows 2 and 0 (Even)
        % 4 Nodes per row
        for col = 0:3
            x_node = (col - 1.5) * L_x;
            for dx = triplet_x
                local_x(end+1) = x_node + dx;
                local_y(end+1) = y_km;
            end
            if col < 3 % Add 3 bridge pairs
                for bx = bridge_x
                    local_x(end+1) = x_node + (L_x/2) + bx;
                    local_y(end+1) = y_km;
                end
            end
        end
    else % Row 1 (Middle) - Staggered
        % 5 Nodes per row
        for col = -2:2
            x_node = col * L_x;
            for dx = triplet_x
                local_x(end+1) = x_node + dx;
                local_y(end+1) = y_km;
            end
            if col < 2 % Add 4 bridge pairs
                for bx = bridge_x
                    local_x(end+1) = x_node + (L_x/2) + bx;
                    local_y(end+1) = y_km;
                end
            end
        end
    end
% --- TRANSIT PAIRS INJECTION ---
    % Add 2 pairs of drifters strictly along the diagonal transit line
    if row > 0 % Since we loop [2, 1, 0], we only transit after rows 2 and 1
        % 1. Find the current row's ending X coordinate
        if mod(row, 2) == 0 % Rows 2 and 0 end at col 3
            end_x = (3 - 1.5) * L_x;
        else                % Row 1 ends at col 2
            end_x = 2 * L_x;
        end
        
        % 2. Find the next row's starting X coordinate
        next_row = row - 1;
        if mod(next_row, 2) == 0 % Even rows start at col 0
            start_x_next = (0 - 1.5) * L_x;
        else                     % Odd rows start at col -2
            start_x_next = -2 * L_x;
        end
        
        % 3. Y coordinates for the transit
        end_y = y_km;
        start_y_next = (next_row - 1) * L_y;
        
        % 4. Calculate the unit vector of the diagonal path
        dx_transit = start_x_next - end_x;
        dy_transit = start_y_next - end_y;
        transit_length = sqrt(dx_transit^2 + dy_transit^2);
        
        % Unit vector components (direction of the ship)
        ux = dx_transit / transit_length; 
        uy = dy_transit / transit_length;
        
        % 5. Drop pairs at 1/3 and 2/3 of the way along the transit
        for fraction = [1/3, 2/3]
            % Base center point for the pair
            transit_x = end_x + fraction * dx_transit;
            transit_y = end_y + fraction * dy_transit;
            
            % Add a pair using bridge_x offsets ALONG the ship's path
            for bx = bridge_x
                local_x(end+1) = transit_x + (bx * ux);
                local_y(end+1) = transit_y + (bx * uy);
            end
        end
    end
end

% % 3. EAST PICKET (South to North)
% for y_picket = linspace(-L_y, L_y, 4)
%     for dx = quad_x
%         local_x(end+1) = X_dist + dx;
%         local_y(end+1) = y_picket;
%     end
% end
% 3. EAST PICKET (South to North)
% Mirror of the West picket on the eastern boundary
for y_node = y_picket_nodes
    for dy = quad_y
        local_x(end+1) = X_dist;
        local_y(end+1) = y_node + dy; % Quadruplet is aligned vertically along the line
    end
end
% 4. ROTATION & COORDINATES
% If you want to align the "rows" with a specific heading
theta = deg2rad(rotation_deg);
R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
rotated_coords = R * [local_x; local_y];

%  TRANSLATE TO TARGET LAT/LON
% Convert km to degrees and add to target
core_lats2 = target_lat + km2deg(rotated_coords(2,:), "earth");
core_lons2 = target_lon + km2deg(rotated_coords(1,:), "earth");

% initial pair distance distribution
distPlan2=pdist(rotated_coords');
fprintf('Total drifters deployed: %d\n', length(local_x));

%% plots
figure()
subplot(2,1,1)
% hold on
% plot([A.lon flip(B.lon) C.lon flip(DD.lon)],[A.lat flip(B.lat) C.lat flip(DD.lat)],'-or')
% plot([AAA.lon flip(BBB.lon) CCC.lon flip(DDD.lon)],[AAA.lat flip(BBB.lat) CCC.lat flip(DDD.lat)],'-or')
% % 
% % plot([wA.lon flip(wB.lon) wC.lon flip(wDD.lon)],[wA.lat flip(wB.lat) wC.lat flip(wDD.lat)],'-ob')
% % plot([w2A.lon flip(w2B.lon) w2C.lon flip(w2DD.lon)],[w2A.lat flip(w2B.lat) w2C.lat flip(w2DD.lat)],'-og')
hold on
% plot([A.lon flip(B.lon) C.lon flip(DD.lon)],[A.lat flip(B.lat) C.lat flip(DD.lat)],'-or')
% plot([AAA.lon flip(BBB.lon) CCC.lon flip(DDD.lon)],[AAA.lat flip(BBB.lat) CCC.lat flip(DDD.lat)],'-or')
% 
% plot([wA.lon flip(wB.lon) wC.lon flip(wDD.lon)],[wA.lat flip(wB.lat) wC.lat flip(wDD.lat)],'-ob')
% plot([w2A.lon flip(w2B.lon) w2C.lon flip(w2DD.lon)],[w2A.lat flip(w2B.lat) w2C.lat flip(w2DD.lat)],'-og')

% plot(core_lons,core_lats,'-ok')
plot(core_lons2,core_lats2,'-ob')
% plot(ring_lons,ring_lats,'-ok')
%
subplot(2,1,2)
hold on
% histogram(distPlan./1000.,'binwidth',0.5,'FaceColor','r','DisplayName','quicche')
histogram(distPlan2,'binwidth',0.5,'FaceColor','b','DisplayName',['WHIRLS dipole LX-LY ',num2str(L_x),'km Xd',num2str(X_dist),'km'])

% histogram(qdistPlan./1000,'BinWidth',0.5,'EdgeColor','k','FaceColor',[0.5 0.5 0.5])
xlabel('separation bins [km]')
ylabel('number of pairs')
% title(['Initial pair separation (',num2str(length(D)),' drifters, ',num2str(length(distPlan)),' pairs)'])
box on
grid on
grid minor
legend()%,'quincunx 4lines')%;'real deployment'),'WHIRLS plan 2','WHIRLS plan'
set(gca,'fontsize',24)

%%
% --- CREATE DEPLOYMENT LOG FOR THE CAPTAIN (DD & DDM FORMATS) ---
core_lats = core_lats2; core_lons = core_lons2;
% 1. Create sequential list of waypoint IDs
waypoint_ids = (1:length(core_lats))';

% 2. Calculate Degrees and Decimal Minutes (DDM) Vectorially
lat_deg = fix(core_lats');
lat_min = abs(core_lats' - lat_deg) * 60;

lon_deg = fix(core_lons');
lon_min = abs(core_lons' - lon_deg) * 60;

% 3. Use 'compose' for clean, lightning-fast vectorized string creation
lat_ddm = compose('%d° %.4f''', lat_deg, lat_min);
lon_ddm = compose('%d° %.4f''', lon_deg, lon_min);

% 4. Assemble into a 4-column table with clear, unmistakable headers
deployment_table = table(waypoint_ids, core_lats', core_lons', lat_ddm, lon_ddm, ...
    'VariableNames', {'Waypoint_ID', 'Lat_DecimalDegrees', 'Lon_DecimalDegrees', 'Lat_Deg_DecMinutes', 'Lon_Deg_DecMinutes'});

% 5. Define the output file name
filename = sprintf('WHIRLS_Deployment_Plan_Target_%.1f_%.1f.txt', target_lat, target_lon);

% 6. Write the table to a comma-separated text file
writetable(deployment_table, filename, 'Delimiter', ',');

% Print confirmation message
fprintf('Success! Saved 4-column bridge log for the captain: %s\n', filename);

% --- CALCULATE THE SHIP'S TOTAL PATH LENGTH ---

% 1. Extract x and y coordinates of the sequential track (in km)
track_x = rotated_coords(1, :);
track_y = rotated_coords(2, :);

% 2. Compute the distance between consecutive deployment points
% This calculates sqrt((x2-x1)^2 + (y2-y1)^2) for all points
segment_distances = sqrt(diff(track_x).^2 + diff(track_y).^2);

% 3. Sum segments to get total deployment distance in kilometers
total_dist_km = sum(segment_distances);

% 4. Convert kilometers to Nautical Miles (1 NM = 1.852 km)
total_dist_nm = total_dist_km / 1.852;

% 5. Estimate duration assuming a standard survey speed (e.g., 10 knots)
ship_speed_knots = 10; 
estimated_hours = total_dist_nm / ship_speed_knots;

% Print the navigation summary to the Command Window
fprintf('\n================ BRIDGE NAVIGATION SUMMARY ================\n');
fprintf('Total Steam Distance:  %.2f km (%.1f Nautical Miles)\n', total_dist_km, total_dist_nm);
fprintf('Estimated Duration:    %.1f hours (at %d knots survey speed)\n', estimated_hours, ship_speed_knots);
fprintf('===========================================================\n\n');
%%
%% --- TRIAD SCALE GROUPING TOOL ---
fprintf('\n--- Processing Triad Scale Analysis ---\n');

% 1. Generate ALL possible combinations of 3 drifters
N_drifters = length(local_x);
all_triplets = nchoosek(1:N_drifters, 3); 

% 2. Extract rotated kilometer coordinates for all vertices
% Rows of tri_coords correspond to [x1, y1, x2, y2, x3, y3] for each triangle
x1 = rotated_coords(1, all_triplets(:,1))';
y1 = rotated_coords(2, all_triplets(:,1))';
x2 = rotated_coords(1, all_triplets(:,2))';
y2 = rotated_coords(2, all_triplets(:,2))';
x3 = rotated_coords(1, all_triplets(:,3))';
y3 = rotated_coords(2, all_triplets(:,3))';

% 3. Calculate side lengths
side_a = sqrt((x2 - x1).^2 + (y2 - y1).^2);
side_b = sqrt((x3 - x2).^2 + (y3 - y2).^2);
side_c = sqrt((x1 - x3).^2 + (y1 - y3).^2);

% 4. Compute Area (via fast coordinate cross-product method)
tri_areas = 0.5 * abs(x1.*(y2 - y3) + x2.*(y3 - y1) + x3.*(y1 - y2));

% 5. Define Representative Scale: L = sqrt(Area)
L_area = sqrt(tri_areas);

% 6. Calculate Aspect Ratio: (Longest Side)^2 / (2 * Area)
longest_side = max([side_a, side_b, side_c], [], 2);
aspect_ratios = (longest_side.^2) ./ (2 * tri_areas);

% 7. Apply Geometric Filters
% Drop collinear points (Area approx 0) and any triad with an aspect ratio > 5
ar_threshold = 5;
valid_triangles = (aspect_ratios <= ar_threshold) & (tri_areas > 1e-4);

% Filter our master matrices down to only the physically useful triads
final_triplets = all_triplets(valid_triangles, :);
final_L       = L_area(valid_triangles);
final_AR      = aspect_ratios(valid_triangles);

% 8. Categorize Triangles into Representative Scale Bins (in km)
scale_edges = [0, 0.5, 1.0, 2.0, 5.0, 10.0, 15.0, 20.0, Inf];
num_bins = length(scale_edges) - 1;
[bin_assignments, ~] = discretize(final_L, scale_edges);

% 9. Build and Display an organized Summary Table
fprintf('Total potential triplets evaluated: %d\n', length(all_triplets));
fprintf('Valid triplets remaining after aspect ratio filter (AR <= %d): %d\n\n', ar_threshold, length(final_triplets));

fprintf('%-20s %-20s\n', 'Scale Bin (sqrt(Area))', 'Number of Valid Triads');
fprintf('%s\n', repmat('-', 1, 45));

% Store the grouped indices into a convenient structured cell array
triads_by_scale = cell(num_bins, 1);

for b = 1:num_bins
    idx_in_bin = (bin_assignments == b);
    triads_by_scale{b} = final_triplets(idx_in_bin, :);
    
    % Format bin label string
    if isinf(scale_edges(b+1))
        bin_label = sprintf('> %.1f km', scale_edges(b));
    else
        bin_label = sprintf('%.1f to %.1f km', scale_edges(b), scale_edges(b+1));
    end
    fprintf('%-20s %-20d\n', bin_label, sum(idx_in_bin));
end
fprintf('%s\n', repmat('-', 1, 45));

% example use:
% Extract the list of drifter ID triplets belonging to the 2.0 to 5.0 km scale (Bin 4)
target_triads = triads_by_scale{4};