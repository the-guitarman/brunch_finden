#runs sphinx indexer only if no other instance is running


indexer_run=`ps aux|grep " indexer "|grep -v grep|wc -l`.to_i
if indexer_run==0
  print `cd #{ENV["RAILS_PATH"]}; rake ts:in`
else
  p "indexer is running!"
end