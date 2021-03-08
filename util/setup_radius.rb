if $0 == __FILE__
  ['mac', 'user'].each do |name|
    Radius::Radgroupreply.find_or_initialize_by(
      groupname: name,
      attr: 'Tunnel-Type',
    ).tap do |radgroupreply|
      radgroupreply.op = ':='
      radgroupreply.value = '13'
      radgroupreply.save!
      Rails.logger.info("create or update: Tunnel-Type for #{name} group")
    end

    Radius::Radgroupreply.find_or_initialize_by(
      groupname: name,
      attr: 'Tunnel-Medium-Type',
    ).tap do |radgroupreply|
      radgroupreply.op = ':='
      radgroupreply.value = '6'
      radgroupreply.save!
      Rails.logger.info(
        "create or update: Tunnel-Medium-Type for #{name} group")
    end
  end
end
