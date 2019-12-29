%%
if ~exist('d','var')
    d = load('ern_vals.mat');
end

%% Run every 60-year scenario
success = false(1051,1);
ending_balance = ones(1051,1);
withdrawal_rate = 0.027/12;
step = 0.004;
active_check = true;
starting_equity_alloc = 0.65;

for i_start = 1:(length(d.spx_tr)-720)
  all_time_high = max(d.spx_tr(1:i_start));
  
  inflation_values = d.cpi(i_start:i_start+720);
  inflation_values = inflation_values + 4.*d.cpi(i_start).*(1:721)'.*.01./12;
  
  [success(i_start), ending_balance(i_start)] = rising_equity_glidepath(withdrawal_rate, d.spx_tr(i_start:i_start+720), d.bm_10y(i_start:i_start+720), inflation_values, step, active_check, starting_equity_alloc, all_time_high);
end

    