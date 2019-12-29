function [success, ending_balance] = rising_equity_glidepath(withdrawal_rate, equity_values, bond_values, inflation_values, step, active_check, starting_equity_alloc, all_time_high)
  
if ~exist('starting_equity_alloc','var')
  starting_equity_alloc = 0.6;
end
if ~exist('active_check','var')
  active_check = true;
end
if ~exist('step','var')
  step = .004;
end
if ~exist('all_time_high','var')
  all_time_high = equity_values(1);
end

ending_balance = inflation_values(1);  
success = true;
equity_alloc = starting_equity_alloc;

for i = 1:length(equity_values)-1
  ending_balance = ending_balance - withdrawal_rate.*inflation_values(i+1);
  if ending_balance<0
    success = false;
  end
  
  equity_return = (equity_values(i+1)./equity_values(i));
  bond_return = (bond_values(i+1)./bond_values(i));
  # inflation_return = (inflation_values(i)./inflation_values(i+1));
  
  #monthly_return = (equity_return*equity_alloc + bond_return*(1-equity_alloc))*inflation_return;
  monthly_return = equity_return*equity_alloc + bond_return*(1-equity_alloc);
  ending_balance = ending_balance*monthly_return;
  
  if active_check && equity_values(i+1)<all_time_high
    all_time_high = equity_values(i+1);
    equity_alloc = equity_alloc + step;
  else
    equity_alloc = equity_alloc + step;
  end
  
  equity_alloc = min(1,equity_alloc);
  
end

ending_balance = ending_balance./inflation_values(end);