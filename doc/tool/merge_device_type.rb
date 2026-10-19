# froze_string_literal: true

# 名称変更してからマージするため、順番に注意

rename_list = [
  # ["旧名称", "新名称"]
]

merge_list = [
  # ["マージ元", "マージ先"],
]

rename_list.each do |old_name, new_name|
  device_type = DeviceType.find_by(name: old_name)
  if device_type.nil?
    puts "skipping #{old_name} => #{new_name}: old type not found"
  else
    puts "renaming #{old_name} => #{new_name}"
  end

  device_type.update!(name: new_name)
end

merge_list.each do |old_name, new_name|
  old_type = DeviceType.find_by(name: old_name)
  if old_type.nil?
    puts "skipping #{old_name} => #{new_name}: old type not found"
  else
    puts "merging #{old_name} => #{new_name}"
  end

  new_type = DeviceType.find_by!(name: new_name)
  DeviceType.find_by(name: old_name).hardwares.find_each do |hardware|
    hardware.assign_attributes(device_type_id: new_type.id)
    same_hardware = hardware.same
    if same_hardware
      hardware.nodes.find_each do |node|
        same_hardware.nodes << node
      end
      Hardware.find(hardware.id).destroy!
    else
      hardware.save!
    end
  end
  old_type.destroy!
end
