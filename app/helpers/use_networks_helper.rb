module UseNetworksHelper
  def use_network_switch(assignment, name)
    user_id = assignment.user_id
    network_id = assignment.network_id
    flag = assignment[name]
    label = "user_use_network_#{name}_#{network_id}"
    if current_user.admin?
      params = {assignment: {name => !flag}}
      button_to(user_use_network_path(user_id, network_id, params:),
        method: :patch, class: "btn btn-link") do
        use_nework_switch_check_box(label, flag, title: "クリックして変更",
          disabled: true,
          data: {bs_toggle: "tooltip", bs_placement: "left"})
      end
    else
      use_nework_switch_check_box(label, flag, disabled: true)
    end
  end

  def use_nework_switch_check_box(label, flag, disabled: false, **opts)
    tag.div(class: "form-check form-switch", **opts) do
      check_box_tag(label, "1", flag, class: "form-check-input", disabled:) +
        label_tag(label, "", class: "form-check-label")
    end
  end
end
