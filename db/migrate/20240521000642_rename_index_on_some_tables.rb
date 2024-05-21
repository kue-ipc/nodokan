class RenameIndexOnSomeTables < ActiveRecord::Migration[7.1]
  def change
    # index名は64文字までであるため、収まらない場合のみカスタムする。
    # カスタムする場合も、「index_テーブル名_on_カラム名」の規則に併せる
    rename_index :hardwares, :hardware_model, :index_hardwares_on_hardware_model
    rename_index :nics, :node_number, :index_nics_on_node_id_and_number
    rename_index :nodes, :fqdn, name: :index_nodes_on_hostname_and_domain
    rename_index :security_softwares, :security_softoware_name,
      :index_security_softwares_on_security_softoware_name
  end
end
