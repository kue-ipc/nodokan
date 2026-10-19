# デバイスタイプ

使用していないデバイスタイプも多いため、統一すべき。

tool/merge_device_type.rb

merge_listとrename_listを整理

dataにおく

bin/rails runner data/merge_device_type.rb

使用していないハードウェアの削除

Hardware.where(nodes_count: 0, confirmed: false).count
Hardware.where(nodes_count: 0, confirmed: false).destroy_all

DeviceType.all.find_each do |device_type|
  puts [
    device_type.name,
    device_type.order,
    device_type.hardwares.count,
    device_type.hardwares.sum(&:nodes_count),
  ].join(",")
end

Hardware.where(confirmed: true).count
